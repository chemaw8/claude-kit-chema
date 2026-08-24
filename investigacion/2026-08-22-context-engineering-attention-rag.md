# Context engineering, attention y RAG — estado del arte 2026 y qué significa para el Kit Chema

Investigación: 2026-08-22
Pregunta: qué prácticas de context engineering, attention en contexto largo, RAG y
workflows agénticos están validadas en 2026, y cuáles aplican al setup real de José.
Decisión que alimenta: qué entra al Kit Chema v1.11+ y qué se cambia en la
arquitectura de contexto (MEMORY.md, hook de contexto, vault, subagentes).

---

## Resumen ejecutivo

**Tres hallazgos deciden:**

1. **Las *políticas* del kit ya están alineadas con la evidencia de 2026 — lo que le
   falta es *mecanismo*.** Anthropic recortó >80% del system prompt de Claude Code
   para Opus 5 y Fable 5 sin pérdida medible, y la lección fue "estábamos
   sobre-restringiendo a Claude". El núcleo del kit tiene **527 palabras**, casi
   exactamente el tamaño al que Anthropic llegó después de recortar (~514). No hay
   que adelgazarlo. Y dos reglas del núcleo —"esfuerzo proporcional al riesgo" y el
   council reservado a decisiones caras— son justo lo que la literatura recomienda
   contra los dos fallos más caros de los skills y de los sistemas multi-agente.

2. **El mayor costo de contexto que José controla no está en el kit: es
   `MEMORY.md`.** Son **4,353 tokens, el 58%** de todo lo que se autocarga por
   sesión, en 48 líneas de punteros que crecen monótonamente. Es a la vez un
   problema de costo y de *atención*: 48 entradas casi idénticas compiten entre sí.

3. **El vault ya implementa el patrón de RAG que 2026 recomienda; los 24 proyectos
   no.** La regla de consenso es "usa contexto largo para razonar sobre un conjunto
   acotado de evidencia, y recuperación para decidir cuál es ese conjunto".
   `basic-memory` hace exactamente eso sobre el vault. Pero el trabajo real —
   CONTINUAR, DECISIONES, docs de los 24 proyectos — está fuera de toda capa de
   recuperación: solo se alcanza si ya sabes la ruta.

4. **Se delega 444 veces cada seis semanas, siempre al agente genérico.** Sobre
   1,487 transcripts de uso real: `general-purpose` 444 invocaciones, y **cero** a
   los 9 agentes especializados que se pagan en cada sesión. Con un sobrecosto
   multi-agente del orden de 15×, ese es casi con seguridad el mayor consumo de
   tokens del setup, y hoy ninguna de esas delegaciones lleva instrucciones de rol.

5. **Los plugins pueden alcanzarse por proyecto.** Verificado en la documentación:
   `enabledPlugins` tiene alcance "Any file". Vercel cuesta ~2,220 tokens por sesión
   y se usó **2 veces en seis semanas**; los 6 agentes de pr-review-toolkit cuestan
   ~1,570 y se usaron **cero**. No hay que desinstalarlos: hay que encenderlos donde
   se usan.

**Recomendación principal:** el trabajo de mayor retorno no es reescribir skills, es
(a) darle mecanismo a lo que el núcleo ya declara y (b) mover a alcance por proyecto
lo que hoy se paga globalmente. Las fichas de proyecto (diseño del 2026-08-22) son la
pieza que habilita los puntos 3 y 5.

**Efecto acumulado de lo propuesto:** arranque de sesión de 35,692 → ~29,200 tokens
(−18%), sin perder ninguna capacidad.

---

## 1. Medición del setup real (2026-08-22)

Medido, no estimado. Claude Code 2.1.241.

### Arranque de sesión: 35,692 tokens

Dato de `cache_creation_input_tokens` del transcript real de la sesión.

| Bloque | Tokens | % | ¿Controlable? |
|---|---:|---:|---|
| Base de Claude Code + esquemas de herramientas + MCP | ~23,681 | 66% | solo apagando MCPs |
| **`MEMORY.md`** | **4,353** | **12%** | **sí** |
| Núcleo `CLAUDE.md` del kit | 974 | 3% | sí |
| Hook de contexto (empresa+personal+base) | 1,392 | 4% | sí |
| Hook de superpowers (`using-superpowers`) | 850 | 2% | sí |
| Descripciones de skills de plugins (45 skills) | ~2,672 | 7% | sí |
| Descripciones de agentes de plugins (9 agentes) | ~1,770 | 5% | sí |

