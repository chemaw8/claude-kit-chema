#!/usr/bin/env python3
"""Pruebas de revisar_pl.py con tres libros sintéticos. Sin openpyxl o sin LibreOffice se saltan (y lo dicen)."""
import shutil
import sys
import tempfile
from pathlib import Path

AQUI = Path(__file__).resolve().parent
sys.path.insert(0, str(AQUI))
try:
    import openpyxl
except ImportError:
    openpyxl = None
if openpyxl is None or not shutil.which("soffice"):
    print("SE SALTA: falta openpyxl o LibreOffice")
    sys.exit(0)
from revisar_pl import revisar  # noqa: E402


def libro(ruta, pegado=False, error=False):
    wb = openpyxl.Workbook()
    s = wb.active
    s.title = "Supuestos"
    s["A1"], s["B1"] = "Precio", 300
    s["A2"], s["B2"] = "Costo", 100
    p = wb.create_sheet("PyL")
    p["A1"], p["A2"], p["A3"] = "Ingreso", "Utilidad", "Acumulado"
    for m in range(2, 14):
        col = openpyxl.utils.get_column_letter(m)
        if pegado:
            p[f"{col}1"], p[f"{col}2"] = 300, 200
        else:
            p[f"{col}1"] = "=Supuestos!$B$1"
            p[f"{col}2"] = f"={col}1-Supuestos!$B$2" if not error else f"={col}1/0"
        p[f"{col}3"] = f"=SUM($B$2:{col}2)"
    wb.save(ruta)


fallas = 0
with tempfile.TemporaryDirectory() as t:
    t = Path(t)
    for nombre, kw, espera in (("bueno", {}, set()), ("pegado", {"pegado": True}, {"P5"}), ("error", {"error": True}, {"P1"})):
        x = t / f"{nombre}.xlsx"
        libro(x, **kw)
        errores, avisos, info = revisar(x, None, 10)
        reglas = {r for r, _ in errores}
        if not espera <= reglas or (not espera and reglas):
            print(f"FALLA {nombre}: esperaba {sorted(espera) or 'sin errores'}, salió {sorted(reglas)} {errores}")
            fallas += 1
        if nombre == "pegado" and not any(r == "P4" for r, _ in avisos):
            print("FALLA pegado: no avisó la serie pegada (P4)")
            fallas += 1
print("TODO OK" if not fallas else f"{fallas} falla(s)")
sys.exit(1 if fallas else 0)
