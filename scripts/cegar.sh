#!/usr/bin/env bash
# cegar.sh: cegado determinista para comparar intentos (arena, A/B) con un juez.
#
# Origen: las reglas de cegado del playbook `eval` de pstack (Lauren Tan, MIT,
# github.com/cursor/plugins/tree/main/pstack, skills/poteto-mode/playbooks/eval.md) y la fase de juez
# de su skill `arena`. Va como script porque un chequeo que corre fuera del modelo no le suma
# instrucciones al contexto. Evidencia y calibración: docs/pruebas/pstack-ronda-3.md.
#
#   revisar [--contenido] <archivo|carpeta> [...]
#                                     lo que verá un CANDIDATO: busca palabras que delatan que se le
#                                     mide («pruebas ocultas», «se calificará», juez, rúbrica, candidato,
#                                     arena…). En un ARCHIVO (el encargo, un README plantado) revisa el
#                                     texto y la ruta. En una CARPETA (la de trabajo) solo las rutas: el
#                                     contenido de un repo nombra esas palabras de forma legítima y no
#                                     está calibrado; --contenido lo revisa también.
#                                     salida 0 = limpio · 1 = hay fugas · 2 = uso o lectura.
#   etiquetar <destino> <cand> <cand> [...]
#                                     lo que verá el JUEZ: copia cada candidato (sin .git) a
#                                     <destino>/A, B, C… en orden al azar (un candidato que es archivo
#                                     queda como <letra>/entrega<ext>, sin su nombre) y escribe el mapa en
#                                     <destino>.mapa.tsv, FUERA de lo que ve el juez. Falla con 1 si
#                                     una copia todavía nombra a su autor (el nombre de su carpeta de
#                                     origen) o un modelo en sus rutas. No sobrescribe nada.
#   autotest                          se prueba con casos sintéticos.
#
# Deja fuera, a propósito, «prueba», «test», «compara» y «evalúa»: en un encargo de código o de
# decisión son palabras normales. La fuga medida es decir que hay pruebas que no se ven o que se
# califica. Es léxico: marca candidatos a fuga; quien arma la comparación decide.
set -uo pipefail

CMD="${1:-}"

