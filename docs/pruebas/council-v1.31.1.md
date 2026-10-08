# Council v1.31.1. Limpieza del texto del kit: raya al estilo inglés y prefijos con guion (2026-10-08)

Rama `texto/rayas-y-prefijos` (`git diff main...texto/rayas-y-prefijos`). Pendiente desde el acta v1.27 («el texto del
kit conserva 39 rayas espaciadas y 15 prefijos con guion; limpiarlos toca descriptions y queda para otra ronda»).
Pedido por el dueño el 2026-10-07.

## Qué entra

Solo forma, sin cambiar reglas. En el núcleo, las 9 skills, los 4 agentes y los 3 comandos:
- **54 rayas con espacio a ambos lados** (estilo inglés, señal F9 de `scripts/muletillas.sh`) pasan a dos puntos,
  coma, punto y coma o paréntesis según la función, y una a inciso pegado («—su alcance—», norma RAE 2010).
- **19 prefijos con guion** (F12) se escriben juntos: `multiagente`, `reejecutar`, `anticontaminación`,
  `sobreingeniería`, `antianclaje`, `multisesión`, `multiángulo`, `rededucir`, `relanzamiento`. `anti-secretos`, que es
  el nombre de un hook, pasa a código.
- Tocan **16 descriptions** (9 skills, 4 agentes, 3 comandos): cambia la raya y, en `kit-codigo` y `sintetizador`, también un prefijo (`anticontaminación`, `multiagente`).
  Ninguna frase gatillo cambia.

Conteo con `scripts/muletillas.sh revisar` sobre `nucleo/*.md skills/*/SKILL.md skills/*/references/*.md agents/*.md
commands/*.md`: F9 55 → 1 y F12 19 → 0; 18,564 → 18,512 palabras. La F9 que queda es un falso positivo del script
(`commands/cierre.md:34`, inciso bien puesto que cierra tras un `código`). El conteo de v1.27 (39 y 15) era sobre un
conjunto más chico de archivos.

## Evidencia

- **Por qué vale la pena** (acta v1.27): en el A/B de la raya, «con kit» dio 2 de 10 textos con raya espaciada y «kit
  sin rayas» 1 de 10; sin kit, 0 de 10. Provisional: n=10 por brazo, y ni siquiera «con kit» contra «sin kit» es significativo (Fisher p ≈ 0.47) y el kit no es la mayor fuente (las notas
  del vault tienen más). Los prefijos con guion: 0 en texto humano, 15 en el kit, 16 en entregables reales.
- **Gate de disparo:** `python3 docs/pruebas/disparo.py --modelo sonnet --paralelo 6` sobre e480497 → núcleo 21/21,
  confusiones de frontera no benignas 0, rc=0.
- `bash verificar.sh`: rc=0, ninguna FALLA.

## Riesgos que el autor ya ve

- El beneficio no está medido en la audiencia: se limpia una dosis moderada de una fuente entre varias.
- El mandato del evaluador de `kit-propuestas` se «pasa literal»: cambia una palabra (`sobre-ingeniería` →
  `sobreingeniería`). Las actas viejas lo citan con guion; no se reescriben.
- Choca en el núcleo con el PR #82 (v1.32, en borrador) solo si tocan las mismas líneas: no las tocan.

## Postura inicial del autor (antes de leer al panel)

Aprobada: es forma, el gate pasa y es reversible con un revert. Mi única duda es si alguna sustitución cambió el
sentido de una frase.

## 2026-10-08: acta y correcciones verificadas

**Veredicto: aprobada con cambios; aplicados en `a8bd68d`.** OpenAI Astra (viabilidad técnica) y Anthropic Opus 5.5
(abogado del diablo) coincidieron en el bloqueo: cambiar raya por dos puntos rompía el YAML de varias descriptions.
Kimi K3 (riesgos) aprobó, sin detectar ese problema. Su primer intento agotó el tiempo y no se contó como voto;
se repitió con `revisor-kimi`, mismo modelo, mandato y contexto independiente, sin mostrarle los otros informes.
Los tres reportes completos están en `council-v1.31.1-crudos/`.

