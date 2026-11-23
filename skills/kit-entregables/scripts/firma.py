#!/usr/bin/env python3
"""kit-entregables: verificador DETERMINISTA de entregables en dos formatos.
  presentación: lista de láminas {titulo, cuerpo}
  documento:    texto markdown
Cada hallazgo: {regla, gravedad, donde, mensaje}. «alta» = la firma no se cumple; «media» = revisar.
Reglas tomadas de la investigación de la spec (Minto, Zelazny, Duarte, Reynolds, Tufte, Amazon, BLUF, Heath; señales de
«AI slop» de Wikipedia y Kobak et al.).
Entrada (stdin JSON): {"formato": "presentacion", "laminas": [...]} o {"formato": "documento", "texto": "..."}.
"""
from __future__ import annotations
import io, json, re, sys

# --- umbrales (el formato PRESENTACIÓN es para lámina proyectada; el denso va a DOCUMENTO) ---
MAX_PALABRAS_LAMINA = 60       # formato PRESENTACIÓN: lámina proyectada, una idea (Duarte/Reynolds ≤40 como
                               # proxy, más margen); lo denso va al formato DOCUMENTO
MAX_PALABRAS_TITULO = 18
MAX_PALABRAS_DOC = 3000         # ≈ 6 páginas (Amazon)
MAX_ANTES_DE_RECOMENDAR = 80    # palabras antes de la recomendación (BLUF)
RELLENO_MAX = 2                 # muletillas toleradas por pieza antes de avisar

TITULO_TEMA = re.compile(r"^(contexto|antecedentes|introducci[oó]n|agenda|temario|an[aá]lisis|resultados|conclusiones?|"
                         r"resumen|oportunidades?|situaci[oó]n actual|objetivos?|metodolog[ií]a|hallazgos|anexos?|gracias|"
                         r"preguntas|context|background|overview|analysis|results|summary|objectives|methodology|findings|"
                         r"appendix|thank you|questions)\b", re.I)
# Verbo conjugado: terminaciones que casi no dan sustantivos, más los verbos cortos de un título-conclusión (sello: con
# «-a/-e» pasaba cualquier palabra). Lista corta del TEXTO, como los verbos de tendencia.
VERBO = re.compile(r"(?<!\w)(\w{2,}(?:ó|ió|aron|ieron|amos|emos|arán|erán|irán|ará|erá|irá|aban)|"
                   r"es|son|está|están|hay|tiene|tienen|da|dan|deja|dejan|cuesta|cuestan|sube|suben|baja|bajan|crece|crecen|"
                   r"cae|caen|requiere|permite|pide|piden|ahorra|gana|pierde|duplica|supera|cubre|decide|deciden|pedimos|"
                   r"is|are|was|were|has|have|adds|cuts|saves|grows|falls|drops|rises|doubles|needs|requires|keeps|runs|"
                   r"makes|gives|decide|decides|hinges|holds|wins|loses|start|starts|\w{3,}ed)(?!\w)", re.I)
CIFRA = re.compile(r"\d")
# Muletillas de relleno (Wikipedia «Signs of AI writing», Kobak et al.): palabras del TEXTO, no del dato.
RELLENO = re.compile(r"(it is important to note|plays a (key|crucial|pivotal) role|in today'?s .{0,20}landscape|delve|"
                     r"seamless(ly)?|leverag(e|ing)|game.?changer|\b(robust|holistic|synerg(y|ies))\b|es importante (destacar|mencionar|señalar)|cabe (destacar|mencionar|señalar)|juega un papel (clave|fundamental|crucial)|"
                     r"en resumen|en conclusión|en el panorama actual|no solo .{3,60} sino (tambi[eé]n )?|sin lugar a dudas|"
                     r"\b(crucial|fundamental|robust[oa]s?|integral(es)?|sinergias?|holístic[oa]|potenciar|apalancar|disruptiv[oa])\b)", re.I)
PETICION = re.compile(r"\b(pedimos|pido|solicit\w+|aprobar|aprueben|recomiendo|recomendamos|proponemos|propongo|decidir|siguiente paso|"
                      r"we ask|we propose|we recommend|approve|decide|start with|next step)\b", re.I)
FECHA = re.compile(r"\b(20\d\d-\d\d-\d\d|(january|february|march|april|may|june|july|august|september|october|november|december) \d{1,2}|\d{1,2} (january|february|march|april|may|june|july|august|september|october|november|december)|\d{1,2} de (enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre))\b", re.I)
ORIGEN = re.compile(r"^\s*(de d[oó]nde (sale|salen)|fuentes( y notas)?\s*$|fuentes de (las|cada) cifras?|origen de (las|cada) cifras?|"
                    r"every figure, where it comes from)", re.I)   # título de la lámina o sección de fuentes, no cualquier «fuente»
