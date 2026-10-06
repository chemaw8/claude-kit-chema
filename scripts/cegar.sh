#!/usr/bin/env bash
# cegar.sh: cegado determinista para comparar intentos (arena, A/B) con un juez.
#
# Origen: las reglas de cegado del playbook `eval` de pstack (Lauren Tan, MIT,
# github.com/cursor/plugins/tree/main/pstack, skills/poteto-mode/playbooks/eval.md) y la fase de juez
# de su skill `arena`. Va como script porque un chequeo que corre fuera del modelo no le suma
# instrucciones al contexto. Evidencia y calibración: docs/pruebas/pstack-ronda-3.md.
#
#   revisar <archivo|carpeta> [...]   lo que verá un CANDIDATO (encargo, carpeta de trabajo): busca
#                                     palabras que delatan que se le mide («pruebas ocultas», «se
#                                     calificará», juez, rúbrica, candidato, arena…) en el texto y en
#                                     cada parte de la ruta absoluta (la carpeta de trabajo también se ve).
#                                     salida 0 = limpio · 1 = hay fugas · 2 = uso o lectura.
#   etiquetar <destino> <cand> <cand> [...]
#                                     lo que verá el JUEZ: copia cada candidato (sin .git) a
#                                     <destino>/A, B, C… en orden al azar y escribe el mapa en
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
import os, random, re, shutil, sys

META = re.compile(r"(?<![\w])(pruebas? (?:ocultas?|que no ves)|(?:se )?calificar[áa]n?|calificaci[oó]n|calificad[oa]s?|"
                  r"jue(?:z|ces)|r[uú]bricas?|experimentos?|benchmarks?|candidat[oa]s?|arenas?|evals?|"
                  r"puntaje|puntuaci[oó]n|brazos?|a/b|sondas?|hidden tests?|graded?|judge|rubric)(?![\w])", re.I)
MODELO = re.compile(r"(?<![a-z])(anthropic|openai|opus|sonnet|haiku|fable|gpt|codex|astra|kimi|moonshot|"
                    r"deepseek|qwen|grok|gemini|mistral|llama)(?![a-z])", re.I)

def archivos(raiz):
    if os.path.isfile(raiz):
        yield raiz; return
    for d, sub, fs in os.walk(raiz):
        sub[:] = [s for s in sub if s != ".git"]
        for f in fs:
            yield os.path.join(d, f)

def revisar(rutas):
    fugas = 0
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
            try:
                with open(f, "rb") as h: datos = h.read()
            except OSError as e:
                print(f"✗ no se pudo leer {f}: {e}", file=sys.stderr); sys.exit(2)
            if b"\0" in datos[:4096]:
                continue  # binario
            for n, linea in enumerate(datos.decode("utf-8", "replace").splitlines(), 1):
                for m in META.finditer(linea):
                    print(f"{f}:{n}: «{m.group(1)}» delata la medición"); fugas += 1
    print(f"{fugas} fuga(s)" if fugas else "limpio")
    return 1 if fugas else 0

def etiquetar(destino, cands):
    if len(cands) < 2:
        print("✗ hacen falta al menos 2 candidatos", file=sys.stderr); return 2
    mapa = destino.rstrip("/") + ".mapa.tsv"
    for p in (destino, mapa):
        if os.path.exists(p):
            print(f"✗ ya existe {p}: no se sobrescribe", file=sys.stderr); return 2
    for c in cands:
        if not os.path.exists(c):
            print(f"✗ no existe el candidato {c}", file=sys.stderr); return 2
    letras = [chr(65 + i) for i in range(len(cands))]
    orden = list(cands); random.SystemRandom().shuffle(orden)
    os.makedirs(destino)
    filas, fugas = [], 0
    for letra, c in zip(letras, orden):
        dst = os.path.join(destino, letra)
        if os.path.isdir(c):
            shutil.copytree(c, dst, ignore=shutil.ignore_patterns(".git"))
        else:
            os.makedirs(dst); shutil.copy2(c, dst)
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

motor() { python3 -c "$MOTOR_PY" "$@"; }

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
  echo "Hecho por autor-kimi en su rama" > "$tmp/c/autor-kimi/reporte.md"
  motor etiquetar "$tmp/j2" "$tmp/c/autor-kimi" "$tmp/c/dos" >/dev/null 2>&1; chk "copia que nombra a su autor es fuga (1)" $? 1
  mkdir -p "$tmp/c/cuatro"; echo x > "$tmp/c/cuatro/notas-opus.md"
  motor etiquetar "$tmp/j3" "$tmp/c/cuatro" "$tmp/c/dos" >/dev/null 2>&1; chk "ruta que nombra un modelo es fuga (1)" $? 1

  [ "$fallas" -eq 0 ] && echo "autotest: todo en verde" || echo "autotest: $fallas falla(s)"
  [ "$fallas" -eq 0 ]
}

command -v python3 >/dev/null 2>&1 || { echo "✗ cegar.sh necesita python3" >&2; exit 2; }
case "$CMD" in
  revisar)   shift; [ "$#" -ge 1 ] || { echo "uso: cegar.sh revisar <archivo|carpeta> [...]" >&2; exit 2; }; motor revisar "$@" ;;
  etiquetar) shift; [ "$#" -ge 3 ] || { echo "uso: cegar.sh etiquetar <destino> <cand> <cand> [...]" >&2; exit 2; }; motor etiquetar "$@" ;;
  autotest)  cmd_autotest ;;
  *) sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; [ -z "$CMD" ] && exit 2; [ "$CMD" = "-h" ] || [ "$CMD" = "--help" ] && exit 0; exit 2 ;;
esac
