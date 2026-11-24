#!/usr/bin/env python3
"""Chequeo de sincronía de una hipótesis de modelo de negocio (canvas de 9 bloques + mapa de empatía).

Una hipótesis es un JSON con segmentos (cada uno con su mapa de empatía), los 9 bloques y restricciones (por ejemplo,
promesas del brand book). Cada elemento declara qué `requiere` y qué `aporta` (capacidades con nombre libre) y, si
aplica, qué `niega` (capacidades que explícitamente NO tiene, como «red_5g» en una red solo 4G).

Reglas (errores = la hipótesis no es coherente; avisos = revisar):
  C1  los 9 bloques tienen al menos un elemento.
  C2  cada segmento usuario tiene propuesta, canal y relación que lo nombran; cada segmento que paga aparece como
      pagador de algún ingreso, y cada ingreso dice quién lo paga. Paga y usa pueden ser segmentos distintos (B2B2C).
  C3  cada propuesta de valor atiende al menos un dolor o ganancia del mapa de empatía de un segmento al que va dirigida.
  C4  todo `requiere` lo cubre el `aporta` de OTRO elemento de un bloque habilitador (recursos, actividades, socios,
      canales). Una promesa no se habilita a sí misma.
  C5  ninguna capacidad requerida o aportada está negada por otro elemento (contradicción explícita).
  C6  recursos, actividades y socios declaran su partida de costo (error si falta); «sin_costo» sin razón y partidas
      que nadie genera son avisos.
  C7  cómo paga el segmento pagador (empatía `paga_con`) coincide con algún medio de cobro del ingreso; y el segmento
      se entera por donde llegan sus canales (`se_informa` contra `alcanza`).
  C9  promesa absoluta (24/7, ilimitado, garantizado, siempre…) sin una capacidad «capacidad_…» declarada (error).
  C8  segmentos con "estado": "descartado" que algún elemento sigue nombrando (error); forma mínima (ids, nombres y textos) y referencias a ids inexistentes (error); elementos que nadie usa (aviso).
Uso: python3 scripts/coherencia.py <hipotesis.json> [...] [--json salida.json] [--verificar]
     --verificar sale con código 1 si alguna hipótesis tiene errores.
"""
import argparse
import re
import json
import sys
from pathlib import Path

BLOQUES = ["segmentos", "propuesta_valor", "canales", "relaciones", "ingresos", "recursos", "actividades", "socios", "costos"]
HABILITADORES = ("recursos", "actividades", "socios", "canales")
NOMBRE = {"segmentos": "Segmentos", "propuesta_valor": "Propuesta de valor", "canales": "Canales", "relaciones": "Relación",
          "ingresos": "Ingresos", "recursos": "Recursos clave", "actividades": "Actividades clave", "socios": "Socios clave",
          "costos": "Estructura de costos", "restricciones": "Restricción"}


def _lista(x):
    return x if isinstance(x, list) else ([] if x in (None, "") else [x])


ROLES = ("usuario", "pagador", "ambos")


def revisar(h):
    """Revisa una hipótesis; una entrada mal formada que la validación de forma no previó sale como C8, nunca como traceback."""
    try:
        return _revisar(h)
    except (TypeError, AttributeError, KeyError) as e:
        return {"id": h.get("id") if isinstance(h, dict) else None, "nombre": h.get("nombre") if isinstance(h, dict) else None,
                "coherente": False, "avisos": [], "reglas_ok": 0, "reglas_total": 9, "elementos": 0,
                "errores": [{"regla": "C8", "msg": f"estructura inválida ({type(e).__name__}: {e})", "ids": []}]}


