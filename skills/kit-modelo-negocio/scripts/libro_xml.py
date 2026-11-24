#!/usr/bin/env python3
"""Libro de Excel sin dependencias ni escritura desde la terminal (plan B de la etapa 7).

Cuando la terminal no puede escribir archivos o no hay openpyxl, este script IMPRIME en la salida estándar un libro
en XML de hoja de cálculo 2003 (Excel y LibreOffice lo abren y recalculan sus fórmulas). El agente guarda esa salida
con su herramienta de escritura de archivos como `<nombre>.xml`. Así el P&L se entrega con fórmulas aunque el
generador normal no pueda correr.

Entrada: un JSON con hojas y filas; una celda que empieza con «=» es fórmula en notación A1 (se traduce a R1C1).
{"hojas": [{"nombre": "Supuestos", "filas": [["Precio", 799], ["Costo", 879.17]]},
           {"nombre": "PyL", "filas": [["Ingreso", "=Supuestos!B1"], ["Contribución", "=B1-Supuestos!B2"]]}]}

Uso: python3 libro_xml.py libro.json > /dev/stdout   (luego guardar la salida como libro.xml)
"""
import json
import re
import sys
from xml.sax.saxutils import escape

A1 = re.compile(r"(?:(?P<hoja>'[^']+'|[A-Za-zÁÉÍÓÚáéíóúñÑ_][\w.]*)!)?(?P<c>\$?[A-Z]{1,3})(?P<f>\$?\d+)")


def col_num(letras):
    n = 0
    for ch in letras.replace("$", ""):
        n = n * 26 + ord(ch) - 64
    return n


def a_r1c1(formula, fila, col):
    """=B1-Supuestos!$B$2 en la celda (fila, col) → =RC[-?]-Supuestos!R2C2 (relativas como desplazamiento)."""
    def rep(m):
        c, f = m.group("c"), m.group("f")
        cn, fn = col_num(c), int(f.replace("$", ""))
        rr = f"R{fn}" if f.startswith("$") else (f"R[{fn - fila}]" if fn != fila else "R")
        cc = f"C{cn}" if c.startswith("$") else (f"C[{cn - col}]" if cn != col else "C")
        return (m.group("hoja") + "!" if m.group("hoja") else "") + rr + cc
    partes = re.split(r'("[^"]*")', formula)               # no tocar texto entre comillas
    return "".join(p if p.startswith('"') else A1.sub(rep, p) for p in partes)


def celda(v, fila, col):
    if isinstance(v, str) and v.startswith("="):
        return f'<Cell ss:Formula="{escape(a_r1c1(v, fila, col), {chr(34): "&quot;"})}"><Data ss:Type="Number">0</Data></Cell>'
    if isinstance(v, bool) or v is None:
        return "<Cell/>" if v is None else f'<Cell><Data ss:Type="String">{v}</Data></Cell>'
    if isinstance(v, (int, float)):
        return f'<Cell><Data ss:Type="Number">{v}</Data></Cell>'
    return f'<Cell><Data ss:Type="String">{escape(str(v))}</Data></Cell>'


def libro(d):
    out = ['<?xml version="1.0"?>', '<?mso-application progid="Excel.Sheet"?>',
           '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">']
    for h in d["hojas"]:
        out.append(f'<Worksheet ss:Name="{escape(h["nombre"])}"><Table>')
        for i, fila in enumerate(h["filas"], 1):
            out.append("<Row>" + "".join(celda(v, i, j) for j, v in enumerate(fila, 1)) + "</Row>")
        out.append("</Table></Worksheet>")
    out.append("</Workbook>")
    return "\n".join(out) + "\n"


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    sys.stdout.write(libro(json.load(open(sys.argv[1], encoding="utf-8"))))