NO_CONCLUIR = re.compile(r"(no se puede (concluir|afirmar)|lo que no (sabemos|se sabe)|qu[eé] decide|datos? (que )?deciden|l[ií]mites|"
                         r"limitaciones|riesgos?|condiciones|cannot conclude|what we don'?t know|facts? decide|decide whether|"
                         r"risks?|limitations|hinges on|unknown)", re.I)
SUPUESTOS = re.compile(r"(supuestos?|alternativas?|assumptions?|alternatives?)", re.I)
RECOMIENDA = re.compile(r"\b(recomiend\w+|recomendaci[oó]n|propon\w+|propuesta|conviene|debemos|hay que|decisi[oó]n|pedimos|cerrar|aprobar|"
                        r"recommend\w*|propos\w+|we should|decision|we ask|approve)\b", re.I)


def palabras(t: str) -> int:
    return len(re.findall(r"\w+", t or ""))


def h(regla, gravedad, donde, mensaje):
    return {"regla": regla, "gravedad": gravedad, "donde": donde, "mensaje": mensaje}


def titulo_ok(t: str) -> str | None:
    t = (t or "").strip()
    if not t: return "sin título"
    if TITULO_TEMA.match(t) and palabras(t) <= 4: return "título de tema, no de conclusión"
    if palabras(t) > MAX_PALABRAS_TITULO: return f"título de {palabras(t)} palabras (máximo {MAX_PALABRAS_TITULO})"
    # Sin etiquetador gramatical, lo determinista es la forma: un título de tema es una frase nominal corta; una
    # conclusión es una oración. Pasa con cifra, con ≥6 palabras (largo de oración) o con 4–5 palabras y un verbo
    # reconocido. Calibrado con decks reales de dirección.
    n = palabras(t)
    if not (CIFRA.search(t) or n >= 6 or (n >= 4 and VERBO.search(t))): return "el título no afirma nada (frase de tema corta, sin cifra ni verbo)"
    return None


def relleno(t: str) -> list[str]:
    return [m.group(0) for m in RELLENO.finditer(t or "")]


ETIQUETA_MAX = 4   # palabras: «Quiénes somos», «Resultados financieros»


def titulo_efectivo(t: str, subtitulo: str) -> str:
    """Una etiqueta de sección corta seguida de un subtítulo-conclusión cuenta como título; se juzga el
    subtítulo. Si el subtítulo no afirma nada, se juzga la etiqueta (y falla)."""
    if palabras(t) <= ETIQUETA_MAX and subtitulo and titulo_ok(subtitulo) is None:
        return subtitulo
    return t


def revisar_presentacion(laminas: list[dict]) -> list[dict]:
    out = []
    laminas = [{"titulo": str(l.get("titulo") or ""), "subtitulo": str(l.get("subtitulo") or ""), "cuerpo": str(l.get("cuerpo") or "")}
               for l in laminas if isinstance(l, dict)]
    finales = {"gracias", "preguntas", "fin", "thank you", "thanks", "questions"}
    contenido = [l for l in laminas if (l.get("titulo") or "").strip().lower() not in finales]
    for i, l in enumerate(contenido, 1):
        t, c = l.get("titulo", ""), l.get("cuerpo", "")
        if ORIGEN.search(t): continue   # la lámina de fuentes tiene su propio formato
        p = titulo_ok(titulo_efectivo(t, l["subtitulo"]))
        if p: out.append(h("titulo_conclusion", "alta", f"lámina {i}", p))
        n = palabras(c)
        if n > MAX_PALABRAS_LAMINA: out.append(h("una_idea", "alta", f"lámina {i}", f"{n} palabras (máximo {MAX_PALABRAS_LAMINA}): parte la idea o pásala al documento"))
        r = relleno(t + " " + c)
        if len(r) > RELLENO_MAX: out.append(h("relleno", "media", f"lámina {i}", "frases de relleno: " + ", ".join(sorted(set(r))[:5])))
    todo = " ".join((l.get("titulo", "") + " " + l.get("cuerpo", "")) for l in laminas)
    if CIFRA.search(todo) and not any(ORIGEN.search(l.get("titulo", "")) for l in laminas):
        out.append(h("origen_cifras", "alta", "deck", "hay cifras y no hay lámina de «de dónde sale cada cifra»"))
    if not any(NO_CONCLUIR.search(l.get("titulo", "") + " " + l.get("cuerpo", "")) for l in laminas):
        out.append(h("no_concluir", "media", "deck", "no hay lámina de lo que decide el caso o lo que no se puede concluir"))
    # La petición va en alguna de las últimas láminas de contenido (después pueden ir creativos o anexos; calibrado con
    # decks reales), con fecha absoluta o responsable.
    cola = [l for l in contenido if not ORIGEN.search(l.get("titulo", ""))][-4:]
    if not any(PETICION.search(t := l["titulo"] + " " + l["subtitulo"] + " " + l["cuerpo"]) and (FECHA.search(t) or re.search(r"responsab|owner|\bby (q[1-4]|end of)", t, re.I))
               for l in cola):
        out.append(h("peticion", "alta", "cierre", "ninguna de las últimas láminas pide algo concreto con responsable o fecha"))
    return out


