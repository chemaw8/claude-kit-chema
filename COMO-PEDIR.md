# Cómo pedirle bien a Claude

Esta guía es para las personas, no para Claude. El kit ya trae instrucciones de
calidad del lado de Claude; aquí aprendes el otro lado: cómo escribir una
petición para que el resultado salga bien a la primera y no después de tres
correcciones. No necesitas saber de tecnología. Solo necesitas ser claro sobre
qué quieres, para quién y cómo sabrás que quedó bien.

## 1. La anatomía de una buena petición

Una petición floja obliga a Claude a adivinar, y cuando adivina, casi siempre
adivina genérico. Una buena petición responde por adelantado las preguntas que
si no tendría que hacerte. Son seis piezas; las cinco primeras casi nunca
sobran, la sexta cuando aplica:

- **Objetivo**: qué quieres lograr, no solo qué quieres que haga. "Que aprueben
  el presupuesto", no "una presentación".
- **Contexto**: de dónde sale esto, qué pasó antes, qué archivos hay detrás.
- **Audiencia**: para quién es. No es lo mismo el comité de dirección que un
  cliente técnico o tu propio equipo.
- **Formato**: cómo lo quieres entregado. Número de láminas, tabla o texto,
  correo o documento, con marca Innovattia o sin ella.
- **Criterio de éxito**: cómo sabrás que quedó bien. Es la pieza que más se
  olvida y la que más ahorra correcciones.
- **Fecha límite** (cuando la haya): para qué día lo necesitas.

Un mismo pedido, floja y bien planteado, lado a lado:

| Petición floja | Petición buena |
|---|---|
| "Hazme una presentación bonita sobre IA." | "Necesito un deck para el comité de dirección de Ordenaris (no son técnicos) cuyo objetivo es que aprueben invertir en un piloto de IA. Contexto: adjunto el informe de hallazgos. Formato: 12 láminas con marca Innovattia. Está bien si al final entienden el retorno esperado y los riesgos. Fecha: viernes 2026-07-18." |

La de la izquierda produce algo bonito y vacío que tendrás que rehacer. La de la
derecha produce algo que puedes llevar a la reunión.

## 2. Qué adjuntar

Claude trabaja mucho mejor con material real que con descripciones de memoria.
Antes de mandar tu petición, revisa si puedes sumar tres cosas:

- **Los archivos fuente**: el Excel de ventas, el PDF del cliente, el informe
  previo, la carpeta del proyecto. Si el dato existe, adjúntalo en vez de
  resumirlo; el resumen pierde detalle y Claude no puede verificar contra algo
  que no tiene.
- **Un ejemplo de algo que te gustó**: un deck anterior, un correo con el tono
  correcto, una tabla con el formato que buscas. "Que se parezca a esto" ahorra
  más que mil adjetivos.
- **El "no quiero que…"**: lo que quieres evitar. "No quiero que suene a
  vendedor", "no inventes cifras", "no uses gráficas de pastel". Marcar el
  límite por adelantado es más barato que corregirlo después.

## 3. Palabras clave del kit

Tres palabras cambian el protocolo de Claude (las define el núcleo); dos más
son convenciones útiles para marcar en qué punto del trabajo estás:

| Palabra | Qué hace |
|---|---|
| `council` | Fuerza el panel de evaluación: varios evaluadores independientes juzgan el trabajo y dan un veredicto (aprobada / aprobada con cambios / rechazada). Úsala en decisiones caras o irreversibles y en material que sale de la empresa. |
| `rápido` | Salta ese panel, bajo tu responsabilidad, cuando la decisión no lo amerita y prefieres velocidad. |
| `hazlo directo` | Salta la evaluación crítica: Claude ejecuta tu idea sin decirte antes qué le preocupa. Úsala solo cuando ya lo pensaste y no quieres que lo cuestione. |
| `borrador` | Pide velocidad sobre pulido: un primer intento para reaccionar, sin acabado final. |
| `final` | Exige el checklist completo del playbook (la guía de calidad) del dominio: la versión revisada y lista para entregar. |

Las tres primeras están definidas en el núcleo del kit y funcionan en cualquier
conversación. `borrador` y `final` marcan en qué punto del trabajo estás: pide
`borrador` para iterar barato y `final` cuando ya vas a mandarlo.

## 4. Frases que mejoran el resultado

Hay frases de aliento que empujan a Claude a esforzarse más, y funcionan mejor
dichas por ti en la petición que escritas en las instrucciones del kit. No son
magia; son permiso explícito para tomarse el trabajo en serio. Úsalas cuando la
tarea lo merezca:

- "Tómate tu tiempo y hazlo a fondo."
- "La calidad importa más que la velocidad."
- "No saltes pasos de verificación."
- "Dime qué te preocupa de mi idea antes de hacerla."

La última es especialmente útil: invita a Claude a señalar el problema antes de
gastar horas construyendo sobre una base floja.

