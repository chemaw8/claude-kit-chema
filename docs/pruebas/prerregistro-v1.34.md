# Prerregistro v1.34 — «si el dato ya explica una diferencia, afírmalo y entrega» (2026-10-11)

Escrito ANTES de medir. Pedido de José (opción A, 2026-10-11).

## Por qué
Con Claude Code 2.1.295 el caso `reclasificacion-familia-vs-ventas` cayó de ~50 % a 1/15 sin que cambiara el kit
(evals-entregables, DECISIONES 2026-10-11): el productor deja la reclasificación como hipótesis abierta, llama
«corregir el reporte de julio» a algo que no fue error y retiene el comparativo. Lo primero es un error real; la regla
lo ataca en general, no solo en este caso.

## Cambio
`skills/kit-analisis-datos/SKILL.md`: se reescribe el párrafo «Lo que descubres en el dato gobierna el resultado» y su
pregunta del checklist, con presupuesto neutro (8 líneas agregadas, 8 quitadas). Se pierde la frase «la lectura literal
va como referencia» (la lectura corregida sigue diciendo qué corrigió y cuánto movió).

## Medición
evals-entregables, `HARNESS=claude-plan EVAL_INSTRUMENTO=skills EVAL_MODELO=claude-opus-5-5`, Claude Code 2.1.295,
brazo B con `EVAL_SKILLS_B` = esta rama. Brazo A = v1.33 instalada, mismo CLI: ya medido.

| Caso | Tipo | Brazo A (v1.33, CLI 2.1.295) | Reps B |
|---|---|---|---|
| reclasificacion-familia-vs-ventas | objetivo | 0/9 | 6 |
| reaseguro-capa-cae-vs-recupera | control que pasa | 3/3 (línea base 2026-10-10) | 3 |
| sow-monto-vs-horas-tarifa-anexo-b1 | control que pasa | 3/3 | 3 |
| kreditera-rentabilidad, neto-fcf-isr, ventas-rampa | control que pasa | 1/1 cada uno | 1 c/u |
| onepager-dos-fuentes-no-cuadran | frontera: discrepancia NO explicada | 0/3 | 3 |
| reproceso-alza-caida-falsa | frontera: caída falsa | 0/3 | 3 |

## Criterio de éxito (las tres)
1. Objetivo: B ≥ 3/6 en reclasificación (A: 0/9).
2. Controles: ningún control que pasa por mayoría deja de pasar en B.
3. Frontera: en onepager, B no afirma una explicación que el dato no prueba (C de discrepancia no baja); se reporta
   criterio a criterio contra la línea base.

Si falla cualquiera, la regla no entra (o vuelve a redacción). Resultado y desviaciones: `council-v1.34.md`.
