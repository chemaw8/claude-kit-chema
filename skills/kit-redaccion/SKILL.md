---
name: kit-redaccion
license: MIT
description: 'Estándar Kit Chema para la comunicación escrita del día a día — correos, minutas y actas de reunión, notas y memos internos, documentación y comunicados internos, y mensajes de avance que solo informan. Úsala al pedir "escribe un correo", "haz la minuta" o "el acta", "redáctame la nota" o "el memo", "documenta X", "un comunicado interno", "un mensaje de avance o estatus que solo avise". Obliga a un pedido claro y accionable en el correo, a separar acuerdos de discusión con responsables y fechas en la minuta, a una idea principal arriba en notas y memos, y a poner conclusión y números primero en el estatus. Cuándo no usarla — si el mensaje pide aprobar, autorizar o decidir algo (aunque vaya a dirección) → kit-propuestas; material con láminas o identidad visual → kit-presentaciones.'
---

# Comunicación escrita — estándar Kit Chema

Playbook para lo que se escribe todos los días: correos, minutas, notas, memos,
documentación y mensajes de estatus. Dos disciplinas ya viven fuera de esta
skill y no se repiten aquí: definir audiencia y objetivo antes de escribir, y
abrir con la conclusión (pirámide invertida) — están en kit-presentaciones y en
`~/.claude/contexto/`. Esta skill cubre lo que Claude hace mal por defecto en
formatos cortos: se enreda, entierra el pedido y no deja claro quién hace qué.

La regla transversal es cortar relleno: cada oración que no cambia lo que el
lector entiende o hace, sobra. Menos texto que se lee entero vence a más texto
que se hojea.

## Bien hecho significa

- **Correo**: el pedido es claro y accionable —qué necesitas, de quién y para
  cuándo— y no está enterrado en el tercer párrafo. El asunto dice de qué va y
  qué se espera, no "seguimiento". Si el lector tiene que releer para saber qué
  debe hacer, el correo falló.
- **Minuta o acta**: separa lo que se decidió de lo que se discutió. Cada
  acuerdo lleva su responsable y su fecha; cada pendiente, quién lo tiene. Una
  minuta sin responsables ni fechas es un resumen de conversación, no un acta.
- **Nota, memo o comunicado interno**: una sola idea principal arriba, el
  contexto mínimo para entenderla y el siguiente paso al cierre. Si abre con
  tres párrafos de antecedentes antes del punto, está al revés. La documentación
  sigue la misma regla: lo mínimo para que alguien que no estuvo entienda, y nada
  más.
- **Estatus a dirección**: la conclusión y los números primero; el detalle
  después y solo si aporta. Los números van concretos, no en adjetivos ("mejoró
  mucho" → "bajó de 60 a 15 horas al mes"). Informa, no pide aprobar. En cuanto el mensaje
  propone opciones con sus costos y espera un sí o un no, dejó de ser estatus y
  es una propuesta (kit-propuestas).

## Proceso

1. Una frase de propósito. Antes de escribir, di para quién es y qué debe pasar
   al leerlo (que actúen, que se enteren, que quede registro). Si no lo puedes
   decir en una frase, aún no sabes qué escribir. El desarrollo de audiencia y
   objetivo está en kit-presentaciones; aquí basta la frase.
2. La conclusión o el pedido primero. Pon arriba lo que el lector necesita saber
   o hacer. El contexto va después, y solo el que hace falta.
3. Estructura según el formato. Correo: asunto útil, pedido, contexto mínimo.
   Minuta: acuerdos, responsables y fechas, pendientes; con la decisión separada
   de la discusión. Memo o nota: idea principal, contexto, siguiente paso.
   Estatus: conclusión y números arriba; luego avances, próximos pasos y riesgos
   o bloqueos.
4. Corta. Relee y quita relleno: saludos de más, "espero que este correo te
   encuentre bien", adjetivos vacíos, repeticiones. Cada palabra defiende su
   lugar.

## Checklist final

Antes de enviar, con el texto delante:

- ¿La primera línea (o el asunto) ya dice de qué va y qué se espera?
- Correo: ¿queda claro qué se pide, a quién y para cuándo?
- Minuta: ¿cada acuerdo tiene responsable y fecha, y los pendientes tienen dueño?
- ¿Sobra algo? ¿Qué párrafo puedo borrar sin perder información?
- Estatus a dirección: ¿informa sin pedir aprobar? Si pide aprobar, es
  kit-propuestas.
- ¿Nombres de clientes y cifras reales tratados según la confidencialidad del
  contexto?
- ¿El estado del mensaje está declarado con lenguaje preciso ("borrador listo
  para tu revisión" vs "enviado")? Nunca afirmes que un correo se envió si no se
  envió.

## Errores típicos

- Enterrar el pedido. Tres párrafos de contexto y el "¿me lo mandas hoy?" al
  final: nadie llega. El pedido va arriba.
- Minuta sin dueños ni fechas. Registrar lo que se dijo pero no quién hace qué ni
  para cuándo: no sirve para dar seguimiento.
- Relleno de cortesía. Fórmulas huecas y rodeos que alargan sin agregar. Directo
  y profesional no es descortés.
- Estatus que pide aprobación disfrazado. Un "estatus" que en realidad propone
  opciones y espera decisión es una propuesta: usa kit-propuestas y su estructura
  de costos.
- Invadir el terreno vecino. Meter láminas, identidad visual o narrativa de deck
  en algo que era un correo (eso es kit-presentaciones), o convertir una nota en
  una propuesta con council cuando solo había que informar. Cada formato en su
  skill.
