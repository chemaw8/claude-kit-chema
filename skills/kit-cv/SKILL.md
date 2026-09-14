---
name: kit-cv
license: MIT
description: 'Estándar Kit Chema para currículums y materiales de candidatura — CV personalizado por vacante, carta de presentación pareada y perfil de LinkedIn derivado del mismo banco de logros. Úsala al pedir "hazme mi CV", "actualiza mi currículum", "adapta el CV a esta vacante", "escríbeme una carta de presentación", "mejora mi LinkedIn", o al revisar el CV de un candidato. El flujo es fijo: primero entender el puesto al que va la persona, luego pedirle el CV anterior y todo insumo que ya exista, luego entrevistarla por bloques para sacar la mayor información posible, y solo entonces escribir. Obliga a construir un banco de logros verificables antes de escribir una sola línea, a personalizar contra el texto de la vacante en vez de cambiar el nombre de la empresa, y a comprobar que un ATS puede leer el archivo. Cuándo no usarla — si el trabajo es convencer de una decisión o pedir aprobación → kit-propuestas; si es solo el correo con el que se envía la postulación → kit-redaccion; si el resultado es un deck o portafolio con identidad visual → kit-presentaciones.'
---

# Currículums y candidatura — estándar Kit Chema

Playbook para el CV y lo que lo acompaña: carta de presentación y perfil de
LinkedIn. Dos disciplinas ya viven fuera y no se repiten aquí: definir audiencia
y objetivo antes de escribir (kit-presentaciones) y redactar el correo de envío
(kit-redaccion).

Esta skill cubre lo que Claude hace mal por defecto en un CV: infla logros que
nadie le dio, escribe responsabilidades en lugar de resultados, entrega el mismo
documento genérico para toda vacante y rompe la lectura automática con formato
bonito.

## Regla de veracidad — primero y no negociable

Cada línea del CV tiene que ser defendible en una entrevista por la persona, no
por Claude. En concreto:

- Ninguna cifra sin que el usuario la haya dado o confirmado. No se estima, no se
  redondea al alza, no se "reconstruye" a partir del contexto de la empresa.
- Ningún verbo escalado: "participé en" no se convierte en "lideré"; "apoyé" no
  se convierte en "diseñé". El alcance real manda sobre el verbo que suena mejor.
- Puestos, fechas y nombres de instituciones tal como constan en el documento
  oficial, no como se recuerdan.
- Lo que falte se marca `[FALTA: qué dato]` en el borrador y se pregunta. Nunca
  se rellena para que el documento "quede completo".

Detectar un dato que no se puede sostener y dejarlo pasar es el peor fallo posible
bajo esta skill: quema a la persona en la entrevista o, peor, después de contratada.

## Bien hecho significa

- **CV**: una página si hay menos de 10 años de experiencia, dos como máximo
  absoluto. La mitad superior de la primera página ya dice quién es, qué sabe
  hacer y por qué encaja con *esta* vacante.
- **Cada viñeta es un resultado**, no una tarea: verbo de acción + qué se hizo +
  magnitud + efecto. "Responsable de reportería" no dice nada; "automaticé la
  reportería semanal de 40 tiendas y bajé el cierre de 6 horas a 20 minutos" sí.
  Si una viñeta no tiene magnitud ni efecto, o se consigue el dato o se corta.
- **Personalizado de verdad**: el orden de las secciones, las viñetas elegidas y
  el vocabulario responden al texto de la vacante. Cambiar el nombre de la empresa
  en el encabezado no es personalizar (mismo error que la auditoría de audiencia:
  al cambiar destinatario se relee todo, no se hace find-replace).
- **Legible por máquina**: una sola columna, texto seleccionable, sin tablas,
  columnas, cuadros de texto, encabezados/pies, iconos ni barras de "nivel de
  habilidad". El PDF se genera desde texto, nunca como imagen.
- **Insumos agotados antes de escribir**: la vacante leída y devuelta a la persona,
  el CV anterior pedido y auditado, y una entrevista por bloques con repregunta por
  la cifra. Si el CV se escribió con lo poco que la persona dijo de entrada, no está
  bien hecho aunque se lea bonito.
