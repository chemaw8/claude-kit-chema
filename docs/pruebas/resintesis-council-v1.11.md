# Resíntesis del council v1.11 con las cuatro clases y el mapa de acuerdos (2026-10-01)

Prueba de la pieza que cambia el formato del `sintetizador` y la sección «Veredicto» de `kit-propuestas`:
cada hallazgo cae en una sola clase (`actuar`, `considerar`, `anotado`, `descartado`) y la síntesis
trae un mapa de acuerdos entre evaluadores. Adaptado del «lead judgment» de `interrogate` de pstack
(Lauren Tan, MIT, commit fae2c6e).

## De qué acta sale y por qué esa

`docs/pruebas/council-v1.11.md` (2026-08-23). Es la única acta archivada donde cada hallazgo trae el
lente o los lentes que lo aportaron y su disposición, y además una sección de descartados. Las otras
candidatas no alcanzan: `council-v1.8.md` trae conteos por evaluador sobre candidatas, no hallazgos
atribuidos; `council-v1.26.md` y `council-v1.27.md` tienen familias distintas pero atribuyen cada
cambio a un solo evaluador y no conservan lo que se descartó.

**Límite.** Los reportes crudos de los cuatro evaluadores no se archivaron. Esta resíntesis trabaja
con lo que el acta conserva: no hay hallazgos nuevos y la atribución es la del acta. Para no heredar a
ciegas, cada hallazgo comprobable se verificó contra el estado del repo que evaluó el panel
(`4b92bae`, último commit de v1.11 antes del council; los cambios entraron en `19687cb`).

Panel: 4 evaluadores, todos Opus 5 (una sola familia), lentes viabilidad técnica, costo/beneficio,
riesgos y abogado del diablo. Postura inicial del hilo: «Apruebo v1.11 […] Mi única duda es el +19% de
palabras del núcleo».

## Tabla nueva

| # | Hallazgo (resumen del acta) | Quién | Clase | Razón | Verificado en `4b92bae` |
|---|---|---|---|---|---|
| H-1 | `instalar.sh` no copia `agents/`: la propuesta es inerte | técnica, riesgos, diablo | actuar | la propuesta no hace lo que dice; el núcleo ya nombraba agentes que no existirían | sí: la línea 10 crea `skills`, `contexto`, `hooks`; 0 menciones de `agents` |
| H-1b | `verificar.sh` no ve `agents/` ni el crecimiento del núcleo | técnica, diablo | actuar | la postura citaba `verificar.sh` en verde como aval y el linter no podía ver lo nuevo | sí: 0 menciones de `agents/` |
| H-2 | el hook imprime el encabezado fuera del guard; la prueba de presencia pasa con contexto vacío | riesgos | actuar | camino de falla concreto, no hipótesis | sí: el `echo` del encabezado va antes del bucle |
| H-4 | la puerta de delegación se fija en el tamaño y el resto del kit en el riesgo | riesgos | actuar | contradicción interna del núcleo: un cambio de una línea a un cliente saldría sin revisión | sí: «Tarea chica, edición de un archivo… hazla tú» |
| H-4t | los tres agentes heredan todas las herramientas; un `verificador` con Write valida su propia corrección | técnica | actuar | rompe la independencia, que es el valor del agente (lo dice C-a) | sí: ninguno de los tres trae `tools:` |
| C-a | el argumento de costo del `verificador` es falso (Sonnet 1.67× más barato, no un orden de magnitud) | costo | actuar | cifra falsa en la propuesta | no: el argumento estaba en el texto de la propuesta, no en el repo |
| C-b | el «15×» está mal citado y suprimiría delegaciones que sí valen | costo, diablo | actuar | cifra mal aplicada dentro del núcleo | sí: «del orden de 15× en tokens» |
| C-e | el +19% de palabras es en realidad +24% | costo | actuar | cifra falsa en la postura y la propuesta | sí: 505 palabras antes de v1.11 → 628 (+24.4%) |
| T-2 | por plugin los agentes llevan prefijo y `marketplace.json` dice «8 skills + dos hooks» | técnica | actuar | el manifiesto describe mal lo que se distribuye | sí, el manifiesto; el prefijo no se puede comprobar aquí |
| T-x | el núcleo dice «un solo agente iguala a varios» y `kit-propuestas` lanza N evaluadores | técnica | actuar | contradicción interna entre núcleo y skill | sí: línea 65 del núcleo |
| H-3 | «extrae lo que sirve» puede volverse muestreo y dar verificaciones falsas | riesgos | considerar | riesgo real pero hipotético, sin un caso observado; cuesta líneas en un núcleo con tope | sí, la frase existe; el muestreo no se observó |
| H-5 | truncamiento silencioso si las discrepancias no caben en el tope del `verificador` | riesgos | considerar | real y barato de cerrar, pero no cambia la decisión | sí: tope de ~500 tokens sin aviso de lo omitido |
| C-c | v1.11 entra sin métrica ni criterio de retiro, a otras propuestas se les exige gate | costo, diablo | considerar | regla de gobierno, no defecto de la propuesta; la decide el usuario | no aplica (es criterio) |
| C-d | hay retorno 3 a 14 veces mayor en otro lado (`pr-review-toolkit` sin bloquear) | costo, diablo | considerar | de otro momento: tiene acción, pero fuera de v1.11 | no: viene de conteos de transcripts no archivados |
| D-1 | «solución en busca de problema» | diablo | descartado | el propio evaluador lo refutó con 84 delegaciones reales | no: transcripts no archivados |
| D-2 | «el 0/9 de agentes de plugins predice el destino de estos» | costo o diablo (el acta no precisa) | descartado | tasa base no comparable: otros dominios | no |
| D-3 | «contradice el recorte del 80% de Anthropic» | no consta quién lo planteó; lo refutó costo | descartado | aquel recorte quitó restricciones, aquí entran heurísticas permisivas | no |
| D-4 | «`lector-fresco` sobre material confidencial es exposición nueva» | riesgos | descartado | «sin contexto previo» es rol, no frontera; misma cuenta y mismo proceso | no aplica |
| D-5 | «el repo es público, ¿los agentes exponen algo?» | no consta | descartado | se leyeron los tres: roles genéricos, sin datos | sí: los tres archivos solo definen el rol |

