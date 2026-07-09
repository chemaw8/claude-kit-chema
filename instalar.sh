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
elif grep -qF "$INI" "$destino"; then
  awk -v ini="$INI" -v fin="$FIN" -v bloque="$bloque" '
    $0==ini {dentro=1; print bloque; next}
    $0==fin {dentro=0; next}
    !dentro {print}' "$destino" > "$destino.tmp" && mv "$destino.tmp" "$destino"
  echo "núcleo: sección kit-chema actualizada a $VER"
else
  printf '\n%s\n' "$bloque" >> "$destino"
  echo "núcleo: añadido al final de tu CLAUDE.md existente (no se tocó tu contenido)"
fi

# 2. Skills (solo las del kit; sobrescribe únicamente kit-*)
for d in "$KIT"/skills/kit-*/; do
  nombre=$(basename "$d")
  rm -rf "$DIR/skills/$nombre"
  cp -r "$d" "$DIR/skills/$nombre"
  echo "skill: $nombre"
done

# 3. Contexto: solo si no existe (es del usuario)
if [ ! -f "$DIR/contexto/CONTEXTO-EMPRESA.md" ]; then
  cp "$KIT/contexto/CONTEXTO-EMPRESA.md" "$DIR/contexto/"
  echo "contexto: plantilla instalada — edítala con tus datos"
else
  echo "contexto: ya existe, no se toca"
fi

# 4. Hooks: opt-in
resp="${KIT_HOOKS:-}"
if [ -z "$resp" ] && [ -t 0 ]; then
  read -r -p "¿Instalar hook anti-secretos (bloquea commits con credenciales)? [s/N] " resp || resp=""
fi
if [ "${resp,,}" = "s" ]; then
  cp "$KIT/hooks/anti-secretos.sh" "$DIR/hooks/" && chmod +x "$DIR/hooks/anti-secretos.sh"
  python3 - "$DIR/settings.json" "$KIT/hooks/settings-fragment.json" <<'PY'
import json, sys, os
destino, fragmento = sys.argv[1], sys.argv[2]
s = json.load(open(destino)) if os.path.exists(destino) else {}
f = json.load(open(fragmento))
hooks = s.setdefault("hooks", {})
for evento, entradas in f["hooks"].items():
    actuales = hooks.setdefault(evento, [])
    for e in entradas:
        if e not in actuales:
            actuales.append(e)
json.dump(s, open(destino, "w"), indent=2, ensure_ascii=False)
PY
  echo "hooks: anti-secretos activado"
else
  echo "hooks: omitidos (KIT_HOOKS=s ./instalar.sh para activarlos)"
fi

echo
echo "Kit Chema $VER instalado en $DIR. Verifica: abre una conversación nueva y pide un deck — Claude debe preguntar audiencia y objetivo."
