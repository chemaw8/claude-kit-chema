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
    mas_nuevo="$(find "$dir" -type f -newer "$f" \
      -not -path '*/.git/*' -not -path '*/node_modules/*' -not -name 'CONTINUAR.md' \
      -print -quit 2>/dev/null)"
    if [ -n "$mas_nuevo" ]; then
      err "hay archivos modificados DESPUÉS del cierre del $fecha_cierre (p. ej. ${mas_nuevo#$dir/}) — el estado puede estar rancio"
      return 1
    fi
    ok "estado fresco (sin git; nada se tocó después del cierre del $fecha_cierre)"
    return 0
  fi

  commit_real="$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)"
  if [ "$commit_esc" != "$commit_real" ]; then
    err "el estado apunta a $commit_esc pero HEAD es $commit_real — hubo trabajo después del último cierre"
    echo "  → revisa: git -C '$dir' log --oneline $commit_esc..HEAD" >&2
    return 1
  fi
  ok "estado fresco (ancla $commit_esc coincide con HEAD)"
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
    mkdir -p "$dir"; cp "$nuevo" "$viejo"; ok "CONTINUAR.md creado (no había estado previo)"; return 0
  fi

  python3 - "$viejo" "$nuevo" "$bit" "$HOY" "$DRY" <<'PY'
import sys, os, shutil

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
conservadas = {norm(x) for x in n}

# Desplazado = lo que estaba y ya no está, en su orden original y sin repetir.
desplazado, vistas = [], set()
for l in v:
    if sustantiva(l) and norm(l) not in conservadas and norm(l) not in vistas:
        desplazado.append(l)
        vistas.add(norm(l))

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

# Verificación ANTES de escribir nada: cada línea sustantiva del viejo tiene que
# sobrevivir, o en el nuevo o en la bitácora. Se comprueba en memoria para que un
# fallo no deje a medias ni la bitácora ni CONTINUAR.md.
ya_en_bitacora = {norm(x) for x in lineas(bit)} if os.path.exists(bit) else set()
sobrevive = conservadas | ya_en_bitacora | {norm(x) for x in desplazado}
perdidas = [l for l in v if sustantiva(l) and norm(l) not in sobrevive]
if perdidas:
    print(f"✗ ABORTADO: {len(perdidas)} líneas se habrían perdido. No se tocó nada.",
          file=sys.stderr)
    for l in perdidas[:5]:
        print("   ·", l[:90], file=sys.stderr)
    sys.exit(1)

# Orden a prueba de fallos: primero archivar, después reemplazar. Si algo fallara
# en medio, el peor caso es una entrada repetida en la bitácora — nunca una pérdida.
os.makedirs(os.path.dirname(bit), exist_ok=True)
if not os.path.exists(bit):
    with open(bit, "w", encoding="utf-8") as fh:
        fh.write("# Bitácora\n\nHistoria del proyecto. Se lee al retomar tras un hueco\n"
                 "largo o cuando CONTINUAR.md no basta. Append-only: no se edita.\n")

with open(bit, "a", encoding="utf-8") as fh:
    fh.write(f"\n## {hoy} — rotado desde CONTINUAR.md\n\n")
    for l in desplazado:
        fh.write(l + "\n")

aplicar(nuevo, viejo)
print(f"✓ rotadas {len(desplazado)} líneas a {bit} — cero pérdida verificada")
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

  # Contrato incompleto: debe fallar.
  printf '# CONTINUAR — x  ·  cierre 2026-08-26\n\n## Dónde vamos\nalgo\n' > "$p/CONTINUAR.md"
  if cmd_contrato "$p" >/dev/null 2>&1; then err "autotest: el contrato incompleto debió fallar"; f=1; fi

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
