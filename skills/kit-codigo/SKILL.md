---
name: kit-codigo
description: Estándar Kit Chema para escribir, modificar o revisar código, scripts y proyectos de desarrollo. Úsala siempre antes de tocar código — al crear una función o proyecto, arreglar un bug, hacer un script, refactorizar o revisar un PR. Frases gatillo típicas "haz un script que", "arregla este error", "crea el proyecto", "revisa este código", "automatiza con código". Incluye la higiene anti-contaminación (reutilizar antes de crear, cero residuos, dependencias justificadas) y el flujo entender→plan→TDD→implementar→verificar de verdad.
---

# Código — estándar Kit Chema

Playbook para escribir, modificar o revisar código. La sección más importante
es la higiene anti-contaminación: es lo que evita que el código generado se
convierta en basura acumulada.

## Bien hecho significa

- Funciona verificado end-to-end: lo corriste con datos de verdad, no solo pasan
  los tests. Ver los tests en verde no es prueba de que la funcionalidad sirva.
- Sigue los patrones del repo: mismo estilo, naming, estructura de carpetas y
  forma de manejar errores que el código que ya está.
- Es el cambio mínimo que resuelve la tarea pedida, nada más.
- No deja residuos: sin código muerto, sin prints de debug, sin archivos de
  prueba, sin comentarios "TODO" tuyos.
- No contiene secretos (claves, tokens, contraseñas) ni datos reales de clientes;
  esos van en variables de entorno o archivos fuera del control de versiones.
- Commits atómicos (un cambio lógico por commit) con mensajes que explican el qué
  y el porqué.

## Proceso

Este es el orden; el primer paso es el que más se salta y el que más cuesta.

1. Entender. Lee el código existente relevante antes de escribir una línea:
   cómo se resuelven ahí problemas parecidos, qué utilidades ya hay, qué
   convenciones se usan. Sin este paso terminas duplicando o rompiendo cosas.
2. Plan corto. Antes de programar, di en 2-4 líneas qué archivos vas a tocar y
   qué vas a hacer. Si el plan no cabe en unas líneas, la tarea es más grande de
   lo que parece: divídela.
3. TDD cuando hay lógica que probar. Escribe un test que falle, luego la
   implementación mínima que lo hace pasar, luego confirma que pasa. Para código
   sin lógica (config, scripts de un solo uso, ajustes triviales) no fuerces
   tests; para parsers, cálculos, reglas de negocio, sí.
4. Verificación end-to-end real. Corre la app o el script con datos verdaderos y
   mira la salida. Un script de datos se ejecuta contra el archivo real; un
   endpoint se llama y se revisa la respuesta.
5. Limpieza del diff. Antes de cerrar, repasa el diff completo (`git diff`) y
   quita todo lo que no aporta a la tarea.

## Higiene anti-contaminación

La regla que sostiene todo lo demás. Cada punto es verificable.

- Reutilizar antes de crear. Antes de escribir una función, utilidad o módulo
  nuevo, busca si ya existe algo que lo haga (`grep`/búsqueda por nombre y por
  comportamiento). Grep primero, escribir después. Si ya existe, úsalo o
  extiéndelo; no lo dupliques.
- Respetar el estilo y naming del repo aunque no te guste. Tu preferencia
  personal no es motivo para introducir un estilo distinto en un proyecto que ya
  tiene el suyo.
- Nada de refactors no pedidos. No reescribas, renombres ni "mejores" código que
  no es parte de la tarea. Si ves algo que conviene cambiar, propónlo aparte; no
  lo metas de contrabando en este cambio.
- Cero residuos antes de terminar. Borra el código muerto que hayas dejado, los
  prints y logs de depuración, y los archivos de prueba o experimento que creaste
  para trabajar.
- Dependencias justificadas. Cada dependencia nueva se justifica en una línea
  (qué problema resuelve y por qué no basta con lo que ya hay), y antes de
  añadirla verificas que el proyecto no tenga ya una equivalente.
- Revisar el diff completo antes del commit final. Lee todo lo que vas a
  commitear. Lo que no aporte a la tarea, fuera.

## Debugging sistemático

- Reproduce el error antes de intentar arreglarlo. Si no puedes reproducirlo, no
  sabes si lo arreglaste.
- Trabaja por hipótesis: formula una causa probable, busca la evidencia que la
  confirma o descarta, y solo entonces aplica el fix.
- No "arregles" código que no entiendes. Cambiar cosas al azar hasta que parezca
  funcionar deja bugs escondidos; primero entiende por qué falla.

## Checklist final

- ¿Corre de verdad, ejecutado con datos reales?
- ¿Pasan los tests?
- ¿El diff está limpio (sin residuos, sin cambios ajenos a la tarea)?
- ¿Sin secretos ni datos reales de clientes en el código o los commits?
- ¿Commits atómicos con mensajes claros?
- Si es algo nuevo, ¿documenté cómo correrlo?

## Errores típicos

- Duplicar una utilidad que ya existía en el repo por no buscar primero.
- Colar "mejoras" o refactors que nadie pidió junto al cambio real.
- Declarar la tarea lista sin haberla ejecutado ni una vez.
- Dejar en el repo archivos-experimento, prints de debug o código muerto.
