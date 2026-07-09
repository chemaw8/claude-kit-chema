# Manuales de instrucciones y arquitecturas de prompts para Claude: mejores prácticas 2024–2026

Reporte final de investigación para el diseño del Kit Chema. Fecha de consulta de todas las fuentes: 2026-07-08. Notación de votación: "3-0" significa que tres verificadores independientes confirmaron la afirmación contra la fuente primaria en ronda adversarial; "2-1" indica mayoría con un voto disidente (el matiz del disidente se recoge en la sección de Transparencia).

---

## 1. Resumen ejecutivo

Siete hallazgos cambian decisiones de diseño del kit:

**Primero: menos texto produce más obediencia, y es doctrina oficial.** Anthropic recomienda mantener cada CLAUDE.md por debajo de 200 líneas y aplicar una prueba de poda línea a línea: si quitar una línea no provocaría errores, se elimina. Los archivos inflados no solo consumen contexto, hacen que Claude ignore las instrucciones que sí importan. Esto convierte la brevedad del núcleo del kit en el requisito número uno, por delante de la exhaustividad.

**Segundo: CLAUDE.md es un consejo, no una ley.** El contenido de CLAUDE.md se inyecta como mensaje de usuario después del system prompt, sin garantía de cumplimiento estricto. Lo que deba cumplirse siempre (validaciones, políticas de seguridad, formatos obligatorios) debe implementarse como *hooks* —comandos de shell que el cliente ejecuta en eventos fijos, decida lo que decida el modelo— o como scripts empaquetados. La regla de Anthropic es literal: "el código es determinista; la interpretación del lenguaje no".

**Tercero: la arquitectura "núcleo compacto + skills bajo demanda" que contempla el kit es exactamente la que Anthropic prescribe.** CLAUDE.md se carga en cada sesión, así que solo debe contener lo transversal; el conocimiento de dominio va en skills que se cargan solo cuando son relevantes, mediante "divulgación progresiva" en tres niveles (nombre y descripción siempre; cuerpo del SKILL.md si es relevante; archivos de referencia solo si hacen falta). Importante: trocear el CLAUDE.md con importaciones `@ruta` no ahorra contexto, porque los archivos importados se cargan enteros al arranque.

**Cuarto: el campo `description` de cada skill es el interruptor que decide si se activa.** Debe decir qué hace la skill y cuándo usarla, con frases gatillo literales que diría el usuario, en menos de 1024 caracteres. Una descripción vaga ("ayuda con proyectos") condena a la skill a no dispararse nunca. Redactar bien estas descripciones es probablemente la tarea de mayor apalancamiento de todo el kit.

**Quinto: gritar en mayúsculas ya es contraproducente.** El énfasis agresivo ("CRITICAL: You MUST...") diseñado para modelos antiguos provoca sobreactivación en Claude Opus 4.5/4.6 y posteriores; Anthropic recomienda explícitamente volver a redacción normal ("Usa esta herramienta cuando..."). Además, el aliento anti-pereza ("tómate tu tiempo", "la calidad importa más que la velocidad") es más efectivo en el prompt del usuario que en los archivos de instrucciones, lo que traslada esa munición a la guía humana (COMO-PEDIR.md), no al kit estático.

**Sexto: la posición del contenido está cuantificada.** Con entradas largas (20k+ tokens), poner los documentos arriba y la pregunta/instrucciones al final mejoró la calidad hasta un 30% en pruebas de Anthropic. Dentro de los archivos de instrucciones, lo crítico va al principio, con cabeceras tipo "## Importante". Y si dos reglas se contradicen entre archivos, Claude elige una arbitrariamente: la consistencia entre núcleo y skills debe verificarse, no asumirse.

**Séptimo: los revisores automáticos sobre-reportan por diseño, y hay que acotarles el mandato.** Anthropic recomienda la revisión adversarial con subagentes de contexto fresco, pero advierte de un modo de fallo conocido: un revisor al que se le pide encontrar fallos los reportará aunque el trabajo esté bien, y perseguir cada hallazgo lleva a sobre-ingeniería. El protocolo *council* del kit debe limitar el mandato a hallazgos que afecten a la corrección o a la decisión, exigir evidencia, y tratar "sin hallazgos relevantes" como salida válida. La literatura comunitaria sobre paneles de jueces (jurados de modelos diversos e independientes) apunta en la misma dirección, aunque con menor peso probatorio.

