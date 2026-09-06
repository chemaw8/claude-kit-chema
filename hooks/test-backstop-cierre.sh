#!/usr/bin/env bash
# Prueba de hooks/backstop-cierre.sh. Uso: bash hooks/test-backstop-cierre.sh [ruta-al-hook]
# Simula el evento Stop de Claude Code con un transcript y un proyecto sintéticos. El
# veredicto fresco/rancio se inyecta con BACKSTOP_RECONCILIAR (0 fresco · 1 rancio ·
# 2 sin CONTINUAR · 3 no se puede reconciliar); al final hay dos casos de integración
# con el helper REAL (scripts/rotar-continuar.sh) sobre un repo git temporal.
HOOK="${1:-$(dirname "${BASH_SOURCE[0]}")/backstop-cierre.sh}"
ROTAR_REAL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/rotar-continuar.sh"
T=$(mktemp -d); fallos=0
PROY="$T/proyecto"; mkdir -p "$PROY"; printf '# CONTINUAR — x\n' > "$PROY/CONTINUAR.md"
SIN="$T/sin-continuar"; mkdir -p "$SIN"
TR="$T/transcript.jsonl"
export BACKSTOP_MARCAS="$T/marcas"

tool() { printf '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"t","name":"%s","input":%s}]}}\n' "$1" "$2"; }
w()    { tool Write "{\"file_path\":\"$1\",\"content\":\"x\"}"; }              # una escritura
w3()   { w "$1/a.py"; w "$1/b.py"; w "$1/c.py"; }                             # trabajo real (umbral)
cont() { tool Edit "{\"file_path\":\"$1/CONTINUAR.md\",\"old_string\":\"a\",\"new_string\":\"b\"}"; }
evento() { printf '{"session_id":"%s","cwd":"%s","transcript_path":"%s","stop_hook_active":%s}' "${SID:-s1}" "$1" "$TR" "${2:-false}"; }
corre()  { BACKSTOP_RECONCILIAR="echo '✗ motivo de prueba' >&2; exit $3" bash "$HOOK" <<<"$(evento "$1" "$2")" 2>/dev/null; }
BLOCK='"decision"[[:space:]]*:[[:space:]]*"block"'
espera() { # descripcion salida patron(vacio = NO debe bloquear)
  if [ -z "$3" ]; then
    if printf '%s' "$2" | grep -q "$BLOCK"; then echo "  FALLA $1 → bloqueó: $2"; fallos=$((fallos+1)); else echo "  ok    $1"; fi
  else
    if printf '%s' "$2" | grep -q "$3"; then echo "  ok    $1"; else echo "  FALLA $1 → esperaba /$3/ y salió: $2"; fallos=$((fallos+1)); fi
  fi
}

echo "no estorba cuando no hay motivo:"
: > "$TR";                       espera "sin trabajo en la sesión" "$(corre "$PROY" false 1)" ""
w3 "$PROY" > "$TR";              espera "proyecto sin CONTINUAR.md" "$(corre "$SIN" false 2)" ""
                                 espera "trabajo real pero estado fresco (rc 0)" "$(corre "$PROY" false 0)" ""
                                 espera "no se puede reconciliar (rc 3) → no afirma nada" "$(corre "$PROY" false 3)" ""
                                 espera "stop_hook_active=true" "$(corre "$PROY" true 1)" ""
w "$PROY/a.py" > "$TR";          espera "UNA sola edición no llega al umbral" "$(corre "$PROY" false 1)" ""
{ w3 "$PROY"; cont "$PROY"; } > "$TR";                    espera "CONTINUAR.md actualizado después del trabajo" "$(corre "$PROY" false 1)" ""
{ w3 "$PROY"; cont "$PROY"; w "$PROY/docs/bitacora.md"; tool Bash '{"command":"git commit -m cierre"}'; } > "$TR"
                                 espera "cierre + bitácora + commit de cierre → no bloquea" "$(corre "$PROY" false 1)" ""
