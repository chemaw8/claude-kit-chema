# Changelog — Kit Chema

## v1.19.3 — 2026-09-08
Cosecha del paper de Prime Agent (arXiv 2608.23552), evaluado el mismo día desde un reel que lo
vendía como hito de AGI; el harness se **rechazó** y de ahí salió la evidencia. Council de 3 lentes
(exactitud factual, encaje, abogado del diablo) + síntesis: **aprobada con cambios**, todos
aplicados; acta en `docs/pruebas/council-v1.19.3.md` (9 hallazgos sobre el borrador y 5 más
que introdujeron las propias correcciones). Sin gate de disparo: solo tocan documentación y cuerpo de skill (GOBERNANZA §4).
No es solo evidencia citada — trae una **autoevaluación de gobernanza con dos huecos declarados**.
- **`GOBERNANZA.md`, "Mejora del kit por corrección": el caso RCON.** Un harness con auto-mejora
  en línea descubrió que unos comandos RCON creaban recursos de la nada, usó el atajo **pese a un
  heartbeat anti-trampas** y después **lo guardó como skill reutilizable**. Reward hacking
  persistido en estado durable. Es la evidencia empírica de por qué la mejora del kit por
  corrección no se auto-aplica.
- **Y la autoevaluación que salió del council, que es lo que de verdad cambia algo.** Contra las
  tres condiciones que el paper concluye que hacen falta, el kit **cumple una, tiene otra a medias
  y le falta la tercera**: rollback auditable sí; validación independiente a medias (el council es
  un panel del mismo modelo juzgando lo que escribió el mismo modelo, y `main` va con
  "Aprobaciones requeridas: 0"); mínimo privilegio no. Los dos huecos quedan escritos, no dados
  por resueltos, y el de mínimo privilegio entra a **Diferido**.
- **`kit-orquestacion`: la forma observada de un reparto grande.** 633 subagentes de profundidad
  uno en 149 oleadas, máximo siete concurrentes, en una corrida de siete días. El árbol salió
  plano **aunque ese harness sí permite recursión**. Lectura del kit sobre una sola corrida: si el
  diseño necesita que los subagentes lancen subagentes, sospechar del reparto. Y se cierra por los
  dos lados la frontera entre **agrupar** (piezas que comparten material) y **hacer oleadas**
  (piezas independientes contra el tope de concurrencia), que antes se contradecían.
- Núcleo **intacto en 133/150**: la evidencia no entra al archivo que se carga en cada sesión.


## v1.19.2 — 2026-09-08
Viene de un council de 4 lentes sobre el entorno del mantenedor (aprobada con cambios; acta en
`docs/pruebas/council-v1.19.2.md`). Qué paga: en una semana medida, la gran mayoría de los tokens
se iban al modelo más caro sin que ninguna regla lo frenara, y el escalón Fable de la escalera
no tenía ningún agente asignado.
- **Núcleo (+4 líneas, 133/150): esfuerzo antes que modelo.** Antes de subir de Opus 5 a Fable,
  sube `--effort` en Opus 5. **Medido antes de fusionar** (cierra el aviso del council que pedía
  evidencia de que Opus 5 a `--effort max` se queda corto): sobre una batería propia de casos con
  juez fijo, **no se detectó diferencia de calidad** entre los escalones (la batería está saturada:
  eso no prueba igualdad, pero sí que no hay evidencia para subir de modelo por calidad), el
  esfuerzo salió más barato por corrida que el salto de modelo, y Fable 5.1 salió **más rápido**.
  Con una salvedad que el documento carga: el único caso donde los brazos divergieron quedó fuera
  del conteo, y en él Fable 5.1 respondió dentro del mensaje y Opus 5 no —diferencia de
  comportamiento, con re-juicio pendiente—, así que la lectura "no se detectó diferencia" se toma
  con eso encima, y con que en los casos limpios esa lectura de calidad se sostiene en 2 casos,
  no en 4. De ahí la
  excepción que la regla lleva escrita: cuando manda la latencia y no el costo, salta de modelo.
  Resultados relativos y método en `docs/pruebas/medicion-esfuerzo-v1.19.2.md`.
- **kit-propuestas:** en el protocolo de council, la síntesis del veredicto deja de hacerla el hilo
  principal y la hace el agente `sintetizador`, al que hay que pasarle la postura inicial del hilo
  (el veredicto debe decir si los evaluadores le hicieron cambiar de opinión). Si el agente no está
  disponible, sintetiza el hilo principal. Es el único flujo para el que el agente existe y antes
  no lo invocaba.
- **kit-orquestacion:** la alternativa barata al fan-out es "esfuerzo primero, modelo después", y
  cada etapa de una corrida declara su modelo y su esfuerzo (pendiente desde la decisión del
  2026-08-29 que nunca se ejecutó).
- **Agentes:** nace `sintetizador` (Fable, solo lectura): integra veredictos de council o reportes
  de varios agentes en un juicio final, verificando hallazgos antes de heredarlos. Era lo que el
  núcleo mandaba ("Fable solo para síntesis y juicio") y ningún agente cumplía. `lector-fresco`
  **se queda en Opus 5**: subirlo a Fable sin haber probado Opus a `--effort max` habría violado la
  regla que este mismo cambio introduce (lo señaló el revisor del gate).

