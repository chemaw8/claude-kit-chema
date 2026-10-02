#!/usr/bin/env bash
# por-que.sh — evidencia local para /por-que; no interpreta ni usa la red.
# Adaptado de `why` y `recall` de pstack, Lauren Tan, MIT (fae2c6e).
# Uso: por-que.sh <objetivo> [--repo DIR] | autotest
# Salida: 0 = consulta completa (puede estar vacía); 2 = uso o lectura fallida.
set -uo pipefail

motor() {
  python3 -I - "$@" <<'PY'
import collections
import os
from pathlib import Path
import re
import stat
import subprocess
import sys

LOG_MAX, HISTORIA_MAX, BLAME_MAX = 20, 500, 10
GREP_MAX, DOC_MAX, VAULT_MAX, TEXTO_MAX = 40, 30, 40, 300
# Una sola política para rutas locales y pathspecs de git. Se excluyen TODAS
# las sesiones y JSONL, aunque alguno no sea una transcripción. Sin symlinks.
EXCLUIDAS = ('.git', '.codex', 'sessions', 'transcripts', 'agent-transcripts')
SECUENCIAS = (('.claude', 'projects'), ('.pi', 'agent', 'sessions'))

class ErrorConsulta(Exception):
    pass

def visible(texto, limite=None):
    texto = ''.join(c if c.isprintable() else repr(c)[1:-1] for c in texto)
    if limite is not None and len(texto) > limite:
        return texto[:limite] + ' … [línea truncada]'
    return texto

def permitida(ruta):
    partes = tuple(p.casefold() for p in ruta.parts)
    if any(p in EXCLUIDAS or p.endswith('.jsonl') for p in partes):
        return False
    for sec in SECUENCIAS:
        if any(partes[i:i + len(sec)] == sec for i in range(len(partes))):
            return False
    # Nunca seguir un enlace, ni cuando es un directorio padre o la raíz.
    return not any(p.is_symlink() for p in (ruta, *ruta.parents))

def regular(ruta):
    if not permitida(ruta):
        return False
    try:
        return stat.S_ISREG(ruta.lstat().st_mode)
    except FileNotFoundError:
        return False

def git(repo, *args, aceptados=(0,), entrada=None):
    env = os.environ.copy()
    # Incluso un clon parcial debe fallar por objeto ausente, no ir a la red.
    env.update(GIT_NO_LAZY_FETCH='1', GIT_ALLOW_PROTOCOL='',
               GIT_TERMINAL_PROMPT='0', GIT_OPTIONAL_LOCKS='0')
    for clave in ('GIT_DIR', 'GIT_WORK_TREE', 'GIT_INDEX_FILE', 'GIT_EXTERNAL_DIFF',
                  'GIT_LITERAL_PATHSPECS', 'GIT_GLOB_PATHSPECS', 'GIT_NOGLOB_PATHSPECS',
                  'GIT_ICASE_PATHSPECS'):
        env.pop(clave, None)
    p = subprocess.run(['git', '-C', str(repo), '-c', 'core.fsmonitor=false',
                        '-c', 'color.ui=false', '-c', 'log.showSignature=false',
                        '--no-pager', *args],
                       input=entrada, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                       env=env, timeout=30)
    if p.returncode not in aceptados:
        detalle = visible(p.stderr.decode('utf-8', 'replace').strip(), TEXTO_MAX)
        raise ErrorConsulta(f'git {args[0]} falló (rc={p.returncode}): {detalle}')
    return p.stdout

def literal(ruta):
    return ':(top,literal)' + ruta

def exclusiones_git():
    patrones = [f'**/{p}/**' for p in EXCLUIDAS]
    patrones += ['**/' + '/'.join(s) + '/**' for s in SECUENCIAS]
    patrones += ['**/*.jsonl']
    return [':(top,glob,exclude,icase)' + p for p in patrones]

def cita_commit(linea):
    h, fecha, asunto = linea.decode('utf-8', 'replace').split('\t', 2)
    return f'git {h} | {fecha} | {visible(asunto, TEXTO_MAX)}'

def historial(repo, args, fuente):
    datos = git(repo, 'log', '--no-ext-diff', '--no-textconv',
                f'-n{LOG_MAX + 1}', '--format=%h%x09%cs%x09%s', *args).splitlines()
    for linea in datos[:LOG_MAX]:
        print(f'[{cita_commit(linea)}]')
    if not datos:
        print(f'[{fuente}] sin coincidencias en {fuente}')
    if len(datos) > LOG_MAX:
        print(f'[{fuente}] truncado: primeras {LOG_MAX} coincidencias')

def historia_archivo(repo, ruta, existe):
    # Antes de pedir contenido a blame, revisar TODOS los nombres anteriores
    # (solo metadatos). El tope de presentación no puede ocultar un alias prohibido.
    cambios = git(repo, 'log', '--follow', '--no-ext-diff', '--no-textconv',
                  '--format=', '--name-status', '-z', '--diff-filter=RC',
                  'HEAD', '--', literal(ruta)).split(b'\0')
    i = 0
    while i < len(cambios) and cambios[i]:
        if not re.fullmatch(rb'[RC]\d+', cambios[i]):
            raise ErrorConsulta('no se pudieron comprobar los nombres históricos')
        for alias in cambios[i + 1:i + 3]:
            if not permitida(repo / os.fsdecode(alias)):
                raise ErrorConsulta('historia cruza una ruta excluida; no se consulta blame')
        i += 3
    nombre = visible(ruta)
    print(f'\n## git log --follow: {nombre} (máximo {LOG_MAX}; desde HEAD)')
    historial(repo, ['--follow', 'HEAD', '--', literal(ruta)], 'git log --follow')
    print(f'\n## git blame: {nombre} (árbol de trabajo; máximo {BLAME_MAX} commits)')
    en_head = git(repo, 'ls-tree', '-z', 'HEAD', '--', literal(ruta))
    if not existe or not en_head:
        print('[git blame] sin líneas actuales atribuibles: archivo ausente o sin archivo en HEAD')
        return
    datos = git(repo, 'blame', '--no-textconv', '--line-porcelain', '--', ruta)
    cuentas, primeras = collections.Counter(), {}
    for linea in datos.splitlines():
        m = re.fullmatch(rb'([0-9a-f]{40,64}) \d+ (\d+)(?: \d+)?', linea)
        if m:
            h = m[1].decode('ascii')
            cuentas[h] += 1
            primeras.setdefault(h, int(m[2]))
    for h, cantidad in cuentas.most_common(BLAME_MAX):
        if set(h) == {'0'}:
            cita = 'sin commit | sin fecha de commit | cambios locales'
        else:
            cita = cita_commit(git(repo, 'show', '-s', '--format=%h%x09%cs%x09%s', h).rstrip(b'\n'))
        print(f'[{cita}; {nombre}:{primeras[h]}] {cantidad} líneas')
    if not cuentas:
        print('[git blame] sin líneas: archivo vacío')
    if len(cuentas) > BLAME_MAX:
        print(f'[git blame] truncado: {BLAME_MAX} de {len(cuentas)} commits contribuyentes')

def borrado_en_historia(repo, ruta):
    # Un archivo que ya no existe sigue teniendo historia: sin esto caía a -S, que busca contenido y no nombres
    # (council v1.30, hallazgo de council-codex). Solo cuenta si se borró exactamente esa ruta, no algo bajo ella.
    datos = git(repo, 'log', '-1', '--diff-filter=D', '--no-renames', '-z', '--name-only', '--format=',
                'HEAD', '--', literal(ruta))
    return os.fsencode(ruta) in re.split(rb'[\0\n]', datos)

def buscar_git(repo, objetivo, rastreados):
    print(f'\n## git log -S (literal; máximo {HISTORIA_MAX} commits de HEAD y {LOG_MAX} coincidencias)')
    commits = git(repo, 'rev-list', f'--max-count={HISTORIA_MAX + 1}', 'HEAD').splitlines()
    # --no-walk + --stdin limita los commits examinados, no solo los hallazgos.
    datos = git(repo, 'log', '--no-walk=unsorted', '--stdin', '--no-ext-diff',
                '--no-textconv', '--no-renames', f'-n{LOG_MAX + 1}',
                '--format=%h%x09%cs%x09%s', '-S' + objetivo,
                '--', '.', *exclusiones_git(),
                entrada=b'\n'.join(commits[:HISTORIA_MAX]) + b'\n').splitlines()
    for linea in datos[:LOG_MAX]:
        print(f'[{cita_commit(linea)}]')
    if not datos:
        print('[git log -S] sin coincidencias en git log -S dentro del alcance consultado')
    if len(datos) > LOG_MAX:
        print(f'[git log -S] truncado: primeras {LOG_MAX} coincidencias')
    if len(commits) > HISTORIA_MAX:
        print(f'[git log -S] búsqueda truncada: solo los últimos {HISTORIA_MAX} commits de HEAD')

    print(f'\n## git grep (literal; árbol de trabajo rastreado; máximo {GREP_MAX})')
    # Lista permitida ANTES de abrir contenido. Evita atravesar un directorio
    # rastreado que haya sido reemplazado por un symlink en el árbol de trabajo.
    archivos = [p for p in rastreados if regular(repo / p)]
    encontrados = 0
    for inicio in range(0, len(archivos), 100):
        datos = git(repo, 'grep', '-n', '-z', '-I', '-F', '--no-textconv',
                    f'--max-count={GREP_MAX + 1}', '-e', objetivo, '--',
                    *(literal(p) for p in archivos[inicio:inicio + 100]), aceptados=(0, 1))
        # -z delimita ruta y número, no contenido: se preservan ':' y espacios.
        while datos:
            ruta, datos = datos.split(b'\0', 1)
            numero, datos = datos.split(b'\0', 1)
            texto, _, datos = datos.partition(b'\n')
            encontrados += 1
            if encontrados > GREP_MAX:
                print(f'[git grep] truncado: primeras {GREP_MAX} coincidencias')
                return
            cita = visible(os.fsdecode(ruta)) + ':' + numero.decode('ascii')
            print(f'[{cita}] {visible(texto.decode("utf-8", "replace"), TEXTO_MAX)}')
    if not encontrados:
        print('[git grep] sin coincidencias en git grep')

FECHA = re.compile(r'\b\d{4}-\d{2}-\d{2}\b')
ENCABEZADO = re.compile(r'^(#{1,6})\s+')

def coincidencias(ruta, objetivo):
    # Fecha del encabezado contenedor más cercano, NO una fecha mencionada de
    # pasada en la prosa. La cita del encabezado permite comprobar la asociación.
    secciones = []
    with ruta.open(encoding='utf-8', errors='replace') as archivo:
        for n, linea in enumerate(archivo, 1):
            encabezado = ENCABEZADO.match(linea)
            if encabezado:
                nivel = len(encabezado[1])
                while secciones and secciones[-1][0] >= nivel:
                    secciones.pop()
                fecha = FECHA.search(linea)
                heredada = secciones[-1][1] if secciones else None
                secciones.append((nivel, (fecha[0], n) if fecha else heredada))
            if objetivo in linea:
                yield n, linea.rstrip('\r\n'), secciones[-1][1] if secciones else None

def documentos(repo, objetivo):
    for nombre in ('DECISIONES.md', 'CONTINUAR.md', 'docs/bitacora.md'):
        print(f'\n## {nombre} (máximo {DOC_MAX})')
        ruta = repo / nombre
        if not permitida(ruta):
            print(f'[{nombre}] fuente excluida por política de rutas/enlaces')
            continue
        if not regular(ruta):
            print(f'[{nombre}] sin coincidencias en {nombre} (fuente ausente)')
            continue
        cantidad = 0
        for n, texto, fecha in coincidencias(ruta, objetivo):
            cantidad += 1
            if cantidad > DOC_MAX:
                print(f'[{nombre}] truncado: primeras {DOC_MAX} coincidencias')
                break
            entrada = f'entrada {fecha[0]} ({nombre}:{fecha[1]})' if fecha else 'entrada sin fecha explícita'
            print(f'[{nombre}:{n}; {entrada}] {visible(texto, TEXTO_MAX)}')
        if not cantidad:
            print(f'[{nombre}] sin coincidencias en {nombre}')

def vault(objetivo):
    print(f'\n## vault (Markdown; rutas relativas; máximo {VAULT_MAX})')
    # La raíz se resuelve antes de aplicar la política: un HOME con enlace (/home → var/home en Fedora Atomic) no
    # deja fuera el vault; la ruta resuelta pasa igual por los nombres excluidos (aviso del gate, v1.30).
    raiz = Path(os.path.realpath(os.environ.get('POR_QUE_VAULT') or Path.home() / 'vault'))
    if not permitida(raiz):
        print('[vault] vault excluido por política de rutas/enlaces')
        return
    try:
        modo = raiz.stat().st_mode
    except FileNotFoundError:
        print('[vault] sin coincidencias en vault (fuente ausente)')
        return
    if not stat.S_ISDIR(modo):
        raise ErrorConsulta('vault no es un directorio')
    def error_recorrido(error):
        raise error
    cantidad = 0
    for base, dirs, archivos in os.walk(raiz, followlinks=False, onerror=error_recorrido):
        dirs[:] = sorted(d for d in dirs if permitida(Path(base) / d))
        for nombre in sorted(archivos):
            ruta = Path(base) / nombre
            if ruta.suffix.lower() not in ('.md', '.markdown') or not regular(ruta):
                continue
            for n, texto, _ in coincidencias(ruta, objetivo):
                cantidad += 1
                if cantidad > VAULT_MAX:
                    print(f'[vault] truncado: primeras {VAULT_MAX} coincidencias (orden de rutas)')
                    return
                cita = visible(ruta.relative_to(raiz).as_posix())
                print(f'[vault/{cita}:{n}] {visible(texto, TEXTO_MAX)}')
    if not cantidad:
        print('[vault] sin coincidencias en vault')

def main():
    args = sys.argv[1:]
    if len(args) not in (1, 3) or (len(args) == 3 and args[1] != '--repo'):
        raise ErrorConsulta('uso: por-que.sh <objetivo> [--repo DIR] | autotest')
    objetivo = args[0]
    if not objetivo.strip() or '\n' in objetivo or '\r' in objetivo:
        raise ErrorConsulta('el objetivo debe ser texto no vacío de una sola línea')
    repo = Path(os.path.realpath(args[2] if len(args) == 3 else '.'))
    if not permitida(repo):
        raise ErrorConsulta('repo excluido por política de rutas/enlaces')
    repo = Path(os.fsdecode(git(repo, 'rev-parse', '--show-toplevel')).rstrip('\n'))
    if not permitida(repo):
        raise ErrorConsulta('raíz del repo excluida por política de rutas/enlaces')
    candidato = Path(os.path.abspath(repo / objetivo))
    try:
        ruta = candidato.relative_to(repo).as_posix()
    except ValueError:
        ruta = None   # «/cierre» o «../x» no son rutas del repo: se buscan como término (aviso del gate, v1.30)
    if ruta is not None and not permitida(candidato):
        raise ErrorConsulta('objetivo excluido por política de rutas/enlaces')
    head = cita_commit(git(repo, 'log', '-1', '--format=%h%x09%cs%x09%s', 'HEAD').rstrip(b'\n'))
    rastreados = sorted(set(os.fsdecode(p) for p in git(repo, 'ls-files', '-z').split(b'\0') if p))
    print(f'# Evidencia local: {visible(objetivo)}')
    print(f'[{head}] base; el árbol de trabajo puede contener cambios sin commit')
    print('[alcance] sin red; sin sesiones/JSONL ni enlaces; búsqueda literal sensible a mayúsculas')
    if git(repo, 'rev-parse', '--is-shallow-repository').strip() == b'true':
        print('[git] historial incompleto: clon superficial (shallow)')
    existe = ruta is not None and regular(candidato)
    if ruta is not None and (existe or ruta in rastreados or borrado_en_historia(repo, ruta)):
        historia_archivo(repo, ruta, existe)
    else:
        buscar_git(repo, objetivo, rastreados)
    documentos(repo, objetivo)
    vault(objetivo)

try:
    main()
except (ErrorConsulta, OSError, ValueError, subprocess.TimeoutExpired) as error:
    print(f'error: consulta incompleta; {visible(str(error), TEXTO_MAX)}', file=sys.stderr)
    sys.exit(2)
PY
}

