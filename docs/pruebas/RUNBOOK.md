# RUNBOOK — gate de disparo

Cómo correr el gate que comprueba que cada petición carga la skill correcta, sin
infraestructura extra. El banco de peticiones es `docs/pruebas/banco/disparo.md`.

## Qué mide (y qué no)

`verificar.sh` solo mide los límites mecánicos: núcleo < 150 líneas, descriptions
en rango, sin mayúsculas de énfasis. No sabe si las descriptions disparan bien;
eso lo delega a este gate. Los dos son complementarios: uno cuida los números,
el otro el comportamiento.

## El juez

Un subagente Sonnet, esfuerzo bajo, contexto fresco. Recibe únicamente:

1. los pares `nombre + description` de las skills instaladas (nada más del
   SKILL.md: ni el cuerpo, ni los ejemplos);
2. una petición del banco.

Devuelve el nombre de una skill o `ninguna`. No ve las demás peticiones ni los
resultados anteriores, para que cada juicio sea independiente. El juez es siempre
Sonnet esfuerzo bajo: nunca Opus ni Fable. El disparo real ocurre con el
router del propio Claude Code leyendo solo las descriptions, así que subir el
modelo del juez falsearía la prueba (mediría un lector más listo que el real).

En altas de skill nueva o cambios de frontera puede correrse además una pasada
con juez Haiku como sonda de robustez: informa —marca las descriptions que un
lector más débil encuentra ambiguas—, nunca bloquea. El gate lo decide solo el
juez Sonnet, que es quien iguala al lector real: un juez más débil sobre-rechaza
igual que uno más listo sobre-aprueba (council 2026-07-10).

## Criterio de paso

Se pasa el gate si se cumplen las dos cosas:

- **Proporcional:** ≥ 19 de las 21 peticiones del núcleo aciertan (≈ 91%).
- **Fronteras:** cero confusiones nuevas en los bordes vecinos —
  informe ↔ deck, mensaje-de-aprobación ↔ propuesta, correo/estatus ↔ redacción.
  Una confusión de frontera nueva bloquea aunque el proporcional pase.

Un fallo ya conocido y benigno (petición 10, script-de-una-vez que cae en
kit-automatizacion, que igual aplica kit-codigo al construir) no cuenta como
confusión nueva.

## Cómo correrlo

1. Reúne las descriptions vigentes de las skills instaladas.
2. Por cada fila del banco, lanza un juez con contexto fresco (las descriptions +
   esa petición) y anota qué eligió.
3. Compara contra la columna "skill esperada" y calcula proporcional + fronteras.
4. Si algo falla, no engordes las descriptions por un caso: revisa si es frontera
   genuinamente ambigua (documéntala) o una confusión real que cerrar por ambos
   lados, como se hizo con redacción ↔ propuestas.

El workflow que automatiza este barrido (un juez por petición, en paralelo) vive
en la sesión de construcción del kit; aquí se referencia el patrón, no una ruta
de archivo frágil que se rompería al reorganizar. Reconstruirlo desde esta
descripción es directo.

## Gate de push — prueba en vivo (2026-09-07, repo piloto claude-kit-chema)

La única prueba del gate que gasta cuota. Todo lo demás corre sin red
(`hooks/test-sello-push.sh`, `scripts/sello-push.sh autotest`). Qué se hizo y qué debe verse:

1. Rama `gate-prueba` con dos defectos sembrados que `verificar.sh` no ve: un hook con ruta
   absoluta de una máquina y una prueba con `|| true` que siempre imprime TODO OK.
2. `git push` → el hook bloquea: `8a8b16d (rama gate-prueba) no tiene sello de revisión`.
3. `sello-push.sh revisar` (timeout 600000) → pruebas en verde en el worktree → revisor Opus.
4. Corregir (quitar los archivos) → sha nuevo → `git push` bloquea citando el sello anterior
   con sus 3 pendientes → `revisar` → previos resueltos → `git push` pasa → `permitido`.

| Revisión | Diff | Resultado | Tokens (in+out+cache) | USD | Duración |
|---|---|---|---|---|---|
| 1ª (8a8b16d) | 1,378 líneas, 12 archivos | 3 bloqueantes, 5 avisos, 0 sin evidencia | 65,312 | 0.90 | 164 s |
| 2ª (b7c2690) | 1,386 líneas, 10 archivos | aprobado; 7 avisos; previos 7 resueltos, 1 sigue | 80,443 | 0.72 | 632 s |

El revisor cazó **los dos defectos sembrados** con evidencia literal y, además, **tres defectos
reales del propio gate** (contador de `saltar`, escape válido en comentarios, timeout y
`omitido` en repos sin llave), corregidos en el commit 63977b8 antes de la segunda vuelta; la
segunda vuelta dejó siete avisos menores, también atendidos. El hallazgo que "sigue" (H7) es
que ninguna prueba sin cuota ejercita la llamada real a `claude -p`: eso lo cubre esta prueba
en vivo, y la fila `revision` del ledger guarda `cli_version` y `prompt_sha` para saber con qué
se midió. Observaciones: la duración la marca la salida del revisor (26k tokens de salida en la
segunda), no las pruebas; la primera revisión rozó el tope de 1 USD, por eso el default de
`SELLO_TOPE_USD` es 2. Las filas quedan en `~/.claude/kit-chema/gate.jsonl` y
`sello-push.sh metricas 1` las agrega: 1 permitido, 2 bloqueos, 2 revisiones.

Para repetirla: sembrar defectos con evidencia literal obvia en el diff; si el revisor devuelve
0 hallazgos, repetir una vez; si vuelve a 0, anotar "revisor no cazó" aquí y no bloquear la
construcción por eso (RF-19 de la spec 002 de claude-entorno).