**De los ~12,011 tokens que José controla, `MEMORY.md` es el 36%** — y el 58% si se
excluyen las descripciones de plugins.

### Las 8 skills del kit

| Skill | Palabras | ~tokens | Archivos de apoyo |
|---|---:|---:|---:|
| kit-codigo | 1,189 | 1,826 | 0 |
| kit-propuestas | 1,048 | 1,651 | 0 |
| kit-redaccion | 866 | 1,328 | 0 |
| kit-presentaciones | 843 | 1,292 | 1 |
| kit-analisis-datos | 836 | 1,294 | 0 |
| kit-finanzas | 803 | 1,247 | 0 |
| kit-research | 774 | 1,186 | 0 |
| kit-automatizacion | 762 | 1,201 | 0 |
| **Núcleo `CLAUDE.md`** | **527** | **876** | — |

Solo se carga la skill que dispara, no las ocho. **Ninguna es grande** (1.2k–1.8k
tokens); el tope del kit es 5,000 palabras y la mayor usa el 24%.

### Otros datos del inventario

- 24 proyectos: 13 con repo+remoto, 8 con repo local, **3 sin git**.
- 3,609 líneas acumuladas de `CONTINUAR.md`; la mayor, 911 líneas (~12k tokens).
- `~/.claude/agents/`, `~/.claude/commands/`, `~/.claude/workflows/`: **vacíos**.
- `claude doctor` → sin problemas de instalación.

### Uso real, medido sobre 1,487 transcripts (2026-07-08 → 2026-08-22)

Seis semanas de trabajo real. Esto convierte varias decisiones de opinión en
evidencia.

**Skills — el kit es el caballo de batalla:**

| Skill | Invocaciones |
|---|---:|
| kit-research | 64 |
| kit-codigo | 24 |
| kit-redaccion | 16 |
| kit-presentaciones | 15 |
| superpowers:brainstorming | 15 |
| kit-propuestas | 14 |
| claude-api | 14 |
| kit-analisis-datos | 12 |
| document-skills:xlsx | 11 |
| **Total kit-\*** | **156** |
| **Total vercel:\* (30 skills cargadas)** | **2** |

**Subagentes — 444 delegaciones, todas genéricas:**

| Tipo | Invocaciones |
|---|---:|
| `general-purpose` | 444 |
| `claude` | 7 |
| `claude-code-guide` | 2 |
| **Los 9 agentes especializados de plugins** | **0** |

**MCP — todos se usan:** claude-in-chrome 303, Google/Gmail 179, basic-memory 120,
scrapling ~220, context7 18. **No hay ningún MCP que cortar.**

**Tres lecturas:**

1. **El kit se gana su lugar con holgura:** 156 invocaciones contra 2 del plugin más
   caro. Cualquier duda sobre si vale la pena mantenerlo queda contestada con datos.
2. **Vercel cuesta ~2,220 tokens en cada sesión y se usó 2 veces en seis semanas.**
   Es el desperdicio más claro del setup — pero José tiene tres proyectos en Vercel,
   así que la respuesta no es desinstalarlo (ver P6).
3. **444 delegaciones, todas a `general-purpose`; cero a los 9 agentes especializados
   que se pagan cada sesión (~1,770 tokens).** José delega constantemente y ninguna
   delegación recibe instrucciones de rol. Esto valida los tres subagentes de v1.11
   con datos duros: no se añade una capacidad nueva, se le da propósito a algo que ya
   ocurre 444 veces cada seis semanas — y que a ~15× de sobrecosto es, con casi total
   seguridad, el mayor consumo de tokens del setup.

---

## 2. Estado del arte 2026

Marcado por nivel de respaldo, según el estándar de `kit-research`.

### CONSENSO (múltiples fuentes independientes)

**a) Todo modelo se degrada conforme crece el contexto, mucho antes de llenar la
ventana.** La investigación de Chroma evaluó **18 modelos frontera** (GPT-4.1,
Claude 4, Gemini 2.5, Qwen3) y encontró degradación en *todos*, en *cada* incremento
de longitud probado, incluso en tareas simples de recuperación y copiado. Confirmado
independientemente por la guía de Anthropic y por la cobertura de Redis y Morph.

**b) El efecto "lost in the middle" es real y grande.** Curva en U: alta precisión al
inicio y al final del contexto, **>30% menos precisión en el medio**.