def secciones(texto: str) -> list[tuple[str, str]]:
    partes = re.split(r"^#{1,3}\s+(.+)$", texto, flags=re.M)
    return [(partes[i].strip(), partes[i + 1]) for i in range(1, len(partes) - 1, 2)]


def revisar_documento(texto: str) -> list[dict]:
    out = []
    secs = secciones(texto)
    titulo = secs[0][0] if secs else ""
    p = titulo_ok(titulo)
    if p: out.append(h("titulo_conclusion", "alta", "título", p))
    cuerpo0 = re.sub(r"<!--[\s\S]*?-->", "", texto)   # el comentario de la plantilla no es contenido (sello)
    cuerpo0 = re.sub(r"^#\s.*$", "", cuerpo0, count=1, flags=re.M).strip()
    primero = ""
    for b in re.split(r"\n\s*\n", cuerpo0):
        lineas = [l for l in b.strip().splitlines() if not l.lstrip().startswith("#")]   # «## Recomendación\ntexto»: cuenta el texto
        if lineas: primero = "\n".join(lineas); break
    if not RECOMIENDA.search(primero) or palabras(primero) > MAX_ANTES_DE_RECOMENDAR:
        out.append(h("conclusion_primero", "alta", "inicio", "el primer párrafo no es la recomendación (o pasa de "
                     f"{MAX_ANTES_DE_RECOMENDAR} palabras): «{primero[:80]}…»"))
    nombres = " ".join(s for s, _ in secs)
    if CIFRA.search(texto) and not any(ORIGEN.search(n) for n, _ in secs):
        out.append(h("origen_cifras", "alta", "documento", "hay cifras y no hay sección de origen de las cifras"))
    if not SUPUESTOS.search(nombres): out.append(h("supuestos", "alta", "documento", "falta la sección de supuestos y alternativas"))
    if not NO_CONCLUIR.search(nombres): out.append(h("no_concluir", "alta", "documento", "falta la sección de lo que no se puede concluir"))
    if not FECHA.search(texto): out.append(h("peticion", "media", "documento", "la acción no trae fecha absoluta"))
    n = palabras(texto)
    if n > MAX_PALABRAS_DOC: out.append(h("largo", "alta", "documento", f"{n} palabras (máximo {MAX_PALABRAS_DOC} ≈ 6 páginas): pasa el detalle a un anexo"))
    r = relleno(texto)
    if len(r) > RELLENO_MAX * 3: out.append(h("relleno", "media", "documento", "frases de relleno: " + ", ".join(sorted(set(r))[:6])))
    return out


from pathlib import Path as _P
try:   # si falta o está dañado, los modos presentacion/documento siguen funcionando (sello)
    ESTRUCTURAS = {k: v for k, v in json.loads((_P(__file__).with_name("estructuras.json")).read_text(encoding="utf-8")).items() if not k.startswith("_")}
except (OSError, ValueError, AttributeError, TypeError):   # también JSON válido con otra forma (sello)
    ESTRUCTURAS = {}


