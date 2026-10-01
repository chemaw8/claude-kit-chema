#!/usr/bin/env bash
# Asistente público autónomo: también funciona al recibirlo por curl | bash.
set -euo pipefail

URL_KIT=https://github.com/chemaw8/claude-kit-chema.git
URL_ASISTENTE=https://raw.githubusercontent.com/chemaw8/claude-kit-chema/main/entorno/instalar.sh
URL_UV=https://astral.sh/uv/install.sh
PI_PAQUETE=@earendil-works/pi-coding-agent@0.87.0
perfil= entorno= si=0 dry=0 con_pi=0 con_proyectos=0
flags=("$@")
kit="$HOME/Trabajo/proyectos/claude-kit-chema"
privado="$HOME/Trabajo/proyectos/claude-entorno"
temporal=

uso() {
  printf '%s\n' 'Uso: bash entorno/instalar.sh [opciones]' \
    '  --perfil colega|completo   Sin flag, pregunta; con --si usa colega.' \
    '  --entorno dueño/repo       Repositorio del perfil completo, sin valor público por defecto.' \
    '  --dry-run                  Muestra el plan sin escribir ni ejecutar instalaciones.' \
    '  --si                       Sin preguntas; omite pi opcional y no abre logins.' \
    '  --con-proyectos            Se transmite al asistente del perfil completo.' \
    '  --help                     Muestra esta ayuda.'
}
error() { printf 'Error: %s\n' "$1" >&2; exit "${2:-1}"; }
comando() { local texto; printf -v texto '%q ' "$@"; printf '%s' "${texto% }"; }
preguntar() {
  printf '%s ' "$1" >&3
  IFS= read -r respuesta <&3 || error 'No se pudo leer /dev/tty. Vuelve a correr en una terminal o usa --si.' 2
}
aceptar() {
  preguntar "$1 [s/N]"
  case "$respuesta" in s|S|si|sí) return 0 ;; *) return 1 ;; esac
}

# Todas las preguntas propias usan el TTY, nunca el stdin que contiene el script.
configurar() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --perfil|--entorno)
        [ "$#" -ge 2 ] && [ -n "$2" ] && [[ "$2" != --* ]] || error 'Falta el valor de --perfil o --entorno.' 2
        if [ "$1" = --perfil ]; then perfil="$2"; else entorno="$2"; fi
        shift 2 ;;
      --si) si=1; shift ;;
      --dry-run) dry=1; shift ;;
      --con-proyectos) con_proyectos=1; shift ;;
      --help|-h) uso; exit 0 ;;
      *) error 'Opción desconocida. Consulta --help.' 2 ;;
    esac
  done
  if [ "$si" -eq 0 ]; then
    { exec 3<>/dev/tty; } 2>/dev/null && [ -t 3 ] ||
      error 'No hay TTY. Ejecuta en una terminal o agrega --si (y --entorno dueño/repo para completo).' 2
  fi
  if [ -z "$perfil" ]; then
    if [ "$si" -eq 0 ]; then preguntar 'Perfil [colega/completo] (colega):'; perfil="${respuesta:-colega}"
    else perfil=colega; fi
    flags+=(--perfil "$perfil")
  fi
  case "$perfil" in colega|completo) ;; *) error 'El perfil debe ser colega o completo.' 2 ;; esac
  if [ "$perfil" = completo ]; then
    if [ -z "$entorno" ]; then
      [ "$si" -eq 0 ] || error 'Con --si y perfil completo debes indicar --entorno dueño/repo.' 2
      preguntar 'Repositorio de tu entorno (dueño/repo):'; entorno="$respuesta"
      flags+=(--entorno "$entorno")
    fi
    [[ "$entorno" =~ ^[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9._-]+$ ]] &&
      [ "${entorno#*/}" != . ] && [ "${entorno#*/}" != .. ] ||
      error '--entorno debe tener el formato dueño/repo, sin URL ni credenciales.' 2
  elif [ -n "$entorno" ] || [ "$con_proyectos" -eq 1 ]; then
    error '--entorno y --con-proyectos requieren --perfil completo.' 2
  fi
  if [ "$si" -eq 0 ] && aceptar '¿Instalar pi opcional (versión 0.87.0)?'; then con_pi=1; fi

  if command -v pacman >/dev/null 2>&1; then
    gestor=pacman; paquetes=(git curl ca-certificates python nodejs npm github-cli jq)
    sistema=(pacman -Syu --needed --noconfirm "${paquetes[@]}")
  elif command -v apt-get >/dev/null 2>&1; then
    gestor=apt-get; paquetes=(git curl ca-certificates python3 nodejs npm gh jq)
    sistema=(apt-get install -y "${paquetes[@]}")
  elif command -v dnf >/dev/null 2>&1; then
    gestor=dnf; paquetes=(git curl ca-certificates python3 nodejs npm gh jq)
    sistema=(dnf install -y "${paquetes[@]}")
  else
    error 'Sistema no compatible: se necesita pacman, apt (apt-get) o dnf.' 2
  fi
  privilegio=(sudo)
  [ "$si" -eq 0 ] || privilegio+=(-n)
}

