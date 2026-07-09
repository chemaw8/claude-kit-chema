---
name: kit-propuestas
description: Estándar Kit Chema para redactar o evaluar propuestas y decisiones — propuestas de desarrollo, de inversión, de arquitectura, cotizaciones, o cualquier "¿hacemos X o Y?". Úsala al escribir una propuesta, al evaluar una idea del usuario con consecuencias reales, y siempre que se pida "council". Frases gatillo "hazme la propuesta", "¿te parece bien esta idea?", "evalúa esta decisión", "council". Incluye el protocolo Council: panel de evaluadores independientes con veredicto aprobada / con cambios / rechazada.
---

# Propuestas y decisiones — estándar Kit Chema

Playbook para redactar una propuesta y para juzgar una decisión con
consecuencias. El corazón es el Council: un panel de evaluadores independientes
que revisa lo que importa sin inventar problemas para parecer riguroso.

## Estructura de toda propuesta

Una propuesta útil se lee en este orden y no le falta ninguna pieza:

1. Problema. Qué duele y a quién. Concreto: quién sufre el problema hoy y qué
   le cuesta. Sin esto, todo lo demás es una solución en busca de un problema.
2. Opciones. Dos o tres alternativas reales, no espantapájaros. Cada una tiene
   que ser algo que alguien defendería en serio; poner una opción de paja al
   lado de la que quieres no es comparar, es hacer trampa.
3. Costos por opción. Dinero, tiempo y riesgo de cada una. Números cuando los
   haya; si no, rangos honestos. Una opción sin sus costos no está evaluada.
4. Recomendación con razones. Cuál eliges y por qué, atada a los costos de
   arriba. La recomendación se sigue de la comparación, no la precede.
5. Cómo revertirla. Qué haría falta para dar marcha atrás si sale mal. Esto
   distingue una apuesta barata de una jugada irreversible y fija cuánto rigor
   merece la decisión.

## Cuándo corre un Council

No toda decisión necesita panel. Corre un Council cuando:

- el usuario dice "council" (lo fuerza siempre);
- la decisión es cara o difícil de revertir;
- el material sale de la empresa (cliente, proveedor, público).

Si no aplica ninguno, basta la evaluación crítica del núcleo (qué está bien,
qué me preocupa, qué haría yo). No montes un panel para elegir el nombre de una
variable.

## Protocolo Council

El panel son de 3 a 5 evaluadores independientes, cada uno con contexto fresco
—sin ver las conclusiones de los demás— y un lente asignado:

- viabilidad técnica: ¿se puede hacer de verdad, con lo que hay?
- costo/beneficio: ¿los números cierran?, ¿el retorno justifica el gasto?
- riesgos: ¿qué puede salir mal y qué tan grave sería?
- abogado del diablo: el mejor argumento en contra de la recomendación.
- dominio relevante (opcional): un experto del área concreta cuando la haya
  (legal, fiscal, seguridad, el negocio del cliente).

A cada evaluador se le entrega la propuesta y el mandato acotado de la sección
siguiente. La mecánica cambia según dónde corras:

- En Claude Code: lanza los evaluadores como subagentes en paralelo, con modelo
  Opus 4.8 cada uno. El hilo principal recoge sus reportes y sintetiza un solo
  veredicto.
- En claude.ai (web): no hay subagentes, así que evalúa secuencialmente en la
  misma conversación, tomando un lente a la vez y marcando cada sección con su
  nombre ("Viabilidad técnica:", "Riesgos:", ...). Trata cada lente como una
  pasada independiente: no dejes que la anterior contamine la siguiente. Al
  final, sintetiza el veredicto.

## Mandato acotado del evaluador

Este texto se pasa literal a cada evaluador, sin cambiarlo:

"Reporta solo hallazgos que cambien la corrección o la decisión, cada uno con
evidencia concreta. 'Sin hallazgos relevantes' es una respuesta válida y
esperada. No rellenes por cumplir."

La razón es concreta: a un revisor al que se le pide "encuentra fallos" los
inventa para justificar su presencia. "Sin hallazgos relevantes" es un
resultado plenamente válido y esperado, no un fracaso del evaluador. Un panel
que siempre encuentra algo no es riguroso, es teatral.

## Veredicto

Antes de opinar, consulta el `DECISIONES.md` del proyecto: si algo ya se
decidió y anotó ahí con sus razones, no lo reabras salvo que haya evidencia
nueva. Reabrir lo cerrado hace perder tiempo a todos.

El Council cierra con uno de tres veredictos exactos:

- `aprobada`: la propuesta procede tal cual.
- `aprobada con cambios`: procede, pero con una lista concreta de ajustes
  —cada uno accionable, no un "podría mejorarse".
- `rechazada`: no procede, con las razones que lo sustentan.

Si el panel no puede decidir, no inventes un veredicto: di qué evidencia
concreta falta para poder decidir.

## Errores típicos

- Council teatral: inventar fallos para parecer riguroso. Si no hay hallazgos,
  el veredicto es "sin hallazgos relevantes" y ya.
- Opciones de paja: rodear la opción favorita de alternativas que nadie
  defendería, para simular que hubo comparación.
- Recomendar sin costos: dar la conclusión sin poner dinero, tiempo y riesgo
  de cada opción encima de la mesa.
- Reabrir decisiones cerradas: discutir de nuevo lo que ya está en
  `DECISIONES.md` sin evidencia nueva que lo justifique.