Ninguno cae en `anotado`. Conteo: 10 actuar, 4 considerar, 0 anotado, 5 descartados.

**Cambios concretos** (los 10 de `actuar` agrupados por raíz, como pide la regla de «si pasan de cinco»):

1. Instalar y vigilar los agentes: `instalar.sh` copia `agents/` y `verificar.sh` lo comprueba (H-1, H-1b).
2. Encabezado del hook dentro del guard (H-2).
3. Corregir las tres cifras: costo del `verificador`, «15×», +24% (C-a, C-b, C-e).
4. Quitar las dos contradicciones del núcleo: tamaño contra riesgo y un agente contra N (H-4, T-x).
5. `tools:` explícito en `verificador` y `lector-fresco`; manifiesto actualizado (H-4t, T-2).

## Mapa de acuerdos

| Señal | Hallazgos | Lentes |
|---|---|---|
| Tres lentes | H-1 | técnica, riesgos, diablo |
| Dos lentes | H-1b, C-b, C-c, C-d | técnica + diablo (H-1b); costo + diablo (los otros tres) |
| Un solo lente | H-2, H-3, H-4, H-5 · H-4t, T-2, T-x · C-a, C-e | riesgos · técnica · costo |
| Contradicciones | ninguna registrada; D-3 pudo ser una (alguien lo planteó y costo lo refutó), pero el acta no dice quién | |

Lectura:
- El consenso es entre lentes de una sola familia (Opus 5). Es independiente por contexto fresco, pero
  no es la señal entre modelos distintos que usa pstack: pesa menos.
- El abogado del diablo está en 5 de los 5 hallazgos con consenso. Sin él, solo H-1 tendría más de un
  lente: costo y diablo se cruzan mucho.
- Los dos hallazgos más graves por su camino de falla (H-2 y H-4t) los trajo un solo lente. El consenso
  no los habría priorizado; la verificación sí.
- En la tabla del acta, cada lente aparece en exactamente 5 hallazgos. Sin los reportes crudos no se sabe si es un tope del
  encargo, la consolidación del acta o relleno.

## Diferencia contra la síntesis original

- **Cambian de trato 4 hallazgos.** H-3, H-5 y C-c se aplicaron como si fueran obligatorios; ahora son
  `considerar` y los decide el usuario. C-d estaba como «anotado» pero tenía una acción (siguiente paso
  en el CONTINUAR); con las definiciones nuevas es `considerar`. El acta misma mide el costo de no
  separar: las cláusulas del council llevaron el núcleo de +24% a +44% (verificado: 628 → 728 palabras
  en `19687cb`), y H-3 fue una de ellas.
- **Lo que era implícito ahora es explícito.** El filtro del hilo principal no se veía: de los 14
  hallazgos que los evaluadores sostuvieron, 13 se aplicaron completos o en parte y ninguno se
  descartó; 4 de los 5 descartados los refutó el propio evaluador. La tabla nueva obliga a dar una
  razón por clase, y la columna de verificación separa lo que se comprobó en archivos (12 filas) de lo
  que se heredó del acta.
- **El veredicto no cambia:** `aprobada con cambios`. Los 10 de `actuar` bastan para ese veredicto, y los
  5 cambios agrupados cubren lo que bloqueaba (H-1).
- **Qué no mejora.** En el resultado, probablemente nada: H-3, H-4 y H-5 siguen en el kit 18 versiones
  después (núcleo líneas 50 y 93; `verificador` línea 35) y el criterio de retiro de C-c quedó en el
  CHANGELOG. Si el usuario hubiera recibido esos cuatro como `considerar`, lo más probable es que los
  aceptara. La ganancia es de transparencia y de control del crecimiento del núcleo, no de acierto.
  Sin los reportes crudos, el mapa de acuerdos repite la atribución del acta y no agrega información.

**Qué faltaría para medirlo de verdad:** archivar los reportes crudos de cada evaluador en el próximo
council (con familia y lente) y sintetizar dos veces, con el formato anterior y con el nuevo, contando
cuántos hallazgos entran como cambio y cuántos de esos siguen en el kit una versión después.
