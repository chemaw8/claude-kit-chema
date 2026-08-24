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

# El encabezado va DENTRO del bucle (primer archivo encontrado): si no hay
# ningún archivo de contexto, no se imprime nada. Un encabezado solo haría
# creer que el contexto se cargó cuando no había nada que cargar —fallo
# silencioso sobre las reglas de confidencialidad (council v1.11, H-2).
salida=$(
  primero=1
  for f in "$HOME/.claude/contexto/CONTEXTO-EMPRESA.md" \
           "$HOME/.claude/contexto/CONTEXTO-PERSONAL.md" \
           "$HOME/.claude/contexto/BASE-CONOCIMIENTO.md"; do
    [ -f "$f" ] && [ -s "$f" ] || continue
    if [ "$primero" -eq 1 ]; then
      echo "# Contexto Kit Chema (cargado automáticamente al iniciar sesión)"
      primero=0
    fi
    echo; echo "=== $(basename "$f") ==="; cat "$f"
  done
)

# Nada que inyectar: se sale limpio y el núcleo pedirá el contexto por su cuenta.
[ -n "$salida" ] || exit 0

printf '%s' "$salida" | python3 -c 'import json, sys; texto = sys.stdin.read(); print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": texto}}, ensure_ascii=False))'