## 5. Plantillas por dominio

Copia la plantilla del tipo de trabajo que necesitas y rellena los [huecos]. No
tienes que usar todos; cuantos más completes, mejor sale.

**Presentaciones**
> Necesito un deck para [audiencia] cuyo objetivo es que [decisión/reacción].
> Contexto: [adjunto/carpeta]. Formato: [n láminas, marca Innovattia].
> Está bien si [criterio de éxito]. Fecha: [límite].

**Análisis de datos**
> Analiza [archivo/datos] para responder [pregunta de negocio].
> Contexto: [de dónde salen los datos, qué periodo cubren].
> Formato: [hallazgos con evidencia / dashboard / gráfica].
> Está bien si [criterio, p. ej. sé qué hacer distinto]. Fecha: [límite].

**Research**
> Investiga [tema/pregunta] para decidir [para qué la usarás].
> Contexto: [qué ya sé, qué fuentes prefiero o descarto].
> Formato: [comparativa / resumen con fuentes citadas].
> Está bien si [criterio, p. ej. cada afirmación clave con fuente y fecha]. Fecha: [límite].

**Código**
> Necesito [script/función/arreglo] que [qué debe hacer].
> Contexto: [proyecto, lenguaje, dónde vive el código].
> Formato: [entregable: script corriendo / PR (propuesta de cambios lista para revisión) / explicación].
> Está bien si [criterio, p. ej. pasa estos casos]. Fecha: [límite].

**Propuestas**
> Prepara una propuesta de [qué] para [quién decide].
> Contexto: [situación, restricciones, presupuesto].
> Formato: [documento / correo / council con veredicto].
> Está bien si [criterio, p. ej. queda claro por qué esta opción]. Fecha: [límite].

**Finanzas**
> Necesito [cotización/presupuesto/proyección] de [qué] para [para qué].
> Contexto: [cifras base, periodo, supuestos que ya conozco].
> Formato: [tabla con escenarios / resumen ejecutivo].
> Está bien si [criterio, p. ej. veo el margen y los supuestos]. Fecha: [límite].

**Automatización**
> Automatiza [proceso] para que [resultado que corre solo].
> Contexto: [disparador, qué entra, qué sale, cada cuánto].
> Formato: [script programado / integración / bot].
> Está bien si [criterio, p. ej. corre sin que yo intervenga]. Fecha: [límite].

## 6. Errores comunes

- **Pedir "algo bonito" sin decir para quién.** Sin audiencia, Claude produce
  algo genérico que no le habla a nadie. Di siempre quién lo va a leer o a ver.
- **No dar criterio de éxito.** Si no dices cómo sabrás que quedó bien, Claude
  tampoco lo sabe, y entregará algo plausible en vez de algo correcto. Una línea
  de "está bien si…" te ahorra rondas de correcciones.
- **Corregir el resultado a mano sin decirle la regla.** Si arreglas lo mismo
  cada vez (el tono, un formato, una cifra que siempre calcula mal), no lo
  arregles en silencio: dile la regla. El kit aprende — cuando corriges dos
  veces lo mismo, esa corrección se puede volver regla permanente y dejas de
  pelear con ella para siempre.

## 7. Cómo llenar tu contexto

Los archivos de `~/.claude/contexto/` (empresa y, opcional, personal) son lo que
Claude lee antes de cada trabajo. Bien llenados ahorran repetir lo mismo en cada
petición; mal llenados solo estorban.

**Regla de oro para cada línea:** "¿si quito esta línea, Claude cometería un
error?". Si la respuesta es no, sóbrala. Un campo vacío es mejor que relleno
vacuo: el relleno de adorno diluye lo que sí importa y hace que Claude lo pase
por alto.

**Los tres campos que más rinden** (si solo llenas tres, que sean estos):

- **Audiencias, con su nivel técnico.** No "clientes", sino "dirección del grupo
  (no técnica, decide por retorno)" o "equipo de sistemas (técnico, quiere el
  detalle)". Es lo que evita que Claude escriba genérico.
- **Tono, con un ejemplo así-sí / así-no.** Un adjetivo como "formal" o
  "cercano" lo interpreta cada quien distinto. Una frase de muestra de cómo sí y
  cómo no quieres que suene vale más que cinco adjetivos.
- **Glosario, solo de términos internos.** Las siglas, nombres de sistemas o
  productos que Claude no puede adivinar. No metas palabras del diccionario.

**Qué NO incluir:**

- Datos confidenciales reales (nombres de clientes, cifras de negocio,
  credenciales). El contexto puede terminar en ejemplos, commits o servicios
  externos; deja ahí solo la *regla* ("nunca menciones clientes por nombre"), no
  el dato.
- Narrativa institucional (misión, visión, historia de la empresa). No cambia
  cómo se hace el trabajo, así que solo ocupa espacio.
