# Acta del council — v1.19.3 (2026-09-08)

**Propuesta.** Añadir evidencia citada del paper de Prime Agent (arXiv 2608.23552) a
`GOBERNANZA.md` (§ Mejora del kit por corrección) y a `skills/kit-orquestacion/SKILL.md`
(§ Cuánto repartir). Cambio de documentación y cuerpo de skill; núcleo intacto.

**Postura inicial del hilo, fijada antes de leer ningún reporte.** *"El cambio es correcto
y proporcionado: añade evidencia citada a dos documentos, no toca el núcleo, no cambia
ninguna regla y es trivialmente reversible; el único riesgo real es la exactitud de la cita
y sobre-generalizar un dato de un solo paper."*

**Panel.** 3 evaluadores independientes (Opus 5), ciegos entre sí, con el mandato acotado de
`kit-propuestas`. Síntesis por el agente `sintetizador` (Fable 5.1).

**Veredicto: aprobada con cambios.** Todos aplicados antes de abrir el PR.

## Recuento de hallazgos

Sobre el borrador original, **9 hallazgos** (3 lentes):

| Lente | # | Hallazgo |
|---|---|---|
| Exactitud factual | 1 | El superlativo "la corrida más larga publicada" no está en el paper |
| Exactitud factual | 2 | "medida" atribuye al paper una conclusión que no saca: registra, no compara ancho contra profundo |
| Exactitud factual | 3 | `/refine` aplica en frontera de turno, no "al terminar una trayectoria"; y el paper (§2.5) dice que Prime Agent ya versiona con provenance y permite rollback |
| Exactitud factual | 4 | La cita recortaba "In this trace," sin marca de elisión |
| Encaje | 5 | El párrafo nuevo contradecía el consejo tres líneas arriba: "agrupa varias por agente" vs "muchas oleadas de pocos agentes", sin criterio para elegir |
| Encaje | 6 | La heurística de "profundidad tres" era arbitraria sobre un dato de profundidad uno |
| Encaje | 7 | El mapeo "punto por punto" citaba dos mecanismos equivocados (rollback → PR borrador + CHANGELOG; mínimo privilegio → "no se auto-aplica") |
| Abogado del diablo | 8 | **El "punto por punto" era autocomplacencia**: el council es un panel del mismo modelo juzgando lo que escribió el mismo modelo, `main` va con "Aprobaciones requeridas: 0", y de mínimo privilegio no hay nada |
| Abogado del diablo | 9 | La skill atribuía a los autores lo contrario de lo que escriben: su abstract vende "Recursive subagents" |

Un hallazgo blando adicional (no bloqueante): los siete concurrentes pudieron ser un tope
configurado y no un óptimo; se atendió igual.

Tras aplicar esas correcciones, el **sintetizador encontró 5 problemas nuevos que las
correcciones mismas introdujeron**: aritmética rota ("dos de tres" contra sí/a medias/no),
atribuir el fallo solo a la validación independiente cuando el RCON también es fallo de
mínimo privilegio, una glosa en español dentro de una cita en inglés, un bullet de Diferido
que hablaba de "tres pendientes" cuando la sección declara dos huecos, y la contradicción de
la skill cerrada por un solo lado.

**Total de la ronda: 9 sobre el borrador + 5 sobre las correcciones = 14 arreglos.**

## Lo que el council descartó explícitamente

- **Sesgo de confirmación**: la nota de cosecha **rechaza** el harness y caza que sus propias
  re-corridas quedan por debajo de los números publicados. Cosechar evidencia de una fuente
  que rechazaste es lo contrario del sesgo.
- **Analogía forzada**: `/refine` escribe en skills y memorias — el mismo objeto que la regla
  "corrección → regla del kit". El mecanismo transfiere; Factorio es el escenario, no el
  argumento.
- **Costo por sesión**: `GOBERNANZA.md` no se autocarga; el tope de 150 líneas es del núcleo.
- **Envejecimiento de la cita**: la convención "cosecha del \<fecha\>" ya existe en el documento.

## Qué cambió respecto a la postura inicial

Dos cosas, y ambas al alza:

1. **El riesgo dominante no era la exactitud de la cita** —que estaba bien salvo detalles—
   sino la autocomplacencia del mapeo "punto por punto", que presentaba como resuelto el
   eslabón más débil del kit. Lo aportó el abogado del diablo y no estaba en la lectura inicial.
2. **El cambio ya no es "solo evidencia citada que no cambia ninguna regla"**: incluye una
   autoevaluación de gobernanza con dos huecos declarados y un pendiente nuevo en Diferido.

## Nota sobre el propio panel

El documento que sale de esta ronda advierte que un council de instancias del mismo modelo es
**correlacionado, no independiente**. La advertencia es correcta y se queda. Pero esta corrida
es a la vez su contraejemplo parcial: tres lentes del mismo modelo cazaron 9 fallas del
redactor, y la síntesis cazó 5 más. El panel no sustituye la validación humana; sí filtra.