plan() {
  printf 'Perfil: %s. Se usará sudo solo para paquetes del sistema (%s).\n' "$perfil" "$gestor"
  [ "$gestor" != pacman ] || printf 'pacman actualizará el sistema para evitar una actualización parcial.\n'
  [ "$gestor" != apt-get ] || printf '  %s\n' "$(comando "${privilegio[@]}" apt-get update)"
  printf '  %s\n' "$(comando "${privilegio[@]}" "${sistema[@]}")"
  printf 'Se añadirá ~/.local/bin al PATH de esta sesión y de tus archivos de inicio.\n'
  printf 'Si faltan, se descargarán y ejecutarán el instalador oficial de uv y el paquete de Claude Code:\n'
  printf '  %s (UV_INSTALL_DIR=~/.local/bin, UV_NO_MODIFY_PATH=1)\n' "$URL_UV"
  printf '  %s\n' "$(comando npm i -g --prefix "$HOME/.local" @anthropic-ai/claude-code)"
  if [ "$con_pi" -eq 1 ]; then
    printf '  %s\n' "$(comando npm i -g --prefix "$HOME/.local" --ignore-scripts "$PI_PAQUETE")"
  else
    printf 'pi opcional: omitido. Sin --si puedes elegir instalarlo.\n'
  fi
  printf 'Se clonará el kit si falta y se ejecutará su instalador; los clones existentes no se actualizan ni sobrescriben:\n'
  printf '  %s\n  %s\n' "$(comando git clone "$URL_KIT" "$kit")" "$(comando bash "$kit/instalar.sh")"
  printf 'Se comprobará el login de Claude Code; sin --si se ofrecerá: claude auth login\n'
  if [ "$perfil" = completo ]; then
    printf 'Se comprobará GitHub; sin --si se ofrecerá: gh auth login --hostname github.com --git-protocol https --web\n'
    printf '  %s\n  exec %s\n' "$(comando gh repo clone "https://github.com/$entorno.git" "$privado")" \
      "$(comando bash "$privado/asistente.sh" "${flags[@]}")"
  fi
}

declare -a pasos=()
declare -A nombres=() hechos=() arreglos=()
registrar() { pasos+=("$1"); nombres[$1]="$2"; hechos[$1]=0; arreglos[$1]="$3"; }
semaforo() {
  local p
  printf '\nPara usar las herramientas o sus arreglos en tu terminal: export PATH="$HOME/.local/bin:$PATH"\n'
  printf 'Estado | Comprobación | Arreglo si falta\n'
  for p in "${pasos[@]}"; do
    if [ "${hechos[$p]}" -eq 1 ]; then printf '✓ | %s |\n' "${nombres[$p]}"
    else printf '✗ | %s | Arreglo: %s\n' "${nombres[$p]}" "${arreglos[$p]}"; fi
  done
}
cerrar() {
  local rc=$?
  trap - EXIT
  [ -z "$temporal" ] || rm -f -- "$temporal"
  semaforo
  [ "$rc" -eq 0 ] || printf 'No se completó la instalación. Corrige los pendientes y vuelve a ejecutar el asistente.\n' >&2
  exit "$rc"
}
ejecutar() { printf 'Ejecutando: %s\n' "$(comando "$@")"; "$@" </dev/null; }

