---
name: kit-mercadotecnia
license: MIT
description: Estándar Kit Chema para mercadotecnia e investigación de mercado — evaluar una oportunidad comercial, dimensionar un mercado y su demanda, segmentar y posicionar, decidir producto/precio/canal/comunicación, o diseñar un estudio de mercado. Úsala al pedir "investigación de mercado", "dimensiona este mercado", "cómo segmento", "qué estudio necesito", "evalúa esta oportunidad de negocio", "sugerencias de marketing para". Basada en Kotler & Armstrong (18.ª ed.) y las fuentes de FUENTES.md; agnóstica de empresa — el contexto del cliente entra por la conversación y nunca se guarda dentro de la skill.
---

# Mercadotecnia — sugerencias con marco y con fuente (Kit Chema)

Playbook para convertir una pregunta de negocio en sugerencias de mercadotecnia
e investigación de mercado con respaldo teórico. La regla que sostiene todo:
ninguna sugerencia sale sin decir qué decisión alimenta, qué marco la respalda
y qué dato haría falta para confirmarla. Opinión sin marco es corazonada;
marco sin dato es teoría — el entregable une los dos.

## Bien hecho significa

- Cada sugerencia dice qué decisión alimenta, en qué marco se apoya (con su
  módulo de `references/`) y qué investigación la confirmaría o tumbaría.
- Los marcos se citan con su fuente original (ver `FUENTES.md`), no "según
  la teoría". Si el usuario quiere profundizar, puede llegar al libro exacto.
- El contexto de la empresa consultada vive en la conversación o en la carpeta
  del proyecto — jamás dentro de esta skill (ver Anti-contaminación).
- Los números se recalculan, nunca se aceptan de memoria: dimensionamientos y
  proyecciones pasan por kit-finanzas; la búsqueda y verificación de fuentes
  externas pasa por kit-research.
- Las sugerencias van priorizadas: qué estudio o decisión va primero según el
  costo de obtener la información y qué desbloquea.

## Proceso

1. **Encuadra la decisión.** Antes de sugerir nada, escribe qué decide el
   negocio con esto (¿entrar o no?, ¿a qué precio?, ¿a quién?, ¿por qué canal?),
   quién decide y con qué horizonte. Sin decisión clara, cualquier estudio es
   dato suelto.
2. **Ubica la pregunta en el mapa de módulos** (tabla abajo) y lee SOLO los
   módulos relevantes de `references/`. No cargues los 11 para una pregunta
   de precios.
3. **Arma el diagnóstico con los marcos.** Aplica los marcos del módulo al
   contexto que dio el usuario; declara explícitamente los supuestos que
   estás haciendo por falta de dato.
4. **Diseña la investigación** con el módulo 04 como columna vertebral: para
   cada vacío de información — objetivo del estudio, tipo (exploratoria /
   descriptiva / causal), fuente (secundaria primero, primaria si hace falta),
   método (observación, encuesta, entrevista, experimento), muestreo y
   entregable esperado.
5. **Prioriza y entrega.** Ordena las sugerencias por valor de la información
   contra costo de obtenerla. Abre con la recomendación y las 2-3 sugerencias
   que más pesan; el detalle va después. Marca qué quedó sin confirmar.

## Mapa de módulos

| Si la pregunta es… | Lee |
|---|---|
| ¿Qué es valioso para el cliente, cómo se crea y captura valor? | `references/01-proceso-y-fundamentos.md` |
| ¿Cómo planeo la estrategia, el portafolio o el plan de marketing? ¿Cómo mido el ROI? | `references/02-estrategia-y-plan.md` |
| ¿Qué fuerzas del entorno o tendencias afectan el negocio? | `references/03-entorno-y-tendencias.md` |
| ¿Entro a otro país? ¿Estandarizo o adapto mi oferta? | `references/03-entorno-y-tendencias.md` (marco 9) |
| ¿Qué estudio de mercado necesito y cómo lo diseño? (núcleo de la skill) | `references/04-investigacion-de-mercados.md` |
| ¿Por qué compra (o no) el consumidor? ¿Cómo decide? | `references/05-comportamiento-del-consumidor.md` |
| ¿Qué tan grande es el mercado y cuánta demanda puedo esperar? | `references/06-dimensionamiento-de-mercado.md` |
| ¿A quién le vendo y cómo me diferencio? | `references/07-stp-posicionamiento.md` |
| ¿Qué producto/servicio ofrezco, cómo construyo marca, cómo lanzo algo nuevo? | `references/08-producto-marca-innovacion.md` |
| ¿A qué precio? | `references/09-precios.md` |
| ¿Por dónde vendo y con qué fuerza comercial? | `references/10-canales-retail-ventas.md` |
| ¿Cómo comunico: publicidad, promoción, digital, RRPP? | `references/11-comunicacion-integrada.md` |

## Anti-contaminación (regla dura)

Esta skill es agnóstica de empresa y así debe seguir:

- Nombres, cifras y datos de la empresa consultada (o de sus clientes) NUNCA
  se escriben dentro de la skill — ni en módulos, ni en ejemplos, ni en el
  CHANGELOG. Viven en la conversación o en la carpeta del proyecto.
- Los ejemplos de los módulos son genéricos o casos publicados con fuente.
- Si un trabajo con un cliente enseña algo generalizable, se abstrae primero
  (sin rastro del cliente) y entra por el protocolo de mejora continua.
- Aplica siempre la línea roja de datos vigente en el contexto de empresa
  (datos personales, financieros no públicos, credenciales, código propietario).

## Mejora continua

- **Corrección repetida o marco nuevo** → editar el módulo correspondiente y
  registrar en `CHANGELOG.md`: fecha (YYYY-MM-DD), qué cambió, fuente o razón.
- **Fuente nueva** → alta en `FUENTES.md` con autor, año y edición. Sin fuente
  verificable no entra doctrina nueva.
- **Vigencia**: los reportes de tendencias (Euromonitor y similares) caducan
  cada año — al usar el módulo 03, verifica que la edición citada siga siendo
  la más reciente y sugiere actualizarla si no.
- Cambios de fondo o su adopción en el kit oficial (repo claude-kit-chema)
  siguen GOBERNANZA.md: PR en borrador revisado por council, nunca commit
  directo.

## Checklist final

Antes de entregar sugerencias:

- ¿Cada sugerencia dice qué decisión alimenta y qué marco la respalda?
- ¿Declaré los supuestos y los vacíos de información?
- ¿Todo número fue recalculado (no tomado de memoria ni del prompt)?
- ¿Las sugerencias de investigación traen tipo, fuente, método y entregable?
- ¿Quedó la skill limpia — nada del cliente escrito en ella?

## Errores típicos

- **Recomendar el estudio antes de la decisión.** "Hagamos un focus group"
  sin saber qué se decide con él quema presupuesto. Primero la decisión,
  luego el dato que la mueve.
- **Saltarse las fuentes secundarias.** Casi siempre hay dato público (INEGI,
  cámaras, reportes sectoriales) que responde la mitad de la pregunta gratis
  antes de pagar investigación primaria.
- **Dimensionar con un solo número.** Un tamaño de mercado sin desglose
  (potencial → disponible → meta) y sin supuestos declarados no resiste
  preguntas; usa la plantilla del módulo 06.
- **Confundir el marco con la respuesta.** Llenar un FODA o un STP no es
  concluir; el entregable es la implicación accionable, no la matriz llena.
- **Contaminar la skill.** Meter el caso del cliente de hoy "para acordarse"
  la vuelve inservible para el cliente de mañana. El contexto vive fuera.
