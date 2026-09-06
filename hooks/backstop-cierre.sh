#!/usr/bin/env bash
# Hook Stop del Kit Chema: el cierre no pasa ciego. Si en ESTA sesión hubo trabajo
# real dentro del proyecto del cwd (≥3 escrituras fuera del papeleo, o ≥1 commit)
# después de la última actualización de CONTINUAR.md, y `rotar-continuar.sh
# reconciliar` dice que el estado quedó rancio (código 1: trabajo después del
# último cierre, o cierre no limpio), bloquea el fin de turno UNA vez con la razón,
# para que Claude decida: si va a terminar, corre /cierre; si está a mitad de la
# tarea, continúa. En la misma sesión no vuelve a bloquear (deja un aviso al
# usuario) hasta que CONTINUAR.md se actualice de nuevo: entonces se re-arma.
# Si Claude Code ya bloqueó (stop_hook_active), o el helper no puede reconciliar
# (código 3: sin ancla, ancla fuera del historial), o algo falla: deja pasar.
# Opt-in: KIT_BACKSTOP=s ./instalar.sh. Idea: backstop de firstmate (cosecha 2026-09-06).
set -uo pipefail
ROTAR="${BACKSTOP_ROTAR:-$HOME/.claude/scripts/rotar-continuar.sh}"
MARCAS="${BACKSTOP_MARCAS:-${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/kit-chema-backstop}"
MIN_ESCRITURAS="${BACKSTOP_MIN:-3}"
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

# Trabajo real en esta sesión dentro del proyecto, y si quedó sin cerrar. Trabajo real
# = Write/Edit/NotebookEdit fuera del papeleo (CONTINUAR, DECISIONES, CLAUDE.md,
# bitácora) o `git … commit`. Cerrado = se escribió CONTINUAR.md y después no hubo
# más trabajo real (papeleo y commit de cierre no cuentan). Solo lee las líneas con
# tool_use. Imprime: escrituras_posteriores, commits, cerrado, idx_ultimo_continuar.
res=$(grep -F '"tool_use"' "$tr" 2>/dev/null | python3 -c '
import json,sys,os,re
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
        elif name=="Bash" and re.search(r"\bgit\b.*\bcommit\b", i.get("command") or ""):
            commits+=1
posteriores=[t for t in trabajo if t>ultimo_cont]
cerrado = ultimo_cont>=0 and not posteriores
print(len(posteriores)); print(commits); print("1" if cerrado else "0"); print(ultimo_cont)' "$cwd" 2>/dev/null) || exit 0
n=$(sed -n 1p <<<"$res"); commits=$(sed -n 2p <<<"$res"); cerrado=$(sed -n 3p <<<"$res"); ultimo_cont=$(sed -n 4p <<<"$res")
[ "${n:-0}" -ge "$MIN_ESCRITURAS" ] 2>/dev/null || [ "${commits:-0}" -ge 1 ] 2>/dev/null || exit 0
[ "$cerrado" = "1" ] && exit 0

# ¿El estado quedó rancio? 0 fresco · 1 rancio · 2 sin CONTINUAR · 3 no se puede
# reconciliar (sin ancla, ancla fuera del historial). Solo el 1 bloquea, y la razón
# cita el motivo que dio el helper. BACKSTOP_RECONCILIAR inyecta el veredicto en la prueba.
if [ -n "${BACKSTOP_RECONCILIAR:-}" ]; then motivo=$(bash -c "$BACKSTOP_RECONCILIAR" 2>&1); rc=$?
else motivo=$(bash "$ROTAR" reconciliar "$cwd" 2>&1); rc=$?; fi
[ "$rc" -eq 1 ] || exit 0
motivo=$(printf '%s\n' "$motivo" | grep -m1 '✗' | sed 's/^[^✗]*✗ *//' | cut -c1-160)

proy=$(basename "$cwd")
mkdir -p "$MARCAS" 2>/dev/null || exit 0
find "$MARCAS" -type f -mtime +7 -delete 2>/dev/null
marca="$MARCAS/${sid:-sin-sesion}"
# La marca guarda el índice del último CONTINUAR.md al momento del bloqueo: si después
# se volvió a escribir CONTINUAR.md (cierre) y hubo más trabajo, se re-arma.
if [ -f "$marca" ]; then
  guardado=$(cat "$marca" 2>/dev/null); guardado=${guardado:--1}
  if [ "${ultimo_cont:--1}" -gt "$guardado" ] 2>/dev/null; then rm -f "$marca"
  else
    python3 -c 'import json,sys; print(json.dumps({"systemMessage": sys.argv[1]}, ensure_ascii=False))' \
      "Kit Chema: '$proy' sigue con trabajo sin cerrar en esta sesión (ya se avisó una vez). Antes de dejarlo, corre /cierre."
    exit 0
  fi
fi
printf '%s' "${ultimo_cont:--1}" > "$marca" 2>/dev/null || exit 0
python3 -c 'import json,sys; print(json.dumps({"decision":"block","reason": sys.argv[1]}, ensure_ascii=False))' \
  "Kit Chema: en esta sesión hay $n escritura(s) y $commits commit(s) en el proyecto '$proy' después de la última actualización de CONTINUAR.md, y reconciliar dice: ${motivo:-el estado quedó rancio}. Si estás a mitad de la tarea, continúa. Si vas a terminar: corre /cierre o actualiza CONTINUAR.md antes. Si el usuario prefiere dejarlo así, dilo y termina."
exit 0