- **Carta de presentación**: media página, tres párrafos — por qué esta vacante,
  las dos pruebas más fuertes de que puedo, qué pido. Nunca repite el CV en prosa.
- **Perfil de LinkedIn**: titular con oficio y especialidad (no "apasionado por"),
  "Acerca de" en primera persona con las mismas cifras del banco, experiencia
  alineada con el CV en fechas y puestos. Cualquier contradicción entre CV y
  LinkedIn se lee como mentira.

## Proceso

El orden importa: **primero se entiende el trabajo, después se entiende a la
persona.** Al revés, la entrevista sale genérica y se pierde la mitad de los
logros útiles porque nadie sabía todavía qué buscaba la vacante.

1. **Entender el trabajo al que va.** Antes de preguntarle nada a la persona,
   consigue el texto de la vacante — pídelo, o la URL, o el nombre del puesto y la
   empresa para investigarla. Con él en mano, extrae y **escribe** en pantalla:
   requisitos duros (los excluyentes), deseables, qué problema busca resolver el
   puesto en realidad, el vocabulario exacto que usa, seniority, y qué se sabe de
   la empresa. Muestra esa lectura a la persona antes de seguir: si tu lectura del
   puesto está mal, todo lo que viene después está mal. Sin vacante todavía, se
   define un puesto objetivo concreto ("analista de datos en retail, 3-5 años") y
   se trabaja contra eso; un CV sin destino no se puede personalizar.
2. **Pedir lo que ya existe antes de preguntar.** No le preguntes a la persona lo
   que ya está escrito en un documento que puede pasarte en un minuto. Pide, en
   este orden: **CV anterior** (cualquier versión, aunque esté viejo, incompleto o
   feo — es el mejor insumo que hay), perfil de LinkedIn, descripción de su puesto
   actual, evaluaciones de desempeño, portafolio o repos, certificados y cartas de
   recomendación. Aclara que no importa el formato ni la antigüedad. Cuando llegue
   el CV anterior, léelo entero y aplícale el protocolo de
   `references/plantilla-y-ats.md` (§2): qué se rescata, qué se audita, qué se
   tira. Solo entonces sabes qué falta preguntar.
