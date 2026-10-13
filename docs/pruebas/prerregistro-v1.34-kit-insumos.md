# Prerregistro v1.34 «kit-insumos» — skill nueva + fila del núcleo (2026-10-11)

Escrito ANTES de medir. Pedido del dueño del kit (2026-10-11): que la skill de datos se active en tareas con datos, evaluar una
skill nueva y adaptar skills públicas, con el objetivo de pasar las trampas de los evals sin aflojar al juez.

## Por qué esta forma
- **Diagnóstico** (evals-entregables `docs/diagnostico-fallas-2026-10-11.md`): la detección funciona 17/17; falla la
  postura posterior.
- **La regla v1.34 «postura»** (`prerregistro-v1.34-postura.md`) dio un efecto chico (+4 de 30, p = 0.13) y no movió
  rcs ni pnl.
- **Método adaptado de `obra/superpowers`** (`writing-skills`, MIT), «ajusta la forma a la falla»: el entregable de
  forma equivocada se corrige con una receta; la conducta condicionada, con condiciones observables; y la
  racionalización, con una tabla de racionalizaciones y señales de alto. La regla anterior era una prohibición con
  matices, la forma que ese método reporta como la que más degrada.
- **Revisada y descartada:** `anthropics/skills/discernment-nudge`. Agrega preguntas para el usuario, no compromete al
  productor.

## Brazos
- **A, control:** v1.33 instalada.
- **K, propuesta:**
  - skill nueva `skills/kit-insumos/SKILL.md`, con receta, condiciones, tabla de racionalizaciones y señales de alto;
  - fila nueva en la tabla de playbooks del núcleo que manda kit-analisis-datos y kit-insumos a los encargos de otro
    dominio que se apoyan en cifras ajenas (+1 línea; núcleo 141/150; descriptions 5,893/6,000).

Ambos con el mismo CLI, juez aislado y rúbricas vigentes (2026-10-11, con la C5 de reproceso corregida). K entra por
`EVAL_SKILLS_B` (con `CLAUDE.md`) y `EVAL_SKILLS_AGREGAR=1`.

## Medición (dos rondas fijadas de antemano)
- **R1:** suite completa de 14 casos, 32 reps por brazo.
- **R2:** los 5 objetivo y reproceso, 18 reps por brazo.

Objetivo: rcs, onepager, pnl, reclasificación y cortes. Total: 30 reps objetivo por brazo.

## Criterio de éxito de K (las cuatro)
1. **Objetivo:** reps PASA de K ≥ A + 6 de 30, con Fisher de una cola p ≤ 0.10.
2. **Controles:** ningún caso que pasa por mayoría en A en la R1 deja de pasar en K en la R1. Se incluye el caso 14.
3. **Sin sobreafirmar:** onepager C4 de K ≥ A − 1 (6 reps) y pnl C3 de K ≥ pnl C3 de A.
4. **Reproceso** (6 reps) K ≥ A − 1.

Si pasa: PR en borrador al kit y council antes de fusionar. Antes de publicar se mide también el disparo
(`disparo.sh`), para que la skill nueva no le quite disparos a las vecinas. Si no pasa: no entra y se documenta.
Se reportan aparte, sin decidir con ellos: criterios por caso y skills cargadas por repetición (¿cargó kit-insumos?).

## Resultado (2026-10-11 noche): CUMPLE LOS CUATRO CRITERIOS
Reportes en evals-entregables, `reportes/2026-10-12-0*-insumos-{r1,r2}-{A,K}-*` (fechas en UTC). Mismo CLI (2.1.295),
modelo, juez aislado y rúbricas en los dos brazos.

| Caso | A R1 | K R1 | A R2 | K R2 |
|---|---:|---:|---:|---:|
| onepager | 0/3 | 3/3 | 1/3 | 3/3 |
| rcs-colado | 0/3 | 2/3 | 0/3 | 1/3 |
| reclasificación | 0/3 | 2/3 | 2/3 | 3/3 |
| pnl-sms | 0/3 | 0/3 | 0/3 | 0/3 |
| cortes-5s | 0/3 | 0/3 | 0/3 | 0/3 |
| reproceso (control) | 1/3 | 1/3 | 1/3 | 1/3 |
| caso 14 ses-rs (control) | 1/3 | 1/3 | — | — |
| demás controles (7) | todos pasan | todos pasan | — | — |
| **Casos en R1** | **7/14** | **10/14** | | |

