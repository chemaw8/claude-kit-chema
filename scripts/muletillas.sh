#!/usr/bin/env bash
# muletillas.sh — revisor determinista de señales de texto de IA en español («slop»).
#
# Origen: la skill `unslop` de pstack (Lauren Tan, MIT, github.com/cursor/plugins/tree/main/pstack), reescrita
# para el español con Wikipedia:Signs_of_AI_writing (en), Wikipédia:Sinais_de_texto_gerado_por_IA (pt) y la
# norma de la raya de la Ortografía de la RAE (2010). Va como script porque un chequeo que corre fuera del
# modelo no le suma instrucciones al contexto. Calibración y evidencia: investigacion/2026-09-30-pstack-y-mercado.md.
#
# Dos clases de señal, porque las fuentes coinciden en que una palabra suelta no delata nada:
#   F (fuerte)    se marca cada aparición: construcciones que casi solo produce un modelo.
#   D (densidad)  se cuenta por cada 1,000 palabras y solo se marca si pasa su umbral.
# La raya correcta en español es la del inciso pegado al texto que encierra («texto —inciso— texto»);
# la de estilo inglés, con espacio a ambos lados («texto — texto»), es señal fuerte. Muchas rayas, aun
# bien puestas, cuentan como densidad.
#
#   revisar <archivo|-> [...]   hallazgos `archivo:línea: Fn …` y un bloque de densidad por archivo.
#                               salida 0 = limpio · 1 = hay señales · 2 = uso o lectura.
#   reglas                      imprime el catálogo con sus umbrales.
#   autotest                    se prueba con textos sintéticos.
#
# Ignora bloques ``` y `código en línea`. Es léxico: marca candidatos; quien escribe decide.
set -uo pipefail

CMD="${1:-}"