cmd_autotest() (
  set -eu
  t="$(mktemp -d "$PWD/.por-que-test.XXXXXX")"
  trap 'rm -rf -- "$t"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  # No consulta el HOME, la configuración ni los hooks reales del usuario.
  export HOME="$t/home" XDG_CONFIG_HOME="$t/home/config"
  export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
  unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE
  export POR_QUE_VAULT="$t/vault"
  mkdir -p "$HOME" "$POR_QUE_VAULT" "$t/repo/docs"
  local repo="$t/repo" out h1 h2
  g() { git -C "$repo" -c core.hooksPath=/dev/null -c commit.gpgSign=false "$@"; }
  commit() {
    g add -A
    GIT_AUTHOR_DATE="${1}T12:00:00+00:00" GIT_COMMITTER_DATE="${1}T12:00:00+00:00" g commit -qm "$2"
  }
  hay() { grep -Fq -- "$1" <<<"$out" || { echo "✗ falta: $1" >&2; exit 1; }; }
  no_hay() { if grep -Fq -- "$1" <<<"$out"; then echo "✗ se filtró: $1" >&2; exit 1; fi; }
  consulta() { out="$(motor "$1" --repo "$repo")"; }
  falla() {
    if out="$(motor "$@" 2>&1)"; then echo '✗ debía fallar cerrado' >&2; exit 1; fi
    hay 'error:'
  }
  g init -q
  g config user.name 'Prueba sintética'
  g config user.email 'prueba@example.invalid'
  printf 'def calcular_demo():\n    return 1\n' > "$repo/original.py"
  printf '# Decisiones\n\n## 2026-01-02 · elección\nSe eligió termino_solo_decisiones.\n' > "$repo/DECISIONES.md"
  printf '# CONTINUAR · cierre 2026-01-03\n## Pendiente\nRevisar calcular_demo.\n' > "$repo/CONTINUAR.md"
  printf '# Bitácora\n## 2026-01-01 · inicio\nNació calcular_demo.\n' > "$repo/docs/bitacora.md"
  commit 2026-01-01 'base sintética'
  h1="$(g rev-parse --short HEAD)"
  g mv original.py 'archivo con espacios.py'
  printf '# segunda etapa\n' >> "$repo/archivo con espacios.py"
  printf '%s\n' '-opcion [x].* $(sin_ejecutar); "comillas"' > "$repo/literales.txt"
  printf 'literal\n' > "$repo/[raro]*.txt"
  printf 'vecino\n' > "$repo/r.txt"
  printf 'marca_nombre_con_salto\n' > "$repo/"$'salto\nextraño.txt'
  commit 2026-01-02 'renombrar sin perder historia'
  h2="$(g rev-parse --short HEAD)"
  printf '# Nota\ncalcular_demo y archivo con espacios.py\n' > "$POR_QUE_VAULT/nota.md"

  consulta 'archivo con espacios.py'
  hay 'git log --follow'
  hay "$h1 | 2026-01-01 | base sintética"
  hay "$h2 | 2026-01-02 | renombrar sin perder historia"
  hay 'git blame'
  hay '2 líneas'
  hay 'archivo con espacios.py:1'
  hay 'nota.md:2'
  echo '✓ archivo con espacios: renombre, historia y blame con citas'

  consulta calcular_demo
  hay 'git log -S'
  hay "$h1 | 2026-01-01 | base sintética"
  hay 'archivo con espacios.py:1'
  hay 'CONTINUAR.md:3'
  hay 'entrada 2026-01-03'
  hay 'docs/bitacora.md:3'
  hay 'entrada 2026-01-01'
  echo '✓ función: pickaxe, ubicación actual y documentos fechados'

  printf 'Otra fecha mencionada: 2030-02-03.\nfecha_sin_cambiar\n' >> "$repo/DECISIONES.md"
  consulta fecha_sin_cambiar
  hay '[DECISIONES.md:6; entrada 2026-01-02 (DECISIONES.md:3)]'
  printf '\n## Entrada sin fecha\nfecha_desconocida\n' >> "$repo/DECISIONES.md"
  consulta fecha_desconocida
  hay '[DECISIONES.md:9; entrada sin fecha explícita]'
  echo '✓ fecha de la entrada, no fechas ajenas ni heredadas de otra sección'

  consulta termino_solo_decisiones
  hay 'DECISIONES.md:4'
  hay 'entrada 2026-01-02'
  hay 'sin coincidencias en CONTINUAR.md'
  consulta objetivo_inexistente
  hay 'sin coincidencias en git log -S'
  hay 'sin coincidencias en git grep'
  hay 'sin coincidencias en DECISIONES.md'
  hay 'sin coincidencias en vault'
  echo '✓ término solo en DECISIONES y ausencia explícita'

  consulta '-opcion [x].* $(sin_ejecutar); "comillas"'
  hay 'literales.txt:1'
  consulta '[raro]*.txt'
  hay 'git log --follow'
  hay '[raro]*.txt:1'
  no_hay 'r.txt:1'
  consulta marca_nombre_con_salto
  hay 'salto\nextraño.txt:1'
  echo '✓ objetivos literales: guion, comillas, metacaracteres y rutas raras'

  # Canarios solo sintéticos, incluso en archivos versionados y rutas anidadas.
  local raiz ruta
  for raiz in "$repo" "$POR_QUE_VAULT"; do
    for ruta in '.claude/projects/demo/nota.md' '.pi/agent/sessions/nota.md' \
      '.codex/nota.md' 'transcripts/nota.md' 'anidado/sessions/nota.md' \
      'anidado/.claude/projects/demo/nota.md' 'anidado/agent-transcripts/nota.md' \
      'anidado/registro.jsonl' 'anidado/REGISTRO.JSONL'; do
      mkdir -p "$(dirname "$raiz/$ruta")"
      printf 'calcular_demo CANARIO_EXCLUIDO solo_sesion\n' > "$raiz/$ruta"
    done
    ln -s "$raiz/.claude/projects/demo/nota.md" "$raiz/enlace.md"
    ln -s "$raiz/.codex" "$raiz/enlace-dir"
  done
  commit 2026-01-03 'solo material excluido'
  consulta calcular_demo
  no_hay CANARIO_EXCLUIDO
  # El encabezado general cita HEAD aunque ese commit no sea un hallazgo.
  out="${out#*## git log -S}"
  no_hay 'solo material excluido'
  consulta solo_sesion
  hay 'sin coincidencias en git log -S'
  hay 'sin coincidencias en git grep'
  hay 'sin coincidencias en vault'
  falla transcripts/nota.md --repo "$repo"
  falla enlace.md --repo "$repo"
  out="$(POR_QUE_VAULT="$POR_QUE_VAULT/.codex" motor calcular_demo --repo "$repo")"
  hay 'vault excluido'
  no_hay CANARIO_EXCLUIDO
  echo '✓ sesiones, JSONL y enlaces excluidos de git y vault'

  # Seguir renombres tampoco puede convertir una sesión vieja en evidencia.
  local principal="$repo"
  repo="$t/renombre-excluido"
  mkdir -p "$repo/transcripts"
  g init -q
  g config user.name 'Prueba sintética'
  g config user.email 'prueba@example.invalid'
  printf 'CANARIO_RENOMBRADO\n' > "$repo/transcripts/nota.md"
  commit 2026-01-01 'origen excluido'
  g mv transcripts/nota.md nota.md
  commit 2026-01-02 'renombre de prueba'
  falla nota.md --repo "$repo"
  hay 'historia cruza una ruta excluida'
  no_hay CANARIO_RENOMBRADO
  repo="$principal"
  echo '✓ renombre desde una ruta de sesiones: falla cerrado antes de blame'

  printf '# Sin fecha\nlinea_larga %0800d\n' 0 > "$POR_QUE_VAULT/larga.md"
  consulta linea_larga
  hay 'línea truncada'
  for ((i=0; i<45; i++)); do printf 'muchas_coincidencias %s\n' "$i"; done > "$POR_QUE_VAULT/muchas.md"
  cp "$POR_QUE_VAULT/muchas.md" "$repo/CONTINUAR.md"
  consulta muchas_coincidencias
  hay '[git grep] truncado: primeras 40 coincidencias'
  hay '[CONTINUAR.md] truncado: primeras 30 coincidencias'
  hay '[vault] truncado: primeras 40 coincidencias'
  no_hay 'muchas_coincidencias 44'
  echo '✓ topes de coincidencias y longitud visibles'

  printf 'pass\n' > "$repo/borrado.py"
  mkdir -p "$repo/carpeta" && printf 'x\n' > "$repo/carpeta/hijo.txt"
  commit 2026-01-04 'crea borrado.py'
  local h3; h3="$(g rev-parse --short HEAD)"
  g rm -q borrado.py carpeta/hijo.txt
  commit 2026-01-05 'borra borrado.py'
  consulta borrado.py
  hay 'git log --follow'
  hay "$h3 | 2026-01-04 | crea borrado.py"
  hay 'borra borrado.py'
  hay 'archivo ausente'
  consulta carpeta
  hay 'git log -S'
  echo '✓ archivo borrado: su historia, no una búsqueda por contenido (una carpeta sigue siendo término)'

  printf 'Se usa /comando_barra y ../termino_arriba.\n' >> "$repo/DECISIONES.md"
  consulta /comando_barra
  hay 'git log -S'
  hay 'DECISIONES.md:'
  consulta ../termino_arriba
  hay 'DECISIONES.md:'
  ln -s "$t" "$t/enlace-raiz"
  out="$(POR_QUE_VAULT="$t/enlace-raiz/vault" motor calcular_demo --repo "$t/enlace-raiz/repo")"
  hay 'git log -S'
  hay 'nota.md:2'
  no_hay 'excluid'
  no_hay CANARIO_EXCLUIDO
  rm "$t/enlace-raiz"
  echo '✓ término con barra o «..», y raíces (repo, vault) alcanzadas por un enlace'

  rm "$repo/CONTINUAR.md" "$repo/docs/bitacora.md"
  out="$(POR_QUE_VAULT="$t/no-vault" motor calcular_demo --repo "$repo")"
  hay 'CONTINUAR.md (fuente ausente)'
  hay 'docs/bitacora.md (fuente ausente)'
  hay 'vault (fuente ausente)'
  falla calcular_demo --repo "$t/no-repo"
  printf 'index inválido' > "$repo/.git/index"
  falla calcular_demo --repo "$repo"
  hay 'git'
  echo '✓ fuentes ausentes, repo inexistente y error de git distinto de vacío'
  echo 'autotest: todo en verde'
)

case "${1:-}" in
  autotest) if [ "$#" -eq 1 ]; then cmd_autotest; else motor "$@"; fi ;;
  *) motor "$@" ;;
esac