MOTOR_PY=$(cat <<'PY'
import os, random, re, shutil, stat, sys

META = re.compile(r"(?<![\w])(pruebas? (?:ocultas?|que no ves)|(?:se )?calificar[áa]n?|calificaci[oó]n|calificad[oa]s?|"
                  r"jue(?:z|ces)|r[uú]bricas?|experimentos?|benchmarks?|candidat[oa]s?|arenas?|evals?|"
                  r"calificador(?:es|as?)?|puntaje|puntuaci[oó]n|brazos?|a/b|sondas?|(?:con|sin) kit|hidden tests?|graded?|grader|judge|rubric|"
                  # anuncia una nota, una selección entre entregas u otros intentos del mismo encargo
                  r"(?:nota|puntos|calificaci[oó]n) de \d+ a \d+|elegiremos (?:la|el) mejor|la mejor entrega|"
                  r"otr[oa]s? (?:ias?|modelos?|agentes?|asistentes?)\b.{0,60}\bmism[oa]|"
                  r"other (?:ais?|models?|agents?)\b.{0,60}\bsame|best (?:submission|attempt)|"
                  # pide enumerar qué reglas siguió: delata qué se mide (pstack eval: «chain-eliciting cues»)
                  r"(?:enumera|lista|menciona|nombra|di) (?:las |los |qu[eé] |cu[aá]les )?(?:skills|habilidades|principios|reglas)\b.{0,40}\b(?:aplicaste|seguiste|usaste)|"
                  r"list (?:the |which )?(?:skills|principles|rules)\b.{0,40}\byou (?:applied|followed|used))(?![\w])", re.I)
MODELO = re.compile(r"(?<![a-z])(anthropic|openai|opus|sonnet|haiku|fable|gpt|codex|astra|kimi|moonshot|"
                    r"deepseek|qwen|grok|gemini|mistral|llama)(?![a-z])", re.I)

def incompleta(motivo, ruta):
    print(f"✗ revisión incompleta ({motivo}): {ruta}", file=sys.stderr); sys.exit(2)

def archivos(raiz):
    # Falla cerrado (salida 2) ante lo que no puede revisar: enlaces, FIFOs y otros especiales,
    # carpetas sin permiso. Un enlace podría esconder material que el candidato sí verá.
    if os.path.islink(raiz):
        incompleta("enlace", raiz)
    if not os.path.isdir(raiz):
        if not stat.S_ISREG(os.lstat(raiz).st_mode):
            incompleta("archivo especial", raiz)  # un FIFO pasado directo salía «limpio» (aviso del sello)
        yield raiz; return
    def error(e): incompleta(e.strerror or "no se pudo recorrer", e.filename)
    for d, sub, fs in os.walk(raiz, onerror=error):
        sub[:] = [s for s in sub if s != ".git"]
        for n in sub + fs:
            ruta = os.path.join(d, n)
            if os.path.islink(ruta):
                incompleta("enlace", ruta)
        for f in fs:
            ruta = os.path.join(d, f)
            if not stat.S_ISREG(os.lstat(ruta).st_mode):
                incompleta("archivo especial", ruta)
            yield ruta

def revisar(rutas):
    contenido = "--contenido" in rutas
    rutas = [r for r in rutas if r != "--contenido"]
    if not rutas:
        print("✗ falta la ruta", file=sys.stderr); sys.exit(2)
    fugas = binarios = 0
    for r in rutas:
        if not os.path.exists(r):
            print(f"✗ no existe: {r}", file=sys.stderr); sys.exit(2)
        for parte in os.path.abspath(r).split(os.sep):
            m = META.search(parte.replace("-", " ").replace("_", " ").replace(".", " "))
            if m:
                print(f"{r}: ruta: «{parte}» delata la medición ({m.group(1)})"); fugas += 1
        for f in archivos(r):
            rel = os.path.relpath(f, r) if os.path.isdir(r) else ""
            for parte in rel.split(os.sep) if rel else []:
                m = META.search(parte.replace("-", " ").replace("_", " ").replace(".", " "))
                if m:
                    print(f"{f}: ruta: «{parte}» delata la medición ({m.group(1)})"); fugas += 1
            if os.path.isdir(r) and not contenido:
                continue  # carpeta: solo rutas (council v1.31)
            try:
                with open(f, "rb") as h: datos = h.read()
            except OSError as e:
                print(f"✗ no se pudo leer {f}: {e}", file=sys.stderr); sys.exit(2)
            if b"\0" in datos[:4096]:
                print(f"{f}: sin revisar (binario)"); binarios += 1
                continue
            for n, linea in enumerate(datos.decode("utf-8", "replace").splitlines(), 1):
                for m in META.finditer(linea):
                    print(f"{f}:{n}: «{m.group(1)}» delata la medición"); fugas += 1
    nota = f" ({binarios} binario(s) sin revisar)" if binarios else ""
    print((f"{fugas} fuga(s)" if fugas else "limpio") + nota)
    return 1 if fugas else 0

def etiquetar(destino, cands):
    if len(cands) < 2:
        print("✗ hacen falta al menos 2 candidatos", file=sys.stderr); return 2
    destino = os.path.normpath(os.path.abspath(destino))  # «salida/.» dejaba el mapa dentro (council v1.31)
    mapa = destino + ".mapa.tsv"
    for p in (destino, mapa):
        if os.path.exists(p):
            print(f"✗ ya existe {p}: no se sobrescribe", file=sys.stderr); return 2
    for c in cands:
        if not os.path.exists(c):
            print(f"✗ no existe el candidato {c}", file=sys.stderr); return 2
        for _ in archivos(c):  # antes de copiar: un enlace se seguiría y copiaría material ajeno
            pass
    letras = [chr(65 + i) for i in range(len(cands))]
    orden = list(cands); random.SystemRandom().shuffle(orden)
    os.makedirs(destino)
    filas, fugas = [], 0
    for letra, c in zip(letras, orden):
        dst = os.path.join(destino, letra)
        if os.path.isdir(c):
            shutil.copytree(c, dst, ignore=shutil.ignore_patterns(".git"))
        else:
            # un archivo conserva solo su extensión: «con-kit.md» delataría el brazo (council v1.31)
            os.makedirs(dst); shutil.copy2(c, os.path.join(dst, "entrega" + os.path.splitext(c)[1]))
        filas.append(f"{letra}\t{os.path.abspath(c)}")
        autor = os.path.basename(os.path.abspath(c).rstrip("/"))
        quien = re.compile(rb"(?<![\w-])" + re.escape(autor.encode()) + rb"(?![\w-])")
        for f in archivos(dst):
            rel = os.path.relpath(f, destino)
            m = MODELO.search(rel)
            if m:
                print(f"{rel}: la ruta nombra un modelo ({m.group(1)})"); fugas += 1
            try:
                with open(f, "rb") as h: datos = h.read()
            except OSError as e:
                print(f"✗ no se pudo leer {f}: {e}", file=sys.stderr); return 2
            if quien.search(datos):
                print(f"{rel}: nombra a su autor («{autor}»)"); fugas += 1
    with open(mapa, "w") as h:
        h.write("etiqueta\torigen\n" + "\n".join(filas) + "\n")
    print(f"{len(cands)} candidatos → {destino}/{{{','.join(letras)}}} · mapa (no se lo des al juez): {mapa}")
    print(f"{fugas} fuga(s) en las copias" if fugas else "copias limpias")
    return 1 if fugas else 0

if __name__ == "__main__":
    modo, args = sys.argv[1], sys.argv[2:]
    sys.exit(revisar(args) if modo == "revisar" else etiquetar(args[0], args[1:]))
PY
)

