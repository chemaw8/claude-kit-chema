#!/usr/bin/env python3
"""Pruebas de coherencia.py: el ejemplo pasa y cada regla con error falla con su código. Uso: python3 test_coherencia.py"""
import copy
import json
import sys
from pathlib import Path

AQUI = Path(__file__).resolve().parent
sys.path.insert(0, str(AQUI))
from coherencia import revisar  # noqa: E402

BASE = json.loads((AQUI / "ejemplo-hipotesis.json").read_text(encoding="utf-8"))


def caso(mutar):
    h = copy.deepcopy(BASE)
    mutar(h)
    return {x["regla"] for x in revisar(h)["errores"]}


def b(h, blq, i=0):
    return h["bloques"][blq][i]


CASOS = {
    "C1": lambda h: h["bloques"].__setitem__("socios", []) or h["bloques"]["canales"][0].__setitem__("requiere", []),
    "C2": lambda h: b(h, "ingresos").pop("paga"),
    "C3": lambda h: b(h, "propuesta_valor").__setitem__("atiende", []),
    "C4": lambda h: b(h, "propuesta_valor")["requiere"].append("red_5g"),
    "C5": lambda h: b(h, "recursos").__setitem__("niega", ["oferta_sin_plazo"]),
    "C6": lambda h: b(h, "recursos").pop("costo"),
    "C7": lambda h: b(h, "ingresos").__setitem__("cobro", ["efectivo"]),
    "C8": lambda h: b(h, "relaciones").__setitem__("para", ["s_inexistente"]),
    "C9 promesa": lambda h: b(h, "propuesta_valor").__setitem__("t", "Café disponible 24/7 en cada piso"),
    "C9 promesa marca": lambda h: h["restricciones"][0].__setitem__("t", "La marca garantiza entrega inmediata"),
    "C8 descartado": lambda h: h["segmentos"][1].__setitem__("estado", "descartado"),
    "C8 forma": lambda h: h["segmentos"][0].pop("nombre"),
    "C8 id-lista": lambda h: b(h, "recursos").__setitem__("id", ["re_tostador"]),
    "C8 paga_con-objeto": lambda h: h["segmentos"][0]["empatia"].__setitem__("paga_con", [{"x": 1}]),
    "C8 se_informa-objeto": lambda h: h["segmentos"][1]["empatia"].__setitem__("se_informa", [["app"]]),
    "C8 costo-lista": lambda h: b(h, "recursos").__setitem__("costo", ["k_fijos"]),
    "C8 dolores-null": lambda h: h["segmentos"][0]["empatia"].__setitem__("dolores", None),
    "C8 dolores-numero": lambda h: h["segmentos"][0]["empatia"].__setitem__("dolores", 3),
    "C8 aporta-objeto": lambda h: b(h, "recursos").__setitem__("aporta", [{"x": 1}]),
}

def descartado_limpio():
    h = copy.deepcopy(BASE)
    h["segmentos"][1]["estado"] = "descartado"
    for blq in ("propuesta_valor", "canales", "relaciones"):
        h["bloques"][blq] = [x for x in h["bloques"][blq] if "s_empleado" not in x["para"]]
    return h


def promesa_con_capacidad():   # la misma promesa, con la capacidad declarada y aportada: no es error
    h = copy.deepcopy(BASE)
    b(h, "propuesta_valor")["t"] = "Café disponible 24/7 en cada piso"
    b(h, "propuesta_valor")["requiere"].append("capacidad_horario_24_7")
    b(h, "recursos")["aporta"].append("capacidad_horario_24_7")
    return h


fallas = 0
if not revisar(promesa_con_capacidad())["coherente"]:
    print("FALLA promesa con capacidad: marcó error"); fallas += 1
if not revisar(descartado_limpio())["coherente"]:   # descartar bien (sin nada que lo nombre) no es error
    print("FALLA descartado limpio: marcó error"); fallas += 1
r = revisar(copy.deepcopy(BASE))
if not r["coherente"] or r["avisos"]:
    print("FALLA ejemplo:", r["errores"], r["avisos"]); fallas += 1
for nombre, mutar in CASOS.items():
    regla = nombre.split()[0]
    try:
        reglas = caso(mutar)
    except Exception as e:  # el script no debe caerse con entradas mal formadas
        print(f"FALLA {nombre}: excepción {e!r}"); fallas += 1; continue
    if regla not in reglas:
        print(f"FALLA {nombre}: se esperaba error {regla}, salió {sorted(reglas) or 'coherente'}"); fallas += 1
print("TODO OK" if not fallas else f"{fallas} falla(s)")
sys.exit(1 if fallas else 0)
