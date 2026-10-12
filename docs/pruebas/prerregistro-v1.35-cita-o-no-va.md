# Prerregistro v1.35 «cita o no va» (2026-10-12)

Escrito ANTES de medir. Pedido del dueño del kit: mejorar sin reglas a la medida de los casos.

## Por qué
- **v1.34 kit-insumos:** no generalizó (`prerregistro-v1.34-kit-insumos.md`), y con evidencia insuficiente los dos
  brazos afirmaban causas como hecho.
- **Palancas de entorno** (evals-entregables `docs/pruebas/prerregistro-entorno-2026-10-12.md`): Python arregla las
  fallas de cálculo (reclasificación 2/6 → 6/6, reproceso 2/6 → 5/6), pero no las de postura; el objetivo da 3 → 7, sin
  llegar al umbral. El esfuerzo max es inviable (más de 15 min por tarea).
- **La regla:** una sola, general y estructural, en el núcleo (siempre cargado y sin depender del disparo). Toda causa,
  corrección o cifra derivada del titular cita el dato que la prueba; lo que no se puede citar va a «Por confirmar»; lo
  citable va al titular aunque contradiga al pedido. Ataca a la vez el no comprometerse y el sobreafirmar.
- **Presupuesto:** núcleo 140 → 143. Pagan la compactación de la nota de costo de Subagentes y la fusión de «El tamaño
  no manda sobre el riesgo».

## Brazos (los dos con el instrumento `python`, el más cercano a una sesión real)
- **P:** v1.33. Banco de diseño ya medido: `reportes/2026-10-12-*-entorno-{r1,r2}-P-*`.
- **P+R:** P con el núcleo de esta rama (`EVAL_SKILLS_B` con `CLAUDE.md`).

## Medición 1, banco de diseño (los 14 casos del banco), igual que P
R1 suite completa + R2 los 5 objetivo y reproceso. **Pasa si:**
- objetivo ≥ P + 6 de 30 (P = 7), con p ≤ 0.10;
- ningún control que pasa en P R1 cae;
- reproceso ≥ P − 1 (P = 5);
- onepager C4 ≥ P − 1.

## Medición 2, banco fresco (decide; nadie lo ha visto correr)
`evals-entregables/casos-frescos/`: 4 pares de proyectos que no aportaron casos al banco de diseño. Los escribieron
autores Codex y Kimi, los revisó la otra familia y su juez está calibrado al 100 % con hojas pasa/falla. Huellas
sha256 (tarea + esperado + meta, 16 caracteres), congeladas hoy:

| Caso | Huella |
|---|---|
| dashboard-campanas-prueba | d798af8057caf8b5 |
| dashboard-campanas-sin-evidencia | 1cf328766e5dccf0 |
| walmart-contratos-prueba | 114a2137ad919609 |
| walmart-contratos-sin-evidencia | 3e4725227787468d |
| zorya-controles-sin-codigo | 1e15ec5c6485e232 |
| zorya-controles-tautologicos | 5b50646982a7e2eb |
| zorya-dos-definiciones | a4ab0c7edd688a31 |
| zorya-serie-sin-remedio | efa9941df03abf4b |

P y P+R, 2 rondas × 3 reps = 6 reps por caso: 24 reps «con evidencia» (walmart-prueba, dashboard-prueba,
zorya-dos-definiciones, zorya-controles-tautologicos) y 24 «sin evidencia» (walmart-sin, dashboard-sin,
zorya-serie-sin-remedio, zorya-controles-sin-codigo). **Pasa si:**
- total P+R ≥ P + 6 de 48, con p ≤ 0.10;
- en «sin evidencia», P+R ≥ P (no sobreafirma más).

## Decisión
- **Si pasan las dos mediciones:** PR al kit, council y gate de disparo (`DISPARO_NUCLEO`, núcleo ≥ 19/21, sin bajas
  de 2+ contra `main`).
- **Si solo pasa la 1:** no entra (no generaliza).
- **Si solo pasa la 2:** decide el dueño.
- **Aparte, decisión del dueño:** adoptar el instrumento `python` como el de los evals, por realismo, aunque no haya
  cumplido su umbral.