## v1.19.1 — 2026-09-07
Cierra el PR #12 (borrador desde 2026-07-21) en versión corta, con council de 3 lentes
(aprobada con cambios, todos aplicados; acta en `docs/pruebas/council-pr12.md`).
- **kit-propuestas: "Acercamiento personalizado a un contacto"** (3 pasos, 18 líneas de texto): confirmar
  la identidad del contacto antes de personalizar (con salida cuando no hay resultados o no hay
  buscador), personalizar como capa encima del kit que toque solo con información profesional y
  pública, y confirmar el texto final con el usuario antes de que salga a un tercero; un mensaje
  de acercamiento no dispara Council por sí solo. Antipatrón "acercamiento a ciegas".
- **Disparo en ambos lados de la frontera:** la description de kit-propuestas gana la frase
  `"escríbele a fulano de X"` y la de kit-redaccion remite a kit-propuestas cuando el correo es
  a un contacto de otra empresa para vender o proponer. Qué paga: +133 y +107 caracteres de
  description (971 y 898; la suma del kit queda en 5,414 de 6,000).
- **Gate de disparo corrido y documentado:** `docs/pruebas/disparo.py` (juez Sonnet, contexto
  fresco) → 21/21 del núcleo y cero confusiones en las fronteras, con tres fronteras nuevas en
  el banco (28-30: acercamiento a un contacto ↔ correo ↔ estatus interno). El instalador lee
  versiones de tres componentes (`v1.19.1`) para no colisionar con la v1.20 del gate de push.

## v1.19 — 2026-09-06
Fase 1 del programa de mejora del entorno (cosecha del setup de Kun Chen,
2026-09-06; ninguna herramienta suya instalada, solo el diseño). Council de 3
lentes: aprobada con cambios, todos aplicados (`docs/pruebas/council-v1.19.md`).
- **Hook `backstop-cierre.sh`** (`Stop`), **opt-in** (`KIT_BACKSTOP=s`): si en la
  sesión hubo trabajo real en el proyecto (≥3 escrituras fuera del papeleo o ≥1
  commit) después de la última actualización de `CONTINUAR.md` y `reconciliar` dice
  rancio, bloquea el fin de turno una vez citando el motivo del helper; se re-arma
  si se cierra y se sigue trabajando; fail-open. 25 casos de prueba, dos con el
  helper real; medido: 0.1-0.4 s en transcripts de 40-146 MB. Entra opt-in porque no
  cumple la puerta de v1.18 para hooks por defecto (no cerrar es indisciplina, costo
  medio); pasa a por defecto si dos reportes semanales muestran menos rancios sin
  falsos positivos. Idea: backstop de fin de turno de firstmate.
- **`rotar-continuar.sh reconciliar` devuelve 3** cuando NO puede reconciliar (sin
  ancla, ancla fuera del historial), en vez de 1 como "rancio": 13 de 32 CONTINUAR
  de una instalación real no tienen ancla y habrían bloqueado en falso. Quien use el
  código como booleano no cambia.
- **GOBERNANZA: "toda adición al núcleo nombra qué paga"** — núcleo (129/150 hoy) y
  descriptions son presupuesto; cada PR que agrega declara qué sale o qué margen lo
  absorbe; a <10 líneas del tope, la adición exige remoción. Solo adiciones; cubre
  lo que mide `verificar.sh`. Idea: presupuesto de memoria de backpass.
- **kit-codigo: "destructivo = simulacro por defecto"** — `--dry-run` salvo flag
  explícito, clases de riesgo en flags separados en vez de `--force`, fallo cerrado.
  Estándar hacia adelante (hoy ningún script del kit lo cumple del todo). Idea:
  treehouse/gnhf.

## v1.18 — 2026-09-06
**Hook `rutas-fantasma.sh`** (`PreToolUse` sobre `Read|Write|Edit`), instalado
por defecto: bloquea lecturas y escrituras a rutas de otro entorno que el modelo
a veces alucina en la máquina del usuario —`/home/user`, `/mnt/user-data`,
`/repo`, típicas del sandbox de claude.ai— y el `Read` de `/` (siempre EISDIR),
devolviendo al modelo el cwd real. Solo actúa si el prefijo no existe en disco,
así no puede estorbar una lectura legítima; sin python3 o con JSON ilegible deja
pasar; prefiltro en bash para que el camino común no arranque python (~3 ms).
Prefijos configurables con `RUTAS_FANTASMA` (lo usa la prueba). Se apaga con
`KIT_RUTAS_FANTASMA=n ./instalar.sh` tras quitar su entrada de `settings.json`;
revertir el PR no desinstala nada de las máquinas (no hay desinstalador).

Evidencia, la que el congelamiento del 2026-08-29 exige (fallo recurrente en el
reporte semanal de salud): en una instalación real, 46 de 148 errores de tool en
5 días (31%) fueron `Read` a esas rutas, tras 17 la semana anterior; ninguna
regla en prosa aplica porque no es indisciplina sino una alucinación de entorno.
Prueba `hooks/test-rutas-fantasma.sh` (14 casos, independiente de la máquina;
`verificar.sh` la corre) y bloqueo comprobado en vivo el 2026-09-05.

