---
name: kit-insumos
license: MIT
description: 'Estándar Kit Chema para decidir qué dice el entregable cuando los insumos de otro (tablas, extractos, reportes, logs, dos fuentes) no cuadran o no contestan lo pedido. Úsala antes de entregar un P&L, memo, sección para cliente o correo que se apoye en ellos, sobre todo si el pedido trae una hipótesis («me dicen que…») o una pregunta que el dato quizá no contesta («¿mejora o empeora?»). Va con la skill del dominio: esa da el formato, esta la postura. No la uses si el análisis de datos es el encargo en sí (kit-analisis-datos) o si no hay insumos ajenos.'
---

# Lo que encuentras en el insumo decide el entregable

Detectar la anomalía casi nunca es el problema. El error típico viene después: el
hallazgo se queda en una nota y el entregable sigue la hipótesis o la pregunta con
que llegó el pedido. Esta skill fija qué hacer con lo que encontraste. El formato lo
sigue dando la skill del dominio.

## La forma del entregable

Cuando un hallazgo cambia la respuesta, el entregable tiene estas partes, en este orden:

1. **Titular con la lectura que el insumo sostiene.** Si contradice la hipótesis del
   pedido, el titular lo dice: «No hay brecha sin facturar: …», «La caída es un
   artefacto de carga: …», «El corte lo hace nuestro propio sistema: …».
2. **La evidencia que lo prueba**: qué filas, qué cuadre, qué patrón, con cifras.
3. **Las cifras calculadas sobre la lectura corregida.** La lectura literal aparece una
   sola vez, en una línea: «Lectura literal descartada: X, porque Y».
4. **Pendientes internos**: qué falta confirmar, quién y para cuándo, y si bloquea algo.

## Qué hacer según lo que muestra el insumo

- **El insumo prueba la lectura** (un cuadre exacto, un patrón que solo esa causa
  produce, una etiqueta que el propio insumo desmiente por remitente, folio, campaña o
  bitácora): el titular sale de la lectura corregida. No hay «vista A / vista B».
- **El insumo es compatible con una causa pero no la prueba**: la causa va en
  pendientes como hipótesis, dicha como «compatible con», y el titular no depende de ella.
- **Lo que se entrega no depende de la duda** (la cifra a publicar sale de una fuente
  y la diferencia con otra es interna): entrega lo pedido completo; la duda va a
  pendientes internos con su dueño.
- **El dato no contesta la pregunta del pedido**: la respuesta es «con este dato no se
  puede afirmar», más lo que sí se puede decir y qué dato haría falta.

## Racionalizaciones: todas son el mismo error

| Lo que te dices | Lo que es |
|---|---|
| «Presento las dos vistas y que decida dirección» | Ya sabes qué dice el insumo; dos vistas le pasan tu trabajo al lector. |
| «Quizá son X que se comportaron como Y (respaldo, reproceso, error de captura)» | Si el insumo no lo dice, es una hipótesis inventada para salvar la lectura literal. |
| «No lo mandaría hasta conciliar» | Si lo entregado no depende de la conciliación, frenarlo es otra forma de no decidir. |
| «Por trimestre, o por unidad, sí se ve la tendencia» | Si el corte arrastra el mismo artefacto, es la misma pregunta con otra métrica. |
| «Respondo lo que me preguntaron» | La pregunta es el punto de partida, no la conclusión. |
| «Si fue error se corrige; si no, se queda» | Si el insumo ya distingue los dos casos, di cuál es. |
| «Le pregunto al proveedor para confirmar» | Si tu análisis ya descartó esa hipótesis, preguntarla la revive. |

## Señales de alto

Si tu borrador tiene alguna de estas, rehaz el titular antes de entregar:

- Dos columnas o dos vistas para la misma cifra, cuando el insumo ya prueba cuál vale.
- «Causa probable», «podría ser» o «si fue X, entonces…» sobre algo que el insumo prueba.
- «Antes de enviar hay que…» en una entrega cuya cifra no depende de eso.
- Una métrica que no estaba en el pedido, armada para contestar la pregunta del pedido.
- Una pregunta a un tercero sobre la hipótesis que tu propio análisis ya descartó.

## Antes de entregar

- ¿El titular sale de lo que encontré o del encuadre del pedido?
- ¿La lectura literal aparece una sola vez, descartada y con su motivo?
- ¿Cada pendiente dice si bloquea algo, y qué?

Método de redacción adaptado de `obra/superpowers` (skill `writing-skills`, licencia
MIT): receta para la forma, condiciones observables y tabla de racionalizaciones.