La postura inicial cambia: no bastaba que los tests y el gate estuvieran verdes. Se reprodujo el error con el
parser `yaml` del pi instalado: fallaban 11 frontmatters. Tras entrecomillarlos, los 20 frontmatters de skills,
agentes y comandos parsean y traen description de texto. La comprobación nueva de `verificar.sh` detecta esta
clase concreta de error (`: ` en description sin comillas); no se presenta como un validador YAML completo.

| Hallazgo | Clase final | Procedencia | Resolución |
|---|---|---|---|
| YAML inválido en descriptions | actuar | OpenAI y Anthropic | 11 descriptions entrecomilladas; parser real sin fallos |
| Rayas que el revisor léxico no veía dentro del conjunto | actuar | Anthropic | Corregidas en núcleo, sintetizador y proyecto-init |
| Gate sin registro en su acta específica | actuar | Anthropic | Corrida final íntegra y registro en `disparo-descriptions.md` |
| Chequeo para que no vuelva el mismo error YAML | considerar | Anthropic | Adoptado: guardia pequeña, sin dependencias nuevas |
| Rayas y prefijos en estándar y plantillas | considerar | Anthropic | Incluidos en la misma limpieza; no se alteraron contratos de CONTINUAR |
| Puntos ciegos de `muletillas.sh` | considerar | Anthropic y Kimi | No se cambia el script aquí; queda documentado como mejora opcional |
| Frases gatillo y significado conservados | anotado | Las tres familias | Ningún cambio semántico demostrado; gate final íntegro |
| Afirmación general «máquinas sin riesgo» | descartado | Kimi | No cubría el consumidor YAML; no se hereda esa garantía |

**Mapa de acuerdos.** El bloqueo YAML tiene evidencia coincidente de OpenAI y Anthropic, no una mayoría de votos.
La limpieza incompleta y el registro del gate los señaló solo Anthropic. Kimi corroboró mecánicamente los conteos
iniciales y el merge limpio con #82; su aprobación no invalida el fallo del parser. La evidencia de beneficio
estético sigue siendo débil: este cierre no afirma mejora de entregables ni del 7/13.

### Clasificación de hallazgos: comprobación de repetibilidad

Dos `sintetizador` Fable 5.1 corrieron en paralelo con los mismos tres informes y la misma postura inicial, sin
verse entre sí. Ambos dieron **aprobada con cambios**. Sus tablas finales se conservan como extractos literales
(`sintesis-1-tabla.md`, `sintesis-2-tabla.md`); no se afirma que esos archivos sean las síntesis completas.

Se emparejaron manualmente los seis hallazgos que proponían una acción. La correspondencia y los números de fila
están en `clasificacion.tsv`: coinciden **5 de 6 clases**. La diferencia es el registro del gate, `actuar` en una
síntesis y `considerar` en la otra; ambas listas de cambios pedían hacerlo. Se resolvió como `actuar` por el RUNBOOK.
Los enunciados anotados no se puntúan: una síntesis los agrupó y la otra los separó.

Es una sonda de estabilidad del formato, no una prueba de que clasificar mejore las decisiones: mismo modelo,
un council y emparejamiento posterior. Queda cerrado el pendiente de conservar los informes originales y contrastar
la clasificación; no se añade otra regla ni se exige una nueva ronda por este resultado.

### Pruebas finales

- `bash verificar.sh`: código 0, sin FALLA (103 comprobaciones en esta corrida).
- Parser YAML real de pi: 20 frontmatters válidos. Antes de corregir, 11 fallaban.
- Gate de disparo sobre las descriptions finales de `a8bd68d`: 30/30 peticiones, núcleo 21/21,
  cero errores del ejecutor y cero confusiones de frontera; código 0. Salida íntegra en
  `council-v1.31.1-crudos/gate-disparo.txt`.
- Las corridas previas con `TimeoutExpired` no se aceptaron como validación completa, incluso una que imprimió
  PASA. La recuperación OAuth de Anthropic se verificó aparte; no demuestra la causa de todos esos timeouts.
- El conteo inicial F9/F12 de arriba corresponde al árbol revisado por el panel, no al alcance ampliado final.
  Queda el falso positivo conocido de `commands/cierre.md`; los marcadores de la plantilla CONTINUAR se conservan
  porque son un contrato del helper, no prosa libre. No se reescribieron actas históricas.