preparar_path() {
  local archivo
  local linea='case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac'
  for archivo in "$HOME/.profile" "$HOME/.bashrc"; do
    if ! grep -qF '# kit-chema:entorno-path' "$archivo" 2>/dev/null; then
      printf '\n# kit-chema:entorno-path\n%s\n' "$linea" >> "$archivo"
    fi
  done
  case "${SHELL:-}" in
    */zsh)
      archivo="$HOME/.zshrc"
      if ! grep -qF '# kit-chema:entorno-path' "$archivo" 2>/dev/null; then
        printf '\n# kit-chema:entorno-path\n%s\n' "$linea" >> "$archivo"
      fi ;;
    */fish)
      archivo="${XDG_CONFIG_HOME:-$HOME/.config}/fish/conf.d/kit-chema-entorno.fish"
      mkdir -p -- "$(dirname "$archivo")"
      if ! grep -qF '# kit-chema:entorno-path' "$archivo" 2>/dev/null; then
        printf '\n# kit-chema:entorno-path\nfish_add_path --path "$HOME/.local/bin"\n' >> "$archivo"
      fi ;;
  esac
}

# Nunca se ejecuta un instalador de una carpeta que pertenece a otro repo.
validar_clon() {
  local destino="$1" repo="$2" paso="$3" raiz origen fisico
  if [ ! -e "$destino" ] && [ ! -L "$destino" ]; then return 0; fi
  printf -v arreglos["$paso"] 'respaldo=$(mktemp -d %q) && mv -- %q "$respaldo/" && %s' \
    "$destino.respaldo.XXXXXX" "$destino" "$reintento"
  raiz=$(git -C "$destino" rev-parse --show-toplevel 2>/dev/null) || error 'El destino existe pero no es un clon válido. No se tocó.'
  fisico=$(cd "$destino" && pwd -P) || error 'No se puede abrir el clon existente.'
  [ "$raiz" = "$fisico" ] || error 'El destino no es la raíz de su repositorio. No se tocó.'
  origen=$(git -C "$destino" remote get-url origin 2>/dev/null) || error 'El clon no tiene origin. No se tocó.'
  case "$origen" in
    "https://github.com/$repo"|"https://github.com/$repo.git"|"git@github.com:$repo"|"git@github.com:$repo.git"|"ssh://git@github.com/$repo.git") ;;
    *) error 'El origin del clon no corresponde al repositorio pedido. No se tocó.' ;;
  esac
  arreglos[$paso]="$reintento"
}
claude_autenticado() {
  claude auth status --json 2>/dev/null | python3 -c \
    'import json,sys; sys.exit(0 if json.load(sys.stdin).get("loggedIn") is True else 1)' >/dev/null 2>&1
}

