#!/usr/bin/env bash
# Prueba de hooks/backstop-cierre.sh. Uso: bash hooks/test-backstop-cierre.sh [ruta-al-hook]
# Simula el evento Stop de Claude Code con un transcript y un proyecto sintéticos;
# el veredicto fresco/rancio se inyecta con BACKSTOP_RECONCILIAR (un comando que
# devuelve 0 fresco · 1 rancio · 2 sin CONTINUAR), para no depender del helper real.
HOOK="${1:-$(dirname "${BASH_SOURCE[0]}")/backstop-cierre.sh}"
T=$(mktemp -d); fallos=0
PROY="$T/proyecto"; mkdir -p "$PROY"; printf '# CONTINUAR — x\n' > "$PROY/CONTINUAR.md"
SIN="$T/sin-continuar"; mkdir -p "$SIN"
TR="$T/transcript.jsonl"
export BACKSTOP_MARCAS="$T/marcas"   # dónde guarda "ya avisé en esta sesión"

tool() { # nombre json-input
  printf '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"t","name":"%s","input":%s}]}}\n' "$1" "$2"
}
evento() { # cwd [stop_hook_active]
  printf '{"session_id":"%s","cwd":"%s","transcript_path":"%s","stop_hook_active":%s}' "${SID:-s1}" "$1" "$TR" "${2:-false}"
}
corre() { # cwd stop_hook_active reconciliar_rc  → imprime salida
  BACKSTOP_RECONCILIAR="exit $3" bash "$HOOK" <<<"$(evento "$1" "$2")" 2>/dev/null
}
espera() { # descripcion salida patron_esperado(vacio=sin bloqueo)
  local desc="$1" out="$2" pat="$3"
  if [ -z "$pat" ]; then
    if printf '%s' "$out" | grep -q '"decision"[[:space:]]*:[[:space:]]*"block"'; then echo "  FALLA $desc → bloqueó: $out"; fallos=$((fallos+1)); else echo "  ok    $desc"; fi
  else
    if printf '%s' "$out" | grep -q "$pat"; then echo "  ok    $desc"; else echo "  FALLA $desc → esperaba /$pat/ y salió: $out"; fallos=$((fallos+1)); fi
  fi
}

echo "no estorba cuando no hay motivo:"
: > "$TR"; espera "sin trabajo en la sesión" "$(corre "$PROY" false 1)" ""
tool Write "{\"file_path\":\"$PROY/a.py\",\"content\":\"x\"}" > "$TR"
espera "proyecto sin CONTINUAR.md" "$(corre "$SIN" false 2)" ""
espera "trabajo real pero estado fresco" "$(corre "$PROY" false 0)" ""
espera "stop_hook_active=true (ya se bloqueó una vez)" "$(corre "$PROY" true 1)" ""
{ tool Write "{\"file_path\":\"$PROY/a.py\",\"content\":\"x\"}"; tool Edit "{\"file_path\":\"$PROY/CONTINUAR.md\",\"old_string\":\"a\",\"new_string\":\"b\"}"; } > "$TR"
espera "CONTINUAR.md actualizado en la sesión" "$(corre "$PROY" false 1)" ""
tool Write "{\"file_path\":\"/otro/lado/a.py\",\"content\":\"x\"}" > "$TR"
espera "escrituras fuera del proyecto" "$(corre "$PROY" false 1)" ""
echo "no estorba si algo se rompe (fail-open):"
espera "JSON roto" "$(printf 'no-json' | BACKSTOP_RECONCILIAR='exit 1' bash "$HOOK" 2>/dev/null)" ""
printf 'basura\n' > "$TR"; espera "transcript ilegible" "$(corre "$PROY" false 1)" ""

echo "bloquea UNA vez cuando hubo trabajo real y el estado quedó rancio:"
export SID="s2"; rm -rf "$BACKSTOP_MARCAS"
tool Write "{\"file_path\":\"$PROY/a.py\",\"content\":\"x\"}" > "$TR"
out=$(corre "$PROY" false 1)
espera "primera vez → decision block" "$out" '"decision"[[:space:]]*:[[:space:]]*"block"'
espera "la razón nombra al proyecto y a /cierre" "$out" 'proyecto.*cierre\|cierre.*proyecto'
out2=$(corre "$PROY" false 1)
espera "segunda vez misma sesión → ya no bloquea" "$out2" ""
espera "…pero deja aviso al usuario (systemMessage)" "$out2" '"systemMessage"'
export SID="s3"; espera "otra sesión → vuelve a bloquear una vez" "$(corre "$PROY" false 1)" '"decision"[[:space:]]*:[[:space:]]*"block"'
echo "distingue cierre real de cierre seguido de más trabajo:"
export SID="s5"; { tool Edit "{\"file_path\":\"$PROY/CONTINUAR.md\",\"old_string\":\"a\",\"new_string\":\"b\"}"; tool Write "{\"file_path\":\"$PROY/b.py\",\"content\":\"x\"}"; } > "$TR"
espera "CONTINUAR y DESPUÉS más trabajo → bloquea" "$(corre "$PROY" false 1)" '"decision"[[:space:]]*:[[:space:]]*"block"'
export SID="s6"; { tool Write "{\"file_path\":\"$PROY/a.py\",\"content\":\"x\"}"; tool Edit "{\"file_path\":\"$PROY/CONTINUAR.md\",\"old_string\":\"a\",\"new_string\":\"b\"}"; tool Write "{\"file_path\":\"$PROY/docs/bitacora.md\",\"content\":\"x\"}"; tool Bash "{\"command\":\"git commit -m cierre\"}"; } > "$TR"
espera "CONTINUAR + bitácora + commit de cierre → no bloquea" "$(corre "$PROY" false 1)" ""
echo "también bloquea con commits (Bash git commit) como trabajo real:"
export SID="s4"; tool Bash "{\"command\":\"git commit -m x\"}" > "$TR"
espera "git commit cuenta como trabajo real" "$(corre "$PROY" false 1)" '"decision"[[:space:]]*:[[:space:]]*"block"'

rm -rf "$T"; echo; [ $fallos -eq 0 ] && echo "TODO OK" || { echo "$fallos fallos"; exit 1; }
