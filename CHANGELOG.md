# Changelog — Kit Chema

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