def _revisar(h):
    errores, avisos = [], []
    if not isinstance(h, dict) or not isinstance(h.get("bloques", {}), dict) or not isinstance(h.get("segmentos", []), list):
        return {"id": None, "nombre": None, "coherente": False, "avisos": [], "reglas_ok": 0, "reglas_total": 9, "elementos": 0,
                "errores": [{"regla": "C8", "msg": "estructura inválida: se espera un objeto con «segmentos» (lista) y «bloques» (objeto)", "ids": []}]}

    def err(regla, msg, ids=()):
        errores.append({"regla": regla, "msg": msg, "ids": list(ids)})

    def aviso(regla, msg, ids=()):
        avisos.append({"regla": regla, "msg": msg, "ids": list(ids)})

    # Forma mínima: sin ella las reglas no se pueden leer; se reporta como C8 en vez de caerse.
    forma = []
    if not isinstance(h.get("restricciones", []), list) or not all(isinstance(v, list) for v in h.get("bloques", {}).values()):
        forma.append("«restricciones» y cada bloque deben ser listas")
    else:
        for s in h.get("segmentos", []):
            if not isinstance(s, dict) or not isinstance(s.get("id"), str) or not s["id"] or not s.get("nombre"):
                forma.append(f"un segmento no es objeto o le falta id o nombre: {str(s)[:60]}")
                continue
            emp = s.get("empatia", {})
            if not isinstance(emp, dict):
                forma.append(f"el mapa de empatía de «{s['id']}» no es objeto")
                continue
            for q in ("paga_con", "se_informa"):
                v = emp.get(q)
                if v is not None and not all(isinstance(x, str) for x in (v if isinstance(v, list) else [v])):
                    forma.append(f"en la empatía de «{s['id']}», «{q}» debe ser texto o lista de textos")
            for q in ("dolores", "ganancias"):
                for it in emp.get(q, []):
                    if not isinstance(it, dict) or not isinstance(it.get("id"), str) or not it["id"] or not it.get("t"):
                        forma.append(f"en la empatía de «{s['id']}» hay un {q[:-1]} sin id o sin texto")
        for blq, lst in list(h.get("bloques", {}).items()) + [("restricciones", h.get("restricciones", []))]:
            for e in lst:
                if not isinstance(e, dict) or not isinstance(e.get("id"), str) or not e["id"] or not e.get("t"):
                    forma.append(f"un elemento de «{blq}» no es objeto o le falta id o texto (t): {str(e)[:60]}")
                    continue
                for campo in ("requiere", "aporta", "niega", "para", "paga", "cobro", "alcanza", "atiende", "beneficia"):
                    v = e.get(campo)
                    if v is not None and not all(isinstance(x, str) for x in (v if isinstance(v, list) else [v])):
                        forma.append(f"«{e['id']}»: «{campo}» debe ser texto o lista de textos")
                if "costo" in e and not isinstance(e["costo"], str):
                    forma.append(f"«{e['id']}»: «costo» debe ser el id de una partida (texto)")
    if forma:
        return {"id": h.get("id"), "nombre": h.get("nombre"), "coherente": False, "avisos": [], "reglas_ok": 0,
                "reglas_total": 9, "elementos": 0, "errores": [{"regla": "C8", "msg": m, "ids": []} for m in forma]}

    b = h.get("bloques", {})
    segs = h.get("segmentos", [])
    elementos = {}  # id -> (bloque, elemento)
    todos = [("segmentos", s) for s in segs] + [(blq, e) for blq in BLOQUES[1:] for e in b.get(blq, [])] + \
            [("restricciones", e) for e in h.get("restricciones", [])]
    for blq, e in todos:
        if not isinstance(e, dict) or "id" not in e:
            err("C8", f"un elemento de «{NOMBRE[blq]}» no tiene id")
            continue
        if e["id"] in elementos:
            err("C8", f"id repetido «{e['id']}» ({NOMBRE[elementos[e['id']][0]]} y {NOMBRE[blq]})", [e["id"]])
            continue
        elementos[e["id"]] = (blq, e)
    usados = set()

    # C1
    for blq in BLOQUES:
        if not (segs if blq == "segmentos" else b.get(blq)):
            err("C1", f"el bloque «{NOMBRE[blq]}» está vacío")

    # empatía por segmento
    emp_ids = {}
    for s in segs:
        if s.get("rol", "usuario") not in ROLES:
            err("C2", f"el segmento «{s.get('nombre', s.get('id'))}» tiene un rol inválido «{s.get('rol')}» (usuario, pagador o ambos)", [s.get("id")])
        e = s.get("empatia", {})
        for q in ("dolores", "ganancias"):
            for it in e.get(q, []):
                if it["id"] in emp_ids or it["id"] in elementos:
                    err("C8", f"id repetido «{it['id']}» en el mapa de empatía", [it["id"]])
                emp_ids[it["id"]] = s["id"]
        if s.get("rol", "usuario") in ("usuario", "ambos") and not (e.get("dolores") or e.get("ganancias")):
            err("C3", f"el segmento «{s['nombre']}» no tiene dolores ni ganancias en su mapa de empatía", [s["id"]])

    def ref(eid, origen, campo):
        destino_ok = (eid in emp_ids) if campo == "atiende" else (elementos.get(eid, (None,))[0] == "segmentos")
        if not destino_ok:
            existe = eid in elementos or eid in emp_ids
            err("C8", f"«{origen}» ({campo}) apunta a «{eid}», que " + ("no es del tipo esperado" if existe else "no existe"), [origen])
            return False
        usados.add(eid)
        return True

    # Segmentos descartados (`"estado": "descartado"`): no se les exige propuesta ni ingreso, y nada puede seguir
    # dirigido a ellos. Es el error típico al actualizar un modelo: se descarta un segmento y su canal o su comisión se quedan.
    descartados = {s["id"] for s in segs if s.get("estado") == "descartado"}
    for blq in BLOQUES[1:]:
        for x in b.get(blq, []):
            for campo in ("para", "paga", "beneficia"):
                for p in _lista(x.get(campo)):
                    if p in descartados:
                        err("C8", f"«{x['t']}» ({NOMBRE[blq]}) sigue dirigido al segmento descartado «{elementos[p][1]['nombre']}»: quítalo", [x["id"], p])

    # C2
    for s in segs:
        if s["id"] in descartados:
            continue
        rol = s.get("rol", "usuario")
        if rol in ("usuario", "ambos"):
            for blq in ("propuesta_valor", "canales", "relaciones"):
                if not any(s["id"] in _lista(x.get("para")) for x in b.get(blq, [])):
                    err("C2", f"el segmento «{s['nombre']}» no tiene {NOMBRE[blq].lower()} dirigido a él", [s["id"]])
        if rol in ("pagador", "ambos"):
            if not any(s["id"] in _lista(x.get("paga")) for x in b.get("ingresos", [])):
                err("C2", f"el segmento «{s['nombre']}» paga, pero ningún ingreso lo tiene como pagador", [s["id"]])
    for x in b.get("ingresos", []):
        if not _lista(x.get("paga")):
            err("C2", f"«{x['t']}» no dice quién lo paga", [x["id"]])
        for p in _lista(x.get("paga")):
            if ref(p, x["id"], "paga") and elementos[p][1].get("rol", "usuario") == "usuario":
                err("C2", f"«{x['t']}» lo paga «{elementos[p][1]['nombre']}», que está marcado como solo usuario", [x["id"], p])
        for p in _lista(x.get("beneficia")):
            ref(p, x["id"], "beneficia")
    for blq in ("propuesta_valor", "canales", "relaciones"):
        for x in b.get(blq, []):
            if not _lista(x.get("para")):
                aviso("C8", f"«{x['t']}» ({NOMBRE[blq]}) no está dirigido a ningún segmento", [x["id"]])
            for p in _lista(x.get("para")):
                ref(p, x["id"], "para")

    # C3
    for pv in b.get("propuesta_valor", []):
        at = _lista(pv.get("atiende"))
        validos = [a for a in at if a in emp_ids and emp_ids[a] in _lista(pv.get("para"))]
        for a in at:
            ref(a, pv["id"], "atiende")
        if not validos:
            err("C3", f"la propuesta «{pv['t']}» no atiende ningún dolor o ganancia de los segmentos a los que va", [pv["id"]])

    # C4 y C5
    aporta = {}
    for eid, (blq, e) in elementos.items():
        for c in _lista(e.get("aporta")):
            aporta.setdefault(c, []).append((eid, blq))
    niega = {}
    for eid, (blq, e) in elementos.items():
        for c in _lista(e.get("niega")):
            niega.setdefault(c, []).append(eid)
    for eid, (blq, e) in elementos.items():
        for c in _lista(e.get("requiere")):
            prov = [p for p, pb in aporta.get(c, []) if p != eid and pb in HABILITADORES]
            if c in niega:
                err("C5", f"«{e.get('t', e.get('nombre'))}» ({NOMBRE[blq]}) requiere «{c}», pero "
                          f"{', '.join(_desc(elementos, n) for n in niega[c])} no lo tiene", [eid] + niega[c])
            elif not prov:
                err("C4", f"«{e.get('t', e.get('nombre'))}» ({NOMBRE[blq]}) requiere «{c}» y ningún recurso, actividad, "
                          f"socio o canal lo aporta", [eid])
            else:
                usados.update(prov)
    for c, quien in niega.items():
        for p, _ in aporta.get(c, []):
            ajenos = [n for n in quien if n != p]
            if ajenos:
                err("C5", f"{_desc(elementos, p)} aporta «{c}», pero {', '.join(_desc(elementos, n) for n in ajenos)} "
                          f"dice que no está disponible", [p] + ajenos)

    # C6
    partidas = {x["id"] for x in b.get("costos", [])}
    for blq in ("recursos", "actividades", "socios"):
        for x in b.get(blq, []):
            c = x.get("costo")
            if c is None:
                err("C6", f"«{x['t']}» ({NOMBRE[blq]}) no declara partida de costo", [x["id"]])
            elif c == "sin_costo":
                if not x.get("razon_sin_costo"):
                    aviso("C6", f"«{x['t']}» dice no tener costo sin explicar por qué", [x["id"]])
            elif c not in partidas:
                err("C8", f"«{x['t']}» apunta a la partida «{c}», que no existe", [x["id"]])
            else:
                usados.add(c)
    for x in b.get("costos", []):
        if x["id"] not in usados:
            aviso("C6", f"la partida «{x['t']}» no la genera ningún recurso, actividad ni socio", [x["id"]])

    # C7
    for x in b.get("ingresos", []):
        cobro = set(_lista(x.get("cobro")))
        for p in _lista(x.get("paga")):
            s = elementos.get(p, (None, {}))[1]
            paga = set(_lista(s.get("empatia", {}).get("paga_con")))
            if paga and cobro and not (paga & cobro):
                err("C7", f"«{s.get('nombre')}» paga con {', '.join(sorted(paga))}, pero «{x['t']}» se cobra con "
                          f"{', '.join(sorted(cobro))}", [p, x["id"]])
            elif not paga or not cobro:
                aviso("C7", f"falta declarar cómo paga «{s.get('nombre', p)}» o cómo se cobra «{x['t']}»", [p, x["id"]])
    for s in segs:
        if s["id"] in descartados:
            continue
        info = set(_lista(s.get("empatia", {}).get("se_informa")))
        alc = set()
        for c in b.get("canales", []):
            if s["id"] in _lista(c.get("para")):
                alc |= set(_lista(c.get("alcanza")))
        if not info or not alc:
            if s.get("rol", "usuario") in ("usuario", "ambos") or info:
                aviso("C7", f"falta declarar por dónde se informa «{s.get('nombre')}» o a quién alcanzan sus canales", [s.get("id")])
        elif not info & alc:
            err("C7", f"«{s['nombre']}» se informa por {', '.join(sorted(info))} y sus canales solo llegan a {', '.join(sorted(alc))}", [s["id"]])

    # C9 promesas absolutas: «24/7», «ilimitado», «garantizado», «siempre», «inmediato»… en una propuesta o una restricción
    # de marca exigen una capacidad declarada (`requiere` con algo que empiece por «capacidad_») que algún recurso,
    # actividad o socio aporte. En los casos dorados fue la trampa que nadie corrigió: se señalaba y se dejaba.
    ABSOLUTA = re.compile(r"24\s*/\s*7|24 horas|ilimitad|garantiz|siempre|inmediat|sin l[ií]mite|todos los d[ií]as", re.I)
    for blq, lista in (("propuesta_valor", b.get("propuesta_valor", [])), ("restricciones", h.get("restricciones", []))):
        for x in lista:
            if ABSOLUTA.search(x.get("t", "")):
                caps = [r for r in _lista(x.get("requiere")) if str(r).startswith("capacidad_")]
                if not caps:
                    err("C9", f"«{x['t']}» promete algo absoluto sin declarar la capacidad que lo cumple "
                              f"(añade a «requiere» algo como «capacidad_horario_24_7» y quién la aporta, o reescribe la promesa)", [x["id"]])

    # C8 huérfanos
    for eid, (blq, e) in elementos.items():
        if blq in HABILITADORES[:3] and eid not in usados and not _lista(e.get("aporta")):
            aviso("C8", f"«{e['t']}» ({NOMBRE[blq]}) no habilita nada", [eid])
        if blq in HABILITADORES[:3] and _lista(e.get("aporta")) and eid not in usados:
            aviso("C8", f"«{e['t']}» ({NOMBRE[blq]}) aporta {', '.join(_lista(e['aporta']))}, pero nadie lo requiere", [eid])

    total = 9
    reglas_con_error = {x["regla"] for x in errores}
    return {"id": h.get("id"), "nombre": h.get("nombre"), "coherente": not errores, "errores": errores, "avisos": avisos,
            "reglas_ok": total - len(reglas_con_error), "reglas_total": total,
            "elementos": len(elementos)}


