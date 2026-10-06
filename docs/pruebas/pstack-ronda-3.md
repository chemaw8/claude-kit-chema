# Ronda pstack 3: candidatos 5 a 8 (acta-propuesta, 2026-10-06)

Corrida ultracode uc-202610061430-aogq. Fuente: pstack (`cursor/plugins/pstack`, clon en commit df58112, MIT ©
Lauren Tan). Lista de candidatos: `investigacion/2026-09-30-pstack-y-mercado.md`, sección 1. Núcleo y descriptions
intactos: el gate de disparo no aplica. Toda medición de esta acta es determinista y sin modelos; los comandos para
repetirla están en cada sección. El material local de fuera del repo se describe sin nombres de proyectos de
clientes ni cifras de negocio.

## Veredictos

| # | Candidato | Veredicto | Evidencia | Automatizado |
|---|---|---|---|---|
| 5 | `arena` | entra (1 párrafo en `kit-orquestacion`) | medición de 3 rondas en pi-harness; el texto previo de la skill la prohibía | en parte: `scripts/cegar.sh etiquetar` |
| 6 | registro de decisiones auditado (`show-me-your-work`) | ya está cubierto; lo que falta no aporta | conteo de punteros de evidencia en 38 proyectos locales | no: un verificador de punteros tendría precisión ≤ 12% |
| 7 | «si la duda se resuelve corriendo algo, córrelo» | ya está cubierto | 65 preguntas reales al usuario, 2 caían en la regla | no aplica |
| 8 | reglas de cegado (`eval`) | entra (1 viñeta en `kit-orquestacion`) | 6 de 10 encargos de una medición real delataban la medición | sí: `scripts/cegar.sh revisar` |

Presupuesto: `kit-orquestacion` recibe 2 adiciones netas (el tope de la ronda) y pasa de 1,531 a 1,800 palabras (tras los cambios del council)
(tope 5,000); las paga ese margen. `docs/pruebas/RUNBOOK.md` suma un apunte de 6 líneas que remite a la skill. Ninguna otra skill cambia.

## (5) Arena

**Qué falta en el kit.** Antes de este cambio, `kit-orquestacion` decía «el fan-out solo lanza agentes que leen»
(`skills/kit-orquestacion/SKILL.md:22-23` en main) y trataba la escritura en paralelo como último recurso (`:101-104`).
La escalera de topología (`:38-44`) no tenía fila para varios intentos del mismo encargo, aunque la description
dispara con «compara estas 5 opciones». Quien pide una arena desde Claude Code no encontraba cuándo paga, cuántos
intentos ni qué hace el juez.

**Evidencia de que aporta** (pi-harness, `docs/medicion-arena/README.md`, rondas del 2026-10-01, 2026-10-02 y
2026-10-06; solo lectura):

| Hallazgo | Dato |
|---|---|
| Un intento basta casi siempre | en 8 de 10 tareas, cualquier intento solo ya daba el máximo |
| Cuando un intento falla, la arena paga | en las 2 tareas que discriminan, la arena superó al intento promedio en 5 de 7 configuraciones y al mejor candidato en 2 |
| Tres intentos, no más | N=4 no superó a N=3; con N=5 el juez siguió a la mayoría equivocada y descartó al único correcto |
| El valor está en el caso que nadie cubre | los jueces de dos familias señalaron por su cuenta el caso que ningún candidato cubría; cuando el integrador actuó sobre él, la arena superó al mejor candidato, y cuando lo dejó como matiz, no |

**Lo que entra.** Un párrafo tras la escalera: la arena es la excepción medida a «un solo escritor» (copias aisladas
y un solo integrador), solo paga donde un intento puede fallar, tres intentos, juez de contexto limpio que ve letras
y una rúbrica que los autores no ven, y que dice qué caso no cubre nadie; el integrador decide por escrito qué hace
con ese caso. Lo mecánico (copias por letra, mapa aparte) lo hace `cegar.sh etiquetar`.

**Lo que no se automatiza.** Lanzar los intentos, juzgar e injertar requieren agentes; en pi-harness ya existe como
`/ultracode --arena`. En Claude Code solo hay una familia de modelos, así que la mezcla de familias que midió
pi-harness no se puede repetir ahí; el párrafo no la exige.

