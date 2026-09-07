#!/usr/bin/env bash
# sello-push — hook PreToolUse (Bash) del Kit Chema: gate de push local (OPT-IN).
# En un repo con `git config kit-chema.gate true`, un `git push` desde Claude Code solo
# pasa si el commit que se empuja tiene un SELLO de revisión sin bloqueantes pendientes
# (.git/kit-chema/sellos/<sha>, lo escribe `scripts/sello-push.sh revisar`). Si no, sale 2
# con la razón y el siguiente paso. Reglas: un comando que mueve HEAD y empuja en la misma
# línea se rechaza (el sello se compara con el commit que existe al evaluar); --all y
# --mirror también (una rama a la vez); --dry-run, --delete y un sha ya contenido en el
# remoto pasan; un tag pasa solo si su commit ya está en el remoto o tiene sello (empujar
# un tag empuja su commit). `KIT_SELLO=omitir git push …` (la variable como PREFIJO del
# propio push, no en un comentario ni en otro segmento) pasa y queda anotado. Si el comando
# invoca `sello-push.sh revisar` sobre un repo con la llave, exige run_in_background (el
# Bash de Claude Code en primer plano topa en 10 min y una revisión real tardó 11). Cada decisión se apendea al ledger JSONL (KIT_GATE_LEDGER). Falla
# abierto ante error propio: exit 0 y evento `error-hook` si puede escribirlo. En repos
# sin la llave, sale 0 sin tocar nada. Diseño: claude-entorno/specs/002-gate-de-push/.
set -uo pipefail
input=""; while IFS= read -r linea || [ -n "$linea" ]; do input+="$linea"$'\n'; done   # solo builtins: sirve aunque falte el PATH
# Prefiltro barato: sin "git…push" ni "sello-push" en el comando no arranca python (~3 ms).
case "$input" in *git*push*|*sello-push*) ;; *) exit 0 ;; esac
export KIT_GATE_LEDGER="${KIT_GATE_LEDGER:-$HOME/.claude/kit-chema/gate.jsonl}"
# Fail-open por entorno (sin python3 o sin git): pasa, pero queda anotado con builtins de bash.
error_hook() { local d="${KIT_GATE_LEDGER%/*}" ts; ts=$(printf '%(%FT%T)T' -1 2>/dev/null) || ts=$(date +%FT%T 2>/dev/null) || ts=""; [ -d "$d" ] && printf '{"ts":"%s","evento":"error-hook","motivo":"%s"}\n' "$ts" "$1" >> "$KIT_GATE_LEDGER" 2>/dev/null; exit 0; }   # bash 3.2 (macOS) no tiene %(…)T
command -v python3 >/dev/null 2>&1 || error_hook "sin-python3"
command -v git >/dev/null 2>&1 || error_hook "sin-git"
INPUT="$input" python3 - <<'PY'
import json, os, re, shlex, subprocess, sys, datetime

MUEVEN_HEAD = {"commit", "rebase", "merge", "reset", "cherry-pick", "checkout", "switch", "pull", "revert", "am"}
OPCION_CON_ARG = {"-o", "--push-option", "--repo", "--receive-pack", "--exec"}
GIT_GLOBAL_CON_ARG = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"}
ENVOLTORIOS = {"sudo", "exec", "command", "nohup", "setsid", "time", "env", "timeout", "nice", "ionice"}
OPCION_ENVOLTORIO_CON_ARG = {"-k", "-s", "--kill-after", "--signal", "-n", "-u", "-c", "-C", "-S", "--chdir"}
PREFIJO = "Kit Chema · gate de push: "

def salir(rc, msg=None):
    if msg: sys.stderr.write(msg + "\n")
    sys.exit(rc)

def ledger(**ev):
    p = os.environ.get("KIT_GATE_LEDGER") or ""
    try:
        os.makedirs(os.path.dirname(p), exist_ok=True)
        ev = {"ts": datetime.datetime.now().isoformat(timespec="seconds"), **ev}
        with open(p, "a", encoding="utf-8") as f: f.write(json.dumps(ev, ensure_ascii=False) + "\n")
    except Exception: pass

def git(repo, *args):
    """stdout (sin espacios) si git sale 0; None si falla. '' es éxito sin salida."""
    try:
        r = subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True, timeout=5)
    except Exception: return None
    return r.stdout.strip() if r.returncode == 0 else None

def quitar_heredocs(cmd):
    out, lines, i = [], cmd.split("\n"), 0
    while i < len(lines):
        l = lines[i]; out.append(l); i += 1
        m = re.search(r"<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1", l)
        if m:
            delim = m.group(2)
            while i < len(lines) and lines[i].strip() != delim: i += 1
            i += 1
    return "\n".join(out)

