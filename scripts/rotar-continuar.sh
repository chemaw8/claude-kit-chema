#!/usr/bin/env bash
# rotar-continuar.sh — helper determinista de /cierre y /proyecto-init.
#
# Hace lo mecánico del contrato de reanudación, que es justo lo que no puede
# depender de que el modelo tenga cuidado esa vez:
#
#   rotar <proyecto> <nuevo>   reemplaza CONTINUAR.md por <nuevo> y garantiza que
#                              NADA de lo desplazado se pierde: lo que estaba en el
#                              viejo y no está en el nuevo se añade a
#                              docs/bitacora.md, y se verifica línea por línea.
#   anclar <proyecto>          imprime el encabezado con fecha + ancla de git.
#   reconciliar <proyecto>     ¿el estado escrito es fresco o quedó rancio?
#                              salida 0 = fresco · 1 = rancio · 2 = no hay CONTINUAR ·
#                              3 = no se puede reconciliar (sin ancla, ancla fuera del
#                              historial, o cierre anclado en otra rama).
#   contrato <proyecto>        ¿CONTINUAR.md cumple el contrato mínimo?
#   autotest                   se prueba a sí mismo con datos sintéticos.
#
# Opciones: --dry-run (no escribe nada, solo dice qué haría)
#
# Diseño: docs/superpowers/specs/2026-08-26-comandos-ficha-design.md
set -uo pipefail

DRY=0
args=()
for a in "$@"; do
  if [ "$a" = "--dry-run" ]; then DRY=1; else args+=("$a"); fi
done
set -- "${args[@]:-}"

CMD="${1:-}"
HOY="$(date +%F)"

err() { echo "✗ $*" >&2; }
ok()  { echo "✓ $*"; }

# ── ancla de git ──────────────────────────────────────────────────────────
# Devuelve "commit <hash>" si el proyecto es un repo con commits; si no, un
# sustituto honesto. El ancla existe para detectar divergencia, no para presumir.
ancla_de() {
  local dir="$1"
  if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
    local h r
    h="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"
    r="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    # La rama forma parte del ancla: un CONTINUAR puede viajar a otra rama (un rebase
    # que trae el de main) y ahí su hash deja de ser comparable. En HEAD desprendido
    # no hay rama que estampar y no se inventa una.
    if [ -z "$h" ]; then echo "commit ninguno-aún"
    elif [ -n "$r" ] && [ "$r" != "HEAD" ]; then echo "commit $h (rama $r)"
    else echo "commit $h"; fi
  else
    echo "sin-git"
  fi
}

nombre_de() { basename "$(cd "$1" && pwd)"; }

# Papeleo del propio cierre: /cierre escribe CONTINUAR.md, rota a la bitácora y de
# paso puede tocar la ficha o DECISIONES. Esos archivos están pendientes por diseño
# en el momento de anclar, así que no cuentan como trabajo sin cerrar. Lo usan
# `anclar` (para calcular el campo) y `reconciliar` (para juzgarlo).
PAPELEO='(^|/)(CONTINUAR|CLAUDE|DECISIONES)\.md$|(^|/)docs/bitacora\.md$|(^|/)\.claude/settings\.json$|(^|/)\.gitignore$'

# Trabajo REAL sin commitear, una sola definición para los dos que la necesitan.
# El estado ocupa las 2 primeras columnas y la ruta empieza en la 4ª: se corta por
# POSICIÓN, no por campos. En un RENOMBRE ("R  ficha.md -> codigo.py") cuentan LOS
# DOS lados: quedarse con el origen deja pasar mover el papeleo a un archivo real, y
# quedarse con el destino deja pasar lo contrario —que un archivo real desaparezca
# hacia un nombre de papeleo—, que es el mismo hueco del revés. (Las rutas con
# espacios las entrecomilla git, por eso se quitan las comillas al final.)
# --untracked-files=all: sin eso git colapsa una carpeta nueva en '?? docs/' y el
# filtro de papeleo no la reconoce; con eso lista archivo por archivo.
# Si `git status` falla dentro de un repo válido (index bloqueado, permisos,
# submódulo roto), la salida vacía se leía como árbol limpio: el fallo abría hacia
# el veredicto optimista, justo el que este cambio quiere dejar de regalar. Se
# mira el código de salida y se responde "?" — desconocido, no limpio.
# El fallo se señala por CÓDIGO DE SALIDA (3), nunca por un centinela de texto: una
# ruta puede ser cualquier cosa, incluido un archivo llamado "?", y un centinela que
# también puede ser un dato válido no distingue nada.
sucios_de() {
  local salida rc lista
  salida="$(git -C "$1" status --porcelain --untracked-files=all 2>/dev/null)"; rc=$?
  [ "$rc" -ne 0 ] && return 3
  lista="$(printf '%s\n' "$salida" | awk '
      { ruta = substr($0, 4); i = index(ruta, " -> ")
        if (i) { print substr(ruta, 1, i - 1); print substr(ruta, i + 4) }
        else print ruta }' \
    | sed -E 's/^"//; s/"$//' | grep -vE "$PAPELEO" || true)"   # grep sin coincidencias sale 1
  printf '%s' "$lista"
}

# ¿Queda trabajo real sin commitear? Se calcula, no se declara: el campo que se
# estampaba siempre en "sí" no podía delatar nunca un cierre sucio, y la rama de
# `reconciliar` que reacciona a "no" era código inalcanzable.
limpio_de() {
  local dir="$1" s rc
  git -C "$dir" rev-parse --git-dir >/dev/null 2>&1 || { echo "sin-git"; return; }
  s="$(sucios_de "$dir")"; rc=$?
  [ "$rc" -eq 3 ] && { echo "no-se-pudo-saber"; return; }
  [ -n "$s" ] && echo "no" || echo "sí"
}

# ── anclar ────────────────────────────────────────────────────────────────
cmd_anclar() {
  local dir="${1:-.}"
  printf '# CONTINUAR — %s  ·  cierre %s  ·  %s  ·  cierre limpio: %s\n' \
    "$(nombre_de "$dir")" "$HOY" "$(ancla_de "$dir")" "$(limpio_de "$dir")"
}