**Alternativas descartadas.** Una skill o un comando `/arena` (cuesta disparo y gate, y lo usaría una corrida de
cada diez según la medición); copiar la fase de injerto completa de pstack (la medición no separa el injerto del
juez); dejarlo solo en pi-harness (la skill del kit seguiría diciendo que no se hace).

## (6) Registro de decisiones auditado

**Qué trae pstack.** Un TSV por corrida con una fila por decisión (qué, por qué, evidencia, resultado), solo se
añade, se audita al final contra la transcripción de la corrida y lo revisa otra familia de modelos.

**Qué ya tiene el kit**, pieza por pieza:

| Pieza de pstack | En el kit |
|---|---|
| fila con qué, por qué y evidencia | `DECISIONES.md`: de 10 entradas, 9 citan evidencia, 7 nombran lo descartado y 5 dicen cuándo revisar |
| solo se añade | `scripts/rotar-continuar.sh:7-10`: `rotar` pasa lo desplazado a `docs/bitacora.md` y verifica línea por línea |
| auditar el registro contra lo que pasó | `scripts/rotar-continuar.sh:12-15`: `reconciliar` contrasta el ancla de git con el estado escrito |
| encontrar la razón después | `/por-que` (v1.30) |
| leer la transcripción | excluido a propósito: `/por-que` no lee sesiones (`docs/pruebas/council-v1.30.md:19`) |
| revisión de otra familia | el council y la corrida ultracode la hacen; en Claude Code no hay otra familia |

**Lo único nuevo sería comprobar que cada puntero de evidencia resuelve.** Se midió si hace falta:

| Corpus | Punteros | No resuelven | De esos, rancios de verdad |
|---|---|---|---|
| este repo (`DECISIONES.md`, `CONTINUAR.md`, `CHANGELOG.md`, `docs/bitacora.md`) | 74 rutas, 2 ids de commit | 3 rutas, 1 id | 0: un archivo borrado a propósito por confidencialidad (commit 71163d2), una ruta del proyecto destino de `/crear-verificacion` y una de otro repo; el id es de pi-harness |
| `DECISIONES.md` y `CONTINUAR.md` de 38 proyectos locales | 182 rutas, 25 ids hexadecimales | 12 rutas, 14 ids | a lo más 3 rutas; el resto son plantillas (`specs/NNN`), nombres de rama, rutas de otro repo y ids que no son commits (llamadas, listas) o son de otro repo |

Un verificador de punteros marcaría 26 casos y acertaría a lo más 3 (precisión ≤ 12%). No entra. El registro
por corrida tampoco: la granularidad que añade (una fila por decisión dentro de una sesión) no tiene un fallo medido
que corregir, y su auditoría depende de leer transcripciones, que el kit dejó fuera en v1.30.

El helper de pstack tampoco lo cubre: `log.sh` acepta una fila con `evidence=archivo-inexistente:99` y
`result=tests green` y sale 0 (sonda de otra solución de esta arena, repetible con el clon de pstack): valida forma,
no evidencia. El valor de pstack está en la auditoría contra la transcripción y en el revisor de otra familia, y
esa parte queda sin medir frente a `/cierre` más revisión de artefactos.

Para repetirlo: un script de python que extraiga con regex las rutas entre comillas de código que empiezan por
`docs/`, `scripts/`, `specs/`, etc. y los ids hexadecimales de 7 a 12 caracteres, y compruebe `os.path.exists` y
`git cat-file -e <id>^{commit}` en el repo de cada archivo.

## (7) «Si la duda se resuelve corriendo algo, córrelo antes de preguntar»

**Qué ya dice el kit.** El núcleo pide cerrar lo que falta con lo que se puede reunir antes de preguntar
(`nucleo/CLAUDE.md:16-18`) y ofrecer opciones en vez de preguntar en abstracto (`:19-21`). `kit-codigo` pide reproducir
el error antes de arreglarlo y trabajar por hipótesis con evidencia (`skills/kit-codigo/SKILL.md:102-105`). El
`verificador` corre comandos en vez de suponer (`agents/verificador.md:21`).

