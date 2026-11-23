#!/usr/bin/env python3
"""Revisión por código de un P&L en hoja de cálculo antes de entregarlo (kit-modelo-negocio, etapa 7).

Comprueba lo que un lector no ve a simple vista:
  P1  recalcula con LibreOffice sin interfaz y cuenta errores de celda (#DIV/0!, #REF!, …)        → error si hay
  P2  los resultados salen de fórmulas (cuántas hay)                                              → error si < --min-formulas
  P3  hay una hoja de supuestos (nombre con «supuest», «input» o «parámetro»)                     → aviso si no
  P4  series pegadas: filas fuera de supuestos con ≥ 6 números fijos seguidos (valores pegados)   → aviso
  P5  responde: cambiar un supuesto (--supuesto Hoja!B3, o el primer número de la hoja de
      supuestos) en una copia mueve las filas de utilidad/flujo/acumulado                         → error si no se mueve
Acepta .xlsx, .xml de hoja de cálculo 2003, .ods y .xls (los convierte a .xlsx con LibreOffice).

Uso: python3 revisar_pl.py <libro> [--supuesto 'Supuestos!B3'] [--min-formulas 50] [--json]
Sale con 1 si hay errores, 0 si no; 2 si falta openpyxl o soffice (no se puede revisar: se dice, no se aprueba).
"""
import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ERRORES = ("#DIV/0!", "#REF!", "#VALUE!", "#NAME?", "#N/A", "#NUM!", "#NULL!", "Err:")
CLAVES = ("utilidad", "acumulad", "flujo", "resultado", "ebitda", "margen")


def soffice_a_xlsx(origen: Path, outdir: Path) -> Path:
    subprocess.run(["soffice", "--headless", "--calc", "--convert-to", "xlsx", "--outdir", str(outdir), str(origen)],
                   check=True, capture_output=True, timeout=240)
    return outdir / (origen.stem + ".xlsx")


def es_formula(v):
    return isinstance(v, str) and v.startswith("=")


def es_supuestos(nombre):
    n = nombre.lower()
    return any(k in n for k in ("supuest", "input", "parámetro", "parametro"))


def revisar(libro: Path, supuesto: str | None, min_formulas: int):
    import openpyxl
    errores, avisos, info = [], [], {}
    with tempfile.TemporaryDirectory() as t:
        t = Path(t)
        x = libro if libro.suffix.lower() == ".xlsx" else soffice_a_xlsx(libro, t / "conv")
        wb = openpyxl.load_workbook(x)
        hojas = [ws.title for ws in wb]
        formulas = sum(1 for ws in wb for r in ws.iter_rows() for c in r if es_formula(c.value))
        info.update(hojas=hojas, formulas=formulas)
        if formulas < min_formulas:
            errores.append(("P2", f"solo {formulas} fórmulas (mínimo {min_formulas}): los resultados parecen valores pegados"))
        sup = [h for h in hojas if es_supuestos(h)]
        if not sup:
            avisos.append(("P3", "no hay hoja de supuestos por nombre; los supuestos deberían vivir aparte, con su fuente"))
        for ws in wb:
            if es_supuestos(ws.title):
                continue
            for r in ws.iter_rows():
                corrida = mejor = 0
                for c in r:
                    corrida = corrida + 1 if isinstance(c.value, (int, float)) and not isinstance(c.value, bool) else 0
                    mejor = max(mejor, corrida)
                if mejor >= 6:
                    avisos.append(("P4", f"{ws.title}!fila {r[0].row}: {mejor} números fijos seguidos (¿serie pegada en vez de fórmula?)"))
        base = openpyxl.load_workbook(soffice_a_xlsx(x, t / "base"), data_only=True)
        n_err = sum(1 for ws in base for r in ws.iter_rows() for c in r
                    if isinstance(c.value, str) and c.value.strip().startswith(ERRORES))
        info["errores_de_celda"] = n_err
        if n_err:
            errores.append(("P1", f"{n_err} celdas con error tras recalcular"))
        # P5: sensibilidad
        objetivo = [(ws.title, c.coordinate) for ws in wb for r in ws.iter_rows()
                    if any(isinstance(c0.value, str) and any(k in c0.value.lower() for k in CLAVES) for c0 in r[:3])
                    for c in r if es_formula(c.value)]
        if supuesto:
            h, _, coord = supuesto.partition("!")
            celdas = [(h.strip("'"), coord)]
        else:   # hasta 5 números de la hoja de supuestos; uno puede ser un selector (1, 2, 3) que no admite +10%
            celdas = [(h, c.coordinate) for h in sup for r in wb[h].iter_rows() for c in r
                      if isinstance(c.value, (int, float)) and not isinstance(c.value, bool) and c.value][:5]
        if not celdas or not objetivo:
            avisos.append(("P5", "no se probó la sensibilidad: " + ("no encontré un supuesto numérico" if not celdas else
                                                                     "no encontré filas de utilidad, flujo o acumulado con fórmulas")))
        else:
            probadas = []
            for i, celda in enumerate(celdas):
                copia = t / f"sens{i}.xlsx"
                shutil.copy(x, copia)
                wb2 = openpyxl.load_workbook(copia)
                v = wb2[celda[0]][celda[1]].value
                if not isinstance(v, (int, float)):
                    continue
                wb2[celda[0]][celda[1]].value = v * 1.1 if v else 1
                wb2.save(copia)
                despues = openpyxl.load_workbook(soffice_a_xlsx(copia, t / f"sens{i}"), data_only=True)
                probadas.append(f"{celda[0]}!{celda[1]}")
                if any(isinstance(base[h][k].value, (int, float)) and isinstance(despues[h][k].value, (int, float))
                       and abs(base[h][k].value - despues[h][k].value) > 1e-6 for h, k in objetivo):
                    info["sensibilidad"] = f"{celda[0]}!{celda[1]} +10%: mueve el resultado"
                    break
            else:
                info["sensibilidad"] = f"{', '.join(probadas) or 'ningún supuesto'} +10%: no mueven el resultado"
                errores.append(("P5", f"cambiar {', '.join(probadas) or 'los supuestos'} no mueve utilidad, flujo ni acumulado"))
    return errores, avisos, info


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("libro")
    ap.add_argument("--supuesto")
    ap.add_argument("--min-formulas", type=int, default=50)
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args(argv)
    try:
        import openpyxl  # noqa: F401
    except ImportError:
        print("no se puede revisar: falta openpyxl (pip install openpyxl); el libro NO queda revisado")
        return 2
    if not shutil.which("soffice"):
        print("no se puede revisar: falta LibreOffice (soffice); el libro NO queda revisado")
        return 2
    errores, avisos, info = revisar(Path(a.libro), a.supuesto, a.min_formulas)
    if a.json:
        print(json.dumps({"errores": errores, "avisos": avisos, **info}, ensure_ascii=False, indent=1))
    else:
        print(f"{Path(a.libro).name}: {'CON ERRORES' if errores else 'OK'} · {info.get('formulas')} fórmulas · "
              f"{info.get('errores_de_celda')} errores de celda · {info.get('sensibilidad', 'sensibilidad sin probar')}")
        for r, m in errores:
            print(f"  ✗ {r} {m}")
        for r, m in avisos:
            print(f"  ! {r} {m}")
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
