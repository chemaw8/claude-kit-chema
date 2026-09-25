#!/usr/bin/env bash
# Prueba de hooks/kit-chema-contexto.sh. Uso: bash hooks/test-kit-chema-contexto.sh [ruta-al-hook]
# Independiente de la máquina: arma un HOME y un CLAUDE_CONFIG_DIR falsos en un
# directorio temporal, con una marca distinta en cada contexto/, y mira cuál carga.
HOOK="${1:-$(dirname "${BASH_SOURCE[0]}")/kit-chema-contexto.sh}"
fallos=0
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
mkdir -p "$t/casa/.claude/contexto" "$t/perfil b/contexto" "$t/perfil-vacio" "$t/casa-vacia"
echo "marca-home" > "$t/casa/.claude/contexto/CONTEXTO-EMPRESA.md"
echo "marca-perfil" > "$t/perfil b/contexto/CONTEXTO-EMPRESA.md"
: > "$t/perfil b/contexto/CONTEXTO-PERSONAL.md" # vacío: no debe aparecer

corre() { # home config(vacío = sin definir) → deja la salida en $salida y el código en $rc
  if [ -n "$2" ]; then salida=$(HOME="$1" CLAUDE_CONFIG_DIR="$2" bash "$HOOK" 2>&1); rc=$?
  else salida=$(env -u CLAUDE_CONFIG_DIR HOME="$1" bash "$HOOK" 2>&1); rc=$?; fi
}
caso() { # descripción home config espera(marca | vacio) no-debe-traer
  corre "$2" "$3"
  local ok=1
  [ "$rc" -eq 0 ] || ok=0
  if [ "$4" = vacio ]; then [ -z "$salida" ] || ok=0
  else
    printf '%s' "$salida" | grep -q "$4" || ok=0
    printf '%s' "$salida" | python3 -c 'import json,sys; d=json.load(sys.stdin); sys.exit(d["hookSpecificOutput"]["hookEventName"]!="SessionStart")' 2>/dev/null || ok=0
  fi
  [ -n "$5" ] && printf '%s' "$salida" | grep -q "$5" && ok=0
  if [ $ok -eq 1 ]; then echo "  ok    $1"; else echo "  FALLA $1 → rc=$rc: $salida"; fallos=$((fallos+1)); fi
}

if ! command -v python3 >/dev/null 2>&1; then
  echo "  skip  sin python3 no se puede probar la salida JSON"
else
  echo "sin CLAUDE_CONFIG_DIR lee ~/.claude/contexto (comportamiento de siempre):"
  caso "HOME con contexto" "$t/casa" "" marca-home
  caso "HOME sin contexto" "$t/casa-vacia" "" vacio
  echo "con CLAUDE_CONFIG_DIR lee el contexto/ de ese perfil y nunca el de HOME:"
  caso "perfil con contexto (ruta con espacio)" "$t/casa" "$t/perfil b" marca-perfil marca-home
  caso "perfil sin contexto no cae a HOME" "$t/casa" "$t/perfil-vacio" vacio
  caso "archivo vacío se omite" "$t/casa" "$t/perfil b" marca-perfil CONTEXTO-PERSONAL
  if command -v cygpath >/dev/null 2>&1; then
    echo "Windows: CLAUDE_CONFIG_DIR con diagonales invertidas, como lo deja PowerShell:"
    caso "perfil en ruta C:\\..." "$t/casa" "$(cygpath -w "$t/perfil b")" marca-perfil marca-home
  fi
fi
echo "sin python3 sale limpio:"
salida=$(PATH=/kc-sin-nada HOME="$t/casa" "$BASH" "$HOOK" 2>&1); rc=$?
if [ "$rc" -eq 0 ] && [ -z "$salida" ]; then echo "  ok    sin python3 → 0, nada"; else echo "  FALLA sin python3 → $rc: $salida"; fallos=$((fallos+1)); fi
echo; [ $fallos -eq 0 ] && echo "TODO OK" || { echo "$fallos fallos"; exit 1; }