def segmentar(cmd, cwd):
    """Lista de (tokens, cwd_vigente) por segmento (; && || | & ( ) y saltos de línea).
    Sigue los `cd` y entra en `bash -c '…'`."""
    lex = shlex.shlex(quitar_heredocs(cmd).replace("\n", " ; "), posix=True, punctuation_chars=";&|()<>")
    lex.whitespace_split = True
    try: toks = list(lex)
    except ValueError: toks = quitar_heredocs(cmd).replace("\n", " ").split()   # comillas sin cerrar: tokens crudos
    segs, actual, i = [], [], 0
    while i < len(toks):
        t = toks[i]
        if t and all(c in ";&|()<>" for c in t):
            if "<" in t or ">" in t:                       # redirección: fuera el operador, su destino y el fd previo (2> x, >&1, > /tmp/out)
                if actual and actual[-1].isdigit(): actual.pop()
                i += 2 if (not t.endswith("&")) or (i + 1 < len(toks) and toks[i + 1].isdigit()) else 1
                continue
            if actual: segs.append(actual); actual = []
            i += 1; continue
        actual.append(t); i += 1
    if actual: segs.append(actual)
    salida, cwd_v = [], cwd
    for s in segs:
        envs = []                                     # asignaciones que preceden al comando (VAR=x cmd …)
        while s:                                      # pela asignaciones y envoltorios con sus opciones (timeout -k 5 600, nice -n 10, env -u X)
            if re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", s[0]): envs.append(s[0]); s = s[1:]; continue
            if s[0] in ENVOLTORIOS:
                w = s[0]; s = s[1:]
                while s and s[0].startswith("-"):
                    s = s[2:] if s[0] in OPCION_ENVOLTORIO_CON_ARG and len(s) > 1 else s[1:]
                if w == "timeout" and s: s = s[1:]     # la duración
                continue
            break
        if not s: continue
        if s[0] in ("cd", "pushd"):
            dest = s[1] if len(s) > 1 else "~"
            if dest != "-": cwd_v = os.path.normpath(os.path.join(cwd_v, os.path.expanduser(dest)))
            continue
        if os.path.basename(s[0]) in ("bash", "sh", "zsh", "dash", "fish"):   # bash -c / -lc / -xc '…': se analiza la cadena; `bash script.sh …` sigue como segmento
            j = next((i for i, t in enumerate(s[1:], 1) if t.startswith("-") and not t.startswith("--") and "c" in t and i + 1 < len(s)), None)
            if j is not None: salida.extend(segmentar(s[j + 1], cwd_v)); continue
        salida.append((s, cwd_v, envs))
    return salida

def parsear_git(tokens, cwd):
    """(repo, subcomando, resto) de un segmento que empieza por git; None si no es git."""
    if not tokens or os.path.basename(tokens[0]) != "git": return None   # también /usr/bin/git
    repo, i = cwd, 1
    while i < len(tokens) and tokens[i].startswith("-"):
        t = tokens[i]
        if t == "-C" and i + 1 < len(tokens): repo = os.path.normpath(os.path.join(cwd, os.path.expanduser(tokens[i + 1]))); i += 2
        elif t.split("=")[0] in GIT_GLOBAL_CON_ARG and "=" not in t: i += 2
        else: i += 1
    if i >= len(tokens): return None
    return repo, tokens[i], tokens[i + 1:]

def parsear_push(resto):
    o = {"dry_run": False, "delete": False, "all": False, "mirror": False, "tags": False, "force": False}; pos = []
    i = 0
    while i < len(resto):
        t = resto[i]
        if t == "--": pos.extend(resto[i + 1:]); break
        if t.startswith("-"):
            base = t.split("=")[0]
            if base in ("--dry-run", "-n"): o["dry_run"] = True
            elif base in ("--delete", "-d"): o["delete"] = True
            elif base == "--all": o["all"] = True
            elif base == "--mirror": o["mirror"] = True
            elif base == "--tags": o["tags"] = True
            elif base in ("--force", "-f", "--force-with-lease", "--force-if-includes"): o["force"] = True
            if base in OPCION_CON_ARG and "=" not in t: i += 2; continue
            i += 1; continue
        pos.append(t); i += 1
    return o, pos

def sellos_dir(repo):
    common = git(repo, "rev-parse", "--path-format=absolute", "--git-common-dir")
    if common is None:
        common = git(repo, "rev-parse", "--git-common-dir")
        if common is None: return None
        if not os.path.isabs(common): common = os.path.normpath(os.path.join(repo, common))
    return os.path.join(common, "kit-chema", "sellos")

def leer_sello(dir_, sha):
    try:
        with open(os.path.join(dir_, sha), encoding="utf-8") as f:
            d = dict(l.rstrip("\n").split("=", 1) for l in f if "=" in l)
        return d
    except Exception: return None