**Medición.** Todas las preguntas hechas al usuario con la herramienta de preguntas en las sesiones locales de
Claude Code (2026-10-06): 68 registros, 65 preguntas distintas. Criterio: la respuesta es un hecho que el agente
podía observar corriendo algo en la máquina donde trabajaba. Cumplen 2 de 65, y las dos son de reproducir una falla de interfaz que reportó el usuario,
donde `kit-codigo:102` ya aplica. Las otras 63 son preferencias, alcance, permisos, datos del negocio o hechos de
otra máquina.

**Veredicto.** Ya está cubierto: la regla movería a lo más 3% de las preguntas, y esos casos ya los pide otra regla.
No va al núcleo. Si el council lo quiere de todos modos, el texto exacto (sin líneas nuevas) cambiaría el paréntesis de
`nucleo/CLAUDE.md:17-18` de «(archivos del proyecto, contexto, memoria, la propia conversación)» a «(archivos del proyecto,
contexto, memoria, la propia conversación, o corriendo algo si la respuesta es un hecho observable)», con gate de
disparo en un PR aparte.

**Límites.** El conteo de 65 preguntas sale de sesiones locales y no se puede repetir desde este repo: es un
indicio, no la base del veredicto. La base son las citas de arriba, que cualquiera puede abrir. No cuenta las preguntas hechas en prosa (sin la herramienta) ni las sesiones de pi. La clasificación de
las 65 es mía y las preguntas no se publican (traen datos de clientes): se repite extrayendo los bloques
`AskUserQuestion` de los `*.jsonl` locales y aplicando el criterio de arriba.

## (8) Reglas de cegado de evaluaciones

**Qué ya tiene el kit.** El gate de disparo le da al juez solo las descriptions y una petición
(`docs/pruebas/RUNBOOK.md:15-21`). El council da a cada evaluador solo la propuesta y su mandato
(`skills/kit-propuestas/SKILL.md:87-90`), y los lectores van «ciegos entre sí» (`skills/kit-orquestacion/SKILL.md:42`).
Nada de eso cubre el encargo que recibe un candidato ni las etiquetas con que el juez ve las salidas. En las actas,
de 4 mediciones con juez modelo, 2 declaran cegado (`council-v1.26.md:34`, `council-v1.30.md:92`) y 2 no lo dicen
(`medicion-esfuerzo-v1.19.2.md:15`, `council-v1.25.md:49`).

**Caso real.** En la medición de la arena de pi-harness, los encargos de las rondas 1 y 2 decían «tu código se
calificará además con pruebas que no ves» o «habrá pruebas ocultas además de las tuyas». El autor lo notó a mano
después de la ronda 2 y lo quitó en la ronda 3 («probablemente ayudó»). `cegar.sh revisar` sobre copias de esos
encargos en una carpeta neutral:

| Encargos | Marcados |
|---|---|
| rondas 1 y 2 (6) | 6 |
| ronda 3, ya corregidos a mano (4) | 0 |

**Falsos positivos.** 0 en 57 pedidos normales: las 30 peticiones del banco de disparo y los 27 primeros mensajes
de sesiones interactivas locales. Tras los injertos de la integración (abajo) se repitió lo que es repetible: 6 de 6,
0 de 4 y 0 de 30 en el banco de disparo; los 27 mensajes de sesiones no se repitieron. Los primeros mensajes de sesiones automáticas (965, sobre todo jueces y revisores)
no sirven de control, porque ahí «juez» es legítimo.

**Hallazgo de paso.** La carpeta de trabajo de esta misma corrida se llama `arena-1` y `cegar.sh revisar` la marca:
`/ultracode --arena` de pi-harness nombra las copias `arena-<n>` (su `specs/011-ultracode/spec.md:76`), y cada
candidato ve su carpeta. Arreglarlo toca pi-harness, no este repo.

**Lo que entra.** Una viñeta en «Cómo se verifica» de `kit-orquestacion`, y `scripts/cegar.sh`: `revisar` (encargo y
ruta del candidato) y `etiquetar` (copias por letra al azar, mapa fuera de lo que ve el juez, falla si una copia nombra
a su autor o una ruta nombra un modelo). Deja fuera «prueba», «test», «compara» y «evalúa», que en un encargo normal
son palabras comunes; la fuga medida es anunciar pruebas ocultas o calificación.

