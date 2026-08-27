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
#                              salida 0 = fresco · 1 = rancio · 2 = no hay CONTINUAR.
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
    local h
    h="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"
    if [ -n "$h" ]; then echo "commit $h"; else echo "commit ninguno-aún"; fi
  else
    echo "sin-git"
  fi
}

nombre_de() { basename "$(cd "$1" && pwd)"; }

# ── anclar ────────────────────────────────────────────────────────────────
cmd_anclar() {
  local dir="${1:-.}"
  printf '# CONTINUAR — %s  ·  cierre %s  ·  %s  ·  cierre limpio: sí\n' \
    "$(nombre_de "$dir")" "$HOY" "$(ancla_de "$dir")"
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
      err "CONTINUAR.md sin fecha ni ancla en el encabezado — no se puede reconciliar"; return 1
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
  local PAPELEO='(^|/)(CONTINUAR|CLAUDE|DECISIONES)\.md$|(^|/)docs/bitacora\.md$|(^|/)\.claude/settings\.json$|(^|/)\.gitignore$'

  if [ "$commit_esc" != "$commit_real" ]; then
    local cambiados otros
    cambiados="$(git -C "$dir" diff --name-only "$commit_esc..HEAD" 2>/dev/null)"
    if [ $? -ne 0 ]; then
      # el ancla ya no existe en el árbol (rebase, historia reescrita)
      err "el ancla $commit_esc no está en el historial — no se puede reconciliar; revisa a mano"
      return 1
    fi
    # grep devuelve 1 si no queda nada tras filtrar el papeleo: es el caso fresco,
    # no un error — por eso se filtra sobre la variable, sin mirar su $?.
    otros="$(printf '%s\n' "$cambiados" | grep -vE "$PAPELEO")"
    if [ -n "$otros" ]; then
      err "hubo trabajo real después del último cierre — archivos fuera del papeleo cambiaron:"
      printf '%s\n' "$otros" | sed 's/^/     · /' >&2
      echo "  → revisa: git -C '$dir' log --oneline $commit_esc..HEAD" >&2
      return 1
    fi
  fi

  # Cambios SIN commitear que no sean el papeleo también son trabajo sin cerrar.
  local sucios
  sucios="$(git -C "$dir" status --porcelain 2>/dev/null | awk '{print $2}' | grep -vE "$PAPELEO")"
  if [ -n "$sucios" ]; then
    err "hay cambios sin commitear después del cierre:"
    printf '%s\n' "$sucios" | sed 's/^/     · /' >&2
    return 1
  fi

  if [ "$commit_esc" = "$commit_real" ]; then
    ok "estado fresco (ancla $commit_esc coincide con HEAD)"
  else
    ok "estado fresco (desde el ancla $commit_esc solo se movió el papeleo del cierre)"
  fi
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
# de `.jsonl`. El token arranca en \w, así que un `./` o `/` inicial no se captura.
EXT = r"(?:py|sh|md|sql|R|rb|go|js|mjs|ts|tsx|ipynb)"
PAT = re.compile(rf"[\w][\w./-]*\.{EXT}(?![\w.])")
citados, faltantes = set(), []
for t in tramos:
    for linea in t.splitlines():
        # Se valida por CAMPO (delimitado por espacios o backticks), no por línea
        # entera: así un glob o una URL en la línea no apaga la comprobación de un
        # archivo real citado al lado, y un '?' de la prosa no desactiva nada.
        for campo in re.split(r"[\s`]+", linea):
            if "*" in campo or "?" in campo or "://" in campo:
                continue                     # glob o URL: no es un archivo local
            for m in PAT.findall(campo):
                c = m.strip(".,;:")
                if c.startswith("/"):        # ruta absoluta: no se valida
                    continue
                citados.add(c[2:] if c.startswith("./") else c)
for c in sorted(citados):
    if not os.path.exists(os.path.join(raiz, c)):
        faltantes.append(c)
if faltantes:
    for c in faltantes:
        print(f"✗ 'Cómo retomar' cita un archivo que no existe: {c}", file=sys.stderr)
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
desplazado = []
for l in v:
    if not sustantiva(l):
        continue
    k = norm(l)
    if restante[k] > 0:
        restante[k] -= 1          # esta ocurrencia sobrevive en el nuevo
    else:
        desplazado.append(l)      # esta ocurrencia no está en el nuevo → se archiva

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
    for l in desplazado[:5]:
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
    for l in desplazado:
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

  local f=0
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

  # URL en "Cómo retomar": no es un archivo local, no debe fallar.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\na\n\n## Siguiente paso\n- [ ] x\n\n## Cómo retomar\n- Guía: https://raw.githubusercontent.com/foo/bar/main/README.md\n- Correr: `python scripts/run.py`\n\n## Bloqueadores / esperas\n- Ninguno\n' > "$p/CONTINUAR.md"
  if ! cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: una URL en Cómo retomar no debe fallar el contrato"; f=1; fi

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
  if cmd_reconciliar "$p" >/dev/null 2>&1; then err "autotest: debió detectar el estado rancio"; f=1; fi

  [ "$f" -eq 0 ] && ok "autotest: rotación sin pérdida, contrato y reconciliación funcionan"
  return $f
}

case "$CMD" in
  rotar)       shift; cmd_rotar "$@" ;;
  anclar)      shift; cmd_anclar "$@" ;;
  reconciliar) shift; cmd_reconciliar "$@" ;;
  contrato)    shift; cmd_contrato "$@" ;;
  autotest)    cmd_autotest ;;
  *) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
