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

| Caso | Huella (tarea+esperado+meta) | Huella de la tarea |
|---|---|---|
| contratos-repetidos-prueba | fcd5dd720b5405a3 | b56bddeceb07 |
| contratos-repetidos-sin-evidencia | fd010b913d4e0711 | 946a8bfe9393 |
| controles-sin-codigo | 37d7eba049ab20d2 | 3cad9f52ed4d |
| controles-tautologicos | ff739aab003e5511 | cae754d1562d |
| dashboard-campanas-prueba | d798af8057caf8b5 | 1bb191ba4136 |
| dashboard-campanas-sin-evidencia | 1cf328766e5dccf0 | 8a01ce5720aa |
| series-dos-definiciones | f6a4f560286d88e9 | 9c9f9fbc3949 |
| serie-sin-remedio | 68875af41d129976 | 4f3c96eda442 |

*Ids renombrados el 2026-10-12, antes de la corrida 2 completa, para quitar nombres de clientes; cambian el id y las
rutas de fuente en meta/esperado, no el texto que ven el productor y el juez. Las huellas de arriba son las nuevas.*

P y P+R, 2 rondas × 3 reps = 6 reps por caso: 24 reps «con evidencia» (contratos-repetidos-prueba, dashboard-prueba,
series-dos-definiciones, controles-tautologicos) y 24 «sin evidencia» (contratos-repetidos-sin, dashboard-sin,
serie-sin-remedio, controles-sin-codigo). **Pasa si:**
- total P+R ≥ P + 6 de 48, con p ≤ 0.10;
- en «sin evidencia», P+R ≥ P (no sobreafirma más).

## Decisión
- **Si pasan las dos mediciones:** PR al kit, council y gate de disparo (`DISPARO_NUCLEO`, núcleo ≥ 19/21, sin bajas
  de 2+ contra `main`).
- **Si solo pasa la 1:** no entra (no generaliza).
- **Si solo pasa la 2:** decide el dueño.
- **Aparte, decisión del dueño:** adoptar el instrumento `python` como el de los evals, por realismo, aunque no haya
  cumplido su umbral.

## Resultado parcial (2026-10-12 noche): la corrida se cortó
A mitad de la corrida expiró la sesión OAuth de Claude Code («OAuth session expired and could not be refreshed»), y
desde ahí todas las repeticiones salieron INFRA.
- **Banco fresco, R1 completa en los dos brazos (24 reps cada uno; 1 JUEZ_ERROR en cada brazo):**
  - P 9/24 y P+R 9/24, idénticos caso por caso;
  - con evidencia: 6 contra 6; sin evidencia: 3 contra 3.
  - A nivel criterio, P+R mejora un criterio en dos casos «sin evidencia» (C4 de contratos-sin, 1 → 3; C3 de
    controles-sin-codigo, 1 → 3), sin cambiar ningún veredicto.
- **Banco de diseño, R1 de P+R parcial (17 de 32 válidas):** rcs 1/3, pnl 1/3 y onepager 1/3, contra 0, 0 y 1 de P.
- **R2 de los tres flujos:** INFRA completa (sin datos).

**Lectura provisional:** con la R1 en empate, la medición 2 necesitaría +6 solo en la R2. Lo más probable es que la
regla no entre. Se completa la R2 cuando vuelva la sesión, antes de decidir.