main() {
  configurar "$@"
  plan
  if [ "$dry" -eq 1 ]; then printf '\nSimulacro: no se modificó nada ni se ejecutaron instalaciones o logins.\n'; return; fi
  if [ "$si" -eq 0 ] && ! aceptar '¿Continuar con este plan?'; then printf 'Cancelado sin cambios.\n'; return; fi

  reintento="$(comando curl -fsSL "$URL_ASISTENTE") | bash -s -- $(comando "${flags[@]}")"
  registrar sistema 'Paquetes del sistema y Node.js' "$reintento"
  registrar path 'PATH persistente (~/.local/bin)' "$reintento"
  registrar uv 'uv ejecutable' "$reintento"
  registrar claude 'Claude Code ejecutable' "$(comando npm i -g --prefix "$HOME/.local" @anthropic-ai/claude-code)"
  registrar kit 'Kit instalado y versión' "$reintento"
  registrar comandos 'Comandos del kit instalados' "$(comando bash "$kit/instalar.sh")"
  registrar autotest 'muletillas.sh autotest' "$(comando bash "$kit/instalar.sh") && $(comando bash "$HOME/.claude/scripts/muletillas.sh" autotest)"
  [ "$con_pi" -eq 0 ] || registrar pi 'pi 0.87.0 en PATH' "$(comando npm i -g --prefix "$HOME/.local" --ignore-scripts "$PI_PAQUETE")"
  registrar login 'Login de Claude Code' 'claude auth login'
  if [ "$perfil" = completo ]; then
    registrar github 'Login de GitHub' 'gh auth login --hostname github.com --git-protocol https --web'
    registrar privado 'Clon del entorno con asistente.sh' "$reintento"
  fi
  trap cerrar EXIT

  # No se hereda stdin a herramientas que pudieran consumir el script de la tubería.
  if ! command -v sudo >/dev/null 2>&1; then
    local instalar_sudo
    case "$gestor" in
      pacman) instalar_sudo='pacman -Syu --needed sudo' ;;
      apt-get) instalar_sudo='apt-get update && apt-get install sudo' ;;
      dnf) instalar_sudo='dnf install sudo' ;;
    esac
    arreglos[sistema]="$(comando su -c "$instalar_sudo") && $reintento"
    error 'Falta sudo. El arreglo requiere acceso de administrador; también debes tener permiso para usar sudo.'
  fi
  arreglos[sistema]="sudo -v && $reintento"
  if [ "$gestor" = apt-get ]; then ejecutar "${privilegio[@]}" apt-get update || error 'Falló la actualización del índice de paquetes.'; fi
  ejecutar "${privilegio[@]}" "${sistema[@]}" || error 'Falló la instalación de paquetes (con --si, sudo debe estar autorizado sin preguntas).'
  export PATH="$HOME/.local/bin:$PATH"
  local herramienta mayor minimo=18
  for herramienta in git curl python3 node npm gh; do
    command -v "$herramienta" >/dev/null 2>&1 || error "No quedó disponible el comando $herramienta."
  done
  [ "$con_pi" -eq 0 ] || minimo=20
  mayor=$(node -p 'Number(process.versions.node.split(".")[0])') || error 'Node.js no funciona.'
  if ! [[ "$mayor" =~ ^[0-9]+$ ]] || [ "$mayor" -lt "$minimo" ]; then
    arreglos[sistema]="$(comando npm i -g --prefix "$HOME/.local" node@22) && $reintento"
    error "Se necesita Node.js $minimo o posterior."
  fi
  hechos[sistema]=1
  preparar_path
  hechos[path]=1
  mkdir -p -- "$HOME/.local/bin" "$HOME/Trabajo/proyectos"
  if ! command -v uv >/dev/null 2>&1; then
    temporal=$(mktemp)
    ejecutar curl -fsSL "$URL_UV" -o "$temporal" || error 'Falló la descarga de uv; no se ejecutó el archivo parcial.'
    UV_INSTALL_DIR="$HOME/.local/bin" UV_NO_MODIFY_PATH=1 sh "$temporal" </dev/null || error 'Falló el instalador de uv.'
    rm -f -- "$temporal"; temporal=
  fi
  uv --version >/dev/null 2>&1 || error 'uv está presente pero no funciona.'
  hechos[uv]=1
  if ! command -v claude >/dev/null 2>&1; then
    ejecutar npm i -g --prefix "$HOME/.local" @anthropic-ai/claude-code || error 'Falló la instalación de Claude Code.'
  fi
  claude --version >/dev/null 2>&1 || error 'Claude Code está presente pero no funciona.'
  hechos[claude]=1

  export GIT_TERMINAL_PROMPT=0
  validar_clon "$kit" chemaw8/claude-kit-chema kit
  if [ ! -d "$kit" ]; then
    GIT_SSH_COMMAND='ssh -oBatchMode=yes -oStrictHostKeyChecking=yes' \
      ejecutar git clone "$URL_KIT" "$kit" || error 'No se pudo clonar el kit.'
  fi
  arreglos[kit]="$(comando git -C "$kit" pull --ff-only) && $reintento"
  [ -f "$kit/instalar.sh" ] || error 'El clon del kit no contiene instalar.sh.'
  CLAUDE_DIR="$HOME/.claude" KIT_HOOKS="${KIT_HOOKS:-n}" bash "$kit/instalar.sh" </dev/null || error 'Falló el instalador del kit.'
  local version archivo
  version=$(grep -m1 -oE 'Kit Chema v[0-9]+\.[0-9]+(\.[0-9]+)?' "$HOME/.claude/CLAUDE.md") || error 'No se encontró la versión del kit instalado.'
  nombres[kit]="$version instalado"; hechos[kit]=1
  for archivo in "$kit"/commands/*.md; do
    [ -s "$HOME/.claude/commands/${archivo##*/}" ] || error 'Falta un comando del kit.'
  done
  hechos[comandos]=1
  bash "$HOME/.claude/scripts/muletillas.sh" autotest >/dev/null || error 'Falló muletillas.sh autotest.'
  hechos[autotest]=1
  if [ "$con_pi" -eq 1 ]; then
    if ! command -v pi >/dev/null 2>&1 || [ "$(pi --version 2>/dev/null)" != 0.87.0 ]; then
      ejecutar npm i -g --prefix "$HOME/.local" --ignore-scripts "$PI_PAQUETE" || error 'Falló la instalación de pi.'
    fi
    [ "$(pi --version 2>/dev/null)" = 0.87.0 ] || error 'pi en PATH no corresponde a la versión 0.87.0.'
    hechos[pi]=1
  fi
  if ! claude_autenticado && [ "$si" -eq 0 ]; then
    if aceptar '¿Abrir el login de Claude Code en esta terminal?'; then
      claude auth login <&3 >&3 2>&3 || error 'Falló el login de Claude Code.'
    fi
  fi
  if claude_autenticado; then hechos[login]=1; fi
  if [ "$perfil" = colega ]; then
    [ "${hechos[login]}" -eq 1 ] || error 'Quedó pendiente el login de Claude Code.'
    return
  fi

  if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    [ "$si" -eq 0 ] || error 'Falta el login de GitHub; --si no abre autenticación interactiva.'
    aceptar '¿Abrir el login de GitHub en esta terminal?' || error 'Sin login de GitHub no se puede clonar el entorno.'
    gh auth login --hostname github.com --git-protocol https --web <&3 >&3 2>&3 || error 'Falló el login de GitHub.'
  fi
  gh auth status --hostname github.com >/dev/null 2>&1 || error 'GitHub sigue sin autenticación válida.'
  hechos[github]=1
  validar_clon "$privado" "$entorno" privado
  if [ ! -d "$privado" ]; then
    # HTTPS evita depender del protocolo SSH configurado en gh. Si git reescribe
    # la URL a SSH, BatchMode impide preguntas de clave o confianza del servidor.
    GH_PROMPT_DISABLED=1 GIT_SSH_COMMAND='ssh -oBatchMode=yes -oStrictHostKeyChecking=yes' \
      ejecutar gh repo clone "https://github.com/$entorno.git" "$privado" || error 'No se pudo clonar el entorno.'
  fi
  arreglos[privado]="$(comando git -C "$privado" pull --ff-only) && $reintento"
  [ -f "$privado/asistente.sh" ] || error 'El repositorio del entorno no contiene asistente.sh.'
  hechos[privado]=1
  # El asistente privado también comprueba y guía los logins pendientes.
  semaforo
  printf '\nSe entrega el control al asistente de tu entorno; su salida será el resultado final.\n'
  exec bash "$privado/asistente.sh" "${flags[@]}"
}

# Se lee y define todo antes de ejecutar: ningún hijo consume el resto de curl | bash.
main "$@"
