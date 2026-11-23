# Rúbrica (fijada 2026-11-23, antes de cualquier corrida)

Cada problema Q1–Q11 vale 1 si se cumple con evidencia, 0.5 a medias, 0 si no aparece o se hereda el error.
Puntaje = suma / 11 × 100. El juez ve el texto entregado, el reporte objetivo del Excel (`revisar_excel.py` del caso 02)
y la clave; no sabe qué brazo produjo cada entrega.

## Criterio de éxito (decidido antes de correr; council del 2026-11-23)
- 5 corridas por brazo, `claude plugin eval`, `--model opus`. **A** = kit en `a72731d` (main antes de fusionar la
  skill). **B** = kit en `f3870ae` (main con la skill, congelada). Las no activaciones de la skill en B cuentan.
- Umbral alcanzable: sea `h = 100 − media(A)`. **La skill se queda** si `media(B) − media(A) ≥ max(8, 0.4 × h)` y el
  costo medio de B no supera en más de 50% al de A.
- **Se retira** (PR que la quita del kit) si `media(B) − media(A) ≤ 0`, o si el costo de B supera en más de 50% al de
  A sin ganar puntos. Entre los dos umbrales: sigue experimental hasta la revisión del 2026-12-31.
- Dos jueces de familias distintas (codex y kimi); si difieren más de 10 puntos en una entrega, se promedia y se anota.
