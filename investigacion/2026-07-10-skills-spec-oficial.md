# Investigación: spec y guía oficial de Agent Skills (2026-07-10)

Insumo del council v1.7 (`docs/pruebas/council-v1.7.md`). Método: subagente
investigador (Sonnet) con acceso web, estándar kit-research — cada hecho clave
con URL y fecha de consulta, sección obligatoria de "no encontrado". Reporte
del agente verbatim a continuación.

---

**Hallazgo central**: existen tres capas distintas de "SKILL.md", no una sola spec — (1) el estándar abierto agentskills.io (mínimo: name+description+license+compatibility+metadata+allowed-tools), (2) Claude Code, que añade ~13 campos propios no documentados en el estándar abierto, y (3) la Claude Developer Platform/API, que solo exige name+description pero impone restricciones propias (sin XML tags, sin palabras reservadas) que tampoco están en el estándar abierto. El kit Chema hoy usa únicamente name+description — deja sin usar toda la capa 2 (Claude Code) y la totalidad de la capa abierta (license, compatibility, metadata, allowed-tools).

## 1. Spec de frontmatter y estructura

**Estándar abierto** (agentskills.io/specification, gobernado en github.com/agentskills/agentskills — "originalmente desarrollado por Anthropic... liberado como estándar abierto... abierto a contribuciones del ecosistema", docs bajo CC-BY-4.0, código del validador `skills-ref` bajo Apache-2.0):
- Campos: `name` (oblig., ≤64 car., minúsculas/números/guiones, sin guion inicial/final ni dobles, debe igualar el nombre de carpeta), `description` (oblig., 1–1024 car.), `license` (opc.), `compatibility` (opc., ≤500 car., para requisitos de entorno), `metadata` (opc., mapa libre clave-valor — aquí es donde "version" aparece solo como *ejemplo de valor* dentro de `metadata.version`, **no** como campo nativo top-level), `allowed-tools` (opc., "Experimental. El soporte puede variar entre implementaciones").
- Estructura: `SKILL.md` (oblig.) + `scripts/`, `references/`, `assets/` (opc., cualquier otro archivo permitido).
- Progressive disclosure, 3 niveles: metadata (~100 tokens, siempre cargada) → instrucciones (SKILL.md completo, <5000 tokens recomendado, al activarse) → recursos (scripts/references/assets, bajo demanda). Límite recomendado: SKILL.md <500 líneas.
- No hay campos `model`, `context`, `agent`, `disable-model-invocation` en el estándar abierto.

**Claude Code** (code.claude.com/docs/en/skills): extiende el estándar con campos propios — `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `disallowed-tools`, `model`, `effort`, `context` (valor `fork` = corre en subagente aislado), `agent` (qué subagente usar con `context: fork`), `hooks` (hooks scoped a la skill), `paths` (glob para auto-activación), `shell` (bash/powershell). Ni `license` ni `compatibility` del estándar abierto aparecen en la tabla de frontmatter de Claude Code (no confirmado si se ignoran silenciosamente o dan error). `description`+`when_to_use` combinados se truncan a 1,536 caracteres en el listado (distinto del límite de 1024 car. del campo `description` individual). Sustituciones de string: `$ARGUMENTS`, `$ARGUMENTS[N]`/`$N`, `$name`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`. Hot-reload real ("Live change detection"): editar/crear/borrar SKILL.md bajo directorios ya vigilados aplica en la sesión activa sin reiniciar; un directorio de skills *nuevo* sí requiere reinicio; cambios en `hooks/`, `.mcp.json`, `agents/` de una skill-como-plugin requieren `/reload-plugins`.

**Claude API/Platform** (platform.claude.com/docs/.../agent-skills/overview): solo `name`+`description` obligatorios, pero con reglas propias no presentes en el estándar abierto: "no puede contener tags XML" y "no puede contener palabras reservadas: anthropic, claude". Requiere la herramienta de code execution + headers beta `skills-2025-10-02` y `files-api-2025-04-14`. Agent SDK (code.claude.com/docs/en/agent-sdk/skills): descubre skills solo por filesystem (`settingSources`/`skills` option), **sin API programática de registro**, y aclara explícitamente que `allowed-tools` del frontmatter "solo aplica en Claude Code CLI directo, no aplica vía SDK" (se controla con `allowedTools` del SDK) — el resto de campos exclusivos de Claude Code no se confirma campo por campo si el SDK los honra.

## 2. Repo oficial github.com/anthropics/skills