Qué se espera medir después (el hook no evita que el modelo emita la ruta, mejora
el error que recibe): que los reintentos al mismo destino dentro de una sesión
caigan a uno y que "File does not exist" a esas rutas caiga a cero; el bloqueo se
cuenta aparte en el reporte de salud. Council de 3 lentes: aprobada con cambios,
todos aplicados (`docs/pruebas/council-v1.18.md`).

También: `fusionar_hooks` de `instalar.sh` admite `SOLO_CMD` para fusionar una
sola entrada de un evento (antes, aceptar un hook de `PreToolUse` arrastraba a
todos los del fragmento); `verificar.sh` corre la prueba de todo hook que traiga
`hooks/test-<nombre>.sh` y comprueba que `hooks.json` y `settings-fragment.json`
declaren los mismos hooks.

## v1.17 — 2026-09-01
**El estándar de estructura de proyectos entra al núcleo** (etapa 2 del
council del 2026-08-31): sección "Estructura de proyectos", 7 líneas — el
disparo universal que la etapa 1 dejó pendiente a propósito.

Entra con la evidencia que el congelamiento exige (DECISIONES 2026-08-31):
- **Piloto real**: sql-natural v1 construida con el flujo spec → clarificación
  → plan → tasks → validación; 18/18 preguntas verificadas contra sus fuentes
  originales y 5 trampas de datos cazadas por el proceso.
- **Sonda conductual 7/7**: sesiones frescas en entorno de colega (solo núcleo
  + skills): abre spec en features multi-sesión con lógica de negocio, cero
  ceremonia en fixes y scripts de un uso, pregunta ante tamaño ambiguo
  ("el kit obliga a preguntarte, no a decidir en silencio") y cede a
  writing-plans en el refactor intra-sesión.
- **Gate de disparo como regresión** (resultado en el PR; las descriptions no
  cambian, así que el gate mide no-regresión del ruteo, no la regla nueva —
  esa la mide la sonda, como dictó el council).

## v1.16 — 2026-08-31
**Estándar de estructura de proyectos** dentro de kit-codigo:
`estandar-proyectos.md` (árbol + capa `specs/NNN-nombre/` por feature, flujo
spec → clarificación → plan → tareas → validación → cambio) y 3 plantillas
(`plantillas/`), más la regla de escalado en la sección de compatibilidad
(precedencia clara con brainstorming→writing-plans de superpowers) y el umbral
en /proyecto-init (proyecto muy chico → se pregunta, no se impone).

Adopción parcial de Spec-Driven Development (curso hello-sdd de MoureDev);
fuera EARS obligatorio y spec-as-source. **Council de 5** (viabilidad ·
costo/beneficio · riesgos · abogado del diablo · gobernanza): **aprobada con
cambios**. Los cambios que el panel impuso y aquí se cumplen: vivir dentro de
la skill (el instalador no copia `docs/`), precedencia explícita con
superpowers, disparo como escalado con exclusiones (fix de una línea y script
de un uso siguen con plan corto), y el núcleo en espera del piloto — ver
DECISIONES.md del kit.

## v1.15 — 2026-08-28
Novena skill: **`kit-orquestacion`** — playbook para repartir un trabajo entre
varios agentes en paralelo (barridos, auditorías, investigación multi-ángulo,
corridas "ultracode").

Sale de un barrido de vanguardia de 13 agentes sobre orquestación multi-agente
(investigación en `~/Trabajo/investigacion/2026-08-28-vanguardia-para-ultracode.md`).
El hueco que cierra: el kit tenía escalera de modelos y regla de "cuándo delegar",
pero **ninguna regla de topología** — cómo se reparte, quién escribe, cómo se
verifica.

**Council de 4** (skill-vs-núcleo · disparo · corrección del contenido · abogado del
diablo): **aprobada con cambios, unánime**. El abogado del diablo reportó que su
mejor ataque —"es una copia peor de la guía de workflows del harness"— **no se
sostiene**: solapa una sección de seis, y lo que no solapa cambia conducta.

Qué entra:
- **Un solo escritor**: el fan-out solo lee, mide, verifica y critica; el entregable
  lo redacta un hilo, después. Es donde convergieron los dos polos del debate
  2025-26 sobre multi-agente.
- **Escalera de topología** (0 / 1 / 2-4 / 3-5 / 5+ agentes) con la alternativa
  barata declarada: subir esfuerzo en un hilo en vez de repartir.
- **Tres preguntas antes de lanzar** (objetivo y formato · qué contexto le falta ·
  quién verifica): cubren las tres familias de fallo medidas en estos sistemas.
- **Cómo se verifica**: verificador con contexto limpio, lentes distintos en vez de
  copias, adversarial solo donde hay verdad comprobable.
- **Lo que no se hace**: rondas de debate entre agentes, volcar datos crudos al
  contexto, escritura en paralelo sobre lo mismo, personajes decorativos.
- **Confidencialidad en corrida**: el agente que toca material externo no lleva
  acceso al vault, al correo ni a publicación — nadie ve el paso intermedio en un
  fan-out. Regla que no existía en ninguna parte del kit.

Correcciones del council incorporadas:
- **La cifra del sobrecosto estaba mal anclada** (3 de 4 evaluadores). El ~15× que
  se cita mide multi-agente contra una *conversación sin herramientas*; un hilo
  agéntico ya gasta ~4× de esa base, así que el sobrecosto real de repartir es del
  orden de **4×**, no 15×. Inflado sesgaba en contra de repartir justo en la skill
  que enseña a repartir bien.
