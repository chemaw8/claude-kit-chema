# Investigación: ecosistema de skills de la comunidad (2026-07-10)

Insumo del council v1.7 (`docs/pruebas/council-v1.7.md`). Método: subagente
investigador (Sonnet) con acceso web, estándar kit-research (2+ fuentes
independientes por afirmación clave, cifras de GitHub verificadas vía API en
vivo). ECC (affaan-m) excluido a propósito: ya se cosechó en v1.6. Reporte del
agente verbatim a continuación.

---

**ECC (affaan-m):** sin cambio mayor desde 2026-07-08 — solo rename a `ECC` y release v2.0.0 del 2026-06-10 (anterior al corte); 228,257★ vía API.

## 1. Colecciones y frameworks

| Proyecto | Qué aporta arquitectónicamente | Licencia | Adopción (API GitHub, 2026-07-10) |
|---|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) (Jesse Vincent + Prime Radiant) | 14 skills + metodología (brainstorm→TDD→debug→review) | MIT | 251,750★/22,462 forks; push hoy; release v6.1.1 (07-02) |
| [prime-radiant-inc/superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals) | Harness "drill/Quorum": sesiones tmux reales multi-CLI (Claude/Codex/Gemini/Kimi) + LLM verificador que juzga activación | Sin licencia | 72★; creado 2026-05-13 (nuevo) |
| [anthropics/skills](https://github.com/anthropics/skills) | Repo oficial: pdf/docx/xlsx/pptx + `skill-creator` (meta-skill oficial) | Sin licencia raíz (por carpeta) | 160,115★/18,896 forks |
| [agentskills.io](https://agentskills.io) | Estándar abierto del formato SKILL.md; adoptado por Cursor, OpenCode, Gemini CLI, Copilot, Goose, Letta y ~40 más | Apache-2.0 | 22,877★; estándar formalizado 2025-12-19 |
| [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Marketplace oficial (`/plugin marketplace`); interno + `external_plugins/` con aprobación | Apache-2.0 | 31,954★; creado 2025-11-20 |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Lista más amplia (skills+comandos+agentes) | NOASSERTION | 49,735★; push hoy |
| [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | ~200 skills/12 categorías; vendor (Composio) | Sin licencia | 67,407★; sin push hace 7 semanas |
| [skillsmp.com](https://skillsmp.com) | Índice de SKILL.md públicos, filtro ≥2★; sin instalación propia | — | "2M+ skills" autoreportado sin auditar (terceros dan 26k–1.6M, no reconciliado) |
| [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) | CLI instalador (`npx … skills add`) desde catálogo propio o cualquier repo | MIT | 28,752★ |
| [wshobson/agents](https://github.com/wshobson/agents) | 1 fuente Markdown → artefactos nativos para 5 herramientas | MIT | 37,763★; push 07-08 |

No existe marketplace comunitario dominante llamado literalmente "claude-plugins": solo directorios SEO fragmentados (ClaudePluginHub, Claude Bazaar) que enlazan a GitHub o al marketplace oficial.

## 2. Patrones de arquitectura

| Patrón | Quién lo usa | Madurez |
|---|---|---|
| (a) Meta-skill | Anthropic `skill-creator` ([blog 2026-03-03](https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills)); superpowers `writing-skills` | Consolidado — 2 implementaciones independientes |
| (b) Router/índice central | rohunj/claude-build-workflow (`SKILLS-INDEX.md`, vía DeepWiki); "Skill Router" de crossaitools.com | Emergente — evidencia débil, sin fuente cruda confirmada |
| (c) Eval de activación | Anthropic (loop en skill-creator); [Scott Spence](https://scottspence.com/posts/measuring-claude-code-skill-activation-with-sandboxed-evals) (sandboxes Daytona); [Ivan Seleznov](https://medium.com/@ivan.seleznov1/why-claude-code-skills-dont-activate-and-how-to-fix-it-86f679409af1) (650 corridas); superpowers-evals | Consolidado y activo — no es práctica rara |
| (d) Versión/changelog por skill individual | NO ENCONTRADO como práctica real (solo a nivel de repo completo) | No verificado / probablemente inexistente |
| (e) Composición skill→skill | superpowers: *"writing-skills requiere entender superpowers:test-driven-development"* (cita verificada en archivo crudo) | Confirmado, pero un solo ecosistema; sin campo formal en la spec |
| (f) Hooks + skills | Anthropic oficial ([blog 2026-06-18](https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more)): *"el modelo eligiendo correr un formateador es distinto de que el formateador corra automáticamente"*; nizos/tdd-guard; forced-eval hook de Spence | Consolidado, con guía oficial explícita |
| (g) "Cuándo no usar" en description | Comunidad, aislado: Seleznov mide que la negación explícita sostiene activación bajo presión donde la versión directiva simple cae | Dato único, no replicado |
| (h) Español/multiidioma | tododeia.com (40 skills), abracu/Claude-Skills (6★), alexdcd/Mafia-Claude-Skills (39★) | Existe pero es marginal (decenas de★ vs. cientos de miles en inglés) |

Nota (c): línea base sin hook 50-55%, con *forced-eval hook* 100% en 22 casos estándar (75% en 24 casos límite, 0 falsos positivos; costo del experimento USD 5.59 — Spence). Seleznov: línea base ~50%, descripción con negación explícita 100%, versión directiva simple cae a 37% bajo hook adversarial.

## 3. Guía de practicantes reconocidos

**Consenso (2+ voces):** Skill = procedimiento reutilizable que carga bajo demanda; MCP = acceso a sistemas externos; capas complementarias, no rivales — "si se repite más de 2 veces, hazlo skill". SKILL.md conciso, <500 líneas, ~100 tokens de metadata por skill: lo dicen Willison, la documentación oficial y las guías técnicas 2026 revisadas.

**Simon Willison** ([timeline oct-2025→jun-2026](https://simonwillison.net/tags/skills/)): prefiere skills sobre MCP ("casi todo lo que lograría con un MCP lo resuelve una CLI"); no reporta degradación por muchas skills instaladas (opinión propia, sin dato); en jun-2026 matiza que MCP aventaja en aislar autenticación fuera del contexto.

**Jesse Vincent** (autor de superpowers, [9-oct-2025](https://blog.fsck.com/2025/10/09/superpowers/)): el problema no es que Claude sea tonto sino "eager" (arranca a codear sin preguntar); usa principios de persuasión de Cialdini en las instrucciones porque "funcionan también en LLMs"; pressure-tests cada skill con subagentes antes de publicarla.

**Minko Gechev** (ex-Angular/Google, [skills-best-practices](https://github.com/mgechev/skills-best-practices), 2,111★): "escribe para agentes, no para humanos"; valida en 4 etapas (discovery/lógica/edge cases/arquitectura) y construyó [SkillGrade](https://github.com/mgechev/skillgrade) (568★, MIT) para regresión automatizada con jueces LLM.

**Opinión aislada:** Hamel Husain ([evals-skills](https://github.com/hamelsmu/evals-skills)) prioriza skills de dominio propio sobre genéricas, sin pronunciarse sobre tamaño o testing de activación.

## NO ENCONTRADO / NO VERIFICADO

- Marketplace "claude-plugins" dominante: no existe; solo directorios SEO fragmentados.
- Adopción real de superpowers en usuarios: fuentes secundarias dan 50,000–140,000 developers, sin fuente primaria propia; usar solo el dato de API (251,750★).
- Fecha exacta de ingreso de superpowers al marketplace oficial: una sola fuente secundaria (2026-01-15), sin confirmar.
- "Semantic router" con ahorro 456x/87.5% top-5 (HackerNoon): fuente única; no se pudo verificar el artículo directo (error 403 al fetch).
- Límite de "20 skills por sesión": documentado solo para Managed Agents de la plataforma, no para Claude Code. El límite real en Claude Code es otro: presupuesto de ~16,000 caracteres en `available_skills`, confirmado en [issue anthropics/claude-code#13099](https://github.com/anthropics/claude-code/issues/13099) — con 63 skills instaladas, 21 (33%) quedaron invisibles sin aviso.
- Estudios de Spence y Seleznov: cada uno es un único investigador/dataset, no replicado por un segundo equipo.

## Licencias de lo copiable

**MIT** (libre, atribución mínima): superpowers, SkillGrade, hamelsmu/evals-skills, davila7/claude-code-templates, wshobson/agents, karanb192/awesome-claude-skills.
**Apache-2.0** (libre, exige aviso de cambios): estándar agentskills.io, marketplace oficial de Anthropic.
**Sin licencia declarada** (no asumir reuso libre pese a ser público): anthropics/skills a nivel raíz (licencias por carpeta: ver reporte de spec oficial), superpowers-evals, mgechev/skills-best-practices, ComposioHQ/awesome-claude-skills.
**NOASSERTION**: hesreallyhim/awesome-claude-code.