# ── reconciliar ───────────────────────────────────────────────────────────
# Compara lo que dice el encabezado contra la realidad. Si divergen, el estado
# escrito es anterior al trabajo real: hay que reconstruir antes de creerle.
cmd_reconciliar() {
  local dir="${1:-.}" f="${1:-.}/CONTINUAR.md"
  [ -f "$f" ] || { err "no hay CONTINUAR.md en $dir"; return 2; }

  local cab commit_esc limpio commit_real
  cab="$(head -1 "$f")"
  commit_esc="$(printf '%s' "$cab" | grep -oE 'commit [0-9a-f]+' | awk '{print $2}')"
  limpio="$(printf '%s' "$cab" | grep -oE 'cierre limpio: (sí|si|no)' | sed 's/.*: //')"

  case "$limpio" in
    no) err "el último cierre NO fue limpio — reconstruye del git diff antes de creerle al estado"; return 1 ;;
  esac

  if [ -z "$commit_esc" ]; then
    # Sin ancla de commit: degradación con gracia por fecha vs. mtime.
    local fecha_cierre mas_nuevo
    fecha_cierre="$(printf '%s' "$cab" | grep -oE 'cierre [0-9]{4}-[0-9]{2}-[0-9]{2}' | awk '{print $2}')"
    if [ -z "$fecha_cierre" ]; then
      err "CONTINUAR.md sin fecha ni ancla en el encabezado — no se puede reconciliar"; return 3
    fi
    # Se excluyen los mismos archivos de papeleo que la ruta con git (línea ~99):
    # el propio /cierre puede tocar la ficha, DECISIONES o settings DESPUÉS de
    # escribir CONTINUAR, y eso no es trabajo real sin cerrar.
    mas_nuevo="$(find "$dir" -type f -newer "$f" \
      -not -path '*/.git/*' -not -path '*/node_modules/*' \
      -not -name 'CONTINUAR.md' -not -name 'CLAUDE.md' -not -name 'DECISIONES.md' \
      -not -path '*/docs/bitacora.md' -not -path '*/.claude/settings.json' -not -name '.gitignore' \
      -print -quit 2>/dev/null)"
    if [ -n "$mas_nuevo" ]; then
      err "hay archivos modificados DESPUÉS del cierre del $fecha_cierre (p. ej. ${mas_nuevo#$dir/}) — el estado puede estar rancio"
      return 1
    fi
    ok "estado fresco (sin git; nada se tocó después del cierre del $fecha_cierre)"
    return 0
  fi

  commit_real="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"
  # Papeleo del propio cierre: /cierre escribe CONTINUAR.md, rota a la bitácora,
  # y de paso puede corregir la ficha (CLAUDE.md) o anotar en DECISIONES.md; graba
  # el ancla con el HEAD de ANTES y luego commitea, así que HEAD queda un paso
  # adelante aunque no haya trabajo real pendiente. El estado sigue fresco si lo
  # ÚNICO que cambió desde el ancla son esos archivos narrativos del kit — el
  # "trabajo real" que sí delata un estado rancio es código, datos, scripts.
  # (el patrón vive arriba, junto a limpio_de: lo comparten anclar y reconciliar)

  # Cambios SIN commitear que no sean el papeleo son trabajo sin cerrar, y eso es
  # cierto en CUALQUIER rama. Va antes del cruce de ramas de abajo a propósito: el
  # veredicto "no se puede reconciliar" no debe apagar el aviso más fuerte que hay.
  local sucios
  # El estado ocupa las 2 primeras columnas y la ruta empieza en la 4ª: se corta por
  # POSICIÓN, no por campos. Lo que de verdad rompía al partir en espacios era el
  # RENOMBRE ("R  ficha.md -> codigo.py"), donde cuentan LOS DOS lados: quedarse con el
  # origen dejaba pasar mover el papeleo a un archivo real, y quedarse con el destino
  # deja pasar lo contrario —que un archivo real desaparezca hacia un nombre de
  # papeleo—, que es el mismo hueco del revés. (Las rutas con espacios NO eran el
  # problema: git las entrecomilla, comprobado — `?? "CLAUDE.md viejo.py"` —, y por eso
  # se quitan las comillas al final; el corte por posición las cubre de paso.)
  local rcs
  sucios="$(sucios_de "$dir")"; rcs=$?
  if [ "$rcs" -eq 3 ]; then
    err "no se pudo leer el estado de git en $dir — no se puede reconciliar"; return 3
  fi
  if [ -n "$sucios" ]; then
    err "hay cambios sin commitear después del cierre:"
    printf '%s\n' "$sucios" | sed 's/^/     · /' >&2
    return 1
  fi

  # El ancla que COINCIDE con HEAD zanja el asunto sin mirar la rama: no hay nada
  # entre el ancla y HEAD que reconciliar. Salir de main con `checkout -b` deja el
  # estado fresco, no un caso sin resolver, así que esto va antes del cruce de abajo.
  if [ "$commit_esc" = "$commit_real" ]; then
    ok "estado fresco (ancla $commit_esc coincide con HEAD)"
    return 0
  fi

  # El ancla solo vale dentro de SU rama. Si el cierre se hizo en otra —el CONTINUAR
  # de main que un rebase trae a una rama de feature—, "$commit_esc..HEAD" cuenta como
  # trabajo nuevo todo lo que la rama ya tenía desde antes del cierre: sería un rancio
  # falso, y un veredicto falso enseña a no creerle al panel. No se puede decidir
  # mecánicamente, así que se dice eso y se dice cómo salir.
  local rama_esc rama_real
  rama_esc="$(printf '%s' "$cab" | grep -oE '\(rama [^ )]+\)' | head -1 | sed -E 's/^\(rama //; s/\)$//')"
  rama_real="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [ -n "$rama_esc" ] && [ "$rama_esc" != "$rama_real" ]; then
    local ncom; ncom="$(git -C "$dir" rev-list --count "$commit_esc..HEAD" 2>/dev/null || echo '?')"
    err "el cierre se ancló en la rama '$rama_esc' y estás en '${rama_real:-?}' — no se puede reconciliar entre ramas ($ncom commit(s) desde el ancla, sin juzgar)"
    echo "  → si es aquí donde trabajas, cierra aquí (/cierre): el encabezado nuevo queda anclado en esta rama" >&2
    return 3
  fi

  # Llegados aquí el ancla NO es HEAD (eso ya se decidió arriba), pero puede no estar
  # en el historial: si el diff falla, el ancla se reescribió y no hay nada que comparar.
  local cambiados otros
  cambiados="$(git -C "$dir" diff --name-only --no-renames "$commit_esc..HEAD" 2>/dev/null)" || {
    err "el ancla $commit_esc no está en el historial — no se puede reconciliar; revisa a mano"
    return 3; }
  # grep devuelve 1 si no queda nada tras filtrar el papeleo: es el caso fresco,
  # no un error — por eso se filtra sobre la variable, sin mirar su $?.
  otros="$(printf '%s\n' "$cambiados" | grep -vE "$PAPELEO")"
  if [ -n "$otros" ]; then
    err "hubo trabajo real después del último cierre — archivos fuera del papeleo cambiaron:"
    printf '%s\n' "$otros" | sed 's/^/     · /' >&2
    echo "  → revisa: git -C '$dir' log --oneline $commit_esc..HEAD" >&2
    return 1
  fi

  ok "estado fresco (desde el ancla $commit_esc solo se movió el papeleo del cierre)"
  return 0
}

