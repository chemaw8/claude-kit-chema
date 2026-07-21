---
name: kit-propuestas
license: MIT
description: 'Estándar Kit Chema para redactar o evaluar propuestas y decisiones — propuestas de desarrollo, de inversión, de arquitectura, cotizaciones, o cualquier "¿hacemos X o Y?"; también todo mensaje o correo que pide aprobar, autorizar o decidir algo (aunque vaya a dirección). Úsala al escribir una propuesta, al evaluar una idea del usuario con consecuencias reales, al pedir aprobación de algo, y siempre que se pida "council". Frases gatillo "hazme la propuesta", "¿te parece bien esta idea?", "evalúa esta decisión", "que aprueben/autoricen X", "council". Incluye el protocolo Council: panel de evaluadores independientes con veredicto aprobada / con cambios / rechazada.'
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

## Acercamiento personalizado a un contacto

Aplica cuando el usuario quiere acercarse a una persona concreta de otra
empresa —para una presentación, una propuesta o cerrar una venta— y busca
subir el % de aceptación personalizando el mensaje o el material para esa
persona específica. El orden importa: primero se confirma quién es el
contacto, después se investiga, y al final se produce el entregable.

1. Identifica y confirma al contacto antes de personalizar cualquier cosa.
   Con el nombre, la empresa y el puesto que dé el usuario, busca por web
   (no hay API de LinkedIn para buscar terceros: el scope self-serve solo
   da acceso al perfil propio y a publicar/reaccionar/comentar). Si aparece
   más de una persona plausible —dos con el mismo puesto, nombres
   parecidos, empresas con el mismo nombre en países distintos—, preséntale
   las opciones al usuario con lo que las distingue y que él confirme cuál
   es antes de seguir. Personalizar sobre el contacto equivocado es peor
   que no personalizar: nunca avances con una identidad sin confirmar.
2. Investiga al contacto y a su empresa ya confirmados: rol y prioridades
   del puesto, movimientos o noticias recientes de la empresa, cualquier
   señal pública que conecte con lo que se le quiere ofrecer. Usa solo lo
   verificable; no rellenes con supuestos sobre la persona para que suene
   más personalizado.
3. Pregunta el formato de salida si no es obvio por la conversación —
   mensaje corto de acercamiento, propuesta completa o presentación— y
   aplica el kit que corresponda (`kit-redaccion`, esta misma skill o
   `kit-presentaciones`). La personalización es una capa sobre esa
   estructura, no la reemplaza: un mensaje de acercamiento sigue siendo
   breve y accionable, una propuesta sigue llevando sus cinco piezas.
4. Personaliza con evidencia concreta de la investigación, conectada al
   problema u opción real que ya trae el entregable — no con halagos
   genéricos que aplicarían a cualquier destinatario.
5. Antes de enviar o publicar cualquier cosa a nombre del usuario (mensaje,
   correo, comentario en LinkedIn), confirma con él el contenido final: es
   una acción que sale de la empresa y llega a un tercero real.

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
- abogado del diablo: el mejor argumento en contra de la recomendación, o, si
  no hay uno sólido, decirlo.
- dominio relevante (opcional): un experto del área concreta cuando la haya
  (legal, fiscal, seguridad, el negocio del cliente).

A cada evaluador se le entrega la propuesta y el mandato acotado de la sección
siguiente. Antes de lanzar a los evaluadores, el hilo principal fija en una
frase su postura inicial sobre la propuesta, sin haber leído ningún reporte; al
sintetizar el veredicto dice explícitamente si los evaluadores le hicieron
cambiar de opinión y en qué (que lo diga confirma que el council aportó y no fue
teatral). La mecánica cambia según dónde corras:

- En Claude Code: lanza los evaluadores como subagentes en paralelo, con modelo
  Opus 4.8 cada uno. El hilo principal recoge sus reportes y sintetiza un solo
  veredicto con el modelo principal de la sesión (Fable 5).
- En claude.ai (web): no hay subagentes, así que evalúa secuencialmente en la
  misma conversación, tomando un lente a la vez y marcando cada sección con su
  nombre ("Viabilidad técnica:", "Riesgos:", ...). Trata cada lente como una
  pasada independiente: no dejes que la anterior contamine la siguiente. Al
  final, sintetiza el veredicto.

## Mandato acotado del evaluador

Este texto se pasa literal a cada evaluador, sin cambiarlo:

"Reporta solo hallazgos que cambien la corrección o la decisión, cada uno con
evidencia concreta. Pondera cada hallazgo contra el tamaño, costo y
reversibilidad de la propuesta: una mejora deseable no es una condición, y
exigir controles de nivel corporativo a una solución pequeña es
sobre-ingeniería, no rigor. 'Sin hallazgos relevantes' es una respuesta válida
y esperada. No rellenes por cumplir."

La razón es concreta: a un revisor al que se le pide "encuentra fallos" los
inventa para justificar su presencia. "Sin hallazgos relevantes" es un
resultado plenamente válido y esperado, no un fracaso del evaluador. A cada
evaluador se le entrega solo la propuesta y su mandato, nunca el hilo completo
de la conversación: pasar el historial contamina el juicio independiente y anula
el anti-anclaje. Un panel que siempre encuentra algo no es riguroso, es
teatral. La proporcionalidad es la misma disciplina aplicada a la escala: un
hallazgo real sobre una propuesta pequeña no justifica exigirle el estándar de
una infraestructura crítica.

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

Al sintetizar, verifica los hallazgos antes de heredarlos al veredicto: un
hallazgo que no resista una verificación rápida (dato erróneo, fuera de alcance,
ya resuelto) se descarta explicando por qué. Que venga de un evaluador no lo
hace verdad por sí solo.

## Errores típicos

- Council teatral: inventar fallos para parecer riguroso. Si no hay hallazgos,
  el veredicto es "sin hallazgos relevantes" y ya.
- Opciones de paja: rodear la opción favorita de alternativas que nadie
  defendería, para simular que hubo comparación.
- Recomendar sin costos: dar la conclusión sin poner dinero, tiempo y riesgo
  de cada opción encima de la mesa.
- Reabrir decisiones cerradas: discutir de nuevo lo que ya está en
  `DECISIONES.md` sin evidencia nueva que lo justifique.
- Personalizar sin confirmar identidad: avanzar con un contacto ambiguo (dos
  personas con el mismo puesto) sin que el usuario haya confirmado cuál es.
- Personalización de relleno: usar datos no verificados o halagos genéricos
  que aplicarían a cualquier destinatario, en vez de evidencia concreta.