**Lo que no se automatiza.** Leer transcripciones para calificar si el candidato siguió la cadena (paso 6 del
playbook): choca con la decisión de v1.30 de no leer sesiones. Que el encargo «parezca un pedido normal» es juicio;
el script solo atrapa las fugas léxicas.

**Alternativas descartadas.** Las reglas en `GOBERNANZA.md` o en el RUNBOOK (no se instalan, y quien corre un A/B
desde el kit no las vería); la lista de palabras de pstack tal cual («test», «compare» darían falsos positivos en
cada encargo de código); un chequeo de nombres de modelo en el contenido de las copias (el contenido de este repo los
nombra de forma legítima: «Opus 5.5» en el núcleo).

## Integración de la arena

Esta acta es la base (solución A) de una arena de tres soluciones con juez de otra familia; la nota de síntesis está
en `docs/pruebas/ARENA-uc-202610061430-aogq.md`. Se le injertó:

- **Lector seguro** (de la solución B): un enlace, un FIFO u otro archivo especial, o una carpeta sin permiso, dan
  salida 2 (revisión incompleta) en vez de «limpio»; `etiquetar` revisa los candidatos antes de copiar, porque la
  copia seguiría el enlace. Los binarios se listan como «sin revisar» en vez de saltarse en silencio. Python corre
  con `-I`: el juez mostró que un `random.py` en la carpeta actual se ejecutaba.
- **Casos que ninguna solución cubría** (del juez): anunciar una nota («de 0 a 5»), elegir «la mejor entrega»,
  decir que otra IA resuelve el mismo encargo, pedir que enumere las reglas que aplicó (la pista de cadena de
  pstack), «calificador», «con-kit», y las mayúsculas. En el banco del juez (8 fugas, 8 pedidos normales) la base
  pasó de 4 fugas sin detectar a 0. Siguen marcados 2 pedidos normales («diseña un experimento», «candidatos a
  vacantes»): es léxico y quien arma la comparación decide. Ese banco sirvió para ajustar, así que no es una
  prueba independiente; la independiente es la calibración de arriba, repetida.
- **Apunte en el RUNBOOK** (de la solución C), sin su lista propia: remite a la skill para no tener dos versiones.

## Verificación

- `bash scripts/cegar.sh autotest` → «todo en verde», 34 casos, sin red; `verificar.sh` lo corre solo. Tras los
  injertos, cada mutación nueva lo pone en rojo: quitar `-I`, aceptar un enlace, saltar un binario en silencio. Quitar
  solo el patrón «elegiremos la mejor» no lo pone en rojo porque «la mejor entrega» atrapa la misma línea.
- Rompiendo el script a propósito, el autotest falla en cada caso: sin el patrón de «pruebas ocultas»; sin revisar la
  ruta; ruta inexistente tratada como limpia; mapa escrito dentro de lo que ve el juez; sin buscar al autor en las
  copias; copiando `.git`; `etiquetar` sin devolver 1 ante fugas; sin barajar; buscando al autor sin límite de palabra.
- Las líneas nuevas de `kit-orquestacion` no marcan señales de `muletillas.sh`.

## Riesgos

- La evidencia de la arena es de otro proyecto y de 2 tareas que discriminan: indicio de dirección, no medida de
  cuánto. Si en Claude Code, con una sola familia, tres intentos se equivocan igual, la arena no rinde; el párrafo lo
  acota a donde un intento puede fallar.
- `cegar.sh` es léxico: un encargo que delata la medición con otras palabras pasa limpio. Marca candidatos; quien
  arma la comparación decide.
- El cegado se mide aquí como validez del instrumento, no como cambio de resultado: no hay dato de que la fuga de
  las rondas 1 y 2 haya movido las calificaciones.

## Para el council

1. ¿Entra el párrafo de la arena en `kit-orquestacion`, sostenido en una medición de otro proyecto con 2 tareas que
   discriminan, o espera una corrida de arena hecha desde Claude Code?
2. ¿Entra la viñeta de cegado con `cegar.sh`, con 6 de 6 fugas atrapadas y 0 falsos positivos en 57 pedidos?
3. ¿Se acepta cerrar (6) y (7) como «ya cubierto» con los conteos de arriba, sin propuesta al núcleo?
4. ¿Se avisa a pi-harness que sus carpetas `arena-<n>` delatan la medición al candidato?
