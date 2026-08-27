#!/usr/bin/env bash
# Verifica los límites cuantitativos del Kit Chema (spec P1, P4).
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
fallas=0
total_desc=0

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
  total_desc=$((total_desc+n))
  [ "$n" -gt 0 ] && [ "$n" -lt 1024 ]; chk "$f description $n chars (0<n<1024)" $?
done

# 2b. Suma de descriptions: informativa siempre; aviso sin bloquear si > 6000.
# El presupuesto real del listado de skills es global (~16k chars sobre todas
# las instaladas, del kit y ajenas — issue claude-code#13099); un linter de repo
# solo ve las del kit: esto es higiene del footprint propio, no un blindaje.
echo "INFO  descriptions del kit suman $total_desc chars"
if [ "$total_desc" -gt 6000 ]; then
  echo "AVISO la suma rebasa 6000 chars: considera adelgazar antes de añadir más (no bloquea)"
fi

# 2c. license: declarada en el frontmatter de cada skill (estándar agentskills.io)
for f in skills/*/SKILL.md; do
  [ -e "$f" ] || continue
  grep -q '^license:' "$f"; chk "$f declara license: en frontmatter" $?
done

# 3. SKILL.md < 5000 palabras
for f in skills/*/SKILL.md; do
  [ -e "$f" ] || continue
  palabras=$(wc -w < "$f")
  [ "$palabras" -lt 5000 ]; chk "$f tiene $palabras palabras (< 5000)" $?
done

# 3b. Subagentes: los que el núcleo promete tienen que existir, ser válidos y
# ser instalables. Sin esto el kit puede anunciar agentes que nadie instala
# (council v1.11, hallazgo H-1: instalar.sh no copiaba agents/).
prometidos=$(awk '/^Agentes listos del kit:/,/^$/' nucleo/CLAUDE.md | grep -oE '`[a-z-]+`' | tr -d '`' | sort -u)
for nombre in $prometidos; do
  f="agents/$nombre.md"
  [ -f "$f" ]; chk "el núcleo promete '$nombre' y existe $f" $?
done
for f in agents/*.md; do
  [ -e "$f" ] || continue
  fm=$(awk '/^---$/{c++;next} c==1' "$f")
  # name coincide con el nombre de archivo
  nm=$(printf '%s\n' "$fm" | awk '/^name:/{sub(/^name:[ ]*/,"");print;exit}')
  [ "$nm" = "$(basename "$f" .md)" ]; chk "$f name '$nm' coincide con el archivo" $?
  # model válido
  mdl=$(printf '%s\n' "$fm" | awk '/^model:/{sub(/^model:[ ]*/,"");print;exit}')
  case "$mdl" in haiku|sonnet|opus|fable|inherit) ok=0 ;; *) ok=1 ;; esac
  chk "$f model '$mdl' es válido" $ok
  # description presente y < 1024 chars (mismo presupuesto que las skills)
  d=$(printf '%s\n' "$fm" | awk '/^description:/{sub(/^description:[ ]*/,"");print;exit}')
  n=${#d}
  [ "$n" -gt 0 ] && [ "$n" -lt 1024 ]; chk "$f description $n chars (0<n<1024)" $?
done
# el instalador debe copiar agents/ (si no, los agentes nunca llegan a ~/.claude)
grep -q 'DIR/agents' instalar.sh; chk "instalar.sh instala agents/" $?

# 3c. Comandos y scripts: mismo riesgo que los agentes — el kit puede publicar
# comandos que el instalador nunca copia (pasó con /revisar-salud hasta v1.13).
grep -q 'DIR/commands' instalar.sh; chk "instalar.sh instala commands/" $?
grep -q 'DIR/scripts' instalar.sh;  chk "instalar.sh instala scripts/" $?

for f in commands/*.md; do
  [ -e "$f" ] || continue
  d=$(awk '/^---$/{c++;next} c==1 && /^description:/{sub(/^description:[ ]*/,"");print;exit}' "$f")
  n=${#d}
  [ "$n" -gt 0 ] && [ "$n" -lt 1024 ]; chk "$f description $n chars (0<n<1024)" $?
done

# Los comandos no deben invocar skills que ya no existen (referencia muerta).
# Se extrae CUALQUIER token kit-<algo> (no solo el fraseo literal 'skill kit-x':
# también entre backticks, con Skill(...), etc.) y se compara contra skills/. La
# lista blanca cubre los kit-* que NO son skills (el kit mismo, el hook).
SKILL_WHITELIST="kit-chema kit-chema-contexto"
for f in commands/*.md; do
  [ -e "$f" ] || continue
  muertas=0
  for s in $(grep -oE 'kit-[a-z]+(-[a-z]+)*' "$f" | sort -u); do
    case " $SKILL_WHITELIST " in *" $s "*) continue;; esac
    [ -d "skills/$s" ] || { echo "      $f menciona la skill inexistente '$s'"; muertas=1; }
  done
  chk "$f no invoca skills inexistentes" $muertas
done

# Los scripts auxiliares deben ser ejecutables y pasar su propia prueba.
for f in scripts/*.sh; do
  [ -e "$f" ] || continue
  [ -x "$f" ]; chk "$f es ejecutable" $?
  if grep -q '^  autotest)' "$f"; then
    bash "$f" autotest >/dev/null 2>&1; chk "$f pasa su autotest" $?
  fi
done

# 4. Sin gritos: mayúsculas de énfasis prohibidas en contenido instalable
if grep -rnE '(CRITICAL|IMPORTANTE:|OBLIGATORIO:|NUNCA HAGAS|SIEMPRE DEBES)' nucleo/ skills/ agents/ 2>/dev/null | grep -v ':#'; then
  chk "sin énfasis gritado en nucleo/, skills/ y agents/" 1
else
  chk "sin énfasis gritado en nucleo/, skills/ y agents/" 0
fi

exit $fallas
