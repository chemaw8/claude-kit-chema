# Council v1.34 — retiro de la regla v1.22 (2026-10-19)

**Propuesta:** quitar del núcleo la oración de la v1.22 («Toda tabla o lista de resultados […] nunca de memoria»)
aplicando el criterio de retiro que la regla fijó al entrar (PR #47): «si en 30 días no baja ese patrón en los juicios
del advisor, se retira». Rama `regla/v1.34-retiro-v1.22`, commit evaluado `d448e8f`.

**Panel:** tres evaluadores independientes, una familia cada uno, un ángulo cada uno, sin ver a los otros.

| Familia | Ángulo | Veredicto |
|---|---|---|
| Anthropic (Opus 5.5) | evidencia | aprobada con cambios |
| OpenAI (GPT-6 Astra) | qué se pierde | aprobada con cambios |
| Moonshot (Kimi K3) | proceso y gobernanza | aprobada con cambios |

**Agregado:** aprobada con cambios (3 de 3). Nadie pidió conservar la regla.

## Objeciones y qué se hizo

| # | Objeción | De | Hecho |
|---|---|---|---|
| 1 | El «0 fallos antes» lo produce el regex de la métrica, que no capturaba casos que motivaron la regla | Anthropic | Recontado con un filtro amplio sobre todos los juicios: antes 7/81, después 41/163. Ambos recuentos en el CHANGELOG |
| 2 | La frase «solo en el peor caso la tasa habría bajado» dependía de un denominador que el propio texto descalificaba | Anthropic | Sustituida por «con ningún recuento ni denominador baja el patrón» |
| 3 | La ventana «después» incluye evals | Anthropic | Declarado en el CHANGELOG (7 de 41 en Claude Code, casi todos de evals) |
| 4 | Se aplica al día 25 de 30 | Anthropic | Declarado con su razón |
| 5 | La métrica tenía poco alcance; no reusarla sin validarla contra casos conocidos | Anthropic | Anotado en `reglas-vigiladas.json` al retirar y en DECISIONES |
| 6 | La cobertura que queda es parcial, no equivalente | OpenAI | CHANGELOG reescrito con lo que se pierde |
| 7 | Gate de disparo, acta, DECISIONES, CONTINUAR, `reglas-vigiladas.json` | Kimi | Gate corrido sobre el núcleo de la rama; acta, DECISIONES y CONTINUAR en el PR; `reglas-vigiladas.json` (fuera del repo) se marca al fusionar |
| 8 | No se separaron los dos modos (fabricar contra leer mal) | Kimi | Declarado como límite en el CHANGELOG |

**Sin hallazgos:** referencias rotas (ninguna skill, comando, agente o hook cita la oración), confidencialidad del repo
público, aritmética del núcleo (137 líneas) y versión del manifiesto (1.34.0).
