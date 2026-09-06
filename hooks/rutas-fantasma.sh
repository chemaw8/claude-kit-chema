#!/usr/bin/env bash
# Hook PreToolUse (Read|Write|Edit) del Kit Chema: bloquea rutas de OTRO entorno
# que el modelo a veces alucina en la máquina del usuario —/home/user,
# /mnt/user-data y /repo son del sandbox de claude.ai— y el Read de "/" a secas
# (siempre da EISDIR). Solo bloquea si el prefijo no existe en esta máquina: si
# de verdad tienes /home/user, el hook no estorba. Exit 2 = bloquear (stderr al
# modelo, con el cwd real). Si el JSON no se puede leer o falta python3, deja
# pasar: bloquear toda lectura sería peor que un error de ruta.
# Prefijos configurables (separados por espacio) con RUTAS_FANTASMA; lo usa el test.
set -uo pipefail
PREFIJOS="${RUTAS_FANTASMA:-/home/user /mnt/user-data /repo}"
input=$(cat)
leer=$(printf '%s' "$input" | python3 -c '
import json,sys
d=json.load(sys.stdin)
print(d.get("tool_input",{}).get("file_path","") or "")
print(d.get("cwd","") or "")' 2>/dev/null) || exit 0
ruta=$(printf '%s\n' "$leer" | sed -n 1p)
cwd=$(printf '%s\n' "$leer" | sed -n 2p)
[ -z "$ruta" ] && exit 0
if [ "$ruta" = "/" ]; then
  echo "Kit Chema: leer '/' es un directorio, no un archivo (da EISDIR). Estás en cwd=$cwd; usa Glob o 'ls' sobre la carpeta que buscas." >&2
  exit 2
fi
for p in $PREFIJOS; do
  case "$ruta" in
    "$p"|"$p"/*)
      [ -d "$p" ] && exit 0  # el prefijo sí existe aquí: ruta legítima
      echo "Kit Chema: '$ruta' empieza por '$p', que no existe en esta máquina (es una ruta típica del sandbox de claude.ai). Estás en cwd=$cwd (home=$HOME). Usa la ruta real —normalmente $cwd/<archivo>— o localízala con Glob/Grep antes de leer." >&2
      exit 2 ;;
  esac
done
exit 0