# ── contrato ──────────────────────────────────────────────────────────────
# Los campos blindados. Su ausencia es el fallo que un tope de líneas no ve.
cmd_contrato() {
  local f="${1:-.}/CONTINUAR.md"
  [ -f "$f" ] || { err "no hay CONTINUAR.md en ${1:-.}"; return 2; }
  local faltan=0
  head -1 "$f" | grep -qE 'cierre [0-9]{4}-[0-9]{2}-[0-9]{2}' \
    || { err "falta la fecha absoluta del cierre en el encabezado"; faltan=1; }
  local s
  for s in "Dónde vamos" "Siguiente paso" "Cómo retomar" "Bloqueadores"; do
    grep -qE "^## +$s" "$f" || { err "falta la sección '## $s'"; faltan=1; }
  done
  # El siguiente paso tiene que decir algo, no quedar en el encabezado vacío.
  awk '/^## +Siguiente paso/{f=1;next} /^## /{f=0} f&&NF{n++} END{exit !(n>0)}' "$f" \
    || { err "'## Siguiente paso' está vacío"; faltan=1; }
  # Lo que se cita para RETOMAR (abrir/correr) tiene que existir. Un "cómo retomar"
  # que apunta a un script inexistente no es ejecutable, y eso un tope de líneas no
  # lo ve. Se revisa SOLO "Cómo retomar" — no "Siguiente paso", donde es normal
  # nombrar un archivo que aún no existe porque el paso es crearlo — y solo
  # extensiones de código/doc, no de datos (un .csv suele ser una salida futura).
  python3 - "$f" "${1:-.}" <<'PY' || faltan=1
import re, sys, os
doc, raiz = sys.argv[1], sys.argv[2]
texto = open(doc, encoding="utf-8").read()
tramos = re.findall(r"^## +Cómo retomar\n(.*?)(?=^## |\Z)", texto, re.M | re.S)
# La extensión debe terminar en frontera (?![\w.]) — si no, `.js` matchea dentro
# de `.jsonl`. El token arranca en \w, así que un `./`, `/` o `~/` inicial no se
# captura: por eso las rutas de fuera del proyecto se descartan por campo, abajo,
# y el match ya llega normalizado a relativo.
EXT = r"(?:py|sh|md|sql|R|rb|go|js|mjs|ts|tsx|ipynb)"
PAT = re.compile(rf"[\w][\w./-]*\.{EXT}(?![\w.])")
# Un gate de arranque escrito como conteo ('18/18', '199/199') caduca en cuanto la
# suite crece, y entonces deja de distinguir un fallo real de un desfase de conteo:
# medido el 2026-09-11, cuatro proyectos lo tenían caduco y uno escondía un FAIL de
# verdad. El criterio tiene que ser INVARIANTE al tamaño de la suite. El conteo
# puede quedar al lado como referencia fechada, nunca como criterio solo.
# El criterio se busca por lo que la línea ES, no por una cadena literal: "Verificar
# arranque", "Verificar el arranque", "Gate:" o "Arranque:", en cualquier caja.
GATE = re.compile(r"verificar\b.{0,12}\barranque|^\s*[-*·]?\s*(?:gate|arranque)\s*:", re.I)
# Una FECHA lleva barras y no es un conteo: se quita de la línea antes de buscar.
FECHA = re.compile(r"\b\d{4}\s*/\s*\d{1,2}\s*/\s*\d{1,2}\b|\b\d{1,2}\s*/\s*\d{1,2}\s*/\s*\d{4}\b")
# 'casos' queda fuera a propósito: 'procesa 5 casos y escribe salida.csv' es una
# comprobación funcional, no un conteo de suite.
CONTEO = re.compile(r"\b\d+\s*(?:/|\s+de\s+)\s*\d+\b|\b\d+\s+(?:tests?|pruebas?|chequeos?|checks?)\b", re.I)
INVARIANTE = re.compile(
    r"todas? en verde|en verde|fail\w*\s*[:=]?\s*0|sin\s+fail|sin\s+fallos?"
    r"|0\s+fallos?|exit\s*(?:code\s*)?0|salida\s*0|sin\s+errores|todos?\s+los\s+chequeos",
    re.I)
citados, faltantes, caducos = set(), [], []
for t in tramos:
    for linea in t.splitlines():
        if GATE.search(linea) and CONTEO.search(FECHA.sub(" ", linea)) and not INVARIANTE.search(linea):
            caducos.append(linea.strip()[:110])
        # Se valida por CAMPO (delimitado por espacios o backticks), no por línea
        # entera: así un glob o una URL en la línea no apaga la comprobación de un
        # archivo real citado al lado, y un '?' de la prosa no desactiva nada.
        for campo in re.split(r"[\s`]+", linea):
            if "*" in campo or "?" in campo or "://" in campo:
                continue                     # glob o URL: no es un archivo local
            # Fuera del proyecto: absoluta (/x), de home (~/x) o que sube (../x).
            # Se decide por el CAMPO y no por el match: PAT arranca en \w, así que
            # nunca captura la '/' ni la '~' inicial y el match llega ya sin ellas
            # ('/home/x.sh' -> 'home/x.sh'). Mirar el match daba un falso positivo
            # en toda ruta absoluta citada.
            if campo.lstrip("(<[\"'").startswith(("/", "~", "../")):
                continue
            for m in PAT.findall(campo):
                citados.add(m.strip(".,;:"))
for c in sorted(citados):
    if not os.path.exists(os.path.join(raiz, c)):
        faltantes.append(c)
for c in caducos:
    print(f"✗ el gate de arranque es un conteo que caduca, no una condición: {c}", file=sys.stderr)
    print("  → di el comando y qué debe verse ('sin FAIL', 'fail 0', 'todas en verde');"
          " el número puede quedar al lado como referencia fechada.", file=sys.stderr)
for c in faltantes:
    print(f"✗ 'Cómo retomar' cita un archivo que no existe: {c}", file=sys.stderr)
if faltantes or caducos:
    sys.exit(1)
PY
  if [ "$faltan" -eq 0 ]; then ok "contrato completo ($(wc -l < "$f") líneas)"; return 0; fi
  return 1
}

# ── rotar ─────────────────────────────────────────────────────────────────
# La garantía central: lo desplazado se archiva, y se comprueba que nada se
# perdió. Si la comprobación falla, no se escribe nada.
cmd_rotar() {
  local dir="${1:-}" nuevo="${2:-}"
  [ -n "$dir" ] && [ -n "$nuevo" ] || { err "uso: rotar <proyecto> <archivo-nuevo>"; return 2; }
  [ -f "$nuevo" ] || { err "no existe el archivo nuevo: $nuevo"; return 2; }
  local viejo="$dir/CONTINUAR.md" bit="$dir/docs/bitacora.md"

  if [ ! -f "$viejo" ]; then
    [ "$DRY" -eq 1 ] && { echo "[dry-run] crearía $viejo (no había estado previo)"; return 0; }
    mkdir -p "$dir"; cp "$nuevo" "$viejo" && rm -f "$nuevo"; ok "CONTINUAR.md creado (no había estado previo)"; return 0
  fi

  python3 - "$viejo" "$nuevo" "$bit" "$HOY" "$DRY" <<'PY'
import sys, os, shutil
from collections import Counter

viejo, nuevo, bit, hoy, dry = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5] == "1"

