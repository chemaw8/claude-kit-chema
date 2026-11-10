#!/usr/bin/env bash
# Hook PreToolUse (Bash) del Kit Chema: bloquea git commit si el diff
# staged contiene patrones de credenciales. Exit 2 = bloquear (stderr al modelo).
set -uo pipefail
input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || echo "")
# Si python3 falla o no está disponible, usar el JSON crudo como comando: esto cierra el fallo-abierto (mejor un falso positivo que dejar de escanear).
if [ -z "$cmd" ] && [ -n "$input" ]; then
  cmd="$input"
fi
# Filtro barato y amplio (`git -C ruta commit`, `git -c x=y commit`): el análisis fino va abajo.
case "$cmd" in
  *git*commit*) ;;
  *) exit 0 ;;
esac
# Dos patrones: las palabras clave (`Password=`, `API_KEY:`) se buscan sin distinguir mayúsculas; los formatos de llave
# (AKIA…, sk-…, ghp_…, BEGIN … PRIVATE KEY) tienen mayúsculas fijas y se buscan tal cual. Con `-i` sobre todo, cualquier
# base64 grande (imágenes o fuentes incrustadas en un HTML) traía «aKia» + 16 alfanuméricos y bloqueaba sin razón.
patron_i='(api[_-]?key|secret|token|passw(or)?d)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9_/+.-]{12,}'
patron='AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
# ¿Qué repo y qué incluye el commit? El hook corre ANTES del comando: lo que `-a`/`--all` (también en
# grupos como `-am`) o un `git add` del mismo comando vayan a meter todavía no está en el índice, y con
# `git -C <ruta>` el repo no es el directorio actual. Si python3 falla: escanear de más, en el actual.
analisis=$(printf '%s' "$cmd" | python3 -c '
import os, re, shlex, sys
c = sys.stdin.read()
try:   # punctuation_chars separa `;`, `&&`, `|`, `(` y `)` aunque vengan pegados (`cd r;`, `(cd x`)
    lx = shlex.shlex(c, posix=True, punctuation_chars=True); lx.whitespace_split = True; toks = list(lx)
except ValueError: toks = c.split()
SEP = {";", "&&", "||", "|", "&", "(", ")", ";;", "|&"}
amplio, repo, dir_cd, pila, hay_commit = 0, ".", ".", [], False
# Una vez que el repo es incierto (GIT_DIR=, --git-dir, --work-tree, cd -, cd $(…)), un -C o cd absoluto posterior no
# lo aclara: git sigue escribiendo donde diga GIT_DIR. Se queda incierto y el hook bloquea.
opaco = any(re.match(r"GIT_(DIR|WORK_TREE)=", t) or t.startswith(("--git-dir", "--work-tree")) for t in toks)
i = 0
while i < len(toks):
    if toks[i] == "(": pila.append(dir_cd); i += 1; continue   # el cd de una subshell no sale de ella
    if toks[i] == ")": dir_cd = pila.pop() if pila else dir_cd; i += 1; continue
    if toks[i] in ("cd", "pushd"):                              # `cd X && git commit`: el repo es X
        sig = toks[i+1] if i + 1 < len(toks) else None
        if sig is None or sig in SEP: dir_cd = os.path.expanduser("~"); i += 1; continue   # `cd` solo: HOME
        if sig == "-" or "$(" in sig or "`" in sig: dir_cd = "?"; i += 2; continue        # `cd -`, `cd $(…)`: no se sabe a dónde
        dir_cd = os.path.join(dir_cd, os.path.expandvars(os.path.expanduser(sig))); i += 2; continue
    if re.match(r"GIT_(DIR|WORK_TREE)=", toks[i]): dir_cd = "?"; i += 1; continue   # repo por variable: no se sabe cuál
    if toks[i] != "git": i += 1; continue
    i += 1; ruta = dir_cd
    while i < len(toks) and toks[i].startswith("-"):           # opciones globales: git -C <ruta> -c x=y …
        if toks[i] == "-C" and i + 1 < len(toks):
            v = toks[i+1]
            if v in ("$", "`") or v.startswith(("$(", "`")):     # `-C $(…)` sin comillas: incierto, y se salta entera
                opaco = True; i += 2
                if v == "$" and i < len(toks) and toks[i] == "(":
                    hondo = 0
                    while i < len(toks):
                        hondo += (toks[i] == "(") - (toks[i] == ")"); i += 1
                        if hondo == 0: break
                elif v == "`":
                    while i < len(toks) and toks[i] != "`": i += 1
                    i += 1
                continue
            ruta = os.path.join(ruta, os.path.expandvars(os.path.expanduser(v))); i += 2; continue
        if toks[i].startswith(("--git-dir", "--work-tree")):                                 # sin traducir a un repo: se bloquea
            ruta = "?"; i += 1 if "=" in toks[i] else 2; continue
        if toks[i] in ("-c", "--namespace") and i + 1 < len(toks): i += 2; continue
        i += 1
    if i >= len(toks): break
    sub = toks[i]; i += 1
    if sub == "add": amplio = 1; repo = ruta; continue
    if sub != "commit": continue
    hay_commit = True; repo = ruta; salta = False
    while i < len(toks) and toks[i] not in SEP:
        x = toks[i]; i += 1
        if salta: salta = False; continue
        if x == "--all": amplio = 1; continue
        if not x.startswith("-") or x == "--": amplio = 1; continue   # rutas: se toman del árbol de trabajo, no del índice
        if x in ("--message", "--file", "--author", "--date", "--template", "--reuse-message", "--reedit-message"): salta = True; continue
        if re.fullmatch(r"-[A-Za-z]+", x):
            for j, ch in enumerate(x[1:]):
                if ch == "a": amplio = 1
                if ch in "mFCct": salta = (j == len(x) - 2); break
if opaco and hay_commit: repo = "?"     # sin git commit no hay nada que bloquear
print(f"{amplio}\t{repo}")' 2>/dev/null || printf '1\t.')
amplio=${analisis%%$'\t'*}; repo=${analisis#*$'\t'}
if [ "$repo" = "?" ]; then
  echo "Kit Chema: no puedo saber qué repo revisar en busca de secretos (--git-dir, --work-tree, GIT_DIR=, cd - o cd \$(…)). Haz el commit desde el repo, con cd a una ruta o git -C." >&2
  exit 2
fi
if [ -n "$repo" ] && ! cd -- "$repo" 2>/dev/null; then
  # Sin ubicar el repo de `git -C` no se puede escanear: bloquear antes que revisar otro repo y dejarlo pasar.
  echo "Kit Chema: no pude ubicar el repo $repo (de cd o git -C) para revisar secretos. Corre el commit desde ese repo o con la ruta ya expandida." >&2
  exit 2
fi
top=$(git rev-parse --show-toplevel 2>/dev/null) && cd -- "$top"   # ls-files --others solo ve el directorio actual hacia abajo
# Se escanea a archivo y sin `grep -q`: con pipefail, un grep que cierra temprano deja al productor en
# SIGPIPE (141) y el `if` sale falso justo con los diffs grandes. `-a`: un byte raro no vuelve binario
# todo el temporal; los archivos nuevos binarios ni se copian (grep -I los descarta).
# Sin temporales no se puede revisar: se bloquea (falla cerrado) en vez de dejar pasar el commit sin mirar.
bloquear_es() { echo "Kit Chema: no pude revisar el commit en busca de secretos ($1); bloqueo por precaución." >&2; exit 2; }
msg_secreto="Kit Chema: el diff del commit parece contener credenciales (clave API, token o llave privada). Revísalo y quítalas antes de commitear. Si es un falso positivo, dilo y pide al usuario que lo revise y haga él ese commit en su terminal; no intentes rodear el hook."
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  # Aún no es repo. Con `git init` en el mismo comando, lo que entrará es lo que hay en la carpeta: se revisa directo
  # (por salida, no por código, por lo mismo que arriba). Sin `init`, el commit fallará solo: no hay nada que revisar.
  case "$cmd" in *git*init*) ;; *) exit 0 ;; esac
  en_carpeta=$(grep -rIliE --exclude-dir=.git "$patron_i" . 2>/dev/null; grep -rIlE --exclude-dir=.git "$patron" . 2>/dev/null)
  [ -z "$en_carpeta" ] || { echo "$msg_secreto" >&2; exit 2; }
  exit 0
