#!/usr/bin/env python3
"""Pruebas de revisar_promesas.py: afirmadas fallan; negadas, retiradas, con capacidad o términos de contrato no."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from revisar_promesas import revisar  # noqa: E402

CASOS = [
    ("| Propuesta | Clases con profesores certificados, 24/7 |", 1),
    ("Atención inmediata y datos ilimitados para todos.", 1),
    ("Se quitó «24/7» de la v1: no hay horario para cumplirlo.", 0),
    ("- quite \"24/7\": horario 8-20 lun-sab.", 0),
    ("Con 12 profesores no se pueden dar clases 24/7.", 0),
    ("Soporte 24/7 (capacidad: tres turnos contratados con el proveedor X).", 0),
    ("Pedir un pago mínimo garantizado a la aseguradora.", 0),
    ("```\nservicio 24/7\n```", 0),
]
fallas = 0
for texto, esperado in CASOS:
    n = len(revisar(texto))
    if n != esperado:
        print(f"FALLA «{texto[:50]}»: {n} hallazgos, esperaba {esperado}")
        fallas += 1
print("TODO OK" if not fallas else f"{fallas} falla(s)")
sys.exit(1 if fallas else 0)
