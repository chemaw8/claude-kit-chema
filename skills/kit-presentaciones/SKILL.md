---
name: kit-presentaciones
license: MIT
description: Estándar Kit Chema para presentaciones, decks, láminas e informes con audiencia. Úsala siempre antes de crear o editar un deck, pptx, presentación, informe para cliente o material de reunión — antes de escribir la primera lámina. Frases gatillo "hazme una presentación", "un deck para", "láminas sobre", "prepara el informe", "algo para presentarle a". Obliga a definir audiencia, objetivo y narrativa antes que el diseño, y cierra con checklist de cifras y visual.
---

# Presentaciones e informes — estándar Kit Chema

Playbook para armar un deck, un juego de láminas o un informe con audiencia. La
regla que sostiene todo lo demás es primero-la-audiencia: ninguna lámina se
escribe antes de saber para quién es y qué tiene que lograr. El diseño viene al
final, no al principio.

## Bien hecho significa

- La audiencia sabe qué pensar, qué sentir y qué hacer al terminar. Un deck no
  informa por informar: busca una reacción o una decisión concreta, y si al
  cerrar la última lámina esa reacción no es evidente, el trabajo no está hecho.
- Una idea por lámina. Cada lámina defiende un solo punto; si necesita dos, son
  dos láminas. Meter tres ideas en una es la forma más rápida de que no se
  entienda ninguna.
- Toda cifra tiene fuente. Ningún número aparece sin de dónde salió y de cuándo.
  Un dato sin fuente es una afirmación que no puedes defender si te preguntan.
- El visual tiene identidad. Colores, tipografía y logos siguen la marca:
  consulta `~/.claude/contexto/CONTEXTO-EMPRESA.md` para tono y audiencias, y los
  recursos de marca (p. ej. `~/Trabajo/recursos/marca`) para logos y paleta. Un
  deck que parece plantilla genérica resta credibilidad al mensaje.
- El deck se sostiene sin narrador. Alguien que lo abra sin ti debe entender la
  historia solo con leerlo. Si depende de que tú lo expliques en vivo, se cae en
  cuanto lo reenvían.

## Proceso

Este es el orden. Los dos primeros pasos son los que más se saltan y los que
deciden si el resto sirve.

1. Audiencia y objetivo. Antes de nada, define para quién es y qué decisión o
   reacción buscas provocar (aprobar un presupuesto, adoptar una herramienta,
   entender un riesgo). Escríbelo en una frase. Sin esto no se escribe ni una
   lámina: no sabrías qué dejar dentro ni qué cortar.
2. Narrativa en tres actos. Ordena el mensaje como situación → complicación →
   resolución antes de pensar en láminas concretas. Es lo que convierte un
   montón de datos en una historia que la audiencia sigue. El desarrollo de la
   estructura y un esqueleto de ejemplo están en `references/estructura-narrativa.md`.
3. Esqueleto de láminas. Baja la narrativa a una lista de títulos, uno por
   lámina. Los títulos tienen que contar la historia solos: leídos en fila, sin
   el contenido, deben transmitir el argumento completo. Aquí aún no hay diseño
   ni relleno, solo la secuencia de ideas.
4. Contenido. Rellena cada lámina con lo mínimo que defiende su título: el dato,
   el gráfico o la frase que lo sostiene. Cada cifra entra con su fuente desde el
   primer momento, no "después la busco".
5. Diseño. Recién ahora aplicas identidad visual: marca, jerarquía tipográfica,
   contraste, espacios. El diseño viste una historia que ya está armada; no la
   inventa.
6. Ensayo de flujo. Al terminar, lee el deck de corrido usando solo los títulos.
   Si la historia se entiende y lleva al objetivo, el esqueleto aguanta; si se
   traba o salta, el problema es de narrativa y se arregla antes de pulir nada.

## Checklist final

Antes de dar por terminado, con el archivo abierto delante:

- ¿Los títulos, leídos solos y en orden, cuentan la historia completa?
- ¿Cada cifra está verificada y con su fuente visible?
- ¿Cada lámina defiende una sola idea?
- ¿El contraste y la tipografía se leen bien, también proyectados o en pantalla
  pequeña?
- ¿La marca está aplicada (colores, tipografía, logos) según los recursos de la
  empresa?
- ¿Abriste el archivo generado y lo revisaste lámina por lámina, no solo la
  primera?
- Si el encargo produce varios documentos para la misma decisión (deck + resumen
  + correo, deck + one-pager), ¿las cifras clave coinciden entre todos, no solo
  cada una con su fuente?

## Errores típicos

- Empezar por el diseño. Elegir plantilla y colores antes de saber qué se quiere
  decir y a quién: se pierde el tiempo maquillando una historia que aún no
  existe.
- Láminas-párrafo. Volcar bloques de texto que nadie lee en una reunión. Si una
  lámina es un documento, no es una lámina.
- Datos sin fuente. Poner números sueltos que no puedes respaldar si alguien
  pregunta de dónde salieron.
- "Algo bonito" sin audiencia definida. Aceptar el encargo de un deck sin saber
  para quién es ni qué debe lograr: es imposible hacerlo bien porque no hay
  criterio de qué es "bien".
