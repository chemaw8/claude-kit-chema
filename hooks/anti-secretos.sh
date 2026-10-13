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
patron='(api[_-]?key|secret|token|passw(or)?d)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9_/+.-]{12,}|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
# ¿Qué repo y qué incluye el commit? El hook corre ANTES del comando: lo que `-a`/`--all` (también en
# grupos como `-am`) o un `git add` del mismo comando vayan a meter todavía no está en el índice, y con
# `git -C <ruta>` el repo no es el directorio actual. Si python3 falla: escanear de más, en el actual.
analisis=$(printf '%s' "$cmd" | python3 -c '
import re, shlex, sys
c = sys.stdin.read()
try: toks = shlex.split(c, posix=True)
except ValueError: toks = c.split()
SEP = {";", "&&", "||", "|", "&"}
amplio, repo = 0, "."
i = 0
while i < len(toks):
    if toks[i] != "git": i += 1; continue
    i += 1; ruta = "."
    while i < len(toks) and toks[i].startswith("-"):           # opciones globales: git -C <ruta> -c x=y …
        if toks[i] == "-C" and i + 1 < len(toks): ruta = toks[i+1]; i += 2; continue
        if toks[i] in ("-c", "--git-dir", "--work-tree", "--namespace") and i + 1 < len(toks): i += 2; continue
        i += 1
    if i >= len(toks): break
    sub = toks[i]; i += 1
    if sub == "add": amplio = 1; repo = ruta; continue
    if sub != "commit": continue
    repo = ruta; salta = False
    while i < len(toks) and toks[i] not in SEP:
        x = toks[i]; i += 1
        if salta: salta = False; continue
        if x == "--all": amplio = 1; continue
        if x in ("--message", "--file", "--author", "--date", "--template", "--reuse-message", "--reedit-message"): salta = True; continue
        if re.fullmatch(r"-[A-Za-z]+", x):
            for j, ch in enumerate(x[1:]):
                if ch == "a": amplio = 1
                if ch in "mFCct": salta = (j == len(x) - 2); break
print(f"{amplio}\t{repo}")' 2>/dev/null || printf '1\t.')
amplio=${analisis%%$'\t'*}; repo=${analisis#*$'\t'}
[ -n "$repo" ] && cd -- "$repo" 2>/dev/null || true
# Se escanea a archivo y sin `grep -q`: con pipefail, un grep que cierra temprano deja al productor en
# SIGPIPE (141) y el `if` sale falso justo con los diffs grandes. `-a`: un byte raro no vuelve binario
# todo el temporal; los archivos nuevos binarios ni se copian (grep -I los descarta).
diff=$(mktemp); trap 'rm -f "$diff"' EXIT
git diff --cached 2>/dev/null > "$diff"
if [ "$amplio" != 0 ]; then
  git diff 2>/dev/null >> "$diff"
  git ls-files -z --others --exclude-standard 2>/dev/null | while IFS= read -r -d '' nuevo; do
    [ -f "$nuevo" ] && grep -Iq . -- "$nuevo" 2>/dev/null && head -c 2000000 -- "$nuevo" | sed 's/^/+/' >> "$diff"
  done
fi
if grep -aE '^\+' -- "$diff" | grep -aiE "$patron" >/dev/null; then
  echo "Kit Chema: el diff del commit parece contener credenciales (clave API, token o llave privada). Revísalo y quítalas antes de commitear; si es un falso positivo, dilo y commitea con el hook desactivado." >&2
  exit 2
fi
exit 0