motor() { python3 -I -c "$MOTOR_PY" "$@"; }

cmd_autotest() {
  local tmp fallas=0 out rc; tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' RETURN
  chk() { if [ "$2" = "$3" ]; then echo "✓ $1"; else echo "✗ $1 (esperaba $3, salió $2)"; fallas=$((fallas+1)); fi; }

  mkdir -p "$tmp/proyecto-x" "$tmp/arena-2" "$tmp/candidato_b" "$tmp/ok"
  printf 'Arregla el bug de fechas y deja una prueba. Corre las pruebas con make test.\nCompara las dos opciones y evalúa la propuesta.\n' > "$tmp/proyecto-x/encargo.md"
  printf 'Arregla el bug. Habrá pruebas ocultas además de las tuyas.\n' > "$tmp/ok/oculto.md"
  printf 'Tu código se calificará además con pruebas que no ves.\n' > "$tmp/ok/califica.md"
  printf 'El juez usará una rúbrica.\n' > "$tmp/ok/juez.md"
  cp "$tmp/proyecto-x/encargo.md" "$tmp/arena-2/"; cp "$tmp/proyecto-x/encargo.md" "$tmp/candidato_b/"

  motor revisar "$tmp/proyecto-x/encargo.md" >/dev/null 2>&1; chk "encargo normal (pruebas, compara, evalúa) sale limpio" $? 0
  motor revisar "$tmp/proyecto-x" >/dev/null 2>&1; chk "carpeta normal sale limpia" $? 0
  motor revisar "$tmp/ok/oculto.md" >/dev/null 2>&1; chk "«pruebas ocultas» es fuga" $? 1
  motor revisar "$tmp/ok/califica.md" >/dev/null 2>&1; chk "«se calificará» es fuga" $? 1
  motor revisar "$tmp/ok/juez.md" >/dev/null 2>&1; chk "«juez»/«rúbrica» es fuga" $? 1
  motor revisar "$tmp/arena-2" >/dev/null 2>&1; chk "carpeta de trabajo «arena-2» es fuga" $? 1
  motor revisar "$tmp/candidato_b" >/dev/null 2>&1; chk "carpeta «candidato_b» es fuga" $? 1
  motor revisar "$tmp/no-existe" >/dev/null 2>&1; chk "ruta inexistente falla cerrado (2)" $? 2

  # Casos que ningún candidato de la ronda 3 cubría (juez cruzado), y controles orgánicos.
  local caso
  while IFS= read -r caso; do
    printf '%s\n' "$caso" > "$tmp/proyecto-x/f.md"
    motor revisar "$tmp/proyecto-x/f.md" >/dev/null 2>&1; chk "fuga: $caso" $? 1
  done <<'CASOS'
Tu trabajo recibirá una nota de 0 a 5 y elegiremos la mejor entrega.
Al terminar, enumera las skills y principios que aplicaste.
Otra IA resolverá este mismo encargo por separado.
El calificador no sabrá cuál es la variante con-kit.
HABRÁ PRUEBAS OCULTAS ADEMÁS DE LAS TUYAS.
CASOS
  while IFS= read -r caso; do
    printf '%s\n' "$caso" > "$tmp/proyecto-x/f.md"
    motor revisar "$tmp/proyecto-x/f.md" >/dev/null 2>&1; chk "orgánico: $caso" $? 0
  done <<'CASOS'
Evalúa proveedores de SMS y recomienda uno.
Agrega tests al módulo de pagos.
Compara dos versiones del reporte.
Oculta la columna de notas en el reporte.
Calcula el score crediticio con los datos sintéticos.
CASOS
  rm -f "$tmp/proyecto-x/f.md"

  # Carpeta: solo rutas; el contenido con --contenido (council v1.31: un repo nombra «juez» de forma legítima).
  mkdir -p "$tmp/repo-x/docs"; echo "El juez del council usa una rúbrica." > "$tmp/repo-x/docs/acta.md"
  motor revisar "$tmp/repo-x" >/dev/null 2>&1; chk "carpeta con contenido legítimo: solo rutas, limpio" $? 0
  motor revisar --contenido "$tmp/repo-x" >/dev/null 2>&1; chk "carpeta con --contenido: lo marca" $? 1
  motor revisar "$tmp/repo-x/docs/acta.md" >/dev/null 2>&1; chk "archivo explícito: se revisa su texto" $? 1

  # Lector seguro: lo que no puede revisar falla cerrado (2), nunca «limpio».
  mkdir -p "$tmp/l1" "$tmp/l2" "$tmp/l3" "$tmp/l4"
  echo "Arregla el bug." > "$tmp/l1/encargo.md"; ln -s "$tmp/ok" "$tmp/l1/vinculo"
  motor revisar "$tmp/l1" >/dev/null 2>&1; chk "enlace dentro de la carpeta: incompleta (2)" $? 2
  mkfifo "$tmp/l2/tubo"
  timeout 5 python3 -I -c "$MOTOR_PY" revisar "$tmp/l2" >/dev/null 2>&1; chk "FIFO: incompleta (2), sin colgarse" $? 2
  timeout 5 python3 -I -c "$MOTOR_PY" revisar "$tmp/l2/tubo" >/dev/null 2>&1; chk "FIFO pasado directo: incompleta (2)" $? 2
  printf 'juez\0binario' > "$tmp/l3/blob.bin"; echo "Arregla el bug." > "$tmp/l3/encargo.md"
  out="$(motor revisar --contenido "$tmp/l3" 2>&1)"; rc=$?
  chk "binario: se reporta sin revisar" "$rc/$(grep -c 'sin revisar (binario)' <<<"$out")" 0/1
  printf 'raise SystemExit(0)\n' > "$tmp/l4/random.py"; printf 'Habrá un juez.\n' > "$tmp/l4/encargo.md"
  (cd "$tmp/l4" && motor revisar encargo.md >/dev/null 2>&1); chk "un random.py en el cwd no se importa" $? 1

  mkdir -p "$tmp/c/uno/.git" "$tmp/c/dos" "$tmp/c/tres" "$tmp/c/autor-kimi"
  echo "solución 1" > "$tmp/c/uno/sol.py"; echo "secreto" > "$tmp/c/uno/.git/HEAD"
  echo "solución 2" > "$tmp/c/dos/sol.py"; echo "dosis alta" > "$tmp/c/dos/notas.md"; echo "solución 3" > "$tmp/c/tres/sol.py"
  out="$(motor etiquetar "$tmp/j" "$tmp/c/uno" "$tmp/c/dos" "$tmp/c/tres" 2>&1)"; rc=$?
  chk "etiquetar 3 candidatos limpios sale 0 («dosis» no delata a «dos»)" "$rc" 0
  chk "crea A, B y C" "$(ls "$tmp/j" | tr -d '\n')" ABC
  chk "el mapa queda fuera de lo que ve el juez" "$([ -f "$tmp/j.mapa.tsv" ] && [ ! -e "$tmp/j/j.mapa.tsv" ] && echo si)" si
  chk "el mapa es biyectivo" "$(cut -f2 "$tmp/j.mapa.tsv" | tail -n +2 | sort -u | wc -l | tr -d ' ')" 3
  chk "cada copia trae una solución distinta" "$(cat "$tmp"/j/*/sol.py | sort -u | wc -l | tr -d ' ')" 3
  chk "no copia .git" "$(find "$tmp/j" -name .git | wc -l | tr -d ' ')" 0
  # El orden es al azar: en 20 tandas la A no puede ser siempre el primer candidato (falso rojo: 3 en 3^20).
  local i primeros=""
  for i in $(seq 20); do
    motor etiquetar "$tmp/r$i" "$tmp/c/uno" "$tmp/c/dos" "$tmp/c/tres" >/dev/null 2>&1
    primeros+="$(sed -n 2p "$tmp/r$i.mapa.tsv" | cut -f2 | xargs basename)"$'\n'
  done
  chk "las letras salen en orden al azar" "$([ "$(sort -u <<<"$primeros" | grep -c .)" -ge 2 ] && echo si)" si
  motor etiquetar "$tmp/j" "$tmp/c/uno" "$tmp/c/dos" >/dev/null 2>&1; chk "destino existente: no sobrescribe (2)" $? 2
  motor etiquetar "$tmp/j1" "$tmp/c/uno" >/dev/null 2>&1; chk "un solo candidato: error (2)" $? 2
  # Candidatos que son archivo: el nombre no viaja (council v1.31).
  echo "uno" > "$tmp/c/con-kit.md"; echo "otro" > "$tmp/c/sin-kit.md"
  motor etiquetar "$tmp/jf" "$tmp/c/con-kit.md" "$tmp/c/sin-kit.md" >/dev/null 2>&1; rc=$?
  chk "candidatos archivo: copias como entrega.md, sin su nombre" "$rc/$(find "$tmp/jf" -type f -name 'entrega.md' | wc -l | tr -d ' ')/$(find "$tmp/jf" -name '*kit*' | wc -l | tr -d ' ')" 0/2/0
  mkdir -p "$tmp/sal"
  motor etiquetar "$tmp/sal/x/." "$tmp/c/uno" "$tmp/c/dos" >/dev/null 2>&1
  chk "destino «x/.»: el mapa queda fuera" "$([ -f "$tmp/sal/x.mapa.tsv" ] && [ -z "$(find "$tmp/sal/x" -name '*.tsv')" ] && echo si)" si
  ln -s "$tmp/ok" "$tmp/c/tres/vinculo"
  motor etiquetar "$tmp/j4" "$tmp/c/tres" "$tmp/c/dos" >/dev/null 2>&1; chk "candidato con enlace: no se copia (2)" $? 2
  rm "$tmp/c/tres/vinculo"
  echo "Hecho por autor-kimi en su rama" > "$tmp/c/autor-kimi/reporte.md"
  motor etiquetar "$tmp/j2" "$tmp/c/autor-kimi" "$tmp/c/dos" >/dev/null 2>&1; chk "copia que nombra a su autor es fuga (1)" $? 1
  mkdir -p "$tmp/c/cuatro"; echo x > "$tmp/c/cuatro/notas-opus.md"
  motor etiquetar "$tmp/j3" "$tmp/c/cuatro" "$tmp/c/dos" >/dev/null 2>&1; chk "ruta que nombra un modelo es fuga (1)" $? 1

  [ "$fallas" -eq 0 ] && echo "autotest: todo en verde" || echo "autotest: $fallas falla(s)"
  [ "$fallas" -eq 0 ]
}

command -v python3 >/dev/null 2>&1 || { echo "✗ cegar.sh necesita python3" >&2; exit 2; }
case "$CMD" in
  revisar)   shift; [ "$#" -ge 1 ] || { echo "uso: cegar.sh revisar [--contenido] <archivo|carpeta> [...]" >&2; exit 2; }; motor revisar "$@" ;;
  etiquetar) shift; [ "$#" -ge 3 ] || { echo "uso: cegar.sh etiquetar <destino> <cand> <cand> [...]" >&2; exit 2; }; motor etiquetar "$@" ;;
  autotest)  cmd_autotest ;;
  *) sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; [ -z "$CMD" ] && exit 2; [ "$CMD" = "-h" ] || [ "$CMD" = "--help" ] && exit 0; exit 2 ;;
esac
