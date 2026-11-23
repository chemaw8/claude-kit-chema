#!/usr/bin/env python3
"""Reporte objetivo del Excel entregado en el caso dorado modelo-negocio-02 (lo lee el juez, no el brazo).

Uso: python3 revisar_excel.py <carpeta-de-la-entrega>  → imprime un reporte en markdown.
Recalcula con LibreOffice sin interfaz; requiere openpyxl y soffice.
"""
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import openpyxl

ERRORES = ("#DIV/0!", "#REF!", "#VALUE!", "#NAME?", "#N/A", "#NUM!", "#NULL!")


def recalcular(origen, destino_dir):
    subprocess.run(["soffice", "--headless", "--calc", "--convert-to", "xlsx", "--outdir", str(destino_dir), str(origen)],
                   check=True, capture_output=True, timeout=180)
    return Path(destino_dir) / origen.name


def valores(path):
    wb = openpyxl.load_workbook(path, data_only=True)
    out = {}
    for ws in wb:
        for row in ws.iter_rows():
            for c in row:
                out[(ws.title, c.coordinate)] = c.value
    return out


def filas_utilidad(path):
    wb = openpyxl.load_workbook(path)
    celdas = []
    for ws in wb:
        for row in ws.iter_rows():
            etiqueta = " ".join(str(c.value) for c in row[:3] if isinstance(c.value, str)).lower()
            if "utilidad" in etiqueta or "acumulad" in etiqueta or "flujo" in etiqueta:
                celdas += [(ws.title, c.coordinate) for c in row if isinstance(c.value, str) and c.value.startswith("=")]
    return celdas


def main(carpeta):
    xs = sorted(Path(carpeta).rglob("*.xlsx"))
    if not xs:  # hoja de cálculo XML 2003 u ODS: se convierte a .xlsx con LibreOffice
        otros = sorted(p for p in Path(carpeta).rglob("*") if p.suffix.lower() in (".xml", ".ods", ".xls"))
        if otros:
            conv = Path(tempfile.mkdtemp())
            subprocess.run(["soffice", "--headless", "--calc", "--convert-to", "xlsx", "--outdir", str(conv), str(otros[-1])],
                           check=True, capture_output=True, timeout=180)
            xs = sorted(conv.glob("*.xlsx"))
            print(f"- Formato entregado: `{otros[-1].name}` (convertido a .xlsx con LibreOffice)")
    if not xs:
        print("- Excel: **no se entregó ningún .xlsx**")
        return
    x = xs[0]
    if len(xs) > 1:
        print(f"- Aviso: hay {len(xs)} .xlsx; se revisa `{x.name}`")
    wb = openpyxl.load_workbook(x)
    formulas = sum(1 for ws in wb for r in ws.iter_rows() for c in r if isinstance(c.value, str) and c.value.startswith("="))
    hojas = [ws.title for ws in wb]
    supuestos = [h for h in hojas if "supuest" in h.lower() or "input" in h.lower() or "parámetro" in h.lower() or "parametro" in h.lower()]
    with tempfile.TemporaryDirectory() as t:
        t = Path(t)
        base = valores(recalcular(x, t / "base"))
        errores = sum(1 for v in base.values() if isinstance(v, str) and v.strip() in ERRORES)
        # sensibilidad: cambiar el primer valor fijo 349 (o 300.86) por 400 en una copia
        copia = t / x.name
        shutil.copy(x, copia)
        wb2 = openpyxl.load_workbook(copia)
        cambiada = None
        for ws in wb2:
            for r in ws.iter_rows():
                for c in r:
                    if cambiada is None and isinstance(c.value, (int, float)) and round(float(c.value), 2) in (349.0, 300.86):
                        c.value = 400 if round(float(c.value), 2) == 349.0 else 344.83
                        cambiada = f"{ws.title}!{c.coordinate}"
        wb2.save(copia)
        mueve = "sin probar (no encontré el precio como valor fijo)"
        if cambiada:
            despues = valores(recalcular(copia, t / "sens"))
            # sin filas de utilidad, se comparan solo celdas con fórmula (nunca la celda que se acaba de cambiar)
            wbf = openpyxl.load_workbook(x)
            objetivo = filas_utilidad(x) or [(ws.title, c.coordinate) for ws in wbf for r in ws.iter_rows() for c in r
                                             if isinstance(c.value, str) and c.value.startswith("=")]
            cambio = any(isinstance(base.get(k), (int, float)) and isinstance(despues.get(k), (int, float))
                         and abs(base[k] - despues[k]) > 1 for k in objetivo)
            mueve = f"sí (cambié {cambiada})" if cambio else f"no (cambié {cambiada} y la utilidad no se movió)"
    print(f"- Archivo: `{x.name}` · hojas: {', '.join(hojas)}")
    print(f"- Fórmulas: {formulas}")
    print(f"- Errores de celda tras recalcular con LibreOffice: {errores}")
    print(f"- Hoja de supuestos separada: {'sí (' + ', '.join(supuestos) + ')' if supuestos else 'no por nombre de hoja'}")
    print(f"- Cambiar el precio mueve la utilidad: {mueve}")


if __name__ == "__main__":
    main(sys.argv[1])