---

## 2. Hallazgos por área

### 2a. Guía oficial de Anthropic: CLAUDE.md, memoria y skills

**Contenido del núcleo: solo lo transversal.** CLAUDE.md se carga en cada sesión, por lo que solo debe incluir lo que aplica de forma amplia; el conocimiento de dominio y los flujos ocasionales van en skills que Claude carga bajo demanda sin inflar cada conversación. (Fuente: https://code.claude.com/docs/en/best-practices — votación 3-0).

**Límite cuantitativo: menos de 200 líneas por archivo.** Los archivos más largos consumen más contexto y reducen la adherencia a las instrucciones. (Fuente: https://code.claude.com/docs/en/memory — votación 3-0).

**Prueba de poda por línea.** Para cada línea preguntarse: "¿quitarla haría que Claude cometiera errores?". Si no, se corta. Los CLAUDE.md inflados hacen que Claude ignore las instrucciones reales. (Fuente: https://code.claude.com/docs/en/best-practices — votación 3-0).

**CLAUDE.md es consultivo; los hooks son deterministas.** El contenido de CLAUDE.md se entrega como mensaje de usuario tras el system prompt, no dentro de él, y no hay garantía de cumplimiento estricto. Lo que deba ejecutarse siempre debe ser un hook, que se aplica independientemente de lo que el modelo decida. (Fuentes: https://code.claude.com/docs/en/memory y https://code.claude.com/docs/en/best-practices — votación 3-0 en ambas).

**Las importaciones `@ruta` no reducen contexto.** Ayudan a organizar, pero los archivos importados (hasta 4 saltos de profundidad) se cargan enteros al arranque. Solo las reglas con ámbito de ruta (`.claude/rules/` con frontmatter `paths`) y las skills cargan bajo demanda: son el mecanismo correcto para instrucciones de dominio en un kit modular. (Fuente: https://code.claude.com/docs/en/memory — votación 3-0).

**Existe un mecanismo oficial de despliegue corporativo.** Un CLAUDE.md de política gestionada (p.ej. `/etc/claude-code/CLAUDE.md` en Linux, o la clave `claudeMd` en `managed-settings.json`) se carga antes que los archivos de usuario y proyecto y no puede ser excluido por configuraciones individuales. Es la vía oficial para distribuir estándares de uso de IA a toda una organización. (Fuente: https://code.claude.com/docs/en/memory — votación 3-0).

**Qué es una skill.** Carpetas de instrucciones, scripts y recursos centradas en un SKILL.md con frontmatter YAML (`name`, `description`) que los agentes descubren y cargan dinámicamente, en lugar de incrustar todo el conocimiento procedimental en un prompt largo. (Fuente: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills — votación 3-0).

**Divulgación progresiva en tres niveles.** Al arranque solo se precargan nombre y descripción de cada skill; el cuerpo completo del SKILL.md se lee solo cuando Claude la juzga relevante; los archivos adjuntos (reference.md, etc.) se cargan solo si hacen falta. Esto minimiza tokens manteniendo la expertise, y vía sistema de archivos el contexto empaquetable es "efectivamente ilimitado". (Fuentes: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills y https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf — votación 3-0 en ambas).

**La `description` decide la activación.** Claude usa `name` y `description` para decidir si dispara la skill; deben redactarse con especial cuidado, incluir obligatoriamente qué hace y cuándo usarla (con frases gatillo literales), y mantenerse bajo 1024 caracteres. Descripciones vagas como "Helps with projects" hacen que la skill nunca se active. (Fuentes: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills y https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf — votación 3-0 en ambas).

**Límites anti-bloat para skills.** SKILL.md por debajo de 5.000 palabras, moviendo el detalle a `references/`; revisar si hay más de 20–50 skills habilitadas a la vez, porque el exceso degrada respuestas y ralentiza. Cuando un SKILL.md se vuelve inmanejable, dividirlo en archivos referenciados: mantener separados los contextos mutuamente excluyentes reduce tokens. (Fuentes: PDF de la guía oficial de skills y artículo de ingeniería de Anthropic — votación 3-0 en ambas).

**Reglas de prompting que aplican al kit.** La regla de oro: si un colega con contexto mínimo se confundiría con el prompt, Claude también; el comportamiento "por encima de lo esperado" debe pedirse explícitamente, no asumirse. (Fuente: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices — votación 3-0).

**Context engineering.** La meta es el conjunto más pequeño de tokens de alta señal que maximice el resultado, no listas exhaustivas de casos borde; los prompts deben escribirse a la "altitud" correcta (heurísticas firmes, no lógica rígida codificada en prosa, que es frágil y cara de mantener); y la recuperación de contexto debe ser *just-in-time* con identificadores ligeros (rutas, enlaces) cargados en tiempo de ejecución. (Fuente: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — votaciones 3-0, 3-0 y 2-1 respectivamente; ver Transparencia para el voto disidente).

### 2b. Qué falla en instrucciones largas: bloat, posición, contradicciones, énfasis

**Context rot: la degradación con la longitud es real.** A medida que crece el número de tokens en la ventana de contexto, disminuye la capacidad del modelo para recuperar información con precisión; los archivos de instrucciones inflados reducen la fiabilidad del output. (Fuente: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — votación 3-0). Las fuentes catalogadas de investigación independiente apuntan en la misma dirección: el informe técnico de Chroma sobre "context rot" (https://research.trychroma.com/context-rot), el artículo "Lost in the Middle" (https://arxiv.org/abs/2307.03172), que documentó que la información situada en medio de contextos largos se recupera peor que la del principio o el final, y el benchmark de seguimiento de instrucciones simultáneas de arXiv 2507.11538, que midió cómo se degrada la obediencia al crecer el número de instrucciones. Estas tres fuentes fueron catalogadas durante la investigación pero sus afirmaciones concretas no pasaron ronda de verificación individual: se usan como orientación convergente, no como regla dura.

**Efectos de posición, cuantificados.** Con entradas de 20k+ tokens, los documentos largos van al principio del prompt y la consulta/instrucciones al final; esto mejoró la calidad de respuesta hasta un 30% en pruebas de Anthropic. (Fuente: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices — votación 3-0).

**Instrucciones ignoradas: tres causas y sus remedios.** Anthropic identifica verbosidad, instrucciones enterradas y lenguaje ambiguo como las causas de que Claude ignore instrucciones, y prescribe remedios de posición y redundancia: lo crítico al principio, cabeceras "## Important"/"## Critical", y repetición de puntos clave. Para validaciones críticas, sustituir el lenguaje natural por scripts ejecutables. (Fuente: https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf — votación 3-0).

**Contradicciones = azar.** Si dos reglas se contradicen entre archivos CLAUDE.md, Claude puede elegir una arbitrariamente. El remedio para la mala adherencia es redacción concreta y verificable: "usa sangría de 2 espacios" en lugar de "formatea el código correctamente". (Fuente: https://code.claude.com/docs/en/memory — votación 3-0).

**El énfasis agresivo ahora sobredispara.** Instrucciones en mayúsculas ("CRITICAL: You MUST...") escritas para modelos antiguos provocan sobreactivación en Opus 4.5/4.6 y posteriores; Anthropic recomienda rebajarlas a redacción normal y "afinar a la baja" el prompting anti-pereza heredado. (Fuente: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices — votación 3-0).

**El aliento anti-pereza va en el prompt humano, no en el kit.** Frases como "tómate tu tiempo para hacerlo a fondo", "la calidad importa más que la velocidad" o "no saltes pasos de validación" funcionan, y Anthropic afirma que colocarlas en el prompt del usuario es más efectivo que ponerlas en SKILL.md. (Fuente: PDF de la guía oficial de skills — votación 3-0).

**Convergencia comunitaria.** Las fuentes comunitarias catalogadas —dos hilos de Hacker News sobre CLAUDE.md y prácticas de Claude Code (https://news.ycombinator.com/item?id=46102048, https://news.ycombinator.com/item?id=46098838), la guía de HumanLayer sobre cómo escribir un buen CLAUDE.md (https://www.humanlayer.dev/blog/writing-a-good-claude-md), la guía de configuración 2026 de Shareuhack y las lecciones de proyectos reales de Ran the Builder— convergen en el mismo diagnóstico que la documentación oficial: los archivos largos se ignoran, el error típico es tratar CLAUDE.md como vertedero de documentación, y lo que funciona es un núcleo corto con carga bajo demanda. Estas fuentes fueron catalogadas pero sus afirmaciones individuales no se verificaron adversarialmente: se citan como señal de convergencia, no como evidencia primaria.

### 2c. Kits y sistemas de skills de referencia

**Superpowers (obra/superpowers).** El sistema de skills de código abierto de Jesse Vincent (https://github.com/obra/superpowers, descrito en https://blog.fsck.com/2025/10/09/superpowers/) es el ejemplo comunitario más citado de arquitectura de skills a escala: una biblioteca de skills de *proceso* componibles (brainstorming antes de construir, desarrollo guiado por tests, depuración sistemática, planes escritos, revisión por subagentes, verificación antes de declarar algo terminado), cada una en markdown con descripciones-gatillo del tipo "Use when...", más una meta-skill que enseña al agente a encontrar y usar las demás. Dos patrones son directamente reutilizables por el kit: (1) skills de proceso, no solo de dominio —el "cómo trabajar" también se empaqueta—; y (2) descripciones que empiezan por la condición de disparo, no por la funcionalidad. Fuentes catalogadas (repositorio primario + blog del autor); afirmaciones no verificadas individualmente.

**Colecciones curadas.** awesome-claude-code (https://github.com/hesreallyhim/awesome-claude-code, fuente secundaria) y awesome-claude-code-toolkit (https://github.com/rohitg00/awesome-claude-code-toolkit) catalogan CLAUDE.md reales, comandos y flujos de trabajo de la comunidad. Su valor para el kit no es normativo sino de cantera: ejemplos concretos de los que extraer estructuras y frases gatillo ya probadas. Catalogadas; no verificadas individualmente.

**El modelo oficial de distribución corporativa existe y es suficiente.** La combinación confirmada de (a) CLAUDE.md de política gestionada que se carga primero y no puede excluirse, (b) skills con divulgación progresiva y (c) hooks deterministas (todo 3-0, fuentes oficiales citadas en 2a) cubre íntegramente lo que el Kit Chema necesita para instalarse y gobernarse en una empresa sin depender de herramientas de terceros. La guía oficial de construcción de skills (PDF de Anthropic) documenta además el modelo de distribución vigente a enero de 2026.

### 2d. Verificación multi-agente y anti-complacencia

**Revisión adversarial con contexto fresco, pero con mandato acotado.** Anthropic recomienda que un subagente con contexto limpio revise el trabajo, y advierte del modo de fallo central: un revisor al que se le pide encontrar fallos usualmente reportará algunos aunque el trabajo esté bien, porque eso es lo que se le pidió; perseguir cada hallazgo produce sobre-ingeniería (capas de abstracción extra, código defensivo, tests de casos imposibles). El mandato del revisor debe acotarse a los fallos que afectan a la corrección. (Fuente: https://code.claude.com/docs/en/best-practices — votación 3-0). Este es el hallazgo que más condiciona el diseño del protocolo *council* del kit.

**Determinismo como piso de la verificación.** Dos hallazgos confirmados forman la base: los hooks garantizan ejecución (a diferencia de las instrucciones consultivas) y las validaciones críticas deben ser scripts, no prosa. (Fuentes: https://code.claude.com/docs/en/best-practices y PDF de la guía de skills — votación 3-0 en ambas). Traducción práctica: la capa uno del anti-complacencia no es un juez inteligente, es un script que comprueba lo comprobable (cifras que cuadran, archivos que existen, formatos que validan).

**Paneles de jueces (orientación comunitaria).** Las fuentes catalogadas sobre evaluación multi-agente —la sistematización de jurados de LLMs en la práctica (https://orq.ai/blog/llm-juries-in-practice), que recoge la línea de trabajo según la cual paneles de varios jueces diversos e independientes correlacionan mejor con el juicio humano y mitigan el sesgo de auto-preferencia frente a un juez único; el patrón de revisión adversarial de código (https://asdlc.io/patterns/adversarial-code-review/); la implementación de panel de revisión por agentes (https://github.com/wan-huiyan/agent-review-panel); y un artículo académico de enero de 2026 (https://arxiv.org/html/2601.03269v1)— apoyan el diseño de un council con varios jueces de contexto independiente y votación. Ninguna de estas afirmaciones pasó verificación individual: se adoptan como orientación de diseño, subordinadas a la advertencia oficial confirmada sobre el sobre-reporte de los revisores.

---

## 3. Implicaciones concretas para el diseño del Kit Chema

| # | Hallazgo (votación) | Decisión de diseño para el kit |
|---|---|---|
| 1 | CLAUDE.md < 200 líneas; el bloat causa desobediencia (3-0) | Núcleo CLAUDE.md con objetivo de ~100 líneas y tope duro de 150. Ritual de mantenimiento antes de cada versión: prueba de poda línea a línea ("¿quitarla causaría errores?"). |
| 2 | Solo lo transversal en el núcleo; dominios en skills (3-0) | El núcleo lleva únicamente: identidad y contexto de Innovattia, idioma, convenciones de rutas/entregables y punteros a las skills. Todo lo demás (presentaciones, análisis de datos, research, código, propuestas, finanzas, automatización) vive en las 7 skills. |
| 3 | `@imports` no ahorran contexto; rules con `paths` y skills sí cargan bajo demanda (3-0) | Prohibido "modularizar" el núcleo con `@ruta`. Reglas ligadas a tipos de archivo → `.claude/rules/` con frontmatter `paths`; conocimiento de dominio → skills. |
| 4 | CLAUDE.md es consultivo; hooks son deterministas; el código es determinista (3-0) | Las reglas innegociables (no filtrar datos sensibles, ejecutar el validador de entregables, comprobar cifras en propuestas) se implementan como hooks y scripts empaquetados en las skills, no como prosa. |
| 5 | Despliegue por política gestionada, no excluible (3-0) | El instalador ofrece dos modos: personal (`~/.claude/`) y organizacional (clave `claudeMd` en `managed-settings.json` o `/etc/claude-code/CLAUDE.md`), que carga antes que todo y no puede desactivarse por usuario. |
| 6 | `description` decide la activación: qué + cuándo + frases gatillo, <1024 caracteres (3-0) | Plantilla obligatoria de description para cada skill del kit: una frase de qué hace + condiciones de uso + 3–5 frases gatillo literales en español tal como las diría un colega ("hazme una presentación para...", "analiza estas ventas", "prepara la propuesta de..."). Revisión cruzada para que las descriptions no se solapen entre skills. |
| 7 | SKILL.md < 5.000 palabras; detalle a `references/`; umbral de 20–50 skills (3-0) | Cada SKILL.md del kit con objetivo de ≤ 2.000 palabras; plantillas, checklists y ejemplos largos van a `references/` y `assets/`. Con ~7 skills el kit queda muy por debajo del umbral de saturación. |
| 8 | Lo crítico al principio; cabeceras "## Importante"; repetición puntual (3-0) | En núcleo y skills, las 3–5 reglas críticas van en las primeras líneas bajo "## Importante". La repetición se permite solo para esas reglas, una vez. |
| 9 | Datos largos arriba, pregunta al final: hasta +30% (3-0) | COMO-PEDIR.md enseña el orden: primero pegar el documento/datos, al final la petición e instrucciones. Incluir un ejemplo antes/después. |
| 10 | Contradicciones → elección arbitraria; redacción concreta y verificable (3-0) | Cada regla tiene una sola fuente de verdad (núcleo o una skill, nunca ambos). El instalador incluye un lint de consistencia que detecta reglas duplicadas o contradictorias entre archivos. Estilo obligatorio: instrucciones comprobables ("las cifras llevan separador de miles y fuente citada"), nunca vaguedades ("hazlo profesional"). |
| 11 | El énfasis en mayúsculas sobredispara en modelos actuales (3-0) | Tono imperativo plano en todo el kit; cero "CRÍTICO: DEBES". Si algo necesita énfasis, se gana su posición (arriba) y su cabecera, no sus mayúsculas. |
| 12 | El aliento anti-pereza es más efectivo en el prompt del usuario que en SKILL.md (3-0) | Las frases de exigencia ("tómate el tiempo de hacerlo a fondo", "no saltes validaciones", "calidad antes que velocidad") van a COMO-PEDIR.md como recetario para las personas, no a los archivos del kit. |
| 13 | Los revisores sobre-reportan; acotar a corrección (3-0) | El protocolo council de la skill de propuestas: (a) mandato explícito limitado a hallazgos que cambiarían la decisión o la corrección del entregable; (b) cada hallazgo debe citar evidencia concreta; (c) "sin hallazgos relevantes" es una salida válida y esperada; (d) máximo 2 rondas para evitar bucles de sobre-ingeniería. |
| 14 | Revisión con subagente de contexto fresco (3-0); jurados diversos e independientes (orientación comunitaria, no verificada) | Los jueces del council trabajan con contexto limpio e independiente entre sí (sin ver los veredictos de los demás antes de votar), con rúbricas distintas por juez (exactitud, claridad, riesgo comercial). El formato de votación 3-0/2-1 usado en esta misma investigación sirve de modelo. |
| 15 | Regla de oro: la prueba del colega sin contexto (3-0) | Prueba de aceptación del kit antes de distribuir: entregar cada skill y COMO-PEDIR.md a un colega sin contexto; si él se confunde, Claude también. Lo "por encima de lo esperado" se pide explícitamente en las plantillas de petición. |
| 16 | Tokens mínimos de alta señal; altitud de heurística; carga just-in-time (3-0/3-0/2-1) | El kit codifica heurísticas y criterios de calidad, no árboles de decisión rígidos ni listas de casos borde. Los materiales pesados (plantillas de marca, datasets de ejemplo) se referencian por ruta y se cargan en tiempo de ejecución. |

---

## 4. Transparencia: refutado, no verificado y cómo tratarlo

**Afirmaciones refutadas: ninguna.** Ninguna de las afirmaciones sometidas a verificación adversarial fue desmentida por su fuente primaria.

**Afirmaciones no verificables por fuente inaccesible: ninguna.** Las 24 afirmaciones verificadas fueron accesibles (3/3 verificadores) y confirmadas.

Aun así, tres cautelas aplican al usar este reporte:

1. **Fuentes comunitarias catalogadas pero no verificadas individualmente.** Los hilos de Hacker News, los blogs (HumanLayer, Shareuhack, Ran the Builder, orq.ai, asdlc.io), los repositorios (superpowers, awesome-claude-code, awesome-claude-code-toolkit, agent-review-panel) y los artículos académicos (Lost in the Middle, arXiv 2507.11538, el informe de Chroma, arXiv 2601.03269) fueron catalogados durante la investigación, pero sus afirmaciones concretas no pasaron la ronda de verificación 3-0. Deben usarse como orientación e inspiración de diseño, nunca como regla dura del kit. Toda decisión de la tabla de la sección 3 se sostiene en al menos una afirmación confirmada 3-0, con las fuentes comunitarias solo como refuerzo.

2. **El voto disidente (2-1) sobre just-in-time.** La afirmación de que la recuperación just-in-time es "el fundamento arquitectónico de skills por dominio frente a un CLAUDE.md monolítico" recibió un voto en contra: el disidente señaló, con razón, que Anthropic no plantea sustituir CLAUDE.md por skills, sino un modelo híbrido donde un CLAUDE.md se carga por adelantado por diseño y el resto se recupera bajo demanda. El diseño del kit ya es coherente con esa lectura híbrida (núcleo pequeño siempre cargado + skills bajo demanda), así que la disidencia no cambia ninguna decisión, pero conviene no citar la fuente como si desaconsejara tener núcleo.

3. **Las cifras son guía del fabricante, no mediciones independientes.** Los números confirmados (200 líneas, 5.000 palabras, 1024 caracteres, 20–50 skills, hasta 30% de mejora por posición) provienen de documentación y pruebas internas de Anthropic; están confirmados como *lo que Anthropic dice*, no replicados por terceros. Un matiz menor detectado en verificación: la fuente dice que los archivos largos "reducen la adherencia", sin aportar datos de medición ("measurably" fue un añadido de la afirmación original). Tratarlos como umbrales de trabajo razonables y revisarlos con cada versión mayor de Claude, igual que la guía sobre énfasis cambió entre generaciones de modelos.

---

## 5. Bibliografía completa

| Fuente | Calidad | Papel en el reporte |
|---|---|---|
| https://code.claude.com/docs/en/best-practices | Primaria (documentación oficial Anthropic) | Poda de CLAUDE.md, núcleo vs. skills, hooks vs. instrucciones, sobre-reporte de revisores. 5 afirmaciones, todas confirmadas 3-0. |
| https://code.claude.com/docs/en/memory | Primaria (documentación oficial Anthropic) | Límite de 200 líneas, inyección como mensaje de usuario, contradicciones, `@imports`, política gestionada. 5 afirmaciones confirmadas 3-0. |
| https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills | Primaria (blog de ingeniería Anthropic) | Definición de skills, divulgación progresiva, importancia de name/description, división anti-bloat. Confirmadas 3-0. |
| https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices | Primaria (documentación oficial Anthropic) | Regla de oro del colega, efectos de posición (+30%), sobredisparo por mayúsculas. Confirmadas 3-0. |
| https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | Primaria (blog de ingeniería Anthropic) | Context rot, altitud correcta, tokens mínimos de alta señal, just-in-time. Confirmadas 3-0 (una 2-1). |
| https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf | Primaria (guía oficial Anthropic, vigente a enero 2026) | Tres niveles de divulgación, description <1024, SKILL.md <5.000 palabras, causas de instrucciones ignoradas, anti-pereza en prompt de usuario. Confirmadas 3-0. |
| https://arxiv.org/abs/2307.03172 | Primaria (paper académico, "Lost in the Middle") | Orientación sobre efectos de posición en contextos largos. Catalogada; no verificada individualmente. |
| https://arxiv.org/abs/2507.11538 | Primaria (paper académico, 2025) | Orientación sobre degradación al crecer el número de instrucciones simultáneas. Catalogada; no verificada individualmente. |
| https://research.trychroma.com/context-rot | Primaria (informe técnico de Chroma) | Orientación sobre degradación por longitud de entrada. Catalogada; no verificada individualmente. |
| https://arxiv.org/html/2601.03269v1 | Primaria (paper académico, enero 2026) | Catalogada durante la investigación en el área de evaluación multi-agente; no verificada individualmente. |
| https://github.com/obra/superpowers | Primaria (repositorio del sistema de skills) | Ejemplo de referencia de arquitectura de skills de proceso. Catalogada; no verificada individualmente. |
| https://blog.fsck.com/2025/10/09/superpowers/ | Blog (autor del sistema) | Contexto de diseño de superpowers. Catalogada; no verificada individualmente. |
| https://github.com/hesreallyhim/awesome-claude-code | Secundaria (lista curada) | Cantera de ejemplos de CLAUDE.md, comandos y flujos. Catalogada. |
| https://github.com/rohitg00/awesome-claude-code-toolkit | Blog/curación | Cantera adicional de ejemplos. Catalogada. |
| https://news.ycombinator.com/item?id=46102048 | Foro (Hacker News) | Señal de convergencia comunitaria sobre bloat e instrucciones ignoradas. Catalogada. |
| https://news.ycombinator.com/item?id=46098838 | Foro (Hacker News) | Señal de convergencia comunitaria. Catalogada. |
| https://www.humanlayer.dev/blog/writing-a-good-claude-md | Blog | Guía comunitaria sobre CLAUDE.md concisos. Catalogada. |
| https://www.shareuhack.com/en/posts/claude-code-claude-md-setup-guide-2026 | Blog | Guía de configuración comunitaria 2026. Catalogada. |
| https://ranthebuilder.cloud/blog/claude-code-best-practices-lessons-from-real-projects/ | Blog | Lecciones de proyectos reales con Claude Code. Catalogada. |
| https://github.com/wan-huiyan/agent-review-panel | Blog/repositorio | Implementación de panel de revisión multi-agente. Catalogada. |
| https://asdlc.io/patterns/adversarial-code-review/ | Blog (catálogo de patrones) | Patrón de revisión adversarial de código. Catalogada. |
| https://orq.ai/blog/llm-juries-in-practice | Blog | Jurados de LLMs en la práctica (paneles de jueces diversos). Catalogada. |

**Nota de método.** "Confirmada 3-0 / 2-1" indica el resultado de la verificación adversarial: tres verificadores independientes contrastaron cada afirmación contra su fuente primaria en vivo el 2026-07-08. "Catalogada" indica que la fuente se identificó y clasificó durante la investigación pero sus afirmaciones específicas no pasaron esa ronda; su contenido se emplea solo como orientación.