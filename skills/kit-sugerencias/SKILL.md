---
name: kit-sugerencias
license: MIT
description: 'Estándar Kit Chema para cuando el usuario pide ayuda a elegir o la petición trae poca información. Úsala cuando el usuario diga "dame opciones", "qué sugieres", "qué recomiendas", "no sé cuál", "ayúdame a decidir", "cómo le hago", o cuando la tarea esté poco especificada y haya varias formas razonables de hacerla que llevarían a trabajos distintos. En vez de adivinar o de preguntar en abstracto, presenta 2-4 opciones reales con su recomendación y deja elegir. No es para decisiones caras o irreversibles (eso es kit-propuestas con council) ni para tareas triviales con un default obvio.'
---

# Sugerencias y opciones — estándar Kit Chema

Playbook para los momentos de "no sé bien qué quiero" o "tú dime cómo". La regla que
lo sostiene: ante la duda, **no adivines en silencio ni preguntes en abstracto —
ofrece opciones reales con una recomendación y deja que el usuario elija**. Detectar
que la petición admite varios caminos y arrancar por uno sin avisar es el fallo que
esta skill previene.

## Cuándo aplica (y cuándo no)

Aplica cuando pasa una de dos:

- El usuario **pide ayuda a elegir**: "qué sugieres", "dame opciones", "no sé cuál",
  "cómo le hago", "qué recomiendas".
- La petición está **poco especificada** y hay varias formas razonables de hacerla
  que llevarían a **trabajos materialmente distintos** (no solo detalles menores).

No aplica —y meterla sería sobre-ingeniería— cuando:

- Hay un **default obvio** que un colega haría sin preguntar → hazlo y menciónalo.
- La tarea es **trivial** → respuesta directa.
- La decisión es **cara o irreversible**, o el material sale de la empresa → eso es
  `kit-propuestas` con su Council, no esto.

## Cómo se hace bien

1. **Acota primero lo que sí sabes.** Di en una línea qué entendiste del pedido y
   qué es lo que está abierto. Esto evita opciones que resuelven el problema
   equivocado.

2. **Ofrece 2-4 opciones reales, no de paja.** Cada una tiene que ser algo que
   alguien elegiría de verdad. Rodear tu favorita de alternativas malas no es dar a
   elegir, es simular que se eligió. Si solo hay una opción sensata, dilo y no
   inventes competencia.

3. **Cada opción, con su costo y su para-quién.** Una línea de qué gana y qué cuesta
   (tiempo, dinero, riesgo, mantenimiento). El usuario no puede elegir bien si solo
   ve los nombres.

4. **Recomienda una, con razón.** Lidera con tu recomendación y por qué —atada a los
   costos de arriba, no a un gusto. "Cualquiera sirve" es una no-respuesta: si de
   verdad dan igual, elige tú y sigue.

5. **Deja elegir de forma clara.** Si es interactivo, presenta las opciones para que
   el usuario marque una (con la recomendada primero y señalada). Si no contesta y
   el trabajo puede avanzar bajo un supuesto, avanza con el recomendado declarándolo,
   y deja lo que dependa de la elección para cuando responda.

6. **Cuando la info es muy poca, sugiere tú el marco.** Si el usuario no sabe ni por
   dónde, no le devuelvas la pregunta: propón un punto de partida razonable
   ("yo empezaría por X porque…") y ofrécele ajustarlo. Es más útil una propuesta
   que se corrige que un formulario en blanco.

## La diferencia con preguntar

Preguntar en abstracto ("¿qué formato quieres?", "¿para quién es?") le pasa el
trabajo de vuelta al usuario. Ofrecer opciones ("puede ser A —rápido pero básico—,
B —más completo pero tardo más—, o C; yo iría por B porque…") hace el trabajo de
pensar las alternativas y deja solo la decisión. Pregunta abierta solo cuando ni
siquiera puedes proponer opciones sensatas sin ese dato.

## Errores típicos

- **Opciones de paja**: rodear la favorita de alternativas que nadie elegiría.
- **Recomendar sin costos**: dar la sugerencia sin poner qué cuesta cada opción.
- **Falso empate**: decir "cualquiera funciona" para no comprometerte. Si dan igual,
  elige y avanza.
- **Devolver el formulario**: contestar una petición vaga con puras preguntas cuando
  podrías haber propuesto un punto de partida.
- **Sobre-ofrecer**: montar 4 opciones para algo con un default obvio, o para una
  decisión cara que en realidad pedía un Council.

## Checklist

Antes de entregar las opciones:

- ¿Dije en una línea qué entendí y qué queda abierto?
- ¿Las 2-4 opciones son todas defendibles (ninguna de paja)?
- ¿Cada una trae su costo/beneficio, no solo el nombre?
- ¿Recomendé una con una razón atada a esos costos?
- ¿Dejé claro cómo elegir, y qué haré si no contestan?