MOTOR_PY=$(cat <<'PY'
import re, sys

I = re.I | re.M
# Fuertes: (id, patrón, qué es, sugerencia). Los ids son estables: una regla retirada deja hueco.
F = [
 ("F1", r"\bcabe (destacar|mencionar|señalar|resaltar|recalcar|subrayar)\b|\bes (muy )?(importante|fundamental|crucial|clave|esencial) (destacar|mencionar|señalar|notar|recalcar|subrayar|tener en cuenta)\b|\bvale la pena (destacar|mencionar|señalar)\b",
  "anuncio vacío", "borra el anuncio y di el dato"),
 ("F2", r"\b(en|dentro de) (el|este|la|esta) (panorama|mundo|entorno|era) (actual|de hoy|digital|empresarial actual)\b|\ben la era (digital|actual|de la ia)\b|\ben un mundo cada vez más\b|\ben el vertiginoso\b",
  "marco genérico", "bórralo o nombra el hecho"),
 ("F3", r"\b(juega|desempeña|jugará|desempeñará)n? un (papel|rol) (crucial|fundamental|clave|esencial|importante|vital|decisivo|protagónico)\b",
  "rodeo", "di qué hace"),
 ("F4", r"\bno (solo|sólo|solamente|únicamente)\b[^.;:\n]{1,80}?\bsino (también|que)\b|\bno se trata (solo |sólo )?de\b[^.;:\n]{1,80}?\bsino (de|que)\b|\bno es (solo |sólo |un[ao]? )?[^.;:\n,]{1,40}, es\b",
  "paralelismo negativo («no es X, es Y»)", "di el punto directo"),
 ("F5", r"\bespero que (esto |este [a-záéíóúñ]+ )?(te |les |le )?(sea de (gran )?(ayuda|utilidad)|sirva|ayude)\b|\bno dudes en\b|\b(excelente|buena|gran) pregunta\b|\btienes (toda la )?razón\b|¡(claro|por supuesto|excelente)!|\b(aquí tienes|a continuación te presento)\b|¿(quieres|te gustaría) que (profundice|amplíe|prepare)\b",
  "frase de chatbot", "quítala"),
 ("F6", r"\bel futuro (es|luce|se ve) (prometedor|brillante)\b|\blas posibilidades son infinitas\b|\besto es (solo|sólo) el (comienzo|principio)\b|\bun antes y un después\b|\bal siguiente nivel\b",
  "cierre genérico", "di el plan o el hecho"),
 ("F7", r"\bsin (lugar a )?dudas?( alguna)?\b|\bindudablemente\b|\b(podría|puede|podrían|pueden) (potencialmente|posiblemente|eventualmente)\b",
  "certeza o cobertura de más", "pon la evidencia, o «puede»"),
 ("F8", r"\bse (erige|posiciona|consolida|presenta) como (un[ao]? )?(referente|solución|herramienta|pilar|opción|aliado)\b|\bfunge como\b|\bsirve como (un[ao]? )?(pilar|puente|catalizador|testimonio)\b",
  "evita el «es»", "«es» o «tiene»"),
 ("F9", r"\S \u2014 \S|\S \u2014$",
  "raya al estilo inglés (espacio a ambos lados)", "inciso pegado «—así—», o punto o coma"),
 ("F10", r"^\s*(#{1,6}\s*|[-*+]\s+|\d+[.)]\s+)(?![\U0001F7E0-\U0001F7EB\u2705\u274C\u26A0\u2B50])[\U0001F300-\U0001FAFF\u2600-\u27BF]",
  "emoji decorativo", "quítalo (los semáforos 🟢🟡🔴 y ✅❌⚠ no cuentan)"),
]
# Densidad: (id, patrón, qué es, umbral por 1,000 palabras). Umbrales calibrados 2026-09-30 (ver investigación).
D = [
 ("D1", r"\bcrucial(es)?\b|\bfundamental(es)?\b|\besencial(es)?\b|\bfomenta\w*|\bpotenci(ar|a|an|ando|ará)\b(?! (eléctrica|instalada|nominal|contratada))|\brobust[oa]s?\b|\bmeticulos\w+|\bintrincad\w+|\bvibrantes?\b|\btestimonio de\b|\bsubray(a|an|ando|ar)\b|\bsinergias?\b|\bholístic\w+|\bde vanguardia\b|\bparadigmas?\b|\bpanorama\b|\btransformador(a|es|as)?\b|\binnovador(a|es|as)?\b|\bapalanc\w+|\bprofundiz(ar|aremos|amos) en\b|\bnaveg(ar|amos) (por )?(el|la|los|las) (complej|desaf|panorama)|\b(un|una) (amplio abanico|amplia gama|amplia variedad|sinfín) de\b|\bde (manera|forma) (efectiva|eficiente|significativa|integral|estratégica|óptima)\b|\bse alinea con\b|\bdesbloquea\w*|\bempoder\w+|\bimpulsa(r|ndo)? (el|la|los|las) (crecimiento|innovación|transformación)\b",
  "vocabulario de IA", 4.0),
 ("D2", r"(^|[.!?]\s+)(Además|Asimismo|Adicionalmente|En resumen|En conclusión|En definitiva|En este sentido|Por consiguiente|En última instancia|Por otro lado|Cabe),",
  "conector de relleno al abrir oración", 3.0),
 ("D3", r"\bcon el (fin|objetivo|propósito) de\b|\bdebido al hecho de que\b|\bel hecho de que\b|\ben lo que (respecta|se refiere) a\b|\bllevar a cabo\b|\ben el caso de que\b|\ba nivel de\b",
  "relleno («para», «porque», «sobre», «hacer», «si», «en»)", 2.0),
 ("D4", r"^\s*([-*+]|\d+[.)])\s+\*\*[^*\n]{1,60}(:\*\*|\*\*:)",
  "viñeta con encabezado en negritas y dos puntos", 6.0),
 ("D5", r"\u2014",
  "rayas (aun bien puestas)", 5.0),
]
CF = [(i, re.compile(p, I), q, s) for i, p, q, s in F]
CD = [(i, re.compile(p, I if i != "D2" else re.M), q, u) for i, p, q, u in D]

def titulo_ingles(linea):
    m = re.match(r"^\s*#{1,6}\s+(.+?)\s*#*\s*$", linea)
    if not m: return None
    pal = [w for w in re.findall(r"[A-Za-zÁÉÍÓÚÑáéíóúñü]+", m.group(1))]
    cont = [w for w in pal[1:] if len(w) > 3 and not w.isupper()]
    if len(cont) < 3: return None
    may = [w for w in cont if w[0].isupper()]
    return m.group(1) if len(may) >= 3 and len(may) / len(cont) >= 0.6 else None

args = sys.argv[1:]
if args and args[0] == "reglas":
    for i, p, q, s in F: print(f"{i}\t{q}\t→ {s}")
    for i, p, q, u in D: print(f"{i}\t{q}\tumbral {u:g} por 1,000 palabras")
    print("F11\ttítulo con mayúsculas a la inglesa (Title Case), candidata: se reporta pero no cambia la salida\t→ solo la primera palabra y los nombres propios")
    sys.exit(0)
if not args:
    print("uso: muletillas.sh revisar <archivo|-> [...]", file=sys.stderr); sys.exit(2)

senal_total = 0
for ruta in args:
    try:
        texto = sys.stdin.read() if ruta == "-" else open(ruta, encoding="utf-8").read()
    except (OSError, UnicodeDecodeError) as ex:
        print(f"✗ no se pudo leer {ruta}: {ex}", file=sys.stderr); sys.exit(2)
    en_bloque, prosa = False, []
    for n, linea in enumerate(texto.splitlines(), 1):
        if linea.lstrip().startswith("```"):
            en_bloque = not en_bloque; continue
        if en_bloque: continue
        limpia = re.sub(r"`[^`]*`", "", linea)
        prosa.append(limpia)
        for i, rx, q, s in CF:
            for m in rx.finditer(limpia):
                senal_total += 1
                print(f"{ruta}:{n}: {i} {q} «{m.group(0).strip()}» → {s}")
        t = titulo_ingles(limpia)
        if t:
            print(f"{ruta}:{n}: F11 (candidata) título con mayúsculas a la inglesa «{t}» → solo la primera palabra y los nombres propios; en contratos los términos definidos sí van así")
    cuerpo = "\n".join(prosa)
    palabras = max(len(re.findall(r"\w+", cuerpo)), 1)
    fila = []
    for i, rx, q, u in CD:
        c = len(rx.findall(cuerpo))
        tasa = c * 1000 / palabras
        marca = palabras >= 150 and tasa > u
        senal_total += marca
        fila.append(f"{i} {tasa:.1f}{' ⚠' if marca else ''}")
        if marca:
            print(f"{ruta}: {i} {q}: {c} en {palabras} palabras = {tasa:.1f} por 1,000 (umbral {u:g})")
    print(f"{ruta}: densidad por 1,000 palabras ({palabras}) · " + " · ".join(fila), file=sys.stderr)
sys.exit(1 if senal_total else 0)
PY
)