**c) Enfocar el contexto gana por mucho.** En LongMemEval, prompts enfocados de
**~300 tokens superaron significativamente** a prompts completos de **~113k tokens**
en la misma tarea. La brecha persistió incluso con modos de razonamiento activados.

**d) Menos restricción, más juicio, en la generación Claude 5.** Anthropic borró
**>80% del system prompt de Claude Code** (de ~2,686 a ~514 palabras con memoria
desactivada) para Opus 5 y Fable 5 **sin pérdida medible en sus evaluaciones de
código**. Su diagnóstico textual: *"encontramos que estábamos sobre-restringiendo a
Claude Code, tanto en el system prompt como en los CLAUDE.md y skills"*. Confirmado
por el post original de Anthropic y por cobertura independiente.

**e) Los sistemas multi-agente cuestan ~15× en tokens.** Medición de Anthropic;
papers de 2026 muestran que **sistemas de un solo agente igualan o superan a los
multi-agente a igual presupuesto de tokens**. Para tareas chicas, el subagente solo
añade sobrecarga.

**f) La regla de 2026 para RAG vs contexto largo:** *usa contexto largo para razonar
sobre un conjunto acotado de evidencia, y usa recuperación para decidir cuál es ese
conjunto*. El ganador no es una arquitectura sino la combinación; el RAG agéntico
—donde el modelo descompone la consulta, elige herramientas, itera y verifica— es el
patrón ascendente.

### EN DISPUTA

**¿Los skills ayudan o estorban?** Hay evidencia sólida en los dos sentidos y no está
resuelto:

- **En contra:** el estudio *Agent Skills Can Be Harmful* hizo testing diferencial
  sobre **574 tareas** y **20,664 configuraciones pareadas**, y confirmó **307 fallos
  inducidos por skills**: 125 funcionales y 182 regresiones de eficiencia. Dentro de
  las funcionales, el 68.8% son *Task-Implementation Fault* (el skill hace creer al
  agente que ciertos elementos son obligatorios cuando son opcionales). Dentro de las
  de eficiencia, **62.6% son "procedimiento excesivo"**, y de esas **67 casos son
  verificación/testing excesivo**.
- **A favor:** SkillOpt (Microsoft Research) sostiene que un skill bien optimizado
  captura procedimientos reutilizables, no instrucciones sobreajustadas, y que **el
  mismo skill transfiere entre escalas de modelo, harnesses y tareas vecinas** — con
  un caso de skill de hojas de cálculo entrenado en Codex que mejoró el desempeño de
  Claude Code en **59.7 puntos porcentuales**.

**Lectura honesta:** el skill no es el problema; *sobre-prescribir* lo es. Lo que
transfiere son procedimientos reutilizables y trampas concretas; lo que daña son
reglas rígidas que el modelo ya cumpliría solo.

### DATO ÚNICO, sin verificar

- La cifra "RAG es 1,250× más barato por consulta" viene de una sola fuente
  secundaria (blog de proveedor) y **no la pude rastrear a un estudio original**. No
  la uso para decidir nada.
- La predicción de Gartner de que ">40% de los proyectos de IA agéntica se cancelarán
  para 2027" aparece citada en varias notas pero todas remiten al mismo comunicado;
  es **una fuente**, no varias.

### NO ENCONTRADO

No hallé evaluación independiente que mida el efecto de un kit de skills de dominio
como el de José (prosa de estándares de trabajo, no procedimientos de código) sobre
la calidad del entregable. Toda la evidencia disponible mide tareas de código y
benchmarks. **Esa brecha importa** y se discute en §3.

---

## 3. Auditoría del kit contra la evidencia

### Lo que el kit ya hace bien (y no hay que tocar)

| Regla del núcleo | Evidencia que la respalda |
|---|---|
| **"Esfuerzo proporcional al riesgo"** (trivial → directo; estándar → playbook; caro → council) | Es literalmente la recomendación del paper de skills: *"políticas conscientes del presupuesto: que el alcance de verificación se adapte a la incertidumbre de la tarea… en vez de prescribir flujos exhaustivos universalmente"*. El kit ya lo implementa. |
| **Council reservado a decisiones caras o irreversibles** | La evidencia del 15× de sobrecosto multi-agente dice exactamente eso: solo vale cuando el riesgo justifica revisión independiente. |
| **Núcleo de 527 palabras** | Anthropic recortó su system prompt a ~514 palabras. El núcleo del kit ya está en ese orden de magnitud, sin haberlo buscado. |
| **Skills de 1.2k–1.8k tokens con carga por disparo** | Muy por debajo del umbral de "context bloat" (46 de 182 regresiones de eficiencia). |
| **`kit-research` exige 2+ fuentes independientes y fuente original** | Es la contramedida directa al fallo de distractores documentado por Chroma. |