w3 "/otro/lado" > "$TR";         espera "escrituras fuera del proyecto" "$(corre "$PROY" false 1)" ""
echo "no estorba si algo se rompe (fail-open):"
espera "JSON roto" "$(printf 'no-json' | BACKSTOP_RECONCILIAR='exit 1' bash "$HOOK" 2>/dev/null)" ""
printf 'basura\n' > "$TR";       espera "transcript ilegible" "$(corre "$PROY" false 1)" ""
w3 "$PROY" > "$TR"; export SID="ro"; espera "marcas no escribibles → no bloquea" "$(BACKSTOP_MARCAS=/proc/no-se-puede BACKSTOP_RECONCILIAR='exit 1' bash "$HOOK" <<<"$(evento "$PROY" false)" 2>/dev/null)" ""

echo "bloquea UNA vez con trabajo real sin cerrar y estado rancio:"
export SID="s2"; w3 "$PROY" > "$TR"
out=$(corre "$PROY" false 1)
espera "primera vez → decision block" "$out" "$BLOCK"
espera "la razón cita el motivo del helper" "$out" "motivo de prueba"
espera "la razón deja continuar si va a mitad" "$out" "mitad de la tarea"
out2=$(corre "$PROY" false 1)
espera "segunda vez misma sesión → ya no bloquea" "$out2" ""
espera "…pero deja aviso al usuario (systemMessage)" "$out2" '"systemMessage"'
export SID="s3"; espera "otra sesión → vuelve a bloquear una vez" "$(corre "$PROY" false 1)" "$BLOCK"
echo "se re-arma si después del bloqueo se cierra y se sigue trabajando:"
export SID="s4"; w3 "$PROY" > "$TR"; corre "$PROY" false 1 >/dev/null
{ w3 "$PROY"; cont "$PROY"; w3 "$PROY"; } > "$TR"
espera "bloqueo → CONTINUAR → más trabajo → bloquea de nuevo" "$(corre "$PROY" false 1)" "$BLOCK"
echo "commits cuentan como trabajo real:"
export SID="s5"; tool Bash '{"command":"git commit -m x"}' > "$TR";        espera "git commit" "$(corre "$PROY" false 1)" "$BLOCK"
export SID="s6"; tool Bash '{"command":"git -C /x/repo commit -q -m y"}' > "$TR"; espera "git -C repo commit" "$(corre "$PROY" false 1)" "$BLOCK"
echo "el mensaje no lleva nombres propios:"
export SID="s7"; w3 "$PROY" > "$TR"; espera "sin 'José' en la razón" "$(corre "$PROY" false 1 | grep -ci 'josé')" "^0$"

echo "integración con el helper REAL (repo git temporal):"
if [ -x "$ROTAR_REAL" ] && command -v git >/dev/null; then
  G="$T/git-proy"; mkdir -p "$G"; git -C "$G" init -q; git -C "$G" -c user.email=t@t -c user.name=t commit -q --allow-empty -m base
  printf '%s\n\n## Dónde vamos\nx\n' "$(bash "$ROTAR_REAL" anclar "$G" | head -1)" > "$G/CONTINUAR.md"; git -C "$G" add -A; git -C "$G" -c user.email=t@t -c user.name=t commit -q -m cierre
  # trabajo real sin commitear → reconciliar debe decir rancio (1) → bloquea
  echo z > "$G/z.py"; export SID="g1"; w3 "$G" > "$TR"
  espera "helper real: trabajo tras el cierre → bloquea" "$(BACKSTOP_ROTAR="$ROTAR_REAL" bash "$HOOK" <<<"$(evento "$G" false)" 2>/dev/null)" "$BLOCK"
  # CONTINUAR sin ancla → helper devuelve 3 → no bloquea
  printf '# CONTINUAR — sin ancla\n' > "$G/CONTINUAR.md"; export SID="g2"
  espera "helper real: CONTINUAR sin ancla (rc 3) → no bloquea" "$(BACKSTOP_ROTAR="$ROTAR_REAL" bash "$HOOK" <<<"$(evento "$G" false)" 2>/dev/null)" ""
else echo "  skip  (sin git o sin scripts/rotar-continuar.sh)"; fi

rm -rf "$T"; echo; [ $fallos -eq 0 ] && echo "TODO OK" || { echo "$fallos fallos"; exit 1; }
