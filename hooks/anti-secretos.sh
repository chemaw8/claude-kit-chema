#!/usr/bin/env bash
# Hook PreToolUse (Bash) del Kit Chema: bloquea git commit/push si el diff
# staged contiene patrones de credenciales. Exit 2 = bloquear (stderr al modelo).
set -uo pipefail
input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || echo "")
# Si python3 falla o no está disponible, usar el JSON crudo como comando: esto cierra el fallo-abierto (mejor un falso positivo que dejar de escanear).
if [ -z "$cmd" ] && [ -n "$input" ]; then
  cmd="$input"
fi
case "$cmd" in
  *"git commit"*|*"git push"*) ;;
  *) exit 0 ;;
esac
patron='(api[_-]?key|secret|token|passw(or)?d)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9_/+.-]{12,}|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
if git diff --cached 2>/dev/null | grep -E '^\+' | grep -qiE "$patron"; then
  echo "Kit Chema: el diff staged parece contener credenciales (clave API, token o llave privada). Revísalo y quítalas antes de commitear; si es un falso positivo, dilo y commitea con el hook desactivado." >&2
  exit 2
fi
exit 0