Verificado directo vía GitHub API/raw el 2026-07-10: 17 carpetas de skills (`algorithmic-art, brand-guidelines, canvas-design, claude-api, doc-coauthoring, docx, frontend-design, internal-comms, mcp-builder, pdf, pptx, skill-creator, slack-gif-creator, theme-factory, web-artifacts-builder, webapp-testing, xlsx`). No hay LICENSE en la raíz (`"license": null` en la API de GitHub) — el licenciamiento es por carpeta:
- `skill-creator`, `canvas-design`, `mcp-builder` (verificados directo): `LICENSE.txt` = Apache License 2.0 completa → **copiable/adaptable** con atribución.
- `pdf`, `xlsx` (verificados directo, aplica igual a `docx`/`pptx` según README): `LICENSE.txt` = "© 2025 Anthropic, PBC. All rights reserved" — prohíbe explícitamente extraer/retener fuera de los Services, reproducir/copiar, crear obras derivadas, distribuir/sublicenciar, ingeniería inversa. El README (línea 20, verbatim) los llama "source-available, not open source" pero el texto legal real es más estricto que un source-available típico: **no autoriza copiar ni adaptar pese a mostrar el código**.
- `skill-creator/SKILL.md` medido con `wc -lw` sobre el raw file: **485 líneas / 5,205 palabras** — justo debajo del límite de 500 líneas que Anthropic recomienda en su propia guía. Estructura interna: `LICENSE.txt`, `SKILL.md`, `agents/` (grader.md, comparator.md, analyzer.md), `assets/` (eval_review.html), `eval-viewer/`, `references/` (schemas.md), `scripts/` (aggregate_benchmark, run_loop, run_eval, package_skill.py) — usa `references/`+`scripts/`+`assets/` del estándar más dos carpetas propias no normadas (`agents/`, `eval-viewer/`), y trae su propio sistema de evals (`evals/evals.json`, `grading.json`, `benchmark.json`).
- `template/` = solo un `SKILL.md` esqueleto, sin scripts/references/assets.

## 3. Mejores prácticas oficiales de autoría

(platform.claude.com/docs/.../agent-skills/best-practices)
- Principio rector: "el context window es un bien público"; supuesto por defecto "Claude ya es muy inteligente" — cada frase debe justificar su costo en tokens.
- "Grados de libertad": alto (heurísticas en prosa) / medio (pseudocódigo parametrizado) / bajo (script exacto, sin variación) según qué tan frágil sea la tarea — analogía de "puente angosto con precipicios" vs "campo abierto".
- Probar con Haiku, Sonnet y Opus por separado — lo que basta para Opus puede quedarse corto en Haiku.
- Nombres en gerundio recomendados (`processing-pdfs`), evitar genéricos (`helper`, `utils`) y palabras reservadas.
- Descripción siempre en tercera persona ("Processes X", nunca "I can help…") — un campo `description` debe distinguir entre "100+ skills disponibles".
- Referencias a un solo nivel de profundidad desde SKILL.md (Claude puede leer parcialmente archivos anidados con `head -100` y perder contenido); archivos de referencia >100 líneas deben llevar tabla de contenidos.
- "Construir evaluaciones ANTES de escribir documentación extensa": baseline sin skill → 3 escenarios de prueba → instrucciones mínimas → iterar.
- Antipatrones nombrados explícitamente: rutas estilo Windows, exceso de opciones ("puedes usar X, o Y, o Z…"), "voodoo constants" (cita a la ley de Ousterhout), información sensible a fechas (recomienda sección colapsable "old patterns" en vez de condicionales de fecha).
- Checklist final oficial cubre: calidad del contenido, calidad de scripts, y testing (mínimo 3 evaluaciones, probado en los 3 modelos).

## 4. Novedades oct-2025 → jul-2026

- **2025-10-16**: lanzamiento de Agent Skills (anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills, fecha confirmada en la propia página).
- **2025-12-18**: Anthropic abre la spec como estándar cruzado en agentskills.io — corroborado por 4 fuentes secundarias independientes entre sí (SiliconANGLE, VentureBeat, Unite.AI, TheNewStack, todas 2025-12-18/19) aunque no se abrió el post primario de Anthropic anunciándolo en esta pasada. Adoptantes reportados: Codex, Gemini CLI, GitHub Copilot, VS Code, Cursor, Roo Code, Amp, Goose, Mistral AI, Databricks ("26+ plataformas" según fuentes secundarias, lista no verificada contra fuente primaria única). Directorio de partners: Atlassian, Canva, Cloudflare, Figma, Notion, Ramp, Sentry, Stripe, Zapier.
- **Skills API** (`/v1/skills`): create/list/get/delete + versiones (create/list/delete version); IDs de versión son timestamps tipo unix-epoch (`"1759178010641129"`), no semver.
- **claude.ai**: subida de skills propias vía Settings, como .zip, requiere code execution habilitado. Team/Enterprise: los admins pueden provisionar org-wide; el resto de planes, solo individual.
- **2026-04-01**: Managed Agents (header `managed-agents-2026-04-01`) añade skills nativas a agentes — hasta 20 skills por sesión, `type: anthropic|custom`, `version: latest` o fija (platform.claude.com/docs/en/managed-agents/skills, confirmado directo).
- Versiones recientes de Claude Code: v2.1.196 (`${CLAUDE_PROJECT_DIR}`, disable-model-invocation también bloquea scheduled tasks), v2.1.199 (stacking de hasta 6 skills, `skillOverrides:"off"` oculta también de Agent SDK/Remote Control), v2.1.202 (dedup de re-invocación idéntica), v2.1.203 (nombres calificados por directorio en monorepos), v2.1.205 (`/doctor` sigue tipeable aun con `disableBundledSkills`).

