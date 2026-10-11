# Prerregistro v1.34 «lo que encuentras manda» — núcleo contra skills (2026-10-11)

Escrito ANTES de medir. Pedido de José (2026-10-11): aclarar las rúbricas, medir y, si mejora, sacar la v1.34;
probar alternativas que generalicen.

## Por qué
Diagnóstico de evals-entregables (`docs/diagnostico-fallas-2026-10-11.md`): en las 17 repeticiones que fallan de la
línea base con juez aislado, el productor DETECTA la anomalía (17/17). Falla la postura posterior, alineada con el
encuadre del pedido:
- **P1:** detecta y no se compromete (rcs, cortes-5s, reclasificación).
- **P2:** una duda abierta bloquea una decisión que no depende de ella (onepager).
- **P3:** contesta la pregunta con una métrica sustituta (pnl-sms).

En 4 de los 6 casos que fallan no se carga kit-analisis-datos, donde hoy vive la regla más cercana.

Las v1 y v2 de la v1.34 (rama `v1.34/evidencia-explica`) se midieron con el juez que tenía la config real, ya
descartado. Esta medición usa el juez aislado y las rúbricas aclaradas el 2026-10-11 (reproceso C1/C3/C5, pnl C4,
cortes C2 y la definición de `removed` en su tarea).

## Brazos (misma regla de tres ramas, distinto lugar)
- **A, control:** v1.33 instalada.
- **N, núcleo:** sección nueva «Lo que encuentras manda», de 5 líneas de texto, después de «Evaluación crítica». La
  paga la compactación de la nota de costo de subagentes (−2 líneas); el núcleo queda en 147/150.
- **S, skills:** la misma regla en el párrafo existente de kit-analisis-datos («Lo que descubres en el dato gobierna
  el resultado») y en el de kit-finanzas («Una cifra que no cuadra gobierna el renglón»). +1 línea en cada una.

Textos exactos: `nucleo/CLAUDE.md` y `skills/*/SKILL.md` de esta rama (N y S salen de ellos; ver «Construcción»).

## Medición
evals-entregables, suite completa de 13 casos, 29 repeticiones por brazo, con:

    HARNESS=claude-plan EVAL_INSTRUMENTO=skills EVAL_MODELO=claude-opus-5-5

El juez es aislado (sonnet). Los tres brazos corren el mismo día y con el mismo CLI. N y S entran por `EVAL_SKILLS_B`
(N con `CLAUDE.md`, soporte agregado el 2026-10-11 y comprobado con canario).

**Casos objetivo (15 reps):** rcs-colado, onepager, pnl-sms, reclasificación, cortes-5s.
**Controles (14 reps):** reaseguro, sow, kreditera, neto, rampa, regulación, venta-fecha, reproceso.

## Criterio de éxito de un brazo B (las tres a la vez)
1. **Objetivo:** reps PASA en los 5 casos objetivo ≥ A + 3, y al menos 2 casos objetivo suben ≥ 1 rep. Un caso
   en el límite cambia de veredicto entre pasadas del juez: el 2026-10-11 los mismos entregables dieron 7 u 8 casos.
   Por eso el umbral es +3 reps, no +1 caso.
2. **Controles:** ningún control que pasa por mayoría en A deja de pasar en B.
3. **Sin sobreafirmar:** en onepager, C4 de B ≥ C4 de A − 1 rep, y en pnl-sms C3 de B ≥ C3 de A.

**Si pasan N y S:** gana el de más reps objetivo. Con empate, gana S, porque no gasta presupuesto del núcleo.
**Si no pasa ninguno:** no entra; resultado y lectura abajo.

Información no prerregistrada que se reportará aparte: criterios por caso y skills cargadas por repetición.

## Construcción de los brazos
- **N:** `~/.claude/CLAUDE.md` instalado, con el bloque del núcleo reemplazado por `nucleo/CLAUDE.md` de esta rama.
- **S:** `skills/kit-analisis-datos` y `skills/kit-finanzas` de esta rama.
