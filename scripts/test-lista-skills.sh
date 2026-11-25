#!/usr/bin/env bash
# Prueba del paso «lista de skills» de instalar.sh con un CLAUDE_DIR temporal (sin tocar ~/.claude).
set -uo pipefail
cd "$(dirname "$0")/.."
f=0
corre() { CLAUDE_DIR="$1" KIT_LISTA="${2:-s}" bash instalar.sh >/dev/null 2>&1; python3 -c "import json;print(json.load(open('$1/settings.json')).get('skillListingBudgetFraction'))" 2>/dev/null; }
chk() { if [ "$2" = "$3" ]; then echo "✓ $1"; else echo "✗ $1 (esperaba $3, salió $2)"; f=$((f+1)); fi; }
d=$(mktemp -d); chk "sin settings.json queda en 0.02" "$(corre "$d")" 0.02; rm -rf "$d"
d=$(mktemp -d); echo '{"skillListingBudgetFraction":0.05}' > "$d/settings.json"; chk "un valor mayor se respeta" "$(corre "$d")" 0.05; rm -rf "$d"
d=$(mktemp -d); echo '{"skillListingBudgetFraction":"0.05"}' > "$d/settings.json"; chk "un valor mayor como texto se respeta" "$(corre "$d")" 0.05; rm -rf "$d"
d=$(mktemp -d); echo '{"skillListingBudgetFraction":0.01}' > "$d/settings.json"; chk "un valor menor sube a 0.02" "$(corre "$d")" 0.02; rm -rf "$d"
d=$(mktemp -d); echo '{}' > "$d/settings.json"; chk "KIT_LISTA=n no lo toca" "$(corre "$d" n)" None; rm -rf "$d"
[ "$f" -eq 0 ] && echo "lista de skills: todo en verde"
exit "$f"
