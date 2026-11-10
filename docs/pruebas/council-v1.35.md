# Council v1.35 — Fable 5.2 en la escalera de modelos (2026-11-09)

**Propuesta:** Fable 5.2 reemplaza a 5.1 en el escalón de síntesis, la latencia deja de justificar el salto a Fable y
el costo pasa de 2.5× a 2× frente a Opus 5.5. Rama `modelos/fable-5-2`, commit evaluado `bb53934`. Evidencia en
`medicion-fable-5-2.md`.

**Postura inicial del hilo principal**, fijada antes de leer los reportes: «apruebo con cambios menores; lo que más
dudo es dejar el sintetizador en Fable sin la razón de la latencia».

**Panel:** tres evaluadores independientes, una familia cada uno, un ángulo cada uno, sin ver a los otros. Solo vieron
este repo, no la batería privada.

| Familia | Ángulo | Veredicto |
|---|---|---|
| Anthropic (Opus 5.5) | viabilidad y coherencia con la evidencia | aprobada con cambios |
| OpenAI (GPT-6 Astra) | riesgos y abogado del diablo | aprobada con cambios |
| Moonshot (Kimi K3.1) | costo/beneficio | aprobada con cambios |

**Agregado:** aprobada con cambios (3 de 3). Nadie pidió bajar el sintetizador a Opus 5.5 como condición, ni subir el
hilo principal a Fable.

## Objeciones y qué se hizo

| # | Objeción | De | Hecho |
|---|---|---|---|
| 1 | El sintetizador se justificaba con evidencia prestada: el disparo, que no le aplica porque no elige skills, y los criterios en entregables, que caen dentro del ruido | los tres | Se quitaron las dos razones. Queda como continuidad provisional, sin ventaja medida; se revisa con la primera medición de síntesis |
| 2 | «El doble de precio pesa poco» es falso: en el council de v1.31 la síntesis fue el 38 % del costo de council más síntesis (1.35 / 3.59) | Moonshot | Verificado en `council-v1.31.md`. Ahora se dice que el sobrecosto se acepta a sabiendas y que no es menor |
| 3 | En kit-orquestacion, «medido el 2026-11-09» se extendía a síntesis y juicio, que no se midieron | Anthropic, OpenAI | La fecha queda pegada al precio, al empate y a la latencia; síntesis y juicio son el alcance que el kit asigna, sin ventaja medida |
| 4 | «Exactamente 2×» no tenía fuente | Anthropic | Se agregó la página de precios oficial con la fecha de consulta y los $/M de los dos modelos |

**¿Cambió la postura inicial?** En la justificación sí; en el modelo no. La duda era si el sintetizador debía bajar a Opus
5.5. El panel coincidió en que no hace falta bajarlo, pero mostró que el texto que yo había escrito para sostenerlo
usaba evidencia que no le aplica. Ahora se dice que es provisional y que no tiene ventaja medida.