def _desc(elementos, eid):
    blq, e = elementos.get(eid, ("?", {}))
    return f"«{e.get('t', e.get('nombre', eid))}»"


def _sin_duplicadas(pares):
    d = {}
    for k, v in pares:
        if k in d:
            raise ValueError(f"clave JSON repetida «{k}»")
        d[k] = v
    return d


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("hipotesis", nargs="+")
    ap.add_argument("--json")
    ap.add_argument("--verificar", action="store_true")
    a = ap.parse_args()
    reportes = []
    for ruta in a.hipotesis:
        try:
            h = json.loads(Path(ruta).read_text(encoding="utf-8"), object_pairs_hook=_sin_duplicadas)
        except (OSError, ValueError) as e:
            print(f"{ruta}: no se pudo leer ({e})", file=sys.stderr)
            return 1
        r = revisar(h)
        reportes.append(r)
        estado = "COHERENTE" if r["coherente"] else f"NO COHERENTE ({len(r['errores'])} errores)"
        print(f"{r['id']} · {r['nombre']}: {estado}, {len(r['avisos'])} avisos, reglas sin error {r['reglas_ok']}/{r['reglas_total']}")
        for x in r["errores"]:
            print(f"  ✗ {x['regla']} {x['msg']}")
        for x in r["avisos"]:
            print(f"  · {x['regla']} {x['msg']}")
    if a.json:
        Path(a.json).write_text(json.dumps(reportes, ensure_ascii=False, indent=1), encoding="utf-8")
    return 1 if a.verificar and any(not r["coherente"] for r in reportes) else 0


if __name__ == "__main__":
    sys.exit(main())
