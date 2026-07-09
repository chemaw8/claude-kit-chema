#!/usr/bin/env bash
# Verifica los límites cuantitativos del Kit Chema (spec P1, P4).
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
fallas=0

chk() { # chk <descripcion> <condicion(0=ok)>
  if [ "$2" -eq 0 ]; then echo "OK    $1"; else echo "FALLA $1"; fallas=1; fi
}

# 1. Núcleo < 150 líneas
if [ -f nucleo/CLAUDE.md ]; then
  lineas=$(wc -l < nucleo/CLAUDE.md)
  [ "$lineas" -lt 150 ]; chk "nucleo/CLAUDE.md tiene $lineas líneas (< 150)" $?
fi

# 2. Descriptions < 1024 caracteres (las frases gatillo se validan aparte, con jueces)
for f in skills/*/SKILL.md; do
  [ -e "$f" ] || continue
  desc=$(awk '/^description:/{sub(/^description:[ ]*/,""); gsub(/^["'"'"']|["'"'"']$/,""); print; exit}' "$f")
  n=${#desc}
  [ "$n" -gt 0 ] && [ "$n" -lt 1024 ]; chk "$f description $n chars (0<n<1024)" $?
done

# 3. SKILL.md < 5000 palabras
for f in skills/*/SKILL.md; do
  [ -e "$f" ] || continue
  palabras=$(wc -w < "$f")
  [ "$palabras" -lt 5000 ]; chk "$f tiene $palabras palabras (< 5000)" $?
done

# 4. Sin gritos: mayúsculas de énfasis prohibidas en contenido instalable
if grep -rnE '(CRITICAL|IMPORTANTE:|OBLIGATORIO:|NUNCA HAGAS|SIEMPRE DEBES)' nucleo/ skills/ 2>/dev/null | grep -v ':#'; then
  chk "sin énfasis gritado en nucleo/ y skills/" 1
else
  chk "sin énfasis gritado en nucleo/ y skills/" 0
fi

exit $fallas
