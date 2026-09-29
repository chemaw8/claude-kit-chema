---
description: Copia las plantillas de contexto del Kit Chema (empresa y personal) a la carpeta contexto/ del perfil activo solo si no existen, sin pisar las tuyas, y te recuerda rellenarlas.
---

Tu tarea es dejar al usuario las plantillas de contexto del Kit Chema en
`${CLAUDE_CONFIG_DIR:-$HOME/.claude}/contexto/` sin sobrescribir nada de lo que
ya tenga escrito. Es la carpeta que lee el hook de contexto: la del perfil
activo, que es `~/.claude/contexto/` cuando `CLAUDE_CONFIG_DIR` no está definido.

Las plantillas están en `${CLAUDE_PLUGIN_ROOT}/contexto/` si el kit corre como
plugin o, si se instaló con `instalar.sh`, en `~/.claude/plantillas-kit/contexto/`.
Llámala `ORIGEN` de aquí en adelante.

Haz lo siguiente:

1. Crea esa carpeta si no existe.
2. Por cada `.md` en `ORIGEN`, cópialo a esa carpeta solo si en el destino no
   existe ya un archivo con ese nombre. Nunca sobrescribas uno existente: el
   contenido del usuario manda.

Comando sugerido (no destructivo, respeta lo que ya exista):

```bash
ORIGEN="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plantillas-kit}/contexto"
if ! ls "$ORIGEN"/*.md >/dev/null 2>&1; then
  echo "no encuentro las plantillas en $ORIGEN: vuelve a correr instalar.sh del kit"
  exit 1
fi
dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/contexto"
mkdir -p "$dir"
for f in "$ORIGEN"/*.md; do
  dest="$dir/$(basename "$f")"
  if [ -e "$dest" ]; then
    echo "ya existe, no se toca: $dest"
  else
    cp "$f" "$dest" && echo "instalada plantilla: $dest"
  fi
done
```

3. Al terminar, reporta qué archivos copiaste y cuáles ya existían, y recuerda
   al usuario que las plantillas vienen vacías (con `[corchetes]` de relleno):
   debe editar `CONTEXTO-EMPRESA.md` de esa carpeta y, si lo usa,
   `CONTEXTO-PERSONAL.md` con sus datos reales. Un campo vacío es mejor que
   relleno vacuo; la regla de oro es "¿si quito esta línea, Claude cometería un
   error? si no, sóbrala". La guía para llenarlos está en `COMO-PEDIR.md`.
