#!/usr/bin/env python3
"""Promesas absolutas en el TEXTO del entregable (kit-modelo-negocio). Complementa la regla C9 de `coherencia.py`,
que solo ve las promesas cuando hay hipótesis en JSON; aquí basta el documento que se va a entregar.

Marca cada línea que promete algo absoluto al cliente («24/7», «24 horas», «ilimitado», «sin límite», «todos los
días», «siempre disponible», «atención inmediata», «servicio garantizado») en sentido afirmativo. Una línea no cuenta si la promesa aparece negada, retirada o
condicionada en la misma línea («no», «sin cumplir», «se quitó», «reescrib», «en lugar de», «no se puede», «solo si»),
o si la línea declara la capacidad que la cumple («capacidad:»). Así, decir «quitamos el 24/7 porque no hay horario»
pasa; dejar «profesores disponibles 24/7» en el canvas falla.

Uso: python3 revisar_promesas.py <entregable.md> [más archivos] [--json]
Sale con 1 si queda alguna promesa absoluta afirmada; 0 si no; 2 si no puede leer un archivo.
"""
import json
import re
import sys

# Promesas de servicio al cliente; «garantizado» suelto no (un «pago mínimo garantizado» es un término de contrato).
ABSOLUTA = re.compile(r"24\s*/\s*7|24 horas|ilimitad\w*|sin l[ií]mite\w*|todos los d[ií]as|(?:siempre|en todo momento)\s+disponibles?|"
                      r"disponibles?\s+(?:siempre|en todo momento)|(?:atenci[oó]n|respuesta|entrega|soporte)\s+inmediat\w*|"
                      r"(?:servicio|entrega|resultado|satisfacci[oó]n)\s+garantizad\w*|garant[ií]a\s+total", re.I)
NEGADA = re.compile(r"\bno\b|\bsin cumplir|se quit[oó]|quit[eéoó]\b|quitamos|quitar|retir|reescrib|en lugar de|en vez de|"
                    r"no se puede|solo si|capacidad\s*:|incumpl|no cubre|no alcanza|falso|falsa|irreal", re.I)


def revisar(texto):
    hallazgos = []
    en_codigo = False
    for n, linea in enumerate(texto.splitlines(), 1):
        if linea.strip().startswith("```"):
            en_codigo = not en_codigo
            continue
        if en_codigo:
            continue
        m = ABSOLUTA.search(linea)
        if m and not NEGADA.search(linea):
            hallazgos.append({"linea": n, "promesa": m.group(0), "texto": linea.strip()[:160]})
    return hallazgos


def main(argv):
    rutas = [a for a in argv if not a.startswith("--")]
    if not rutas:
        print(__doc__)
        return 2
    total = {}
    for r in rutas:
        try:
            total[r] = revisar(open(r, encoding="utf-8").read())
        except OSError as e:
            print(f"no pude leer {r}: {e}")
            return 2
    n = sum(len(v) for v in total.values())
    if "--json" in argv:
        print(json.dumps(total, ensure_ascii=False, indent=1))
    else:
        for r, hs in total.items():
            for h in hs:
                print(f"  ✗ {r}:{h['linea']} promete «{h['promesa']}»: {h['texto']}")
        print(("OK: ninguna promesa absoluta afirmada" if not n else
               f"{n} promesa(s) absoluta(s) afirmada(s): quítalas, reescríbelas a lo que sí se cumple o declara la "
               f"capacidad que las cumple («capacidad: …» en la misma línea)."))
    return 1 if n else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
