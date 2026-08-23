# Changelog — Kit Chema

## v1.11 — 2026-08-22 (PENDIENTE DE COUNCIL)
Primera versión que añade **mecanismo** en vez de afinar prosa. Sale de la
investigación `investigacion/2026-08-22-context-engineering-attention-rag.md`,
que contrasta el estado del arte 2026 (Anthropic, Chroma, arXiv 2608.11888,
Microsoft SkillOpt) contra la medición real del setup: 35,692 tokens de arranque
por sesión.

Tres cambios:

1. **Tres subagentes en `agents/`** — `verificador` (Sonnet), `evaluador-council`
   (Opus 5) y `lector-fresco` (Opus 5 sin contexto previo). La escalera de modelos
   existía en el núcleo desde v1.0 pero `~/.claude/agents/` estaba vacío: era una
   regla sin nada que la aplicara. `lector-fresco` formaliza algo que ya funcionó
   a mano (QA del deck de sucursales, 2026-08-19, forzó tres correcciones).
   Costo: ~242 tokens de descriptions siempre cargadas; los cuerpos son diferidos.

2. **Regla "Presupuesto de contexto" en el núcleo** — la omisión más notable del
   kit dado el cuerpo de evidencia sobre context rot (18 modelos evaluados por
   Chroma; en LongMemEval un prompt enfocado de ~300 tokens supera a uno completo
   de ~113k en la misma tarea). ~50 palabras.

3. **La sección "Subagentes" ahora dice cuándo, no solo con qué modelo** —
   incorpora el hallazgo de ~15× de sobrecosto multi-agente y que a igual
   presupuesto un solo agente iguala a varios. Tarea chica → no se delega.

Y un recorte: la sección "Contexto" del núcleo mandaba leer `~/.claude/contexto/`,
cosa que el hook de SessionStart ya hace desde v1.4. Era letra muerta que además
inducía lecturas redundantes.

Núcleo: 84 → 97 líneas, 527 → 628 palabras (+19%). El crecimiento se defiende
porque ambas adiciones son heurísticas que evitan errores caros —el tipo de
contenido que las reglas de Claude 5 dicen conservar— y no reglas rígidas. Aun
así el council debe pronunciarse sobre el saldo.

**Candidato a recorte que NO se aplicó:** la tabla "Playbooks por dominio" (12
líneas) duplica lo que ya declaran las descriptions de las 8 skills, y repetir
instrucciones en ambos lugares está marcado como deprecado para la generación
Claude 5. No se toca sin correr antes el gate de disparo de 21 peticiones: el
20/21 de v1.0 pudo depender de esa tabla. Plugin a 1.11.0.

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