motor() { python3 -I -c "$MOTOR_PY" "$@"; }

cmd_autotest() {
  local tmp fallas=0; tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' RETURN
  chk() { if [ "$2" = "$3" ]; then echo "✓ $1"; else echo "✗ $1 (esperaba $3, salió $2)"; fallas=$((fallas+1)); fi; }
  hay() { grep -c ": $2 " <<<"$1" | awk '{print ($1>0)?"si":"no"}'; }

  cat > "$tmp/sucio.md" <<'EOF'
# Impacto De La Transformación Digital En Las Empresas
Cabe destacar que en el panorama actual la solución es valiosa.
No solo baja el costo, sino que también sube la venta.
El equipo juega un papel fundamental — y el futuro es prometedor.
No es una herramienta, es una aliada. ¡Por supuesto! Aquí tienes el resumen.
La plataforma se posiciona como referente del sector.
- 🚀 Lanzamiento
EOF
  local out rc
  out="$(motor "$tmp/sucio.md" 2>/dev/null)"; rc=$?
  chk "texto sucio sale con 1" "$rc" 1
  for id in F1 F2 F3 F4 F5 F6 F8 F9 F10 F11; do chk "detecta $id" "$(hay "$out" "$id")" si; done
  printf '# Impacto De La Transformación Digital\nLas ventas subieron.\n' | motor - >/dev/null 2>&1; chk "F11 solo es candidata: no cambia la salida" "$?" 0

  # Densidad: 200 palabras neutras + vocabulario de IA repetido pasa el umbral; el mismo texto sin él, no.
  local base; base="$(printf 'Las ventas del trimestre subieron en tres tiendas y bajaron en dos. %.0s' $(seq 1 17))"
  printf '%s Es crucial y fundamental, esencial y robusto, crucial otra vez.\n' "$base" > "$tmp/denso.md"
  out="$(motor "$tmp/denso.md" 2>/dev/null)"; chk "densidad de vocabulario sobre el umbral se marca" "$(hay "$out" D1)" si
  printf '%s\n' "$base" > "$tmp/neutro.md"
  motor "$tmp/neutro.md" >/dev/null 2>&1; chk "texto neutro sale con 0" "$?" 0

  cat > "$tmp/limpio.md" <<'EOF'
# Resultados de junio en la Ciudad de México
Las ventas cayeron 12% en junio; la causa probable —la baja en la tienda X— ya se corrigió.
La potencia instalada no cambia. Recomiendo cerrar el piloto el viernes.
- 🟢 Tienda X al día
```
cabe destacar dentro de un bloque de código — no cuenta
```
El comando `llevar a cabo` va entre comillas de código.
EOF
  motor "$tmp/limpio.md" >/dev/null 2>&1; chk "raya de inciso, semáforo y código no se marcan" "$?" 0
  motor >/dev/null 2>&1; chk "sin archivos sale con 2" "$?" 2
  motor "$tmp/no-existe.md" >/dev/null 2>&1; chk "archivo inexistente sale con 2" "$?" 2
  out="$(printf 'Cabe mencionar esto.\n' | motor - 2>/dev/null)"; chk "lee de stdin" "$(hay "$out" F1)" si
  out="$(printf '¿Quieres que profundice en esto?\n' | motor - 2>/dev/null)"; chk "detecta la oferta de chatbot con «¿»" "$(hay "$out" F5)" si
  [ "$fallas" -eq 0 ] && echo "autotest: todo en verde" || echo "autotest: $fallas falla(s)"
  return "$fallas"
}

case "$CMD" in
  revisar)  shift; motor "$@" ;;
  reglas)   motor reglas ;;
  autotest) cmd_autotest ;;
  *) echo "uso: muletillas.sh revisar <archivo|-> [...] | reglas | autotest" >&2; exit 2 ;;
esac
