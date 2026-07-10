#!/usr/bin/env bash
# Instalador del Kit Chema. No destructivo: nunca pisa contenido ajeno.
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="${CLAUDE_DIR:-$HOME/.claude}"
INI="<!-- kit-chema:inicio -->"
FIN="<!-- kit-chema:fin -->"
VER=$(grep -m1 -oE '## v[0-9]+\.[0-9]+' "$KIT/CHANGELOG.md" | cut -d' ' -f2)

mkdir -p "$DIR" "$DIR/skills" "$DIR/contexto" "$DIR/hooks"

# 1. Núcleo dentro de marcadores
bloque=$(printf '%s\n<!-- Kit Chema %s — no editar dentro de los marcadores; se actualiza con instalar.sh -->\n%s\n%s' "$INI" "$VER" "$(cat "$KIT/nucleo/CLAUDE.md")" "$FIN")
destino="$DIR/CLAUDE.md"
if [ ! -f "$destino" ]; then
  printf '%s\n' "$bloque" > "$destino"
  echo "núcleo: instalado (nuevo $destino)"
else
  ini_n=$(grep -nxF "$INI" "$destino" | cut -d: -f1 || true)
  fin_n=$(grep -nxF "$FIN" "$destino" | cut -d: -f1 || true)
  if [ -z "$ini_n" ]; then ini_count=0
  elif [[ "$ini_n" == *$'\n'* ]]; then ini_count=2
  else ini_count=1
  fi
  if [ -z "$fin_n" ]; then fin_count=0
  elif [[ "$fin_n" == *$'\n'* ]]; then fin_count=2
  else fin_count=1
  fi

  if [ "$ini_count" -eq 0 ] && [ "$fin_count" -eq 0 ]; then
    # Sin marcadores (o solo como subcadena dentro de otra línea): se añade al final.
    printf '\n%s\n' "$bloque" >> "$destino"
    echo "núcleo: añadido al final de tu CLAUDE.md existente (no se tocó tu contenido)"
  elif [ "$ini_count" -eq 1 ] && [ "$fin_count" -eq 1 ] && [ "$fin_n" -gt "$ini_n" ]; then
    cp "$destino" "$destino.pre-kit-chema.bak"
    { head -n $((ini_n-1)) "$destino"; printf '%s\n' "$bloque"; tail -n +$((fin_n+1)) "$destino"; } > "$destino.tmp" && mv "$destino.tmp" "$destino"
    echo "núcleo: sección kit-chema actualizada a $VER"
    echo "núcleo: respaldo del archivo anterior guardado en $destino.pre-kit-chema.bak"
  else
    echo "núcleo: ERROR — los marcadores de Kit Chema en $destino están mal formados." >&2
    echo "Se esperaba encontrar, cada uno en su propia línea completa y exactamente una vez," >&2
    echo "primero '$INI' y más abajo '$FIN'." >&2
    echo "No se ha modificado ningún archivo. Corrige a mano los marcadores en $destino" >&2
    echo "(añade el que falte, elimina duplicados, o pon '$INI' antes de '$FIN') y vuelve a ejecutar instalar.sh." >&2
    exit 1
  fi
fi

# 2. Skills (solo las del kit; sobrescribe únicamente kit-*)
for d in "$KIT"/skills/kit-*/; do
  nombre=$(basename "$d")
  rm -rf "$DIR/skills/$nombre"
  cp -r "$d" "$DIR/skills/$nombre"
  echo "skill: $nombre"
done

# 3. Contexto: cada plantilla solo si no existe (son del usuario)
for plantilla in "$KIT"/contexto/*.md; do
  nombre=$(basename "$plantilla")
  if [ ! -f "$DIR/contexto/$nombre" ]; then
    cp "$plantilla" "$DIR/contexto/"
    echo "contexto: plantilla $nombre instalada — edítala con tus datos"
  else
    echo "contexto: $nombre ya existe, no se toca"
  fi
done

# 4. Hooks. Fusiona en $DIR/settings.json solo los eventos indicados del
# fragmento, sin pisar hooks que ya tengas y sin duplicar si ya están.
fusionar_hooks() { # fusionar_hooks <evento> [evento...]
  python3 - "$DIR/settings.json" "$KIT/hooks/settings-fragment.json" "$@" <<'PY'
import json, sys, os
destino, fragmento = sys.argv[1], sys.argv[2]
solo = set(sys.argv[3:])  # eventos a fusionar; si va vacío, se fusionan todos
s = json.load(open(destino)) if os.path.exists(destino) else {}
f = json.load(open(fragmento))
hooks = s.setdefault("hooks", {})
for evento, entradas in f["hooks"].items():
    if solo and evento not in solo:
        continue
    actuales = hooks.setdefault(evento, [])
    for e in entradas:
        if e not in actuales:
            actuales.append(e)
json.dump(s, open(destino, "w"), indent=2, ensure_ascii=False)
PY
}

# 4a. Hook de contexto (SessionStart): por defecto. Es de bajo riesgo (solo
# inyecta texto al arrancar) y alto valor (Claude arranca con tu contexto).
if command -v python3 >/dev/null 2>&1; then
  cp "$KIT/hooks/kit-chema-contexto.sh" "$DIR/hooks/" && chmod +x "$DIR/hooks/kit-chema-contexto.sh"
  fusionar_hooks SessionStart
  echo "hook contexto: instalado (SessionStart autocarga tu contexto al abrir sesión)"
else
  echo "hook contexto: omitido — necesita python3 para fusionar settings.json y no se encontró en este sistema."
  echo "hook contexto: instala python3 y vuelve a correr ./instalar.sh para activarlo."
fi

# 4b. Hook anti-secretos (PreToolUse): opt-in, sigue preguntando.
resp="${KIT_HOOKS:-}"
if [ -z "$resp" ] && [ -t 0 ]; then
  read -r -p "¿Instalar hook anti-secretos (bloquea commits con credenciales)? [s/N] " resp || true
fi
activar_hooks=0
case "$resp" in
  [sS]) activar_hooks=1 ;;
esac

if [ "$activar_hooks" -eq 1 ] && ! command -v python3 >/dev/null 2>&1; then
  echo "hook anti-secretos: omitido — necesita python3 para fusionar settings.json y no se encontró en este sistema."
  echo "hook anti-secretos: instala python3 y vuelve a correr KIT_HOOKS=s ./instalar.sh para activarlo."
elif [ "$activar_hooks" -eq 1 ]; then
  cp "$KIT/hooks/anti-secretos.sh" "$DIR/hooks/" && chmod +x "$DIR/hooks/anti-secretos.sh"
  fusionar_hooks PreToolUse
  echo "hook anti-secretos: activado"
else
  echo "hook anti-secretos: omitido (KIT_HOOKS=s ./instalar.sh para activarlo)"
fi

echo
echo "Kit Chema $VER instalado en $DIR. Verifica: abre una conversación nueva y pide un deck — Claude debe preguntar audiencia y objetivo."
