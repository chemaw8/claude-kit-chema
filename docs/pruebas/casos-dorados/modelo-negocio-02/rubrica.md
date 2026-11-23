# Rúbrica (fijada 2026-11-22, antes de cualquier corrida)

Puntaje 0–100 por corrida. El juez ve el texto entregado (respuesta final y documentos) y un **reporte objetivo del
Excel** generado por un script fuera del brazo (`revisar_excel.py`): si existe, cuántas fórmulas tiene, errores tras
recalcular con LibreOffice, si tiene hoja o bloque de supuestos y si cambiar el precio en una copia mueve la utilidad.
No sabe qué brazo produjo cada entrega.

| Criterio | Puntos | Cómo se otorga |
|---|---|---|
| P1–P8 | 8 × 6 = 48 | 6 si se corrige con evidencia; 3 a medias o sin evidencia; 0 si no aparece o se hereda el error |
| Cifras | 16 | 16 si las cifras clave (contribuciones, activos 12/24, utilidad mes 12, aportación máxima, mes de equilibrio) coinciden con la clave (±3%); −4 por cada cifra clave equivocada (mínimo 0) |
| Excel | 20 | 5 existe y recalcula sin errores; 5 los resultados salen de fórmulas (≥ 100 fórmulas); 5 supuestos separados con su fuente; 5 cambiar el precio mueve la utilidad |
| Registro de cambios v1 → v2 | 6 | 6 si dice qué cambió, por qué (fuente y fecha) y cuánto movió las cifras; 3 si solo lista cambios |
| Resumen para dirección | 10 | Conclusión primero (da o no da, cuánto poner y hasta cuándo), supuestos marcados y qué validar; 5 si falta uno |

## Criterio de éxito (decidido antes de correr)
- 3 corridas por brazo, `--model opus`; A = kit en `origin/main` (sin la skill), B = rama del PR #113 en el commit
  `aaa35e5` (skill congelada antes de escribir este caso).
- **La skill pasa si** la media de B supera a la de A por **15 puntos o más** y B saca ≥ 15 de 20 en Excel en 2 de 3
  corridas. Entre 0 y 15: sin evidencia suficiente. Si B queda abajo, se cierra el PR.
- Dos jueces de familias distintas; si difieren en más de 10 puntos, se toma la media y se anota.
