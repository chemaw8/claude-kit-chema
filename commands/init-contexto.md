---
description: Copia las plantillas de contexto del Kit Chema (empresa y personal) a ~/.claude/contexto/ solo si no existen, sin pisar las tuyas, y te recuerda rellenarlas.
---

Tu tarea es dejar al usuario las plantillas de contexto del Kit Chema en
`~/.claude/contexto/` sin sobrescribir nada de lo que ya tenga escrito.

Las plantillas viajan dentro de este plugin, en `${CLAUDE_PLUGIN_ROOT}/contexto/`.

Haz lo siguiente:

1. Crea `~/.claude/contexto/` si no existe.
2. Por cada `.md` en `${CLAUDE_PLUGIN_ROOT}/contexto/`, cópialo a
   `~/.claude/contexto/` solo si en el destino no existe ya un archivo con ese
   nombre. Nunca sobrescribas uno existente: el contenido del usuario manda.

Comando sugerido (no destructivo, respeta lo que ya exista):

```bash
mkdir -p ~/.claude/contexto
for f in "${CLAUDE_PLUGIN_ROOT}"/contexto/*.md; do
  dest=~/.claude/contexto/"$(basename "$f")"
  if [ -e "$dest" ]; then
    echo "ya existe, no se toca: $dest"
  else
    cp "$f" "$dest" && echo "instalada plantilla: $dest"
  fi
done
```

3. Al terminar, reporta qué archivos copiaste y cuáles ya existían, y recuerda
   al usuario que las plantillas vienen vacías (con `[corchetes]` de relleno):
   debe editar `~/.claude/contexto/CONTEXTO-EMPRESA.md` y, si lo usa,
   `CONTEXTO-PERSONAL.md` con sus datos reales. Un campo vacío es mejor que
   relleno vacuo; la regla de oro es "¿si quito esta línea, Claude cometería un
   error? si no, sóbrala". La guía para llenarlos está en `COMO-PEDIR.md`.