- **Faltaba la cadena por pieza sin esperas**: el texto solo describía la barrera
  (esperar a que todas las piezas terminen una etapa), que es el patrón lento y no
  el default de la herramienta.
- **La skill legislaba sobre `kit-propuestas`**: la regla de no meterle rondas de
  deliberación al Council se movió a los errores típicos de esa skill, donde vive.
- **`kit-orquestacion` no estaba en la tabla de ruteo del núcleo** (8 filas para 9
  skills). Añadida.
- **La description hablaba en vocabulario de mecanismo** ("en paralelo", "reparte")
  y el usuario pide en vocabulario de alcance ("revisa los 24 proyectos", "los 171
  hallazgos"). Añadidos gatillos de alcance y de volumen.
- **Cláusula de convivencia**: compone con la skill del dominio, no la reemplaza —
  kit-research pone el estándar de fuentes, ésta solo el reparto.
- **Cesión al harness**: cuando el usuario ya pidió una corrida grande, el
  presupuesto lo fijó él; la skill decide la forma del reparto, no si se gasta.

## v1.14 — 2026-08-27
Arreglos de una auditoría adversarial (13 agentes, ultracode) del sistema de
fichas/CONTINUAR. Ningún dato real se perdió —los 7 cierres se re-verificaron por
ocurrencias— pero el audit destapó garantías más débiles de lo declarado.

Correcciones del helper `rotar-continuar.sh`:
- **`rotar` ya no deduplica.** Una línea idéntica bajo padres distintos (hijos de
  listas anidadas, un ítem citado en dos secciones) es información distinta; la
  dedup por texto la colapsaba y perdía ocurrencias en silencio, justo en la pieza
  que garantiza cero pérdida. Ahora se archivan todas.
- **La verificación de cero pérdida era tautológica** (no podía fallar). Ahora
  relee del disco y compara por multiconjunto de ocurrencias; si detecta pérdida,
  revierte y aborta. El spec ya prometía este diff independiente.
- `reconciliar` sin-git aplica la misma lista blanca de "papeleo" que la ruta con
  git; y esa lista incluye ahora `.claude/settings.json` y `.gitignore` (evita el
  falso rancio tras un `/proyecto-init` de libro).
- `contrato` valida "Cómo retomar" por campo, no por línea: una URL o un glob ya no
  fallan en falso ni apagan la validación de un archivo real citado al lado, y un
  `?` de la prosa ya no desactiva la línea.
- La rama "sin estado previo" ya no deja el borrador huérfano (cero residuos).

Comandos y núcleo:
- **`reconciliar` se dispara AL REANUDAR**, no solo al cerrar: el núcleo y la
  plantilla de ficha instruyen correrlo al retomar. El criterio de éxito del spec
  (un estado rancio se delata solo al reanudar) ahora se cumple.
- `cierre.md`: fija la coreografía de commit (trabajo real → anclar → papeleo) y
  corrige la semántica de "rancio" (es normal al abrir /cierre, no una acusación al
  cierre anterior).
- `proyecto-init.md`: todo CONTINUAR existente pasa SIEMPRE por `rotar`, sin
  importar su tamaño — cierra un hueco de pérdida silenciosa.

Instalador y verificación:
- `instalar.sh`: el dedup de hooks compara por ruta de comando, no por dict
  completo. Antes, una entrada que ganaba un `statusMessage` se re-agregaba en cada
  reinstalación → el hook de contexto quedaba DUPLICADO (contexto 2× por sesión).
- `verificar.sh`: el check de skills muertas caza cualquier token `kit-*` citado
  (backticks, paréntesis), no solo el fraseo literal `skill kit-x`.

Un hallazgo se REFUTÓ (la puerta de /proyecto-init "clasifica el repo, no el
comando"): los repos reales citados sí disparan las señales; queda como
endurecimiento opcional, no como falla.

## v1.13 — 2026-08-26
Comandos `/proyecto-init` y `/cierre` — las fichas de proyecto pasan de método
manual a comando, con un contrato de reanudación que sobrevive a que la sesión
muera.

Sale de la pregunta de José al aprobar el diseño: *"cuando cierro, ¿cómo lo
continúo si es que se necesita continuar?"*. El spec anterior de fichas definía
cómo se **recorta** `CONTINUAR.md` (tope de 40 líneas) pero no qué debe
**garantizar** para poder reanudar. Un tope de líneas es una regla de tamaño; le
faltaba la de contenido.

**Council de 4 evaluadores** (modos de falla · viabilidad de flujo · abogado del
diablo · contrato de reanudación): **aprobada con cambios, unánime**. Diseño en
`docs/superpowers/specs/2026-08-26-comandos-ficha-design.md`.

El hallazgo que cambió el diseño (3 de 4 lentes, por separado): atar la
reanudación a que `/cierre` corra es un punto único de falla — la sesión que muere
por crash, cierre de terminal o agotamiento de contexto nunca cierra, y es
justo el caso donde más se necesita el estado.

Qué entra:
- **`/cierre`**: reconstruye el estado desde artefactos durables (git diff,
  archivos tocados) y no desde la memoria de la sesión, que pudo compactarse;
  escribe `CONTINUAR.md` con el contrato mínimo; archiva el detalle en
  `docs/bitacora.md`. Es **silencioso en los no-ops**: solo toca ficha,
  `DECISIONES.md` o vault si de verdad cambiaron.
- **`/proyecto-init`**: genera la ficha con comandos **verificados corriéndolos**,
  propone permisos sin aplicarlos, y trae una **puerta de seguridad** — en repos
  con NDA, PCI, pentest o BD de producción lista los comandos y pide confirmación
  en vez de ejecutar a ciegas.
- **`scripts/rotar-continuar.sh`**: helper determinista compartido por ambos
  comandos. `rotar` garantiza y **verifica línea por línea** que nada se pierde
  (aborta sin tocar nada si algo se perdería); `anclar` estampa fecha + commit;
  `reconciliar` detecta el estado rancio; `contrato` valida los campos blindados;
  `autotest` se prueba solo y lo corre `verificar.sh`.
- **Contrato de reanudación** en `CONTINUAR.md`: dónde vamos · siguiente paso
  ejecutable · cómo retomar · bloqueadores · (frentes abiertos) · última decisión,
  con fecha y ancla de git en el encabezado. El tope de 40 líneas se vuelve
  **blando**: recorta por prioridad, nunca ampute el contrato.
- **Regla que mata la causa raíz del drift**: `CONTINUAR.md` no repite hechos
  estables (repo, remoto, stack) — esos viven en `CLAUDE.md`. Una ficha llegó a
  decir "sin remoto" cuando ya tenía remoto: ese dato envejeció porque vivía donde
  no debía.

Arreglos:
- **`instalar.sh` no instalaba `commands/` ni `scripts/`.** Mismo fallo que el
  council v1.11 encontró con `agents/` (H-1): el kit publicaba `/revisar-salud` e
  `/init-contexto` y nunca llegaban a `~/.claude`. Ahora se instalan, y
  `verificar.sh` lo comprueba para que no vuelva a pasar sin que nadie lo note.
- **Referencia muerta**: `/revisar-salud` invocaba la skill `kit-sugerencias`, que
  el council de v1.12 eliminó al fundirla en el núcleo. `verificar.sh` ahora falla
  si un comando menciona una skill inexistente.

Nota de protocolo: la síntesis del council se hizo con el modelo de sesión
(Opus 4.8) y no con Fable 5 como pide `kit-propuestas`. Los 4 reportes
convergieron sin contradicciones y los hallazgos se verificaron uno a uno, pero
queda anotado.

## v1.12 — 2026-08-24
Mejora de la regla "Arranque de tarea" del núcleo + comando `/revisar-salud`.

Sale de un pedido de José ("algo similar a superpowers para elegir mediante
sugerencias ante poca info"). Se propuso primero como una novena skill
(`kit-sugerencias`); el **council la rechazó como skill por unanimidad (4/4,
aprobada con cambios)** y la reubicó en el núcleo. Registro en
`docs/pruebas/council-v1.12.md`.

Por qué núcleo y no skill (convergencia de los 4 lentes): es una **disposición
transversal** (aplica a cualquier dominio ante ambigüedad), no un playbook de
dominio. El kit ya pone lo transversal en el núcleo ("Arranque de tarea",
"Evaluación crítica"). Como skill sería a la vez más cara (590 chars siempre en
el listado) y menos fiable (solo dispara si el dispatcher la elige — y en el caso
que más importa, la petición vaga sin "dame opciones", no dispararía). El delta
real sobre lo ya existente era una cláusula; el resto duplicaba kit-propuestas
(opciones/costos/recomendación) y la propia regla de arranque.

Qué entra:
- **Núcleo "Arranque de tarea"**: ante info faltante, primero cerrar la ambigüedad
  con lo que se pueda reunir (archivos, contexto, memoria, la conversación); sobre
  lo que quede abierto con varios caminos materiales, **ofrecer 2-4 opciones con
  costo y recomendación en vez de preguntar en abstracto o adivinar**; pregunta
  abierta solo si ni eso se puede proponer. Incorpora los dos hallazgos del
  council: "investigar antes de ofrecer" (riesgos) y "opciones curadas, no
  formulario en blanco" (el delta genuino).
- **kit-propuestas**: description aclarada — "¿X o Y?" **con consecuencias reales**
  (caro/irreversible) es propuestas; la elección ligera la resuelve el núcleo.
  Cierra la colisión de disparo asimétrica que señaló el lente de diseño.
- **Comando `/revisar-salud`** (`commands/`): flujo de revisión-y-corrección de la
  observabilidad — lee el reporte más reciente, reporta tendencia, separa errores
  arreglables de ruido externo y propone arreglos para aprobar.

Sin skill nueva → sin gate de disparo, sin costo permanente de listado. Núcleo
81→~90 líneas (< 150). verificar.sh exit 0.

## v1.11 — 2026-08-23
Primera versión que añade **mecanismo** en vez de afinar prosa. Sale de la
investigación `investigacion/2026-08-22-context-engineering-attention-rag.md`,
que contrasta el estado del arte 2026 (Anthropic, Chroma, arXiv 2608.11888,
Microsoft SkillOpt) contra la medición real del setup: 35,692 tokens de arranque
por sesión y, sobre 1,487 transcripts de seis semanas, 444 delegaciones al agente
genérico y cero a los nueve agentes especializados que ya se pagaban.

**Council de cuatro evaluadores (viabilidad técnica, costo/beneficio, riesgos,
abogado del diablo): aprobada con cambios, por unanimidad.** Registro en
`docs/pruebas/council-v1.11.md`. Los cuatro cambios exigidos ya están aplicados
y verificados; tres de los cuatro evaluadores señalaron el mismo bloqueante.

Qué entra:

1. **Tres subagentes en `agents/`** — `verificador` (Sonnet, `tools: Read, Grep,
   Glob, Bash`), `evaluador-council` (Opus 5) y `lector-fresco` (Opus 5,
   `tools: Read, Grep, Glob`). La escalera de modelos existía en el núcleo desde
   v1.0 pero `~/.claude/agents/` estaba vacío: era una regla sin nada que la
   aplicara. `lector-fresco` es cosecha, no invención: ya funcionó a mano el
   2026-08-19 en el QA de un deck y forzó tres correcciones.
2. **Regla "Presupuesto de contexto" en el núcleo** — la omisión más notable del
   kit dado el cuerpo de evidencia sobre context rot (18 modelos evaluados por
   Chroma; en LongMemEval un prompt enfocado de ~300 tokens supera a uno completo
   de ~113k). Incluye la cláusula que pidió el council: el presupuesto aplica a
   lo que se lee para redactar, no a lo que se mide — conteos, nulos y rangos
   salen del archivo completo, nunca de una muestra.
3. **La sección de subagentes ahora dice cuándo, no solo con qué modelo** — y
   con la cláusula "el tamaño no manda sobre el riesgo": lo que va a dirección o
   a un cliente se verifica aunque el cambio sea de una línea.
4. **El instalador y el linter ahora cubren `agents/`** — `instalar.sh` crea e
   instala `~/.claude/agents/` copiando archivo por archivo (nunca `rm -rf` del
   directorio, para no pisar agentes propios del usuario; probado en sandbox), y
   `verificar.sh` gana 15 comprobaciones: que cada agente prometido por el núcleo
   exista, que `name` coincida con el archivo, que `model` sea válido, que la
   `description` esté bajo 1024 caracteres, y que el instalador siga instalándolos.

Y dos recortes:

- La sección "Contexto" del núcleo mandaba leer `~/.claude/contexto/`, cosa que
  el hook de SessionStart ya hace desde v1.4. Era letra muerta que inducía
  relecturas.
- Se quitó del núcleo la cifra "15×" de sobrecosto por delegar. Dos evaluadores
  independientes la marcaron como cita mal aplicada: la medición de Anthropic es
  de sistemas multi-agente frente a chat, no de una delegación frente a hacerlo
  en línea, donde el orden real es 2–4×. Puesta como hecho general habría
  suprimido delegaciones que sí valen, incluidas las tres que esta versión
  introduce. La regla queda con el criterio y sin el número.

**Correcciones de cifras propias que encontró el council** (importan en un kit
cuyo lema es "terminado significa verificado"):

- El crecimiento del núcleo que se reportó primero (+19%) comparaba el archivo
  instalado de antes —que trae tres líneas de marcadores— contra el archivo crudo
  de después. Crudo contra crudo, y ya con las cláusulas que exigió el council,
  el número final es **505 → 728 palabras: +44%**.
- El "linter en verde" que se citó como respaldo **no cubría nada de lo nuevo**:
  `verificar.sh` solo iteraba `skills/*/SKILL.md` y el único chequeo del núcleo
  era el de <150 líneas. Ese hueco es justo lo que arregla el punto 4.

**Condición de retiro (la misma vara que se le exige a las demás propuestas):**
a las cuatro semanas del merge se cuentan las invocaciones de los tres agentes.
El que esté en cero se borra y su regla se queda. Sin métrica no entra mecanismo.

**Candidato a recorte que NO se aplicó:** la tabla "Playbooks por dominio" (12
líneas) duplica lo que ya declaran las descriptions de las 8 skills, y repetir
instrucciones en ambos lugares está marcado como deprecado para la generación
Claude 5. No se toca sin correr antes el gate de disparo de 21 peticiones: el
20/21 de v1.0 pudo depender de esa tabla.

**Sobre el tamaño, sin adornos:** el núcleo pasa de 81 a 107 líneas y de 505 a
728 palabras (+44%). El argumento que se usó al proponer esta versión —"527
palabras, casi las 514 a las que llegó Anthropic tras recortar su system
prompt"— **ya no se sostiene**: 728 queda 42% por encima de esa referencia y no
se puede invocar la coincidencia como aval y luego pasarla de largo. Lo que
defiende el crecimiento es otra cosa: son heurísticas permisivas y cláusulas de
seguridad que el council exigió, no reglas rígidas —que es lo que Anthropic
diagnosticó como sobre-restricción—. Aun así el saldo queda pendiente de
compensar con el recorte de la tabla "Playbooks", y quien decida el merge debe
saber que entra con esa deuda.

`verificar.sh` exit 0 con las 15 comprobaciones nuevas. Plugin y marketplace a
1.11.0.

## v1.10 — 2026-07-25
Actualización de la escalera de modelos: **Opus 4.8 → Opus 5** en el escalón de
trabajo pesado intermedio (núcleo "Modelos para subagentes" y evaluadores de
council en kit-propuestas). Opus 5 es el sucesor de Opus 4.8 en ese mismo
escalón —mismo precio ($5/$25 por 1M), un step-change en capacidad de
razonamiento/agentic/código—; Fable 5 sigue siendo la cima reservada a la
síntesis final y el juicio crítico. Cambio de nombre factual, no de lógica: la
escalera queda Haiku → Sonnet → Opus 5 → Fable 5. Sin cambios de description ni
de disparo (no requiere gate). Los registros históricos de councils en
`docs/pruebas/` conservan "Opus 4.8" porque esos paneles sí corrieron en ese
modelo. Plugin a 1.10.0.

## v1.9 — 2026-07-15
Mejora por uso (council en `docs/pruebas/council-v1.9.md`): se añade la plantilla
`contexto/BASE-CONOCIMIENTO.md`, el tercer archivo de contexto que el hook
`kit-chema-contexto.sh` ya esperaba pero que el kit no traía —el instalador solo
copiaba EMPRESA y PERSONAL, así que una base de conocimiento (p.ej. un vault por
el MCP basic-memory) quedaba "dormida" sin señal para el usuario. La plantilla es
genérica y fill-in, al estilo de `CONTEXTO-PERSONAL` (regla de oro por línea,
límite de 40-60 líneas), con basic-memory/vault como ejemplo y no como requisito.
Cambio aditivo, no destructivo (respeta archivos existentes) y reversible. Council
a favor por unanimidad (viabilidad, riesgos, abogado del diablo); único ajuste:
alinear el estilo con las otras dos plantillas. Plugin a 1.9.0.

## v1.8 — 2026-07-11
Cosecha de cuerpos contra otros autores (comparativa en
`investigacion/2026-07-10-skills-comparativa-cuerpos.md`; council de veto en
`docs/pruebas/council-v1.8.md`): de 15 candidatas entran 14 —2 fusionadas en
texto existente— y se corta 1 por redundancia. Adiciones de 1-2 líneas a cuerpos,
cero cambios de description (sin gate). Lo más valioso: dos correcciones —el
formato Estatus gana su esqueleto en kit-redaccion (era el único formato sin él)
y kit-automatizacion deja de pedir pruebas "con datos verdaderos" que dispararían
el efecto real (correo/cobro)—; mocks que no aprueban, tope de tres intentos de
fix, y diff real del subagente en kit-codigo; lector fresco en el ensayo de
kit-presentaciones; verificación de hallazgos de evaluador antes de heredarlos
al veredicto en kit-propuestas; vigencia de fuentes en kit-research; grano del
dato y ruido-vs-señal en kit-analisis-datos; validación de entrada externa y
fórmulas vivas en kit-finanzas; heartbeat de última corrida en
kit-automatizacion. GOBERNANZA gana la regla "Rondas de cosecha" (tope
prospectivo de 2 adiciones netas por skill por ronda). Plugin a 1.8.0.

## v1.7 — 2026-07-10
Ajustes del council de "arquitectura de skills" (registro en
`docs/pruebas/council-v1.7.md`; investigación con fuentes en
`investigacion/2026-07-10-skills-*.md`). De cinco ítems propuestos, el council
desagregó: (1) el oficio de crear skills queda como sección "Crear una skill
nueva" de GOBERNANZA — la meta-skill kit-crea-skills se difiere con detonante
explícito (que exista un segundo autor del kit); (2) el INSTRUCTIVO corrige la
vía de claude.ai: documentaba el método degradado (pegar archivos a mano) cuando
existe la subida real de skills con disparo automático (Settings → Capabilities
→ zip), y ahora enlaza la doc oficial en vez de reproducir su click-path; (3)
`verificar.sh` reporta siempre la suma de caracteres de las descriptions y avisa
—sin bloquear— si rebasa 6,000 (higiene del footprint propio; el presupuesto
real del listado es global, ~16k sobre todas las skills instaladas, y un linter
de repo no puede verlo); (4) las 8 skills declaran `license: MIT` en su
frontmatter (metadato del estándar abierto agentskills.io; campos extra
verificados inofensivos en vivo) y el linter ahora lo exige; (5) el juez Haiku
se rechazó como gate (mediría un lector más débil que el router real y empujaría
a engordar descriptions) y queda solo como sonda opcional no bloqueante en el
RUNBOOK. Plugin a 1.7.0.

## v1.6 — 2026-07-10
Lote de mejoras cosechadas de la comparativa con ECC y vetadas por council, todas
como adiciones de 1-2 líneas a cuerpos y checklists de skills (ninguna description
ni el núcleo se tocaron): silent-failure en kit-codigo (ningún catch/except vacío)
y test RED que falla por la razón correcta; en kit-propuestas, evaluador que
recibe solo propuesta+mandato sin el hilo completo, y postura previa del hilo
principal fijada antes de leer reportes; coherencia de cifras entre documentos de
una misma decisión (kit-presentaciones); estado real del correo declarado con
lenguaje preciso (kit-redaccion); paneles de dashboard accionables (kit-analisis-
datos); paso 0 de research que revisa primero el material ya aportado; y ciclo de
vida de la automatización (revisión periódica de que sigue viva y con dueño).
Eval-harness formalizado: banco canónico (`docs/pruebas/banco/disparo.md`),
`docs/pruebas/RUNBOOK.md` (juez Sonnet esfuerzo bajo, contexto fresco, criterio
≥ 19/21 + cero confusiones de frontera) y disparador del gate en `GOBERNANZA.md`.
Se descartó por bloat lo pesado de ECC: tablas de evidencia de TDD, roles fijos de
council, ADR en carpeta, plantillas de reporte y dependencias de MCP.

Operación (mismo día, seguimiento a v1.6): se activó la **branch protection** en
`main` —PR obligatorio, los dos checks de CI en verde, rama al día, aplica a
administradores, sin force-push ni borrado; documentada en `GOBERNANZA.md`— y se
sincronizó el manifiesto del plugin (`.claude-plugin/plugin.json`) a **1.6.0**,
que había quedado en 1.5.0 pese a que v1.6 cambió cuerpos de skill que el plugin
empaqueta.

## v1.5 — 2026-07-10
Nueva skill kit-redaccion (comunicación escrita: correos, minutas/actas, memos,
comunicados, documentación y estatus informativo). Aprobada por council con
cambios y validada por un gate de disparo 10/10 sin confusiones de frontera:
"informe" se queda en kit-presentaciones y kit-propuestas reclama ahora los
mensajes que piden aprobar/autorizar (cierre de frontera por ambos lados).

## v1.4 — 2026-07-10
Hook de contexto (`hooks/kit-chema-contexto.sh`, evento `SessionStart`): autocarga
el contenido de `~/.claude/contexto/` (empresa, personal y base de conocimiento)
al abrir cada sesión, para no depender de que Claude recuerde leerlo. Cierra el
hueco de la regla "leer el contexto antes de un trabajo sustantivo". Se instala
por defecto (bajo riesgo, alto valor); el hook anti-secretos sigue opt-in. Envuelve
el texto en JSON con python3 (`json.dumps`), no con `jq`, para no añadir una
dependencia extra y ser consistente con el resto del kit; si falta python3 sale 0
sin romper la sesión (falla segura, solo se pierde la autocarga). Añadido a las dos
vías de instalación: `instalar.sh` (fusiona la entrada `SessionStart` en
`settings.json`) y plugin (`hooks/hooks.json` con `${CLAUDE_PLUGIN_ROOT}`).
Documentado en INSTRUCTIVO (fila del mapa y señal de que funciona).

## v1.3 — 2026-07-09
Licencia MIT (LICENSE + campo license en plugin.json y marketplace.json): el
repo público ya es legalmente reutilizable. Bloque de compatibilidad en
kit-codigo que zanja tres choques reales con superpowers/pr-review-toolkit
cuando están instalados (TDD proporcional vs Ley de Hierro, arranque por
tamaño, carriles de revisión con veredicto homologado). Sin acoplamiento duro:
la sección solo aplica si esos plugins existen.

## v1.2 — 2026-07-09
Plugin híbrido de Claude Code: se empaquetan las 7 skills y el hook anti-secretos
como plugin (`.claude-plugin/plugin.json` + `marketplace.json`, `hooks/hooks.json`,
slash command `/kit-chema:init-contexto`). El núcleo sigue instalándose aparte
como `~/.claude/CLAUDE.md` porque un CLAUDE.md en la raíz de un plugin no se carga
como contexto (doc oficial). La vía `git clone` + `./instalar.sh` sigue viva para
todo. Ambas vías documentadas en README e INSTRUCTIVO.
Salvaguardas anti-degradación: CI (`.github/workflows/ci.yml`) que corre en PR y
en push a ramas != main con dos jobs, límites (`verificar.sh`) y secretos
(gitleaks por binario de versión fija); `CODEOWNERS`; `GOBERNANZA.md` (cambios
solo por PR, CI en verde, revisión de CODEOWNERS, rollback por revert); la
mejora-por-corrección del núcleo entra como PR en borrador revisado por council.
Guía de contexto: límite duro y regla de oro en las plantillas de contexto,
ejemplos de tono así-sí/así-no, y sección "Cómo llenar tu contexto" en
COMO-PEDIR.md.
Bugfix: el YAML frontmatter de `kit-propuestas` se rompía por un `: ` en el
description (la skill cargaba sin metadata); se entrecomilló el valor.

## v1.1 — 2026-07-09
Contexto generalizado: el núcleo ahora lee toda la carpeta `~/.claude/contexto/`
(empresa + nueva plantilla opcional `CONTEXTO-PERSONAL.md` para proyectos y
preferencias personales); el instalador copia cada plantilla solo si no existe.
Anonimizado el nombre de un cliente en los documentos de prueba (repo público).

## v1.0 — 2026-07-09
Primera versión completa. Criterios de aceptación del spec: 8/8 —
con dos notas ratificadas: C.A.2 quedó en 20/21 disparos (el caso frontera
script-de-una-vez→kit-automatizacion es benigno: ese playbook aplica
kit-codigo al construir) y C.A.7 se cumple en forma condicional (paleta del
deck del grupo 2026-07; la marca oficial se aplicará cuando existan activos
en ~/Trabajo/recursos/marca). Pruebas en docs/pruebas/.
Pendiente para v1.1: desinstalar.sh, aviso de drift de versión, vía Windows.

## v0.9 — 2026-07-08
Construcción inicial: núcleo, 7 skills, hooks, instalador, guías.
(v1.0 se declara cuando pasen los 8 criterios de aceptación del spec.)