def lineas(p):
    with open(p, encoding="utf-8") as fh:
        return [l.rstrip("\n") for l in fh]

def norm(l):
    return l.strip()

# Contenido real: se ignoran líneas vacías, separadores y el título de nivel 1.
# El H1 es la etiqueta del documento, nunca información — y archivarlo metería
# un encabezado de nivel 1 en medio de la bitácora y le rompería la estructura.
def sustantiva(l):
    n = norm(l)
    if not n or set(n) == {"-"} or n.startswith("<!--"):
        return False
    if n.startswith("# ") and not n.startswith("## "):
        return False
    return True

v, n = lineas(viejo), lineas(nuevo)
# Se trabaja por OCURRENCIAS, no por conjunto: una línea idéntica bajo padres
# distintos (hijos de listas anidadas, un ítem citado en dos secciones) es
# información distinta y no se debe colapsar.
old_counts = Counter(norm(l) for l in v if sustantiva(l))
new_counts = Counter(norm(l) for l in n if sustantiva(l))

# Desplazado = las ocurrencias del viejo que el nuevo NO conserva, en orden y
# SIN deduplicar. Cada ocurrencia del nuevo "consume" una del viejo; lo que
# sobra se archiva, duplicados incluidos (un duplicado en la bitácora es el
# peor caso que el propio diseño ya declara aceptable).
restante = Counter(new_counts)
# Cada línea desplazada viaja con su CONTEXTO: la sección de origen y, si es
# una línea hija (indentada), su padre — para que la bitácora no acumule
# huérfanos ilegibles cuando el padre sobrevive en el CONTINUAR nuevo.
def _indent(l):
    return len(l) - len(l.lstrip())

desplazado = []          # tuplas (linea, seccion, padre_vigente_o_None)
seccion = ""
for idx, l in enumerate(v):
    s = l.strip()
    if s.startswith("## "):
        seccion = s[3:].strip()
    if not sustantiva(l):
        continue
    k = norm(l)
    if restante[k] > 0:
        restante[k] -= 1          # esta ocurrencia sobrevive en el nuevo
        continue
    padre = None
    if _indent(l) > 0:            # hija: buscar el padre hacia arriba
        for j in range(idx - 1, -1, -1):
            if sustantiva(v[j]) and _indent(v[j]) < _indent(l):
                # solo se cita como contexto si el padre SIGUE en el nuevo
                if new_counts[norm(v[j])] > 0:
                    padre = v[j].strip()
                break
    desplazado.append((l, seccion, padre))

# `nuevo` suele estar en otro sistema de archivos (un temporal en /tmp), donde
# os.replace falla con "Invalid cross-device link". copyfile sí cruza.
def aplicar(origen, destino):
    shutil.copyfile(origen, destino)
    os.remove(origen)

if not desplazado:
    if dry:
        print("[dry-run] nada que rotar; solo se reemplazaría CONTINUAR.md")
        sys.exit(0)
    aplicar(nuevo, viejo)
    print("✓ CONTINUAR.md actualizado (no hubo detalle que rotar)")
    sys.exit(0)

if dry:
    print(f"[dry-run] rotaría {len(desplazado)} líneas de CONTINUAR.md → {bit}")
    for l, _, _ in desplazado[:5]:
        print("   ·", l[:90])
    if len(desplazado) > 5:
        print(f"   … y {len(desplazado)-5} más")
    sys.exit(0)

# Respaldo en memoria para revertir si la verificación post-escritura falla.
respaldo_viejo = "".join(x + "\n" for x in v)
bit_prev = open(bit, encoding="utf-8").read() if os.path.exists(bit) else None

# Orden a prueba de fallos: primero archivar, después reemplazar.
os.makedirs(os.path.dirname(bit), exist_ok=True)
if bit_prev is None:
    with open(bit, "w", encoding="utf-8") as fh:
        fh.write("# Bitácora\n\nHistoria del proyecto. Se lee al retomar tras un hueco\n"
                 "largo o cuando CONTINUAR.md no basta. Append-only: no se edita.\n")

with open(bit, "a", encoding="utf-8") as fh:
    fh.write(f"\n## {hoy} — rotado desde CONTINUAR.md\n\n")
    ult_seccion, ult_padre = None, None
    for l, seccion, padre in desplazado:
        if seccion != ult_seccion:
            fh.write(f"«{seccion or 'encabezado'}»:\n" if ult_seccion is None
                     else f"\n«{seccion or 'encabezado'}»:\n")
            ult_seccion, ult_padre = seccion, None
        if padre != ult_padre:
            if padre:
                fh.write(f"> bajo: {padre}\n")
            ult_padre = padre
        fh.write(l + "\n")

aplicar(nuevo, viejo)

# Verificación REAL: releer del disco y comparar por OCURRENCIAS. Es independiente
# de cómo se calculó `desplazado` —no comparte su lógica— así que sí puede fallar;
# si falla, revierte y deja el proyecto como estaba (no una pérdida silenciosa).
final = Counter(norm(l) for l in lineas(viejo) if sustantiva(l))
final += Counter(norm(l) for l in lineas(bit) if sustantiva(l))
perdidas = {k: old_counts[k] - final[k] for k in old_counts if final[k] < old_counts[k]}
if perdidas:
    with open(viejo, "w", encoding="utf-8") as fh:
        fh.write(respaldo_viejo)
    if bit_prev is None:
        os.remove(bit)
    else:
        with open(bit, "w", encoding="utf-8") as fh:
            fh.write(bit_prev)
    tot = sum(perdidas.values())
    print(f"✗ ABORTADO: la verificación halló {tot} ocurrencia(s) perdida(s); se revirtió todo.",
          file=sys.stderr)
    for k in list(perdidas)[:5]:
        print("   ·", k[:90], file=sys.stderr)
    sys.exit(1)

print(f"✓ rotadas {len(desplazado)} líneas a {bit} — cero pérdida verificada (por ocurrencias, releído del disco)")
PY
}

