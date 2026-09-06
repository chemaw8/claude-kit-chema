#!/usr/bin/env bash
# Hook Stop del Kit Chema: el cierre no pasa ciego. Si en ESTA sesión se
# modificaron archivos (Write/Edit/NotebookEdit) o se hicieron commits dentro del
# proyecto del cwd, y su CONTINUAR.md quedó rancio (hubo trabajo después del
# último cierre, según `rotar-continuar.sh reconciliar`) y no se actualizó en la
# sesión, bloquea el cierre UNA vez con la razón, para que Claude corra /cierre o
# actualice CONTINUAR.md antes de terminar. En la misma sesión no vuelve a
# bloquear: deja un aviso al usuario. Si Claude Code ya bloqueó antes
# (stop_hook_active), deja pasar. Fail-open: ante cualquier error, deja pasar.
# Idea tomada del backstop de fin de turno de firstmate (cosecha 2026-09-06).
set -uo pipefail
ROTAR="${BACKSTOP_ROTAR:-$HOME/.claude/scripts/rotar-continuar.sh}"
MARCAS="${BACKSTOP_MARCAS:-${XDG_RUNTIME_DIR:-/tmp}/kit-chema-backstop}"
input=$(cat)
leer=$(printf '%s' "$input" | python3 -c '
import json,sys
d=json.load(sys.stdin)
print(d.get("session_id","") or "")
print(d.get("cwd","") or "")
print(d.get("transcript_path","") or "")
print("1" if d.get("stop_hook_active") else "0")' 2>/dev/null) || exit 0
sid=$(sed -n 1p <<<"$leer"); cwd=$(sed -n 2p <<<"$leer")
tr=$(sed -n 3p <<<"$leer"); activo=$(sed -n 4p <<<"$leer")
[ "$activo" = "1" ] && exit 0
[ -n "$cwd" ] && [ -f "$cwd/CONTINUAR.md" ] || exit 0
[ -n "$tr" ] && [ -r "$tr" ] || exit 0

# ¿Hubo trabajo real en esta sesión dentro del proyecto, y quedó sin cerrar? Trabajo
# real = Write/Edit fuera del papeleo (CONTINUAR, DECISIONES, CLAUDE.md, bitácora) o
# git commit. Cerrado = se escribió CONTINUAR.md y después no hubo más trabajo real
# (el commit de cierre no cuenta). Solo se leen las líneas con tool_use.
res=$(grep -F '"tool_use"' "$tr" 2>/dev/null | python3 -c '
import json,sys,os
raiz=sys.argv[1].rstrip("/")
PAPELEO={"CONTINUAR.md","DECISIONES.md","CLAUDE.md","bitacora.md"}
idx=0; ultimo_cont=-1; trabajo=[]; commits=0
for line in sys.stdin:
    try: d=json.loads(line)
    except Exception: continue
    m=d.get("message") or {}
    for c in (m.get("content") or []) if isinstance(m,dict) else []:
        if not isinstance(c,dict) or c.get("type")!="tool_use": continue
        idx+=1
        name=c.get("name"); i=c.get("input") or {}
        if name in ("Write","Edit","NotebookEdit"):
            p=i.get("file_path") or i.get("notebook_path") or ""
            if not p.startswith(raiz+"/"): continue
            b=os.path.basename(p)
            if b=="CONTINUAR.md": ultimo_cont=idx
            elif b not in PAPELEO: trabajo.append(idx)
        elif name=="Bash" and "git commit" in (i.get("command") or ""):
            commits+=1
n=len(trabajo)+commits
# cerrado = se escribio CONTINUAR.md y despues no hubo mas trabajo real (papeleo y commits no cuentan)
cerrado = ultimo_cont>=0 and not any(t>ultimo_cont for t in trabajo)
print(n); print("1" if cerrado else "0")' "$cwd" 2>/dev/null) || exit 0
n=$(sed -n 1p <<<"$res"); cont=$(sed -n 2p <<<"$res")
[ "${n:-0}" -gt 0 ] 2>/dev/null || exit 0
[ "$cont" = "1" ] && exit 0

# ¿El estado quedó rancio? 0 fresco · 1 rancio · 2 sin CONTINUAR. BACKSTOP_RECONCILIAR
# permite inyectar el veredicto en la prueba.
if [ -n "${BACKSTOP_RECONCILIAR:-}" ]; then bash -c "$BACKSTOP_RECONCILIAR"; rc=$?
else bash "$ROTAR" reconciliar "$cwd" >/dev/null 2>&1; rc=$?; fi
[ "$rc" -eq 1 ] || exit 0

proy=$(basename "$cwd")
mkdir -p "$MARCAS" 2>/dev/null
marca="$MARCAS/${sid:-sin-sesion}"
if [ -f "$marca" ]; then
  python3 -c 'import json,sys; print(json.dumps({"systemMessage": sys.argv[1]}, ensure_ascii=False))' \
    "Kit Chema: '$proy' sigue con CONTINUAR.md rancio tras trabajo real en esta sesión (ya se avisó una vez). Corre /cierre antes de dejarlo."
  exit 0
fi
: > "$marca"
python3 -c 'import json,sys; print(json.dumps({"decision":"block","reason": sys.argv[1]}, ensure_ascii=False))' \
  "Kit Chema: esta sesión modificó $n archivo(s) o hizo commits en el proyecto '$proy' y su CONTINUAR.md quedó rancio (hubo trabajo después del último cierre). Antes de terminar: corre /cierre o actualiza CONTINUAR.md. Si José prefiere dejarlo así, dilo y termina."
exit 0