fi
diff=$(mktemp) || bloquear_es "no se pudo crear un temporal"; trap 'rm -f "$diff"' EXIT
git diff --cached 2>/dev/null > "$diff" || bloquear_es "no se pudo leer el diff preparado"
if [ "$amplio" != 0 ]; then
  git diff 2>/dev/null >> "$diff" || bloquear_es "no se pudo leer el diff sin preparar"
  # Archivos nuevos: un solo grep por tanda (xargs), completos y sin copiarlos; -I salta los binarios. Se mira la
  # SALIDA, no el código: grep da 2 con un archivo ilegible o un enlace roto aunque haya hallado algo, y xargs 123
  # si alguna tanda no halló nada; con pipefail eso apagaba la detección.
  hallados=$(mktemp) || bloquear_es "no se pudo crear un temporal"; trap 'rm -f "$diff" "$hallados"' EXIT
  git ls-files -z --others --exclude-standard 2>/dev/null | xargs -0 -r grep -IliE "$patron_i" -- > "$hallados" 2>/dev/null
  git ls-files -z --others --exclude-standard 2>/dev/null | xargs -0 -r grep -IlE "$patron" -- >> "$hallados" 2>/dev/null
  [ -s "$hallados" ] && nuevo_con_secreto=1
fi
agregadas=$(mktemp) || bloquear_es "no se pudo crear un temporal"; trap 'rm -f "$diff" "${hallados:-}" "$agregadas"' EXIT
grep -aE '^\+' -- "$diff" > "$agregadas"; [ $? -le 1 ] || bloquear_es "no se pudo leer el diff"   # 1 = sin líneas nuevas
if [ "${nuevo_con_secreto:-0}" = 1 ] || grep -aiE "$patron_i" -- "$agregadas" >/dev/null || grep -aE "$patron" -- "$agregadas" >/dev/null; then
  echo "$msg_secreto" >&2
  exit 2
fi
exit 0