# ── autotest ──────────────────────────────────────────────────────────────
# Prueba real sobre datos sintéticos: rota, comprueba cero pérdida, detecta
# contrato incompleto y estado rancio. Lo corre verificar.sh.
cmd_autotest() {
  local t; t="$(mktemp -d)"; trap 'rm -rf "$t"' RETURN
  local p="$t/proyecto-demo"; mkdir -p "$p"
  ( cd "$p" && git init -q && git config user.email t@t && git config user.name t )

  cat > "$p/CONTINUAR.md" <<'EOF'
# CONTINUAR — proyecto-demo  ·  cierre 2026-08-01  ·  commit aaaaaaa  ·  cierre limpio: sí

## Dónde vamos
Fase 1 terminada.

## Siguiente paso
- [ ] correr el pipeline

## Cómo retomar
- Correr: make run

## Bloqueadores / esperas
- Ninguno

---
## Detalle vivo
- dato histórico que debe sobrevivir
- otro dato viejo importante
EOF
  echo "x" > "$p/archivo.txt"
  ( cd "$p" && git add -A && git commit -qm inicial )

  cat > "$t/nuevo.md" <<'EOF'
# CONTINUAR — proyecto-demo  ·  cierre 2026-08-26  ·  commit bbbbbbb  ·  cierre limpio: sí

## Dónde vamos
Fase 2 en curso.

## Siguiente paso
- [ ] validar resultados

## Cómo retomar
- Correr: make run

## Bloqueadores / esperas
- Ninguno
EOF

  local f=0 rcx
  cmd_rotar "$p" "$t/nuevo.md" >/dev/null || { err "autotest: la rotación falló"; f=1; }
  grep -q "dato histórico que debe sobrevivir" "$p/docs/bitacora.md" 2>/dev/null \
    || { err "autotest: se perdió una línea histórica"; f=1; }
  grep -q "otro dato viejo importante" "$p/docs/bitacora.md" 2>/dev/null \
    || { err "autotest: se perdió otra línea histórica"; f=1; }
  grep -q "Fase 2 en curso" "$p/CONTINUAR.md" \
    || { err "autotest: no se aplicó el estado nuevo"; f=1; }
  cmd_contrato "$p" >/dev/null || { err "autotest: el contrato debió pasar"; f=1; }

  # Duplicados legítimos: una línea que aparece 2 veces en el viejo (hijos de
  # secciones distintas) debe archivarse 2 veces, no colapsarse a 1.
  local p2="$t/dup-demo"; mkdir -p "$p2"
  printf '# CONTINUAR — d · cierre 2026-08-01\n\n## Detalle vivo\n- subsistema A\n- revisar logs\n- subsistema B\n- revisar logs\n' > "$p2/CONTINUAR.md"
  printf '# CONTINUAR — d · cierre 2026-08-26\n\n## Dónde vamos\nnada que conservar\n' > "$t/dup-nuevo.md"
  cmd_rotar "$p2" "$t/dup-nuevo.md" >/dev/null || { err "autotest: rotación de duplicados falló"; f=1; }
  local nlogs; nlogs=$(grep -c '^- revisar logs$' "$p2/docs/bitacora.md" 2>/dev/null || true)
  [ "${nlogs:-0}" -eq 2 ] || { err "autotest: 'revisar logs' debía archivarse 2 veces, quedó ${nlogs:-0}"; f=1; }

  # Contrato incompleto: debe fallar.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\nalgo\n' > "$p/CONTINUAR.md"
  if cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: el contrato incompleto debió fallar"; f=1; fi

  # "Cómo retomar" que cita un archivo inexistente: no es ejecutable, debe fallar.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Correr: `scripts/99-no-existe.py`\n\n## Bloqueadores / esperas\n- Ninguno\n' > "$p/CONTINUAR.md"
  if cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: debió cazar el archivo citado inexistente"; f=1; fi

  # Sin falsos positivos: glob, .jsonl (que contiene '.js') y un script que SÍ
  # existe, más un archivo futuro en 'Siguiente paso' que NO debe validarse.
  mkdir -p "$p/scripts"; : > "$p/scripts/run.py"
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] crear `salida/reporte-2026.csv`\n\n## Cómo retomar\n- Correr: `python scripts/run.py`\n- Logs: `tests/*.spec.js`\n- Estado: `registro-envios.jsonl`\n\n## Bloqueadores / esperas\n- Ninguno\n' > "$p/CONTINUAR.md"
  if ! cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: falso positivo (glob/.jsonl/paso-futuro no deben fallar)"; f=1; fi

  # El gate de arranque no puede ser un conteo que caduca (condición del council
  # del 2026-09-11 al ítem de gates: sin esto, el cambio de plantilla es prosa que
  # nada comprueba — `contrato` aceptaba tal cual un 'Verificar arranque: … 18/18').
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Verificar arranque: `python scripts/run.py` → debe dar 18/18 PASS\n\n## Bloqueadores / esperas\n- Ninguno\n' > "$p/CONTINUAR.md"
  if cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: un gate '18/18' debió fallar el contrato"; f=1; fi
  # ...pero el conteo COMO REFERENCIA, con una condición invariante al lado, pasa.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Verificar arranque: `python scripts/run.py` → todas en verde, `fail 0` (hoy 18/18, 2026-09-12)\n\n## Bloqueadores / esperas\n- Ninguno\n' > "$p/CONTINUAR.md"
  if ! cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: el conteo como referencia fechada no debe fallar"; f=1; fi
  # Una cifra ESPERADA (un total que debe imprimirse) no es un conteo de suite y no
  # se toca: si esto fallara, el chequeo sería inusable en medio proyecto de datos.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Verificar arranque: `python scripts/run.py` imprime 110,234,723 y termina en OK\n\n## Bloqueadores / esperas\n- Ninguno\n' > "$p/CONTINUAR.md"
  if ! cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: una cifra esperada no es un gate caduco"; f=1; fi
  # El conteo caduca igual sin barra: '18 de 18' y '199 pruebas' son la misma trampa.
  # (Lo cazó el revisor adversario del gate de push: la primera versión del detector
  # solo veía la forma con barra, y el caso que lo probaba no podía fallar nunca.)
  local forma
  for forma in '18 de 18' '199 pruebas OK' '32 tests'; do
    printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Verificar arranque: `python scripts/run.py` → %s\n\n## Bloqueadores / esperas\n- Ninguno\n' "$forma" > "$p/CONTINUAR.md"
    if cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: el gate '$forma' debió fallar el contrato"; f=1; fi
  done
  # El gate se reconoce por lo que la línea es, no por una cadena literal.
  local variante
  for variante in 'Verificar el arranque' 'verificar arranque' 'Gate'; do
    printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- %s: `pytest` → 18/18\n\n## Bloqueadores / esperas\n- Ninguno\n' "$variante" > "$p/CONTINUAR.md"
    if cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: '$variante' con 18/18 debió fallar"; f=1; fi
  done
  # Y no puede cazar lo que no es un conteo de suite: una FECHA con barras, o una
  # comprobación funcional con un número de casos.
  local inocente
  for inocente in 'OK (revisado 2026/09/12)' 'procesa 5 casos y escribe salida.csv'; do
    printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Verificar arranque: `make test` → %s\n\n## Bloqueadores / esperas\n- Ninguno\n' "$inocente" > "$p/CONTINUAR.md"
    if ! cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: falso positivo del gate caduco en '$inocente'"; f=1; fi
  done

  # URL en "Cómo retomar": no es un archivo local, no debe fallar.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Guía: https://raw.githubusercontent.com/foo/bar/main/README.md\n- Correr: `python scripts/run.py`\n\n## Bloqueadores / esperas\n- Ninguno\n' > "$p/CONTINUAR.md"
  if ! cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: una URL en Cómo retomar no debe fallar el contrato"; f=1; fi

  # La bitácora conserva CONTEXTO: sección de origen para todo lo archivado, y
  # el padre citado cuando se archivan hijas de una viñeta que sobrevive.
  local p3="$t/ctx-demo"; mkdir -p "$p3"
  printf '# CONTINUAR — ctx  ·  cierre 2026-08-30  ·  commit ccccccc  ·  cierre limpio: sí\n\n## Dónde vamos\nfase vieja terminada\n\n## Siguiente paso\n- [ ] tarea vieja\n\n## Cómo retomar\n- Correr: make run\n\n## Bloqueadores / esperas\n- Ninguno\n\n---\n## Detalle vivo\n- Investigación de respaldo en la carpeta:\n  archivo-uno con la config probada\n  archivo-dos con los huecos\n' > "$p3/CONTINUAR.md"
  printf '# CONTINUAR — ctx  ·  cierre 2026-08-31  ·  commit ddddddd  ·  cierre limpio: sí\n\n## Dónde vamos\nfase nueva\n\n## Siguiente paso\n- [ ] tarea nueva\n\n## Cómo retomar\n- Correr: make run\n\n## Bloqueadores / esperas\n- Ninguno\n\n---\n## Detalle vivo\n- Investigación de respaldo en la carpeta:\n' > "$t/ctx-nuevo.md"
  cmd_rotar "$p3" "$t/ctx-nuevo.md" >/dev/null || { err "autotest: rotación con contexto falló"; f=1; }
  grep -q "Dónde vamos" "$p3/docs/bitacora.md" \
    || { err "autotest: lo archivado debe llevar su sección de origen"; f=1; }
  grep -q "bajo: - Investigación de respaldo" "$p3/docs/bitacora.md" \
    || { err "autotest: las hijas huérfanas deben citar a su padre vigente"; f=1; }
  grep -q "archivo-uno con la config probada" "$p3/docs/bitacora.md" \
    || { err "autotest: se perdió una hija"; f=1; }

  # Rutas FUERA del proyecto (absoluta, de home, o que sube): no son archivos
  # del repo y no deben validarse. PAT arranca en \w y nunca captura la '/' ni
  # la '~' inicial, así que esto se decide por el CAMPO, no por el match.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Helper: `bash /home/chema/.claude/scripts/rotar-continuar.sh reconciliar .`\n- Hook: `~/.claude/hooks/anti-secretos.sh`\n- Vecino: `../otro-proyecto/README.md`\n- Correr: `python scripts/run.py`\n\n## Bloqueadores / esperas\n- Ninguno\n' > "$p/CONTINUAR.md"
  if ! cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: una ruta absoluta o de home no debe fallar el contrato"; f=1; fi

  # ...pero eso no puede volverse un agujero: un relativo inexistente citado al
  # lado de una ruta absoluta debe seguir cazándose.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Helper: `bash /home/chema/.claude/scripts/rotar-continuar.sh contrato .`\n- Correr: `python scripts/99-no-existe.py`\n\n## Bloqueadores / esperas\n- Ninguno\n' > "$p/CONTINUAR.md"
  if cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: la ruta absoluta no debe enmascarar un relativo inexistente"; f=1; fi

  # Glob y archivo inexistente en la MISMA línea: el inexistente debe cazarse pese al glob.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Correr: `python scripts/99-no-existe.py` y ver `tests/*.spec.js`\n\n## Bloqueadores / esperas\n- Ninguno\n' > "$p/CONTINUAR.md"
  if cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: el glob no debe enmascarar un archivo inexistente citado al lado"; f=1; fi

  # Reconciliación tras el commit de cierre. El ancla se graba con el HEAD de
  # ANTES de commitear, así que el commit del cierre deja HEAD un paso adelante.
  # 1) último trabajo real = HEAD actual (ese es el ancla).
  ( cd "$p" && git add -A && git commit -qm "trabajo real previo" )
  W="$(cd "$p" && git rev-parse --short HEAD)"
  # 2) /cierre escribe CONTINUAR anclado en W y commitea solo el papeleo.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26  ·  commit %s  ·  cierre limpio: sí\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Correr: `python scripts/run.py`\n\n## Bloqueadores / esperas\n- Ninguno\n' "$W" > "$p/CONTINUAR.md"
  ( cd "$p" && git add CONTINUAR.md && git commit -qm "cierre: papeleo" )
  # 3) HEAD adelante solo por el papeleo → FRESCO.
  if ! cmd_reconciliar "$p" >/dev/null 2>&1; then err "autotest: el papeleo del cierre no debe marcar rancio"; f=1; fi
  # 4) trabajo real (otro archivo) tras el cierre → RANCIO.
  : > "$p/otro.txt"; ( cd "$p" && git add otro.txt && git commit -qm "trabajo real" )
  if cmd_reconciliar "$p" >/dev/null 2>&1; then err "autotest: trabajo real tras el cierre debió marcar rancio"; f=1; fi

  # Estado rancio: el ancla no coincide con HEAD → debe detectarlo.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26  ·  commit 0000000  ·  cierre limpio: sí\n' > "$p/CONTINUAR.md"
  cmd_reconciliar "$p" >/dev/null 2>&1; rcx=$?
  [ "$rcx" -eq 3 ] || { err "autotest: un ancla que no se resuelve debía dar 3 (no reconciliable), dio $rcx"; f=1; }

  # Cierre anclado en OTRA rama. El ancla de main comparado contra una rama de
  # feature cuenta como "trabajo nuevo" todo lo que la rama ya tenía desde antes
  # (pasó el 2026-09-08: un rebase trajo a la rama del gate el CONTINUAR de main,
  # con su ancla). Mecánicamente no se puede decidir → 3 (no se puede reconciliar),
  # nunca rancio: un veredicto falso hace que se le deje de creer al panel.
  local p4="$t/rama-demo"; mkdir -p "$p4"
  ( cd "$p4" && git init -q && git config user.email t@t && git config user.name t )
  : > "$p4/base.txt"; ( cd "$p4" && git add -A && git commit -qm base )
  local M RM PLANTILLA rc4
  M="$(cd "$p4" && git rev-parse --short HEAD)"
  RM="$(cd "$p4" && git rev-parse --abbrev-ref HEAD)"   # no se asume el nombre por defecto
  PLANTILLA='# CONTINUAR — rama-demo  ·  cierre 2026-09-08  ·  commit %s (rama %s)  ·  cierre limpio: sí\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Correr: make run\n\n## Bloqueadores / esperas\n- Ninguno\n'
  printf "$PLANTILLA" "$M" "$RM" > "$p4/CONTINUAR.md"
  ( cd "$p4" && git add -A && git commit -qm "cierre: papeleo" )
  cmd_reconciliar "$p4" >/dev/null 2>&1 \
    || { err "autotest: anclado en su propia rama y solo papeleo debió salir fresco"; f=1; }
  # El contrato lee la PRIMERA línea: la forma nueva del encabezado tiene que pasarle.
  cmd_contrato "$p4" >/dev/null 2>&1 \
    || { err "autotest: el contrato debe aceptar el encabezado con rama"; f=1; }
  # La rama de feature trae trabajo real propio; el ancla sigue siendo el de la otra.
  ( cd "$p4" && git checkout -q -b feature && : > trabajo.sh && git add -A && git commit -qm "trabajo de la rama" )
  cmd_reconciliar "$p4" >/dev/null 2>&1; rc4=$?
  [ "$rc4" -eq 3 ] \
    || { err "autotest: ancla de otra rama debe dar 3 (no reconciliable), dio $rc4"; f=1; }
  # ...pero no puede volverse un agujero. Re-anclado en ESTA rama: fresco, y el
  # trabajo real posterior vuelve a ser rancio.
  local B; B="$(cd "$p4" && git rev-parse --short HEAD)"
  printf "$PLANTILLA" "$B" feature > "$p4/CONTINUAR.md"
  ( cd "$p4" && git add -A && git commit -qm "cierre: papeleo de la rama" )
  cmd_reconciliar "$p4" >/dev/null 2>&1 \
    || { err "autotest: re-anclado en su rama debió salir fresco"; f=1; }
  : > "$p4/mas-trabajo.sh"; ( cd "$p4" && git add -A && git commit -qm "más trabajo" )
  cmd_reconciliar "$p4" >/dev/null 2>&1; rc4=$?
  [ "$rc4" -eq 1 ] || { err "autotest: trabajo real tras el cierre en la misma rama debía dar 1 (rancio), dio $rc4"; f=1; }
  # Y lo que está SIN COMMITEAR es trabajo sin cerrar en cualquier rama: eso sigue
  # siendo rancio aunque el ancla venga de otra rama (si no, el 3 apagaría el aviso).
  printf "$PLANTILLA" "$M" "$RM" > "$p4/CONTINUAR.md"
  ( cd "$p4" && git add -A && git commit -qm "papeleo con ancla de otra rama" )
  : > "$p4/sucio.sh"
  cmd_reconciliar "$p4" >/dev/null 2>&1; rc4=$?
  [ "$rc4" -eq 1 ] \
    || { err "autotest: lo sin commitear debe marcar rancio aunque el ancla sea de otra rama, dio $rc4"; f=1; }
  rm -f "$p4/sucio.sh"
  # El campo "cierre limpio" se CALCULA. Antes se estampaba "sí" siempre, así que
  # no podía delatar un cierre sucio y la rama de reconciliar que reacciona a "no"
  # era inalcanzable (medido el 2026-09-11: 20 de 20 CONTINUAR.md decían "sí", y
  # uno de ellos tenía trabajo hecho y probado sin commitear desde hacía tres días).
  local p6="$t/limpio-demo"; mkdir -p "$p6"
  ( cd "$p6" && git init -q && git config user.email t@t && git config user.name t )
  : > "$p6/app.js"; ( cd "$p6" && git add -A && git commit -qm base )
  cmd_anclar "$p6" | grep -q 'cierre limpio: sí' \
    || { err "autotest: árbol limpio debe anclar 'cierre limpio: sí'"; f=1; }
  # El papeleo del propio /cierre está pendiente POR DISEÑO en el momento de anclar
  # (se commitea después): no puede contar como trabajo sin cerrar.
  : > "$p6/CONTINUAR.md"; mkdir -p "$p6/docs"; : > "$p6/docs/bitacora.md"
  cmd_anclar "$p6" | grep -q 'cierre limpio: sí' \
    || { err "autotest: el papeleo del cierre no debe marcar el cierre como sucio"; f=1; }
  # Un RENOMBRE cuenta por sus DOS lados: mover un archivo real a un nombre de
  # papeleo no puede blanquear el cierre (el mismo hueco que `reconciliar` ya
  # documentaba y que la primera versión de limpio_de reabrió — aviso 4 del revisor
  # adversario del gate de push, 2026-09-12).
  # El archivo lleva contenido a propósito: git no detecta renombres entre blobs
  # vacíos, y con 'D' + 'A' el caso pasaría también con el parseo viejo — no fijaría
  # la regresión que dice fijar (aviso 6 del revisor adversario).
  printf 'contenido real para que git detecte el renombre\n' > "$p6/app.js"
  ( cd "$p6" && git add -A && git commit -qm "app con contenido" && git mv app.js CLAUDE.md )
  ( cd "$p6" && git status --porcelain | grep -q '^R' ) \
    || { err "autotest: el caso del renombre no produjo un renombre ('R'), no prueba nada"; f=1; }
  cmd_anclar "$p6" | grep -q 'cierre limpio: no' \
    || { err "autotest: mover un archivo real a un nombre de papeleo no blanquea el cierre"; f=1; }
  ( cd "$p6" && git mv CLAUDE.md app.js )
  # ...pero trabajo real sin commitear sí, esté indexado o no.
  mkdir -p "$p6/web"; : > "$p6/web/nuevo.js"
  cmd_anclar "$p6" | grep -q 'cierre limpio: no' \
    || { err "autotest: trabajo real sin commitear debe anclar 'cierre limpio: no'"; f=1; }
  ( cd "$p6" && git add web/nuevo.js )
  cmd_anclar "$p6" | grep -q 'cierre limpio: no' \
    || { err "autotest: trabajo indexado sin commitear también es cierre sucio"; f=1; }
  # Y lo que anclar escribe como "no", reconciliar tiene que saber leerlo. La rama se
  # aísla a propósito sobre un árbol LIMPIO: con archivos sucios presentes, reconciliar
  # ya devolvería 1 por otra rama y el caso pasaría aunque la lectura del campo se
  # borrara del script (aviso 2 del revisor adversario).
  ( cd "$p6" && git add -A && git commit -qm "todo commiteado" )
  printf '# CONTINUAR — limpio-demo  ·  cierre 2026-09-12  ·  commit %s  ·  cierre limpio: no\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Correr: make run\n\n## Bloqueadores / esperas\n- Ninguno\n' \
    "$(cd "$p6" && git rev-parse --short HEAD)" > "$p6/CONTINUAR.md"
  ( cd "$p6" && git add -A && git commit -qm "papeleo" )
  [ -z "$(sucios_de "$p6")" ] || { err "autotest: el caso del 'no' debe correr sobre un árbol limpio"; f=1; }
  cmd_reconciliar "$p6" >/dev/null 2>&1; local rc6=$?
  [ "$rc6" -eq 1 ] \
    || { err "autotest: reconciliar debe reaccionar al 'no' del encabezado sobre árbol limpio, dio $rc6"; f=1; }
  # Sin git no se inventa un veredicto.
  local p7="$t/sin-git-demo"; mkdir -p "$p7"
  cmd_anclar "$p7" | grep -q 'cierre limpio: sin-git' \
    || { err "autotest: sin repo git el campo no se inventa"; f=1; }
  # Y si git EXISTE pero falla, el campo tampoco se inventa: el fallo no puede abrir
  # hacia el veredicto optimista. Es la rama que nadie ejercita en uso normal — y que
  # el revisor adversario del gate de push señaló como vendida y no probada.
  local p8="$t/git-roto"; mkdir -p "$p8"
  ( cd "$p8" && git init -q && git config user.email t@t && git config user.name t )
  : > "$p8/a.txt"; ( cd "$p8" && git add -A && git commit -qm base )
  printf 'esto no es un index de git' > "$p8/.git/index"
  cmd_anclar "$p8" | grep -q 'cierre limpio: no-se-pudo-saber' \
    || { err "autotest: con git roto el campo debe decir no-se-pudo-saber, no 'sí'"; f=1; }
  printf '# CONTINUAR — x  ·  cierre 2026-09-12  ·  commit 0000000  ·  cierre limpio: sí\n' > "$p8/CONTINUAR.md"
  cmd_reconciliar "$p8" >/dev/null 2>&1; local rc8=$?
  [ "$rc8" -eq 3 ] \
    || { err "autotest: con git roto reconciliar debe dar 3 (no reconciliable), dio $rc8"; f=1; }
  # Un archivo llamado '?' es una ruta válida, no una señal de error.
  local p9="$t/ruta-rara"; mkdir -p "$p9"
  ( cd "$p9" && git init -q && git config user.email t@t && git config user.name t )
  : > "$p9/base.txt"; ( cd "$p9" && git add -A && git commit -qm base )
  : > "$p9/?"
  cmd_anclar "$p9" | grep -q 'cierre limpio: no' \
    || { err "autotest: un archivo llamado '?' es trabajo sin commitear, no un error"; f=1; }

  # `anclar` estampa la rama actual, y en HEAD desprendido no inventa una.
  cmd_anclar "$p4" | grep -q '(rama feature)' \
    || { err "autotest: anclar debe estampar la rama actual"; f=1; }
  ( cd "$p4" && git checkout -q --detach HEAD )
  if cmd_anclar "$p4" | grep -q '(rama '; then err "autotest: en HEAD desprendido no se estampa NINGUNA rama"; f=1; fi

  # El ancla que COINCIDE con HEAD es prueba directa de que no hay nada que
  # reconciliar, valga la rama que valga: salir de main con `checkout -b` deja el
  # estado fresco, no un caso sin resolver. Por eso la igualdad se mira ANTES del
  # cruce de ramas. (Aviso 3 de la revisión adversaria del 2026-09-08.)
  local p5="$t/rama-nueva"; mkdir -p "$p5"
  ( cd "$p5" && git init -q && git config user.email t@t && git config user.name t )
  : > "$p5/base.txt"; ( cd "$p5" && git add -A && git commit -qm base )
  printf "$PLANTILLA" "$(cd "$p5" && git rev-parse --short HEAD)" \
                      "$(cd "$p5" && git rev-parse --abbrev-ref HEAD)" > "$p5/CONTINUAR.md"
  ( cd "$p5" && git checkout -q -b recien-creada )
  cmd_reconciliar "$p5" >/dev/null 2>&1 \
    || { err "autotest: ancla == HEAD debe salir fresco aunque la rama sea otra"; f=1; }

  # `git status --porcelain` no se parsea por campos: en un renombre el segundo campo
  # es el ORIGEN, así que mover la ficha a un archivo real se colaba como papeleo y el
  # veredicto salía fresco — y bajo el 3 esta es la única red que queda. (Aviso 3 de
  # la revisión adversaria del 2026-09-08.) Repo aparte: aquí la rama SÍ coincide, para que el
  # veredicto lo decida el chequeo de lo sin commitear y no el cruce de ramas.
  local p6 rc6; p6="$t/renombre-demo"; mkdir -p "$p6"
  ( cd "$p6" && git init -q && git config user.email t@t && git config user.name t )
  : > "$p6/CLAUDE.md"; ( cd "$p6" && git add -A && git commit -qm ficha )
  printf "$PLANTILLA" "$(cd "$p6" && git rev-parse --short HEAD)" \
                      "$(cd "$p6" && git rev-parse --abbrev-ref HEAD)" > "$p6/CONTINUAR.md"
  cmd_reconciliar "$p6" >/dev/null 2>&1 \
    || { err "autotest: el repo del caso de renombre debía partir de fresco"; f=1; }
  ( cd "$p6" && git mv CLAUDE.md codigo.py )
  cmd_reconciliar "$p6" >/dev/null 2>&1; rc6=$?
  [ "$rc6" -eq 1 ] || { err "autotest: renombrar papeleo a un archivo real debía dar 1 (rancio), dio $rc6"; f=1; }
  # ...y el hueco del revés, en repo aparte porque deshacer el renombre dejaría el
  # árbol limpio: un archivo real que DESAPARECE hacia un nombre de papeleo. Quedarse
  # con un solo lado del "->" no cierra el agujero, lo invierte.
  local p7="$t/renombre-inverso"; mkdir -p "$p7"
  ( cd "$p7" && git init -q && git config user.email t@t && git config user.name t )
  : > "$p7/codigo.py"; ( cd "$p7" && git add -A && git commit -qm codigo )
  printf "$PLANTILLA" "$(cd "$p7" && git rev-parse --short HEAD)" \
                      "$(cd "$p7" && git rev-parse --abbrev-ref HEAD)" > "$p7/CONTINUAR.md"
  ( cd "$p7" && git mv codigo.py CLAUDE.md )
  cmd_reconciliar "$p7" >/dev/null 2>&1; rc6=$?
  [ "$rc6" -eq 1 ] || { err "autotest: un archivo real que desaparece hacia papeleo debía dar 1 (rancio), dio $rc6"; f=1; }

  # El hueco del renombre también existe en lo YA COMMITEADO: `git diff --name-only`
  # detecta renombres e imprime solo el destino, así que un commit que mueve un archivo
  # real a un nombre de papeleo salía "fresco". Con --no-renames se ve el borrado.
  local p8 rc8; p8="$t/renombre-commiteado"; mkdir -p "$p8"
  ( cd "$p8" && git init -q && git config user.email t@t && git config user.name t )
  : > "$p8/codigo.py"; ( cd "$p8" && git add -A && git commit -qm base )
  printf "$PLANTILLA" "$(cd "$p8" && git rev-parse --short HEAD)" \
                      "$(cd "$p8" && git rev-parse --abbrev-ref HEAD)" > "$p8/CONTINUAR.md"
  ( cd "$p8" && git mv codigo.py CLAUDE.md && git add -A && git commit -qm "se va un archivo real" )
  cmd_reconciliar "$p8" >/dev/null 2>&1; rc8=$?
  [ "$rc8" -eq 1 ] || { err "autotest: un renombre COMMITEADO de archivo real a papeleo debía dar 1 (rancio), dio $rc8"; f=1; }

  [ "$f" -eq 0 ] && ok "autotest: rotación sin pérdida, contrato y reconciliación funcionan"
  return $f
}

case "$CMD" in
  rotar)       shift; cmd_rotar "$@" ;;
  anclar)      shift; cmd_anclar "$@" ;;
  reconciliar) shift; cmd_reconciliar "$@" ;;
  contrato)    shift; cmd_contrato "$@" ;;
  autotest)    cmd_autotest ;;
  *) sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