| Criterio | A | K | Cumple |
|---|---:|---:|---|
| 1. Objetivo ≥ A + 6 de 30, p ≤ 0.10 | 3 | 14 | sí (+11; Fisher de una cola p = 0.0017) |
| 2. Ningún control que pasa en A cae en K | — | ninguno | sí |
| 3. Onepager C4 / pnl C3 | 6 / 0 | 6 / 2 | sí |
| 4. Reproceso ≥ A − 1 | 2 | 2 | sí |

**Disparo:** kit-insumos se cargó en 36 de 50 reps de K: 6/6 en rcs, onepager, pnl y reclasificación, y 4/6 en
cortes. **Sigue sin resolver:** pnl-sms (sube C3, pero C4 sigue en 0: contesta «mejoró») y cortes-5s. El caso 14
falla igual en ambos brazos (1/3): revisar aparte.
**Siguiente, según lo prerregistrado:** disparo del banco del kit con esta rama (solo reporte), PR en borrador y
council.

## Council (2026-10-11 noche): aprobada con cambios, dos familias
- **council-codex** (OpenAI; ángulo: medición y sobreajuste): recalculó los cuatro criterios desde los `resultado.json`
  y cuadran (14/30 contra 3/30, p = 0.0017106). Leyó entregables: K mejora por selección y cálculo, no por imitar
  frases. Objeciones:
  1. guardia contra sobreafirmar demasiado estrecha: falta la rama «no alcanza → discrepancia con las dos cifras», y
     un cuadre exacto no prueba una causa;
  2. hay adaptación al banco, no todavía generalización: medir en un banco chico de casos no usados para redactarla,
     con pares contrafactuales;
  3. correr el gate de disparo.
- **council-kimi** (Moonshot; ángulo: encaje y gobernanza). Objeciones:
  1. la señal de alto «dos vistas» contradice a kit-analisis-datos y kit-finanzas en el caso «no alcanza»;
  2. faltan casos de frontera en el banco de disparo y el gate (≥ 19/21);
  3. el presupuesto del núcleo no dice qué paga;
  4. falta el «cuándo no usarla» en la description;
  5. faltan CHANGELOG, versión y manifiesto. Atribución MIT: suficiente.

**Cambios aplicados** (la parte medida de la skill no cambia; se agregan condiciones):
- rama «el insumo no alcanza → discrepancia con las dos cifras»;
- la causa va al titular solo si el insumo la prueba («un cuadre exacto prueba qué filas van juntas, no por qué»);
- señal «dos vistas» condicionada a «cuando el insumo ya prueba cuál vale»;
- description con «no la uses si…» (557 caracteres; total 5,959/6,000);
- núcleo 139/150, con la fila pagada fundiendo un párrafo de Subagentes;
- banco de disparo +2 fronteras (31-32);
- CHANGELOG v1.34 y `plugin.json` 1.34.0 con el manifiesto.