**Conclusión incómoda pero buena:** el kit no tiene un problema de diseño. Las diez
versiones de afinación de prosa produjeron algo que la evidencia de 2026 respalda.

### Dónde el kit sí está expuesto

**1. Verificación excesiva — el riesgo real, con un matiz que lo salva parcialmente.**
El fallo de eficiencia más frecuente del estudio (67 casos) es verificación excesiva,
y "Terminado significa verificado" es una regla central del núcleo, replicada en los
checklists de las 8 skills.

*El matiz:* el estudio mide eficiencia en benchmarks de código, donde verificar de
más solo cuesta tokens. El caso de José es distinto: sus entregables van a dirección
y a clientes, y una cifra mal es cara de verdad. **La regla se defiende — pero solo
porque el núcleo la modula con "esfuerzo proporcional al riesgo".** Si esa modulación
se debilitara, el kit caería justo en el fallo más documentado.

**2. Cero *progressive disclosure*: 7 de 8 skills no tienen archivos de apoyo.** Las
reglas de Claude 5 piden separar lo que siempre se carga de lo que se carga bajo
demanda. *Prioridad baja*: las skills son chicas y el ahorro sería de cientos de
tokens. **No recomiendo tocarlo todavía** — sería trabajo sin retorno medible.

**3. Reglas sin mecanismo.** La escalera de modelos (Haiku→Sonnet→Opus 5→Fable 5)
vive en el núcleo, pero `~/.claude/agents/` está vacío: nada la aplica. Igual el
council, que es prosa que hay que ejecutar a mano. Este es el hueco real del kit y no
es de contenido, es de herramientas.

**4. El kit no dice nada sobre presupuesto de contexto.** Con la evidencia de context
rot en la mano, es la omisión más notable: ocho playbooks sobre cómo hacer el trabajo
y ninguna regla sobre qué se carga y qué no.

---

## 4. Propuestas, en orden de retorno

### P1 — Reestructurar `MEMORY.md` (mayor retorno, fuera del kit)

**Problema:** 4,353 tokens, 48 entradas planas, crecimiento monótono. Cada proyecto
nuevo suma una línea y nada sale jamás. A 100 entradas serán ~9k tokens en cada
sesión, la mayoría irrelevantes para la tarea del momento.

**Por qué importa más allá del costo:** con 48 entradas de forma casi idéntica, la
recuperación de cualquiera de ellas compite con las otras 47. La evidencia de Chroma
sobre distractores y sobre similitud semántica dice que esto degrada el acierto, no
solo el precio.

**Propuesta:** índice jerárquico por dominio (~12–15 líneas) en vez de lista plana de
48. Los archivos individuales ya existen y ya son recuperables bajo demanda; lo que
sobra es el catálogo completo cargado siempre.

```
## Índice de memoria
- Cómo trabajo — [usuario](usuario-jose.md) · [idioma](preferencia-idioma-voz.md) · [modelos](politica-modelos-subagentes.md)
- Infraestructura — [repos](repos-y-respaldos.md) · [stack Claude](stack-claude-empresa.md) · [vault](proyecto-vault-conocimiento.md)
- Fixes de esta laptop — [btrfs/InnoDB] · [basic-memory/Python] · [xlsx/LibreOffice] · [GPU BIOS] · [LaTeX]
- Terreno del negocio — [contratos] · [regulación del sector] · [cuentas]
- Proyectos activos (12) → ver ~/Trabajo/proyectos/<nombre>/CLAUDE.md
- Proyectos cerrados (9) → [índice-cerrados.md]
```

**Ahorro estimado: ~3,000 tokens por sesión** (−69% del archivo, −25% de todo lo que
José controla).

**Riesgo:** que baje el recall — que yo ya no encuentre la memoria correcta. **Es
medible:** se prueban 10 preguntas cuya respuesta está en una memoria específica,
antes y después. Si el recall cae, se revierte. No se adopta sin esa medición.

**Dependencia:** el renglón "Proyectos activos → ver su CLAUDE.md" solo funciona
cuando existan las fichas. **P1 y las fichas se habilitan mutuamente.**