def revisar_estructura(texto: str, clave: str) -> list[dict]:
    """La estructura del catálogo (tipo × objetivo): cada sección presente y en ORDEN. Reconoce cada encabezado por su
    patrón (es/en); un encabezado que no es de la estructura no cuenta. Las reglas comunes (conclusión primero en modo
    «lectura», relleno, título) las añade main() con revisar_documento."""
    e = ESTRUCTURAS[clave]
    encabezados = [t for t, _ in secciones(texto)][1:] if texto.lstrip().startswith("# ") else [t for t, _ in secciones(texto)]
    pos, usados = [], set()
    out = []
    for nombre, patron, _guia in e["secciones"]:
        # cada encabezado cuenta para una sola sección (dos patrones que se traslapan no roban el mismo)
        i = next((j for j, t in enumerate(encabezados) if j not in usados and re.search(patron, t, re.I)), None)
        if i is not None: usados.add(i)
        if i is None:
            out.append(h("seccion_faltante", "alta", nombre, f"falta «{nombre}» ({e['fuente']})"))
        else:
            pos.append((nombre, i))
    for (a, i), (b, j) in zip(pos, pos[1:]):
        if j < i:
            out.append(h("orden", "alta", b, f"«{b}» va después de «{a}» en esta estructura ({e['fuente']})"))
    n = palabras(texto)
    if n > e.get("max_palabras", 10**9):
        out.append(h("largo", "alta", "documento", f"{n} palabras (máximo {e['max_palabras']} para {clave})"))
    return out


def plantilla(clave: str) -> str:
    """Plantilla markdown de la estructura: secciones en orden, con su guía y el autor."""
    e = ESTRUCTURAS[clave]
    cab = f"# {{{{Título: la conclusión con su cifra}}}}\n\n<!-- Estructura «{clave}»: {e['uso']}. Fuente: {e['fuente']}. Modo: {e['modo']}"
    cab += " (conclusión primero)" if e["modo"] == "lectura" else " (tensión: la solución va al final)"
    cab += f". Máximo {e['max_palabras']} palabras. Verificar: firma.py --estructura {clave} <archivo.md> -->\n"
    return cab + "".join(f"\n## {n}\n{{{{{g}}}}}\n" for n, _p, g in e["secciones"])


def main() -> int:
    if len(sys.argv) >= 2 and sys.argv[1] == "--plantilla":
        if len(sys.argv) < 3 or sys.argv[2] not in ESTRUCTURAS:
            print(f"uso: firma.py --plantilla <estructura>; opciones: {', '.join(ESTRUCTURAS)}", file=sys.stderr); return 1
        print(plantilla(sys.argv[2])); return 0
    if len(sys.argv) >= 2 and sys.argv[1] == "--estructura":   # firma.py --estructura <clave> <archivo.md>
        if len(sys.argv) < 4 or sys.argv[2] not in ESTRUCTURAS:
            print(f"uso: firma.py --estructura <estructura> <archivo.md>; opciones: {', '.join(ESTRUCTURAS)}", file=sys.stderr); return 1
        try:
            with open(sys.argv[3], encoding="utf-8") as f: texto = f.read()
        except OSError as e:
            print(f"no pude leer {sys.argv[3]}: {e.strerror}", file=sys.stderr); return 1
        sys.stdin = io.StringIO(json.dumps({"estructura": sys.argv[2], "texto": texto}))
    if len(sys.argv) >= 2 and sys.argv[1] == "--catalogo":
        for k, v in ESTRUCTURAS.items(): print(f"{k:22} {v['modo']:8} {v['uso']} — {v['fuente']}")
        return 0
    e = json.load(sys.stdin)
    if e.get("estructura"):
        if e["estructura"] not in ESTRUCTURAS:
            print(json.dumps({"error": f"estructura desconocida; opciones: {', '.join(ESTRUCTURAS)}"}, ensure_ascii=False)); return 1
        r = revisar_estructura(e.get("texto") or "", e["estructura"])
        if ESTRUCTURAS[e["estructura"]]["modo"] == "lectura":
            pide_origen = any(ORIGEN.search(n) for n, _p, _g in ESTRUCTURAS[e["estructura"]]["secciones"])   # estatus y one-pager no la llevan (sello)
            comunes = ("conclusion_primero", "titulo_conclusion", "relleno", "peticion") + (("origen_cifras",) if pide_origen else ())
            r += [x for x in revisar_documento(e.get("texto") or "") if x["regla"] in comunes]
        else:
            r += [x for x in revisar_documento(e.get("texto") or "") if x["regla"] in ("titulo_conclusion", "relleno")]
        print(json.dumps({"hallazgos": r, "pasa": not any(x["gravedad"] == "alta" for x in r)}, ensure_ascii=False)); return 0
    f = (e.get("formato") or "").lower().replace("ó", "o")
    if f not in ("presentacion", "documento"):
        print(json.dumps({"error": "formato debe ser «presentacion» o «documento»"}, ensure_ascii=False)); return 1
    r = revisar_presentacion(e.get("laminas") or []) if f == "presentacion" else revisar_documento(e.get("texto") or "")
    print(json.dumps({"hallazgos": r, "pasa": not any(x["gravedad"] == "alta" for x in r)}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
