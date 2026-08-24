# Council — Kit v1.12 (sugerencias ante poca info)

Fecha: 2026-08-24
Propuesta original: novena skill `kit-sugerencias` — ante peticiones con poca
información o "ayúdame a elegir", ofrecer 2-4 opciones con costo y recomendación.
Panel: 4 evaluadores independientes, Opus 5, contexto fresco, sin verse entre sí.
Lentes: diseño/disparo, costo/valor, riesgos, abogado del diablo.

## Postura del hilo principal ANTES de leer reportes

> Apruebo con reservas. Llena un hueco real que José pidió y está bien escrita,
> pero me preocupa el solapamiento con kit-propuestas y con la regla del núcleo
> "pregunta 2-3". La duda es si gana su lugar como skill o si debía ser regla del
> núcleo.

## Veredicto del panel

| Lente | Veredicto |
|---|---|
| Diseño / disparo | aprobada con cambios |
| Costo / valor | aprobada con cambios |
| Riesgos | aprobada con cambios |
| Abogado del diablo | aprobada con cambios |

**Unánime: aprobada con cambios — con un cambio estructural: NO agregar la skill;
plegar el delta en el núcleo.** Los cuatro lentes, sin verse, convergieron en lo
mismo.

## ¿Cambió de opinión el hilo principal?

**Sí, decisivamente.** Mi duda inicial (skill vs. núcleo) quedó resuelta por el
council hacia el núcleo. Cuatro evaluadores independientes llegaron al mismo
diagnóstico sin coordinarse: eso es lo que un council debe producir y no fue
teatral.

## El hallazgo convergente

Es una **disposición transversal**, no una skill de dominio:
- Las 8 skills del kit son dominios (producen un entregable). Ésta es una postura
  conversacional ante ambigüedad — del mismo tipo que "Arranque de tarea" y
  "Evaluación crítica", que el kit puso en el **núcleo**.
- Como skill es **más cara** (590 chars siempre en el listado, verificado por el
  lente de costo: descriptions del kit pasarían a 4,604) y **menos fiable** (solo
  ayuda si el dispatcher elige la skill; en el caso que más importa —petición vaga
  sin "dame opciones"— no hay frase gatillo, así que no dispara). Una regla del
  núcleo, siempre en contexto, sí aplica ahí.
- El **delta real** sobre lo existente era una cláusula: "opciones curadas en vez
  de formulario en blanco". El resto **duplicaba kit-propuestas** (opciones/costos/
  recomendación/anti-paja — verificado: líneas 20-25 y 117 de kit-propuestas) y la
  propia regla de arranque del núcleo.

## Hallazgos y qué se hizo

| # | Lente | Hallazgo | Resolución |
|---|---|---|---|
| núcleo-vs-skill | los 4 | disposición transversal → pertenece al núcleo, no a skill #9 | **Aplicado.** Skill eliminada; cláusula añadida a "Arranque de tarea". |
| investigar-primero | riesgos | la skill enmarcaba binario (adivinar vs opciones); falta el tercer camino: cerrar la ambigüedad con el contexto disponible antes de ofrecer | **Aplicado.** El núcleo ahora dice "primero intenta cerrarlo con lo que puedes reunir". |
| formulario-en-blanco | diseño, diablo | el único delta genuino: convertir preguntas de aclaración en opciones curadas con recomendación | **Aplicado.** Es el corazón de la cláusula nueva del núcleo. |
| frontera kit-propuestas | diseño (H-1) | "¿X o Y?" barato matcheaba ambas descriptions; la partición era unidireccional | **Aplicado.** Description de kit-propuestas: "¿X o Y?" **con consecuencias reales**; la elección ligera la resuelve el núcleo. |
| compone-no-reemplaza | diseño (H-3) | triggers anchos ("cómo le hago") competían con skills de dominio | **Resuelto de raíz.** Al no haber skill, no hay competencia de dispatch; la regla del núcleo compone con cualquier skill de dominio por definición. |
| auto-avance ambiguo | riesgos (H2) | "avanza con el recomendado si no contesta" mal definido en sesión interactiva | **Resuelto.** La cláusula del núcleo no incluye auto-avance; queda el default sano de esperar la elección. |
| description larga | costo | 590 chars, 5 frases-gatillo sinónimas | **Resuelto.** Sin skill, sin description; costo de listado = 0. |
| evidencia bajo el umbral | diablo | un feature-request, no "el usuario corrige dos veces" (la vara del kit) | **Atendido.** Se aplica el delta mínimo al núcleo, no una skill entera; la vara se respeta con el cambio más pequeño que captura el valor. |

## Qué se conservó de la propuesta

El **comando `/revisar-salud`** (flujo de revisión-corrección de la observabilidad)
no era parte del debate de la skill y entra tal cual: es un comando, no carga
listado, y cierra el lazo observar→corregir.

## Nota de método

El council corrió con `general-purpose` + el prompt del rol, porque el agente
`evaluador-council` del kit (v1.11) todavía no está mergeado a `main` ni instalado.
A partir del merge de v1.11, el council usa ese agente.