3. **Entrevistar para sacar la mayor información posible.** Aquí la meta es
   extraer, no ahorrar preguntas: **el límite de 2-3 preguntas del CLAUDE.md no
   aplica a este paso**, y así se le dice a la persona ("te voy a hacer varias
   preguntas por bloques; con esto se arma el CV de una vez"). Reglas del
   interrogatorio:
   - Por **bloques de 3 a 5 preguntas**, no un cuestionario de cuarenta de golpe.
     El banco completo por bloque está en `references/plantilla-y-ats.md` (§3).
   - **Nunca preguntes lo que ya contestó** el CV anterior, LinkedIn o un mensaje
     previo. Preguntar lo que ya te dieron quema la paciencia y la confianza.
   - **Repregunta siempre por la cifra.** Toda respuesta sin magnitud lleva una
     segunda pregunta: cuánto, de cuánto a cuánto, en cuánto tiempo, cuántas
     personas. Ahí está el 80% del valor del CV.
   - Cubre los bloques incómodos, no los esquives: huecos de empleo, salidas,
     cambios de giro, y **qué cifras no puede publicar por confidencialidad o NDA**
     (un CV con datos de cliente crea un problema legal, no una ventaja).
   - Cierra con lo logístico: disponibilidad, ubicación o remoto, expectativa
     salarial, permiso de trabajo, fecha límite de la postulación.
4. **Banco de logros.** Con la vacante entendida y la entrevista hecha, cada logro
   se registra con verbo, magnitud, periodo, rol real, evidencia y de dónde salió
   la cifra. Es el trabajo real; la plantilla está en
   `references/plantilla-y-ats.md`. Se guarda en la carpeta del interesado, no en
   el chat, para no reconstruirlo la próxima vez.
5. **Mapa vacante → evidencia.** Antes de redactar, una tabla de tres columnas:
   requisito de la vacante | evidencia del banco | hueco. Los huecos se dicen en
   voz alta, con recomendación de si conviene postular; no se disimulan con
   redacción. Si un requisito excluyente queda sin evidencia, se dice antes de
   escribir el CV, no después.
6. **Armar.** Estructura y orden según el mapa: arriba lo que la vacante pide
   primero. Reescribir las viñetas con el vocabulario de la vacante siempre que
   sea verdad, respetando el límite de página.
7. **Verificar.** Terminado significa verificado: extraer el texto del PDF y
   confirmar que sale legible y en orden, contar páginas, recalcular cada cifra
   contra el banco, revisar fechas sin huecos ni traslapes inexplicados, y abrir
   el archivo generado antes de decir que está listo.

## Datos personales (México)

Fuera del CV por defecto: CURP, RFC, NSS, dirección exacta, edad, fecha de
nacimiento, estado civil, dependientes y foto. No aportan a la decisión y abren
puerta a discriminación. Van solo si la vacante los pide de forma explícita, y
entonces se avisa al usuario de qué se está exponiendo. Sí van: nombre, ciudad y
país, teléfono, correo profesional y LinkedIn.

## Checklist final

Antes de decir que está listo, con el archivo abierto delante:

- ¿Leí la vacante y le devolví mi lectura a la persona antes de entrevistarla?
- ¿Pedí el CV anterior y los demás insumos, y los audité en vez de copiarlos?
- ¿Repregunté por la cifra en cada logro sin magnitud?
- ¿Pregunté qué cifras no puede publicar por confidencialidad o NDA?
- ¿Cada cifra del CV sale del banco de logros y tiene fuente? ¿Queda algún
  `[FALTA]` sin resolver?
- ¿Alguna viñeta describe una tarea en vez de un resultado?
- ¿Cabe en el límite de páginas sin bajar la tipografía a tamaño ilegible?
- ¿Los tres requisitos principales de la vacante se ven en la mitad superior de
  la primera página?
- ¿El texto del PDF se extrae completo, en orden y sin caracteres partidos?
- ¿Fechas y puestos coinciden exactamente entre CV, carta y LinkedIn?
- ¿Se quedó fuera algún dato personal innecesario (edad, CURP, foto, estado civil)?
- ¿El nombre del archivo identifica a la persona y el puesto, no "CV final v3"?
- ¿Se declaró el estado real ("borrador para tu revisión" vs "listo para enviar")?

## Errores típicos

- **Inventar para tapar el hueco.** Estimar un porcentaje, inflar un equipo,
  ascender un verbo. El hueco se declara; no se maquilla.
- **Escribir antes de entrevistar.** Redactar el CV con las tres frases que la
  persona dijo de entrada. El resultado es un CV pobre que parece terminado, y el
  60% de los logros se queda sin salir.
- **Preguntar lo que ya estaba en el CV anterior.** Quema la paciencia y hace
  evidente que no se leyó lo que la persona mandó.
- **Tratar el CV anterior como fuente de verdad.** Hereda las inflaciones de quien
  lo escribió; cada afirmación sin cifra se audita antes de reciclarla.
- **Copiar el organigrama.** Listar responsabilidades del puesto en vez de lo que
  la persona logró. El reclutador ya sabe qué hace un analista.
- **CV genérico con la empresa cambiada.** Un solo documento para todas las
  vacantes, o personalización que se limita al encabezado.
- **Formato que se ve bien y no se lee.** Dos columnas, iconos, gráficas de
  habilidades, PDF exportado como imagen: el ATS entrega un CV vacío y nadie lo ve.
- **Padding de habilidades.** Listas de veinte tecnologías con una semana de uso
  cada una. Diluyen las tres que sí importan y son trampa en la entrevista.
- **Carta que es el CV en prosa.** Repetir el mismo contenido sin agregar el
  porqué de esta vacante.
- **Confundir el terreno vecino.** Convertir el CV en un deck de portafolio
  (kit-presentaciones) o el correo de postulación en una propuesta (kit-propuestas).