def ent(x, d=0):
    try: return int(x)
    except Exception: return d

def pendientes(s):
    b = ent(s.get("bloquea"), None)
    return 1 if b is None else max(0, b - ent(s.get("saltados"), 0))   # sello ilegible → bloquea

def ultimo_sello_rama(dir_, rama):
    mejor = None
    try:
        for n in os.listdir(dir_):
            s = leer_sello(dir_, n)
            if s and s.get("rama") == rama and (mejor is None or s.get("fecha", "") > mejor[1].get("fecha", "")): mejor = (n, s)
    except Exception: pass
    return mejor

def identidad(repo):
    return git(repo, "config", "--get", "remote.origin.url") or git(repo, "rev-parse", "--show-toplevel") or repo

def main():
    d = json.loads(os.environ.get("INPUT", ""))
    if d.get("tool_name") != "Bash": return
    ti = d.get("tool_input") or {}
    cmd = ti.get("command") or ""
    cwd = d.get("cwd") or os.getcwd(); sid = d.get("session_id", "")
    segs = segmentar(cmd, cwd)
    def gateado(dir_):
        r = git(os.path.normpath(dir_), "rev-parse", "--show-toplevel")
        return r if r and git(r, "config", "--bool", "--get", "kit-chema.gate") == "true" else None
    # RF-7: `sello-push.sh revisar` sobre un repo con la llave puede tardar más de los 120 s del Bash.
    if not ti.get("run_in_background"):
        for toks, cwd_v, _ in segs:
            for i, t in enumerate(toks[:-1]):
                if "sello-push.sh" in t and toks[i + 1] == "revisar":
                    arg = toks[i + 2] if len(toks) > i + 2 and not toks[i + 2].startswith("-") else "."
                    if gateado(os.path.join(cwd_v, os.path.expanduser(arg))):   # pruebas (hasta 600 s) + revisor (hasta 900 s) no caben en el Bash en primer plano
                        salir(2, PREFIJO + "`sello-push.sh revisar` corre las pruebas y un revisor (una revisión real ha tardado 11 min) y el Bash en primer plano topa en 10: vuelve a correrlo con run_in_background: true y espera el aviso.")
    gits = []   # (indice, repo, sub, resto, envs)
    for idx, (toks, cwd_v, envs) in enumerate(segs):
        p = parsear_git(toks, cwd_v)
        if p: gits.append((idx, p[0], p[1], p[2], envs))
    pushes = [g for g in gits if g[2] == "push"]
    if not pushes: return
    for idx, dir_, _, resto, envs in pushes:
        repo = gateado(dir_)
        if not repo: continue                                   # fuera de un repo o sin la llave: nada que hacer
        # RF-5: escape explícito del usuario, solo como prefijo del propio push; queda anotado
        if "KIT_SELLO=omitir" in envs:
            ledger(evento="omitido", repo=identidad(repo), rama=None, comando=cmd[:200], session=sid); continue
        # RF-3: nada que mueva HEAD antes del push en el mismo comando
        movers = [g for g in gits if g[0] < idx and (g[2] in MUEVEN_HEAD or (g[2] == "stash" and g[3][:1] in (["pop"], ["apply"])))]
        if movers:
            ledger(evento="bloqueo", repo=identidad(repo), motivo="mueve-head", detalle=f"git {movers[0][2]}", session=sid)
            salir(2, PREFIJO + f"este comando mueve HEAD (git {movers[0][2]}) y empuja en la misma línea, y el sello se compara con el commit que existe al evaluar. Haz el push en un comando aparte, después de /revisar-antes-de-subir.")
        o, pos = parsear_push(resto)
        if o["all"] or o["mirror"]:
            ledger(evento="bloqueo", repo=identidad(repo), motivo="varias-ramas", session=sid)
            salir(2, PREFIJO + "--all/--mirror empujan varias ramas a la vez y el gate sella una rama a la vez. Empuja cada rama por separado.")
        if o["dry_run"] or o["delete"]: continue
        remoto = pos[0] if pos else None
        refspecs = pos[1:] if len(pos) > 1 else []
        up = git(repo, "rev-parse", "--symbolic-full-name", "@{push}") or git(repo, "rev-parse", "--symbolic-full-name", "@{u}") or ""
        if remoto is None:                                       # sin remoto explícito: el del upstream, pushDefault u origin
            remoto = up.split("/", 3)[2] if up.startswith("refs/remotes/") and up.count("/") >= 3 else (git(repo, "config", "--get", "remote.pushDefault") or "origin")
        if o["tags"]:                                            # --tags empuja los tags ADEMÁS de los refspecs: se revisan siempre
            tags = [t for t in (git(repo, "tag", "--list") or "").split("\n") if t]
            if len(tags) > 10:
                ledger(evento="bloqueo", repo=identidad(repo), motivo="varios-tags", session=sid)
                salir(2, PREFIJO + f"--tags empujaría {len(tags)} tags y el gate los revisa uno por uno (tope 10 para no agotar su timeout): empuja los tags por nombre.")
            refspecs = refspecs + tags
        specs = []
        if not refspecs:
            rama = git(repo, "rev-parse", "--abbrev-ref", "HEAD") or "HEAD"
            partes = up.split("/", 3) if up.startswith("refs/remotes/") else []
            specs.append(("HEAD", partes[3] if len(partes) > 3 else rama))
        else:
            for rs in refspecs:
                if rs.startswith("+"): o["force"] = True
                rs = rs.lstrip("+")
                if rs.startswith(":"): continue                       # borrado remoto: nada nuevo llega
                src, _, dst = rs.partition(":"); dst = dst or src
                if dst.startswith("refs/heads/"): dst = dst[len("refs/heads/"):]
                if dst.startswith("refs/tags/"): dst = dst[len("refs/tags/"):]
                specs.append((src, dst))
        if not specs: continue
        dir_sellos = sellos_dir(repo); ident = identidad(repo)
        for src, dst in specs:
            sha = git(repo, "rev-parse", "--verify", "--quiet", f"{src}^{{commit}}")
            if not sha:                                             # variable sin expandir, $(…) o ref inexistente: el hook no ejecuta nada, así que no puede saber qué se empuja → bloquea
                ledger(evento="bloqueo", repo=ident, rama=dst, motivo="refspec-irresoluble", detalle=src[:80], session=sid)
                salir(2, PREFIJO + f"no puedo resolver el refspec '{src}' sin ejecutar el comando (variable, sustitución o ref inexistente). Escribe la rama o el commit por su nombre literal: git push {remoto} <rama>.")
            s7 = sha[:7]
            es_tag = git(repo, "show-ref", "--verify", "--quiet", f"refs/tags/{src}") is not None
            # ¿ya está en el remoto? nada nuevo llega → permitido (sin-cambios)
            if es_tag:                                              # solo cuenta el remoto DESTINO del push
                en_remoto = bool(git(repo, "branch", "-r", "--contains", sha, "--list", f"{remoto}/*"))
            else:
                rt = git(repo, "rev-parse", "--verify", "--quiet", f"refs/remotes/{remoto}/{dst}")
                en_remoto = bool(rt) and git(repo, "merge-base", "--is-ancestor", sha, rt) is not None
                if en_remoto and o["force"] and rt != sha: en_remoto = False   # forzar a un ancestro REBOBINA la rama remota: eso sí exige sello
            if en_remoto:
                ledger(evento="permitido", repo=ident, rama=dst, head=sha, veredicto="sin-cambios", session=sid); continue
            sello = leer_sello(dir_sellos, sha) if dir_sellos else None
            if es_tag and sello is None:
                ledger(evento="bloqueo", repo=ident, rama=dst, head=sha, motivo="tag-sin-sello", session=sid)
                salir(2, PREFIJO + f"'{src}' es un tag y empujarlo empuja su commit {s7}, que no está en ningún remoto ni tiene sello. Empuja primero la rama revisada o corre /revisar-antes-de-subir sobre ese commit.")
            if sello is None or pendientes(sello) > 0:
                pend = pendientes(sello) if sello else 0
                ult = ultimo_sello_rama(dir_sellos, dst) if dir_sellos else None
                ult_txt = f"último sello de esta rama: {ult[0][:7]}, {ult[1].get('veredicto','?')}, {pendientes(ult[1])} pendiente(s)" if ult else "esta rama no tiene ningún sello"
                estado = f"tiene {pend} pendiente(s) sin corregir ni saltar" if sello else "no tiene sello de revisión"
                ledger(evento="bloqueo", repo=ident, rama=dst, head=sha, bloquea=ent(sello.get("bloquea"), None) if sello else None, saltados=ent(sello.get("saltados"), None) if sello else None, motivo="sin-sello" if sello is None else "pendientes", session=sid)
                salir(2, PREFIJO + f"{s7} (rama {dst}) {estado}; {ult_txt}. Corre /revisar-antes-de-subir y vuelve a empujar. Solo si el usuario lo pide expresamente: KIT_SELLO=omitir git push … (queda anotado).")
            ledger(evento="permitido", repo=ident, rama=dst, head=sha, veredicto=sello.get("veredicto", ""), bloquea=ent(sello.get("bloquea")), saltados=ent(sello.get("saltados")), session=sid)

try:
    main()
except SystemExit:
    raise
except Exception as e:
    ledger(evento="error-hook", detalle=f"{type(e).__name__}: {e}"[:200])
    sys.exit(0)
PY
rc=$?
[ "$rc" -eq 2 ] && exit 2
exit 0