### P2 — Dar mecanismo a la escalera de modelos (kit, frente C)

**Evidencia nueva que cambia el diseño:** con el 15× de sobrecosto multi-agente y con
"single-agent iguala a multi-agente a igual presupuesto", la escalera no debe decir
solo *qué modelo* usar, sino **cuándo vale un subagente**. Y los subagentes deben
devolver resúmenes destilados de **1,000–2,000 tokens**, no volcados.

**Propuesta:** tres agentes en `~/.claude/agents/` con contrato de salida explícito:

| Agente | Modelo | Cuándo | Devuelve |
|---|---|---|---|
| `verificador` | Sonnet, esfuerzo bajo | recalcular cifras, checar fuentes, correr checklists | veredicto + discrepancias, ≤500 tok |
| `evaluador-council` | Opus 5 | solo decisión cara o irreversible | veredicto + objeciones con evidencia, ≤1,500 tok |
| `lector-fresco` | Opus 5, sin contexto | QA de entregables antes de que salgan | qué no se entiende, ≤800 tok |

`lector-fresco` no es invención: José ya lo usó a mano en el deck de sucursales del
2026-08-19 y forzó tres correcciones reales. Formalizarlo es cosechar algo que ya
funcionó.

**Regla que acompaña, respaldada por la evidencia:** *tarea chica → nunca subagente;
el agente principal es más rápido y más barato.*

### P3 — Regla de presupuesto de contexto en el núcleo (kit)

La omisión más notable del kit. Redacción propuesta, en el registro de "heurística,
no regla rígida" que pide la guía de Claude 5:

```markdown
## Presupuesto de contexto

Antes de cargar algo grande (un CSV completo, un log, una carpeta entera),
di qué decisión alimenta. Si no alimenta ninguna, no lo cargues: extrae lo
que sirve y trabaja con eso. Cargar de más no es gratis — degrada el
acierto, no solo el precio.
```

**Respaldo:** LongMemEval (300 tok enfocados ≫ 113k completos) y la recomendación de
"context awareness" de Anthropic. **Cuesta ~60 tokens y ataca el fallo más
documentado de 2026.**

### P4 — Cerrar el hueco de RAG: los 24 proyectos no son recuperables

**Diagnóstico:** `basic-memory` da recuperación agéntica sobre el vault — el patrón
que 2026 recomienda. Pero el trabajo real (CONTINUAR, DECISIONES, docs de 24
proyectos) está fuera: solo se alcanza sabiendo la ruta.

**Propuesta:** no montar un RAG nuevo. La ficha de proyecto **es** el "conjunto
acotado de evidencia" de la regla de consenso, y el paso 4 de `/cierre` (nota
enlazada en el vault) es la vía de indexación. **El diseño de fichas ya resuelve
esto**; lo que faltaba era el argumento de por qué es la arquitectura correcta y no
solo una comodidad. Ya lo tiene.

**Lo que explícitamente NO recomiendo:** construir embeddings/vector store propio
sobre los proyectos. La evidencia dice que para corpus bajo ~200k tokens el
contexto completo con caché le gana a construir infraestructura de recuperación, y
los proyectos de José entran holgadamente en ese rango uno por uno.

### P5 — Alcance de plugins por proyecto (hallazgo nuevo, alto retorno)

**Verificado el 2026-08-22 en la documentación oficial:** la clave `enabledPlugins`
tiene alcance **"Any file"** — se puede declarar en el `.claude/settings.json` de un
proyecto, no solo en el global. Los `deny` de permisos, además, aplican de inmediato
sin esperar a que se confíe la carpeta.

**Qué habilita:** el `.claude/settings.json` de la ficha no es solo para permisos.
Puede decidir **qué plugins se cargan en este proyecto**.

| Plugin | Costo por sesión | Uso en 6 semanas | Acción propuesta |
|---|---:|---:|---|
| vercel (30 skills + 3 agentes) | ~2,220 tok | 2 | apagar global; encender en `homologador-tpu`, `verne-web`, `broukn-web` |
| pr-review-toolkit (6 agentes) | ~1,570 tok | 0 agentes | apagar global; encender donde se revise código de verdad |

**Ahorro combinado con P1: ~6,500 tokens por sesión**, de 35,692 a ~29,200 (−18%),
sin perder ninguna capacidad — solo se paga donde se usa.

