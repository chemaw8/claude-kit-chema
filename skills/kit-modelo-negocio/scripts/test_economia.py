#!/usr/bin/env python3
"""Pruebas de economia_unitaria.py y libro_xml.py (ficticias; cifras del caso dorado 03, cuya clave se calculó aparte)."""
import copy
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

AQUI = Path(__file__).resolve().parent
sys.path.insert(0, str(AQUI))
from economia_unitaria import revisar  # noqa: E402
from libro_xml import a_r1c1, libro  # noqa: E402

BASE = {"unidad": "bici activa al mes", "precio": 799, "iva_incluido": True, "iva": 0.16,
        "costos": [{"concepto": "depreciación", "monto": 14500 / 24, "fuente": "costos"},
                   {"concepto": "mantenimiento", "monto": 180, "fuente": "costos"},
                   {"concepto": "seguro", "monto": 95, "fuente": "costos"}],
        "merma_pct": 0.015, "valor_unidad": 14500, "churn_mensual": 0.082, "viable": False}
fallas = 0


def falla(m):
    global fallas
    print("FALLA", m)
    fallas += 1


r, e, _ = revisar(BASE)
if e or abs(r["contribucion"] - (-407.87)) > 0.01 or abs(r["precio_equilibrio"] - 1272.13) > 0.01:
    falla(f"base: {r} {e}")
con_com = dict(copy.deepcopy(BASE), comisiones=[{"concepto": "plataforma", "pct": 0.12, "recurrente": True, "fuente": "contrato"}])
if abs(revisar(con_com)[0]["contribucion"] - (-490.53)) > 0.01:
    falla(f"comisión recurrente: {revisar(con_com)[0]}")
for nombre, mut, codigo in (
        ("E1", lambda f: f.pop("iva_incluido"), "E1"),
        ("E2", lambda f: f.__setitem__("comisiones", [{"concepto": "x", "pct": 0.1, "fuente": "y"}]), "E2"),
        ("E3", lambda f: f["costos"][0].pop("fuente"), "E3"),
        ("E4", lambda f: f.pop("valor_unidad"), "E4"),
        ("E5", lambda f: f.__setitem__("viable", True), "E5")):
    f = copy.deepcopy(BASE)
    mut(f)
    if codigo not in {c for c, _ in revisar(f)[1]}:
        falla(f"{nombre}: no marcó {codigo}")

alta = dict(copy.deepcopy(BASE), churn_mensual=None, precio=2000, cac=900, comisiones=[{"concepto": "escuela", "pct": 0.1, "recurrente": False, "fuente": "x"}])
ra = revisar(alta)[0]
if abs(ra["cac_total"] - (900 + 0.1 * 2000 / 1.16)) > 0.01:
    falla(f"comisión de alta no suma al CAC: {ra}")
if a_r1c1("=LOG10(B1)+ATAN2(A1,B2)", 1, 3) != "=LOG10(RC[-1])+ATAN2(RC[-2],R[1]C[-1])":
    falla(f"funciones tomadas como celdas: {a_r1c1('=LOG10(B1)+ATAN2(A1,B2)', 1, 3)}")
# libro_xml: traducción A1 → R1C1 y, si hay LibreOffice, que recalcule
if a_r1c1("=B1-Supuestos!$B$2", 2, 2) != "=R[-1]C-Supuestos!R2C2":
    falla(f"R1C1: {a_r1c1('=B1-Supuestos!$B$2', 2, 2)}")
spec = {"hojas": [{"nombre": "Supuestos", "filas": [["Precio", 100], ["Costo", 60]]},
                  {"nombre": "PyL", "filas": [["Ingreso", "=Supuestos!B1"], ["Utilidad", "=B1-Supuestos!B2"]]}]}
if shutil.which("soffice"):
    try:
        import openpyxl
    except ImportError:
        openpyxl = None
    if openpyxl:
        with tempfile.TemporaryDirectory() as t:
            x = Path(t) / "l.xml"
            x.write_text(libro(spec))
            subprocess.run(["soffice", "--headless", "--calc", "--convert-to", "xlsx", "--outdir", t, str(x)],
                           capture_output=True, timeout=240)
            wb = openpyxl.load_workbook(Path(t) / "l.xlsx", data_only=True)
            if wb["PyL"]["B2"].value != 40:
                falla(f"libro_xml: utilidad {wb['PyL']['B2'].value}, esperaba 40")
print("TODO OK" if not fallas else f"{fallas} falla(s)")
sys.exit(1 if fallas else 0)
