#!/usr/bin/env bash
# Kit Chema — hook SessionStart.
# Inyecta el contexto (empresa, personal y base de conocimiento) al iniciar
# cada sesión, para no depender de que Claude recuerde leerlo. Cierra el hueco
# de la regla "leer el contexto antes de un trabajo sustantivo".
#
# Envuelve el texto en JSON con python3 (json.dumps), no con jq, para ser
# consistente con el resto del kit y no añadir una dependencia extra.
# Falla segura: si python3 no está disponible, sale 0 sin imprimir nada y la
# sesión arranca normal (solo pierde la autocarga, no se rompe).
set -uo pipefail

# Sin python3 no se puede construir el JSON: se sale limpio (exit 0).
command -v python3 >/dev/null 2>&1 || exit 0

{
  echo "# Contexto Kit Chema (cargado automáticamente al iniciar sesión)"
  for f in "$HOME/.claude/contexto/CONTEXTO-EMPRESA.md" \
           "$HOME/.claude/contexto/CONTEXTO-PERSONAL.md" \
           "$HOME/.claude/contexto/BASE-CONOCIMIENTO.md"; do
    [ -f "$f" ] && { echo; echo "=== $(basename "$f") ==="; cat "$f"; }
  done
} | python3 -c 'import json, sys; texto = sys.stdin.read(); print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": texto}}, ensure_ascii=False))'
