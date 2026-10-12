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

## Resultado de la ronda 1 (2026-10-11 noche)
Reportes `evals-entregables/reportes/2026-10-11-222022-postura-{A,N,S}-*`: suite completa, CLI y juez iguales en los tres.

| Brazo | Objetivo (15) | Casos | Reps | Onepager C4 | pnl C3 | Reproceso (control) |
|---|---:|---:|---:|---:|---:|---:|
| A v1.33 | 0 | 8/13 | 13/29 | 3/3 | 0/3 | 2/3 |
| N núcleo | 4 | 9/13 | 16/29 | 3/3 | 1/3 | **1/3** |
| S skills | 1 | 7/13 | 13/29 | 3/3 | 0/3 | 1/3 |

**Según el prerregistro: no entra ninguno.** S falla el criterio 1. N cumple el 1 y el 3, pero falla el 2: reproceso
baja de 2/3 a 1/3.
**Desviación declarada:** las dos repeticiones de N que fallan reproceso lo hacen por C5, por una cláusula que la
aclaración de rúbricas del mismo día agregó por error («rectificar lo ya circulado»). La rúbrica original no la pedía.
Se corrigió la cláusula y se re-juzgaron los tres brazos completos con `rejuzgar.py`:

| Brazo | Objetivo | Casos | Reps | Onepager C4 | pnl C3 | Reproceso |
|---|---:|---:|---:|---:|---:|---:|
| A | 0 | 7/13 | 12/29 | 3/3 | 0/3 | 1/3 |
| N | 3 | 9/13 | 17/29 | 3/3 | 0/3 | 3/3 |
| S | 1 | 7/13 | 13/29 | 1/3 | 0/3 | 1/3 |

Con la rúbrica corregida, N cumple 1, 2 y 3, pero en el borde (+3). Las dos pasadas del juez difieren en ±1 rep por caso.

## Ronda 2 de confirmación (prerregistrada ANTES de correr, 2026-10-11 noche)
- Solo A y N; S queda descartado.
- 3 reps nuevas de cada uno en los 5 casos objetivo y en reproceso: 18 reps por brazo, mismo CLI, juez y rúbricas
  vigentes.

**N entra si, sumando ronda 1 (re-juicio con la rúbrica corregida) y ronda 2:**
(1) objetivo N ≥ A + 5 de 30 reps, y ≥ 2 casos objetivo con más reps que A;
(2) reproceso N ≥ A − 1 en las 6 reps;
(3) onepager C4 de N ≥ C4 de A − 1, y pnl C3 de N ≥ pnl C3 de A.

Si falla, no entra y se documenta.

## Resultado de la ronda 2 (2026-10-11 noche): NO ENTRA
Reportes `evals-entregables/reportes/2026-10-12-000945-postura-r2-{A,N}-*` (hora UTC; local 2026-10-11). Suma ronda 1
(re-juicio con C5 corregido) + ronda 2:

| Criterio | A | N | Cumple |
|---|---:|---:|---|
| 1. Objetivo ≥ A + 5 de 30 | 2 (3 en una 2.ª pasada del juez) | 6 | **no** (+4 / +3) |
| 1b. ≥ 2 casos objetivo arriba de A | — | onepager 3 vs 0; reclasificación 4 vs 2 | sí |
| 2. Reproceso ≥ A − 1 | 3/6 | 6/6 | sí |
| 3. Onepager C4 / pnl C3 | 5 / 0 | 6 / 0 | sí |

Fisher de una cola: objetivo 6/30 contra 2/30, p = 0.13 (contra 3/30, p = 0.24); reproceso 6/6 contra 3/6, p = 0.09.

**Lectura:** la regla en el núcleo va en la dirección correcta en todas las mediciones (onepager y reclasificación
suben; ningún control baja; reproceso mejora), pero el efecto es chico y no alcanza el umbral fijado antes de medir.
No mueve rcs ni pnl-sms (0 en todos los brazos): ahí el productor elige la lectura literal o contesta con una métrica
sustituta aunque la regla le diga lo contrario. Hace falta otra intervención, no otra redacción de la misma regla.
La regla en skills (S) no aporta, en parte porque la skill no se carga en 4 de los 6 casos.