**Precaución:** apagar un plugin globalmente significa que en una carpeta sin ficha
no está disponible. Por eso esto va **después** de las fichas, no antes: sin ficha
en los tres proyectos de Vercel, apagarlo global es una regresión, no una mejora.

### P6 — Lo que NO hay que hacer

| Tentación | Por qué no |
|---|---|
| Adelgazar el núcleo "porque Anthropic recortó 80%" | Ya está en 527 palabras, el tamaño al que ellos llegaron. Recortar más quitaría contenido que sí gana su lugar. |
| Partir las 8 skills en archivos de apoyo | Son de 1.2k–1.8k tokens. El ahorro son cientos de tokens; el costo es reescribir 8 skills y arriesgar el gate de disparo (20/21) que ya pasaron. |
| Meter más plugins | Los 45 skills y 9 agentes de plugins ya cuestan ~4.4k tokens de descripciones por sesión. Cada plugin nuevo se paga en todas las sesiones, no solo cuando se usa. |
| Vector store propio sobre los proyectos | Bajo 200k tokens, el contexto con caché gana. Sería infraestructura sin retorno. |
| Multiplicar subagentes por defecto | 15× de sobrecosto; single-agent iguala a igual presupuesto. |

---

## 5. Orden de ejecución sugerido

| # | Qué | Ahorro / efecto | Bloqueado por |
|---|---|---|---|
| 1 | **P2 + P3** — kit v1.11: tres subagentes, presupuesto de contexto, puerta de delegación | da propósito a 444 delegaciones/6 semanas | council (GOBERNANZA) |
| 2 | **Fichas de proyecto** (diseño 2026-08-22) | habilita P1, P4 y P5 | revisión del spec por José |
| 3 | **P1** — `MEMORY.md` jerárquico | −2,700 tok/sesión | fichas + prueba de recall ≥9/10 |
| 4 | **P5** — plugins por proyecto | −3,800 tok/sesión | fichas en los 3 proyectos de Vercel |

P4 (RAG) no lleva trabajo propio: se cumple solo cuando 2 esté hecho.

**Efecto acumulado si todo entra:** arranque de sesión de 35,692 → ~29,200 tokens
(−18%), y las 444 delegaciones dejan de ser genéricas. Ninguna capacidad se pierde.

---

## 6. Fuentes

Consultadas el 2026-08-22.

**Primarias**

- Anthropic — *Effective context engineering for AI agents*.
  https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Anthropic / Claude — *The new rules of context engineering for Claude 5 generation
  models* (Thariq Shihipar, publicado 2026-07-24).
  https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models
- Chroma Research — *Context Rot: How Increasing Input Tokens Impacts LLM Performance*
  (18 modelos). https://www.trychroma.com/research/context-rot
- *Agent Skills Can Be Harmful: An Empirical Study of Skill-Induced Failures in LLM
  Agents* — arXiv 2608.11888. https://arxiv.org/html/2608.11888v1
- Microsoft Research — *SkillOpt: Agent skills as trainable parameters*.
  https://www.microsoft.com/en-us/research/blog/skillopt-agent-skills-as-trainable-parameters/

**Secundarias (usadas solo para verificación cruzada, no como origen de dato)**

- Techstrong.ai — cobertura independiente del recorte del 80%.
  https://techstrong.ai/agentic-ai/anthropic-cut-80-of-claude-codes-system-prompt-heres-why-that-matters-for-your-agents/
- Redis — *Context rot explained (& how to prevent it)*.
  https://redis.io/blog/context-rot/
- Sourcegraph — *Context Engineering: A Practical Guide for AI Agents (2026)*.
  https://sourcegraph.com/blog/context-engineering
- knightli.com — desglose de costo de subagentes.
  https://knightli.com/en/2026/05/31/subagent-multi-agent-token-cost/

**Mediciones propias** (reproducibles): `cache_creation_input_tokens` del transcript
de sesión en `~/.claude/projects/-home-chema/`; conteos de `wc` sobre
`~/.claude/skills/kit-*`, `~/.claude/contexto/`, `~/.claude/projects/-home-chema/memory/`;
parseo de frontmatter de `~/.claude/plugins/cache/*/*/*/skills/*/SKILL.md`.

**Advertencia de vigencia:** este tema se mueve rápido. Las reglas de Claude 5 son de
julio 2026 y el estudio de skills es de agosto 2026; el resto del cuerpo de evidencia
de context rot es de 2025 y sigue siendo el estándar citado. Revalidar si sale una
generación de modelos nueva.
