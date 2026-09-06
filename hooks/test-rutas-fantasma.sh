#!/usr/bin/env bash
# Prueba de hooks/rutas-fantasma.sh. Uso: bash hooks/test-rutas-fantasma.sh [ruta-al-hook]
# Independiente de la máquina: usa un prefijo inventado (/kc-fantasma) para los
# bloqueos y /tmp (existe en todas) para comprobar que un prefijo real deja pasar.
HOOK="${1:-$(dirname "${BASH_SOURCE[0]}")/rutas-fantasma.sh}"
fallos=0
caso() { # tool ruta exit_esperado
  local salida rc
  salida=$(printf '{"session_id":"t","cwd":"/home/alguien/proyecto","tool_name":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2" | RUTAS_FANTASMA="/kc-fantasma /tmp" bash "$HOOK" 2>&1); rc=$?
  if [ "$rc" -eq "$3" ]; then echo "  ok    $1 $2 → $rc"; else echo "  FALLA $1 $2 → $rc (esperaba $3): $salida"; fallos=$((fallos+1)); fi
}
echo "bloquea rutas a un prefijo que no existe en esta máquina:"
caso Read  /kc-fantasma/scripts/guardian.py 2
caso Read  /kc-fantasma 2
caso Write /kc-fantasma/uploads/.claude/settings.json 2
caso Edit  /kc-fantasma/a/b.py 2
caso Read  / 2
echo "deja pasar si el prefijo sí existe (/tmp) o no coincide:"
caso Read  /tmp/archivo-que-no-existe.txt 0
caso Read  /kc-fantasmagoria/x 0
caso Write /home/alguien/proyecto/salida.md 0
echo "prefijos por defecto (solo si no existen aquí):"
for p in /home/user /mnt/user-data /repo; do
  if [ -d "$p" ]; then echo "  skip  $p existe en esta máquina"; continue; fi
  salida=$(printf '{"cwd":"/x","tool_name":"Read","tool_input":{"file_path":"%s/a.py"}}' "$p" | bash "$HOOK" 2>&1); rc=$?
  if [ "$rc" -eq 2 ]; then echo "  ok    Read $p/a.py → 2"; else echo "  FALLA Read $p/a.py → $rc"; fallos=$((fallos+1)); fi
done
echo "no estorba si no hay file_path o el JSON viene roto:"
rc=$(printf '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | bash "$HOOK" >/dev/null 2>&1; echo $?); [ "$rc" = 0 ] && echo "  ok    sin file_path → 0" || { echo "  FALLA sin file_path → $rc"; fallos=$((fallos+1)); }
rc=$(printf 'no-es-json' | bash "$HOOK" >/dev/null 2>&1; echo $?); [ "$rc" = 0 ] && echo "  ok    json roto → 0" || { echo "  FALLA json roto → $rc"; fallos=$((fallos+1)); }
echo "el mensaje de bloqueo dice el cwd real:"
msg=$(printf '{"cwd":"/home/alguien/proyecto","tool_name":"Read","tool_input":{"file_path":"/kc-fantasma/a.py"}}' | RUTAS_FANTASMA="/kc-fantasma" bash "$HOOK" 2>&1)
echo "$msg" | grep -q "/home/alguien/proyecto" && echo "  ok    menciona cwd" || { echo "  FALLA no menciona cwd: $msg"; fallos=$((fallos+1)); }
echo; [ $fallos -eq 0 ] && echo "TODO OK" || { echo "$fallos fallos"; exit 1; }
