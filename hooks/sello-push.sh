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
# invoca `sello-push.sh revisar` sobre un repo con la llave, exige timeout ≥ 300000 (el
# Bash de Claude Code corta a 120 s). Cada decisión se apendea al ledger JSONL (KIT_GATE_LEDGER). Falla
# abierto ante error propio: exit 0 y evento `error-hook` si puede escribirlo. En repos
# sin la llave, sale 0 sin tocar nada. Diseño: claude-entorno/specs/002-gate-de-push/.
set -uo pipefail
input=$(cat)
# Prefiltro barato: sin "git…push" ni "sello-push" en el comando no arranca python (~3 ms).
case "$input" in *git*push*|*sello-push*) ;; *) exit 0 ;; esac
command -v python3 >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0
export KIT_GATE_LEDGER="${KIT_GATE_LEDGER:-$HOME/.claude/kit-chema/gate.jsonl}"
INPUT="$input" python3 - <<'PY'
import json, os, re, shlex, subprocess, sys, datetime

MUEVEN_HEAD = {"commit", "rebase", "merge", "reset", "cherry-pick", "checkout", "switch", "pull", "revert", "am"}
OPCION_CON_ARG = {"-o", "--push-option", "--repo", "--receive-pack", "--exec"}
GIT_GLOBAL_CON_ARG = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"}
ENVOLTORIOS = {"sudo", "exec", "command", "nohup", "setsid", "time", "env"}
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
    lex = shlex.shlex(quitar_heredocs(cmd).replace("\n", " ; "), posix=True, punctuation_chars=";&|()")
    lex.whitespace_split = True
    try: toks = list(lex)
    except ValueError: toks = quitar_heredocs(cmd).replace("\n", " ").split()   # comillas sin cerrar: tokens crudos
    segs, actual = [], []
    for t in toks:
        if t and all(c in ";&|()" for c in t):
            if actual: segs.append(actual); actual = []
        else: actual.append(t)
    if actual: segs.append(actual)
    salida, cwd_v = [], cwd
    for s in segs:
        envs = []                                     # asignaciones que preceden al comando (VAR=x cmd …)
        while s and (re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", s[0]) or s[0] in ENVOLTORIOS):
            if s[0] not in ENVOLTORIOS: envs.append(s[0])
            s = s[1:]
        if s and s[0] == "timeout" and len(s) > 2: s = s[2:]
        if not s: continue
        if s[0] in ("cd", "pushd"):
            dest = s[1] if len(s) > 1 else "~"
            if dest != "-": cwd_v = os.path.normpath(os.path.join(cwd_v, os.path.expanduser(dest)))
            continue
        if s[0] in ("bash", "sh", "zsh", "dash") and "-c" in s:
            i = s.index("-c")
            if i + 1 < len(s): salida.extend(segmentar(s[i + 1], cwd_v))
            continue
        salida.append((s, cwd_v, envs))
    return salida

def parsear_git(tokens, cwd):
    """(repo, subcomando, resto) de un segmento que empieza por git; None si no es git."""
    if not tokens or tokens[0] != "git": return None
    repo, i = cwd, 1
    while i < len(tokens) and tokens[i].startswith("-"):
        t = tokens[i]
        if t == "-C" and i + 1 < len(tokens): repo = os.path.normpath(os.path.join(cwd, os.path.expanduser(tokens[i + 1]))); i += 2
        elif t.split("=")[0] in GIT_GLOBAL_CON_ARG and "=" not in t: i += 2
        else: i += 1
    if i >= len(tokens): return None
    return repo, tokens[i], tokens[i + 1:]

def parsear_push(resto):
    o = {"dry_run": False, "delete": False, "all": False, "mirror": False, "tags": False}; pos = []
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

def pendientes(s):
    try: return max(0, int(s.get("bloquea", 0)) - int(s.get("saltados", 0)))
    except Exception: return 1

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
                    if gateado(os.path.join(cwd_v, os.path.expanduser(arg))):
                        to = ti.get("timeout")
                        if not isinstance(to, (int, float)) or to < 300000:
                            salir(2, PREFIJO + "`sello-push.sh revisar` corre las pruebas y un revisor y puede tardar más de 2 minutos: vuelve a correrlo con timeout: 600000 (o run_in_background: true).")
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
            salir(2, PREFIJO + f"este comando mueve HEAD (git {movers[0][2]}) y empuja en la misma línea, y el sello se compara con el commit que existe al evaluar. Haz el push en un comando aparte, después de /revisar-antes-de-subir.")
        o, pos = parsear_push(resto)
        if o["all"] or o["mirror"]:
            salir(2, PREFIJO + "--all/--mirror empujan varias ramas a la vez y el gate sella una rama a la vez. Empuja cada rama por separado.")
        if o["dry_run"] or o["delete"]: continue
        remoto = pos[0] if pos else None
        refspecs = pos[1:] if len(pos) > 1 else []
        if o["tags"] and not refspecs:
            refspecs = [t for t in (git(repo, "tag", "--list") or "").split("\n") if t]
        specs = []
        if not refspecs:
            up = git(repo, "rev-parse", "--symbolic-full-name", "@{push}") or git(repo, "rev-parse", "--symbolic-full-name", "@{u}")
            rama = git(repo, "rev-parse", "--abbrev-ref", "HEAD") or "HEAD"
            if up and up.startswith("refs/remotes/"):
                partes = up.split("/", 3); remoto = remoto or partes[2]; specs.append(("HEAD", partes[3] if len(partes) > 3 else rama))
            else:
                remoto = remoto or git(repo, "config", "--get", "remote.pushDefault") or "origin"; specs.append(("HEAD", rama))
        else:
            for rs in refspecs:
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
            if not sha: continue                                    # ref inexistente: que git falle solo
            s7 = sha[:7]
            es_tag = git(repo, "show-ref", "--verify", "--quiet", f"refs/tags/{src}") is not None
            # ¿ya está en el remoto? nada nuevo llega → permitido (sin-cambios)
            if es_tag:
                en_remoto = bool(git(repo, "branch", "-r", "--contains", sha))
            else:
                rt = git(repo, "rev-parse", "--verify", "--quiet", f"refs/remotes/{remoto}/{dst}")
                en_remoto = bool(rt) and git(repo, "merge-base", "--is-ancestor", sha, rt) is not None
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
                ledger(evento="bloqueo", repo=ident, rama=dst, head=sha, bloquea=int(sello.get("bloquea", 0)) if sello else None, saltados=int(sello.get("saltados", 0)) if sello else None, session=sid)
                salir(2, PREFIJO + f"{s7} (rama {dst}) {estado}; {ult_txt}. Corre /revisar-antes-de-subir y vuelve a empujar. Solo si el usuario lo pide expresamente: KIT_SELLO=omitir git push … (queda anotado).")
            ledger(evento="permitido", repo=ident, rama=dst, head=sha, veredicto=sello.get("veredicto", ""), bloquea=int(sello.get("bloquea", 0)), saltados=int(sello.get("saltados", 0)), session=sid)

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