**Gates antes de fusionar** (el PR queda en borrador hasta cumplirlos):
- (a) re-medir la versión con cambios en los casos objetivo, más sow y reproceso, contra el A del mismo día: que no
  pierda lo ganado (objetivo de K' ≥ A + 6 de 30, sin bajar sow);
- (b) gate de disparo con el banco de 32 (núcleo ≥ 19/21, cero confusiones nuevas, 31-32 cargan kit-insumos);
- (c) banco de generalización (objeción 2 de Codex): decide el dueño del kit si es requisito antes de publicar o vigilancia
  posterior, como la v1.33.

## Gate (a), re-medición de la versión con los cambios del council (K', commit bf6d67a)
Dos rondas, objetivo + reproceso + sow, 6 reps por caso. Reportes `evals-entregables/reportes/*-insumos-k2-{a,b}-*`.

| Caso | A | K (medida) | K' (con cambios) |
|---|---:|---:|---:|
| onepager | 1/6 | 6/6 | 4/6 |
| rcs | 0/6 | 3/6 | 2/6 |
| reclasificación | 2/6 | 5/6 | 3/6 |
| pnl | 0/6 | 0/6 | 0/6 (C3 2/6) |
| cortes | 0/6 | 0/6 | 0/6 (C3 «no reclama» 5/6) |
| **Objetivo** | **3** | **14** | **9** (+6, p = 0.052) |
| reproceso | 2/6 | 2/6 | 1/6 |
| sow | 3/3 | 3/3 | 5/6 (pasa por mayoría) |

**Cumple el gate (a) en el borde** (+6), pero los cambios del council costaron casi la mitad de la ganancia: la rama
«no alcanza → discrepancia» y la causa condicionada dan al modelo una salida para no comprometerse. Es lo que el método
de origen advierte sobre los matices.

## Gate (b), disparo: sin correr
`disparo.sh` mide con el núcleo INSTALADO y se niega si el instalado (v1.33) no es la versión del repo (1.34.0).
Control de `main` del mismo día: 83/90, sin regresiones. El disparo de la rama antes del council (núcleo instalado +
skills de la rama): 79/90, con diferencias en los casos 1 (1/3 contra 3/3), 13 y 25. kit-insumos no se cargó en ninguna
corrida del banco, así que no les robó el disparo de forma directa; con 3 corridas por caso no se separa ruido de
competencia de descriptions. Para correr el gate hace falta que `disparo.sh` acepte un núcleo de prueba (como el
`config_b` de los evals) o instalar la rama.

## Decisión del dueño (2026-10-12) y gates finales, prerregistrados ANTES de medir
Se publica una versión intermedia, **K''** = texto medido K (2da226d) + dos cambios: la señal «dos vistas» condicionada
a «cuando el insumo ya prueba cuál vale» (quita la contradicción con kit-analisis-datos y kit-finanzas) y la
description con «no la uses si…». Se retiran la rama «no alcanza» y la causa condicionada del cuerpo, que costaron
5 de 14 en K'. El resto del PR (núcleo 139/150, banco de disparo 32, CHANGELOG) queda igual.

- **(a'') Re-medición** en los casos objetivo, reproceso y sow, 6 reps por caso, contra A (3/30). Pasa si: objetivo
  ≥ A + 8 de 30 con p ≤ 0.05, sow pasa por mayoría y reproceso ≥ A − 1.
- **(b) Disparo** con el banco de 32, usando un núcleo de prueba (`disparo.sh` aceptará `DISPARO_NUCLEO`). Pasa si:
  núcleo (1-21) ≥ 19/21; ningún caso de 1-30 baja 2+ corridas contra el control de `main` del mismo día (83/90);
  31-32 cargan kit-insumos en ≥ 2/3 cada uno.
- **(c) Generalización, exigida por el dueño.** Casos nuevos que no se usaron para escribir la skill, cosechados de
  otros proyectos auditados, en pares contrafactuales:
  - (i) el insumo prueba la lectura;
  - (ii) el insumo no alcanza, y la respuesta correcta es mantener la discrepancia.
  Los casos se escriben y se firman antes de correr ningún brazo. Pasa si: en (i), K'' > A en reps PASA; en (ii), K''
  ≥ A − 1 (no sobreafirma).
Si cualquiera falla, no se publica.

## Gate (c): banco de generalización congelado ANTES de correr (2026-10-12)
Tres pares nuevos, cosechados de proyectos que no se usaron para escribir la skill. Los escribieron autores ciegos a
kit-insumos (Codex y Kimi; no pudieron leerla porque solo existe en esta rama) y los revisó otra familia (Kimi revisó
los de Codex y Codex el de Kimi), con las correcciones aplicadas. Cifras verificadas contra la fuente con scripts.
Viven en evals-entregables `casos-generalizacion/`. Huella sha256 (tarea + esperado + meta, 16 caracteres):

| Caso | Huella |
|---|---|
| serie-cambio-extracto-prueba | faa2dc7a8ae5019d |
| serie-cambio-extracto-sin-evidencia | 3fd6f66f9c0b15f5 |
| precio-cantidad-uno-prueba | 4f8af099689758a3 |
| precio-cantidad-uno-sin-evidencia | 142b3dbc8194f7ab |
| pico-factura-mal-capturada-prueba | 9a1392515892f052 |
| pico-factura-mal-capturada-sin-evidencia | ca930a06839ac33d |

**Corrida:** A (v1.33) y K'' (texto de este PR, `e0336a4`), mismo CLI, juez aislado, 2 rondas × 3 reps = 6 reps por
caso por brazo; (i) = los tres «-prueba» (18 reps), (ii) = los tres «-sin-evidencia» (18 reps).
**Pasa si:** (i) reps PASA de K'' > A; (ii) reps PASA de K'' ≥ A − 1. Se reportan aparte, sin decidir con ellos:
Fisher de (i) y criterios por caso.

## Resultado del gate (a''): CUMPLE, en el umbral
Reportes `evals-entregables/reportes/*-insumos-k3-{a,b}-*`. K'' contra A, 6 reps por caso:

| Caso | A | K | K' | K'' |
|---|---:|---:|---:|---:|
| onepager | 1/6 | 6/6 | 4/6 | 4/6 |
| rcs | 0/6 | 3/6 | 2/6 | 2/6 |
| reclasificación | 2/6 | 5/6 | 3/6 | 4/6 |
| pnl | 0/6 | 0/6 | 0/6 | 1/6 |
| cortes | 0/6 | 0/6 | 0/6 | 0/6 |
| **Objetivo** | 3 | 14 | 9 | **11** (+8, p = 0.015) |
| reproceso | 2/6 | 2/6 | 1/6 | 5/6 |
| sow | 3/3 | 3/3 | 5/6 | 6/6 |

**Señal en contra** (fuera de los criterios de este gate, que no la incluían): onepager C4, «sin sobreafirmar», queda
en 4/6, contra 6/6 de A. Es la preocupación del council.

## Resultado del gate (b): NO CUMPLE
`DISPARO_NUCLEO` con el núcleo de esta rama, banco de 32: 82/96. Reporte en `evals-entregables/reportes/2026-10-12-0229-disparo/`.
- **Núcleo (1-21): 18/21 < 19.** El control de `main` del mismo día dio 19/21.
- **Caso 1:** 1/3 contra 3/3 en `main`. Se repite en las dos corridas de la rama, antes y después del council: con
  kit-insumos en el catálogo, ese caso termina SIN ninguna skill en 2 de 3.
- **31:** 2/3 (cumple). **32 (memo con tablas):** 0/3, sin ninguna skill (no cumple).

**Conclusión: no se publica.** La siguiente iteración es la description y el disparo, no el cuerpo: que el memo con
tablas dispare y que la skill no le quite el disparo a la presentación del caso 1.

## Resultado del gate (c), generalización: NO CUMPLE
Reportes `evals-entregables/reportes/*-gen-{r1,r2}-{A,K}-*`, 6 reps por caso y brazo.

| Caso | A | K'' |
|---|---:|---:|
| serie-cambio-extracto-prueba | 5/6 | 4/6 |
| precio-cantidad-uno-prueba | 0/6 | 0/6 |
| pico-factura-mal-capturada-prueba | 0/6 | 0/6 |
| **(i) con evidencia** | **5/18** | **4/18** (no cumple K'' > A) |
| serie-cambio-extracto-sin-evidencia | 0/6 | 0/6 |
| precio-cantidad-uno-sin-evidencia | 0/6 | 0/6 |
| pico-factura-mal-capturada-sin-evidencia | 0/6 | 0/6 |
| **(ii) sin evidencia** | **0/18** | **0/18** (cumple ≥ A − 1, por piso) |

**Lectura:**
- La skill no mostró transferencia a trampas nuevas. La objeción 2 de Codex queda confirmada en lo que este banco
  puede medir.
- Hay efecto piso. En pico-factura-mal-capturada-prueba los dos brazos detectan y corrigen (C1-C3) y fallan solo C4, un requisito de
  procedimiento muy específico. Esa rúbrica se revisa antes de reusar el caso; ninguno de los 6 tiene hojas de juez
  calibradas.
- **Hallazgo nuevo y general:** en los tres casos «sin evidencia», AMBOS brazos afirman una causa como hecho («es un
  lote atrasado», «F no cayó»). La sobreafirmación con evidencia insuficiente es una falla del productor que el kit
  actual no cubre, y K'' tampoco: quitó la rama «si solo es compatible, va a pendientes».

**Decisión, según lo prerregistrado: v1.34 NO se publica** (fallan b y c). El PR #91 queda en borrador como registro.
**Siguiente iteración** (otra ronda, con prerregistro nuevo):
1. Description y disparo: que el memo con tablas dispare y no se pierda el caso 1.
2. Recuperar la rama «compatible → pendientes» en forma de condición observable y medirla contra los casos
   «sin evidencia».
3. Calibrar al juez del banco de generalización y revisar el C4 de pico-factura-mal-capturada.
4. Ampliar ese banco antes de volver a usarlo como gate.