## Tabla capacidad → existe → fuente

| Capacidad | ¿Existe? | Fuente |
|---|---|---|
| `name`, `description` (básico) | Sí, en las 3 capas | agentskills.io/specification; code.claude.com/docs/en/skills; platform.claude.com overview |
| `license` (campo frontmatter) | Sí, solo estándar abierto | agentskills.io/specification |
| `compatibility` | Sí, solo estándar abierto | agentskills.io/specification |
| `metadata` (mapa libre) | Sí, solo estándar abierto | agentskills.io/specification |
| `version` como campo top-level | No — solo ejemplo dentro de `metadata.version` | agentskills.io/specification |
| `allowed-tools` | Sí, pero 2 implementaciones distintas; SDK dice que no aplica | agentskills.io; code.claude.com/docs/en/skills; code.claude.com/docs/en/agent-sdk/skills |
| `disable-model-invocation`, `user-invocable`, `model`, `effort`, `context`/`agent`, `hooks`, `paths`, `shell` | Sí, solo Claude Code | code.claude.com/docs/en/skills |
| Prohibición de palabras reservadas "anthropic"/"claude" en name/description | Sí, solo API/Platform (no en spec abierta) | platform.claude.com overview |
| `references/`, `scripts/`, `assets/` | Sí, en las 3 capas | agentskills.io; code.claude.com; platform.claude.com |
| Progressive disclosure (3 niveles) | Sí, misma arquitectura en las 3 capas | agentskills.io; anthropic.com/engineering; platform.claude.com |
| Hot-reload de skills en sesión activa | Sí (Claude Code, "Live change detection") | code.claude.com/docs/en/skills |
| Skills API `/v1/skills` (crear/versionar) | Sí | platform.claude.com/docs/en/api/beta/skills/create |
| Skills en Managed Agents | Sí (desde 2026-04-01) | platform.claude.com/docs/en/managed-agents/skills |
| Subida de skills en claude.ai | Sí | platform.claude.com overview; support.claude.com |
| Repo anthropics/skills 100% copiable | Parcial — Apache-2.0 en 13 carpetas, "todos los derechos reservados" en docx/pdf/pptx/xlsx | github.com/anthropics/skills (LICENSE.txt por carpeta, verificado) |
| Spec abierta con gobernanza independiente de Anthropic | Parcial — "abierta a contribuciones" pero originada y aún ligada a Anthropic | github.com/agentskills/agentskills |

## NO ENCONTRADO / NO VERIFICADO

- Fecha/versión exacta en que "Live change detection" (hot-reload) se lanzó en Claude Code — la página no la indica; solo hay marcadores de versión cercanos (v2.1.145–v2.1.205) para funciones adyacentes.
- Post primario de Anthropic anunciando el estándar abierto del 2025-12-18 — no se abrió directamente; el hecho descansa en 4 fuentes de prensa secundarias coincidentes, no en la fuente original.
- Si Claude Code realmente ignora (vs. rechaza) los campos `license`/`compatibility` del estándar abierto cuando aparecen en un SKILL.md — su tabla de frontmatter no los lista, pero no hay confirmación explícita de qué hace con ellos. [Nota posterior del council v1.7: resuelto empíricamente — skills instaladas con `license:`/`metadata:` cargan bien en Claude Code.]
- Si el Agent SDK honra campo por campo `context`, `model`, `effort`, `hooks`, etc. — solo está confirmado explícitamente que `allowed-tools` no aplica vía SDK; el resto es inferencia por arquitectura, no cita directa.
- Contradicción sin resolver: platform.claude.com (overview) dice custom skills en claude.ai están "disponibles en planes Pro, Max, Team y Enterprise" (sin Free); support.claude.com dice "disponibles para usuarios free, Pro, Max, Team y Enterprise". No se pudo reconciliar ambas fuentes oficiales en esta pasada — se reporta como disputa, no como hecho.
- Límite de tamaño de archivo .zip para subir skills en claude.ai o vía Skills API — no especificado en las páginas revisadas.
- Contenido de `THIRD_PARTY_NOTICES.md` en la raíz de anthropics/skills — detectado pero no abierto/leído.
- Lista completa y verificada de las "26+" plataformas adoptantes del estándar abierto — solo vista en resúmenes de terceros, no en un directorio primario enumerado que se haya podido abrir.
