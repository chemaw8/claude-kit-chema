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
