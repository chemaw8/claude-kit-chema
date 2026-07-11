# Investigación: vías de distribución de skills fuera de Claude Code (2026-07-10)

Insumo del council v1.7 (`docs/pruebas/council-v1.7.md`). Método: subagente
investigador (Sonnet) con acceso web, estándar kit-research. Pregunta de fondo:
¿cómo usa las skills del kit un colega que no tiene Claude Code? Reporte del
agente verbatim a continuación.

---

## 1. claude.ai — subir/crear skills custom

**Pasos (cuenta individual, cualquier plan):**
1. Settings → Capabilities → activar "Code execution" y "File creation" (obligatorio; sin esto Skills no funciona) — [support.claude.com/12512180](https://support.claude.com/en/articles/12512180-use-skills-in-claude), [support.claude.com/12512198](https://support.claude.com/en/articles/12512198-creating-custom-skills), consultado 2026-07-10.
2. Customize → Skills → "+" → "Upload a skill" → subir .zip con carpeta que incluya `SKILL.md` (mismas fuentes).
3. El skill queda privado a la cuenta; se activa/desactiva individualmente.

**Planes:** hoy, "Free, Pro, Max, Team, and Enterprise" (confirmado en 3 artículos del Help Center, 2026-07-10). Ojo con la evolución: el lanzamiento original (claude.com/blog/skills, 16-oct-2025, consultado 2026-07-10) excluía Free ("Pro, Max, Team and Enterprise users. Free plan users do not have access"); Free se sumó en una expansión posterior (~feb-2026 según cobertura de prensa, fecha exacta no localizada) que trajo también file creation y connectors al plan gratuito.

**Team/Enterprise — quién habilita:** el *organization owner*, en Organization settings → Skills, sube el .zip y "the skill is immediately provisioned to all users in your organization", activo por default (usuarios pueden apagarlo) — [support.claude.com/13119606](https://support.claude.com/en/articles/13119606-provision-and-manage-skills-for-your-organization), 2026-07-10. Para limitar a un grupo: empaquetar el skill en un plugin y asignarlo a ese grupo. Anuncio oficial de esta función admin + directorio de socios (Notion, Canva, Figma, Atlassian, Cloudflare, Sentry, Vercel, Zapier) + el estándar abierto "Agent Skills": [claude.com/blog/organization-skills-and-directory](https://claude.com/blog/organization-skills-and-directory), 18-dic-2025, consultado 2026-07-10.

**¿Ejecutan scripts?** Sí, Python/Node vía code execution — [support.claude.com/12512198](https://support.claude.com/en/articles/12512198-creating-custom-skills). Acceso a red: variable, según configuración usuario/admin — [platform.claude.com/agent-skills/overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview), 2026-07-10.

**Límites confirmados:** nombre ≤64 caracteres (minúsculas/números/guiones, sin "anthropic"/"claude"); descripción ≤1024 caracteres, spec general (misma fuente). Tamaño de zip: la API exige <30MB — [platform.claude.com/skills-guide](https://platform.claude.com/docs/en/build-with-claude/skills-guide), 2026-07-10; para la UI de claude.ai no se halló cifra dedicada (ver NO ENCONTRADO).

**¿Sirven en Projects?** Sí, se complementan: Projects = contexto estático siempre cargado; Skills = procedimientos que se activan dinámicamente y funcionan "everywhere across Claude" — [support.claude.com/12512176](https://support.claude.com/en/articles/12512176-what-are-skills), 2026-07-10.

## 2. Qué NO viaja fuera de Claude Code

- **CLAUDE.md** (`~/.claude/CLAUDE.md` o de proyecto): archivo leído del filesystem local por el CLI; sin equivalente en claude.ai — [code.claude.com/docs/en/settings](https://code.claude.com/docs/en/settings), 2026-07-10. Sustituto parcial: "Profile preferences" (Settings → Profile) — un solo campo de texto global, sin jerarquía usuario/proyecto (fuentes de terceros que comparan ambos, no un artículo oficial dedicado; verificar con cautela).
- **Hooks** (SessionStart, PreToolUse…): viven en `settings.json` de Claude Code, exclusivos de esa herramienta — [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks), 2026-07-10. Nada equivalente documentado en claude.ai.
- **Subagentes:** "Available in Claude Code and the Claude Agent SDK" — explícitamente no en claude.ai — [claude.com/blog/skills-explained](https://claude.com/blog/skills-explained) y [code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents), ambos 2026-07-10.
- **Comandos slash de plugins** (ej. `/commit-commands:commit`): ligados a `/plugin install` del CLI; claude.ai activa skills solo automáticamente por relevancia, sin slash commands documentados — [code.claude.com/docs/en/discover-plugins](https://code.claude.com/docs/en/discover-plugins), 2026-07-10.

**Conclusión:** un colega solo-claude.ai puede tener Skills, pero no reglas-siempre-activas tipo CLAUDE.md (solo un campo de perfil plano), ni hooks, ni subagentes, ni comandos slash de plugin.

## 3. Distribución en equipo dentro de Claude Code

1. `/plugin marketplace add <owner/repo>` (GitHub, URL git, ruta local o URL a `marketplace.json`).
2. `/plugin install <plugin>@<marketplace>`, eligiendo scope User/Project/Local.
3. `/reload-plugins` para activar sin reiniciar. — Todo en [code.claude.com/docs/en/plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) y [.../discover-plugins](https://code.claude.com/docs/en/discover-plugins), 2026-07-10.

**¿Auto-actualiza?** El marketplace oficial (`claude-plugins-official`) trae auto-update ON por default; marketplaces de terceros/locales lo traen OFF (se activa manual en /plugin → Marketplaces). Un admin puede forzarlo con `"autoUpdate": true` en `extraKnownMarketplaces` de managed settings. Variables `DISABLE_AUTOUPDATER` / `FORCE_AUTOUPDATE_PLUGINS=1` dan control fino (misma fuente).

**Managed settings de empresa:** sí, un admin de sistema puede forzar/pre-instalar, vía archivo `managed-settings.json` (macOS `/Library/Application Support/ClaudeCode/`, Linux `/etc/claude-code/`, Windows `C:\Program Files\ClaudeCode\`) o MDM (Jamf, Kandji, Intune, Group Policy) — [code.claude.com/docs/en/settings](https://code.claude.com/docs/en/settings), 2026-07-10. Puede forzar: permisos (`allowManagedPermissionRulesOnly`), hooks (`allowManagedHooksOnly`, bloquea los de usuario/proyecto salvo los de plugins forzados), marketplaces (`strictKnownMarketplaces`, `blockedMarketplaces`), plugins (`enabledPlugins`, scope "managed", no modificable por el usuario), MCP servers, y memoria organizacional tipo CLAUDE.md vía el campo `claudeMd` (solo válido en managed/policy, ignorado si se define en user/project). Managed tiene prioridad máxima, no se puede sobreescribir.

**Skills API (`/v1/skills`):** para desarrolladores que construyen apps sobre la Claude API (Messages API + code execution tool, headers beta `skills-2025-10-02` + `files-api-2025-04-14`), no para usuarios de chat. CRUD completo, versionado, skills privados por workspace — [platform.claude.com/skills-guide](https://platform.claude.com/docs/en/build-with-claude/skills-guide), 2026-07-10. No sincroniza con claude.ai ni Claude Code: "Custom Skills do not sync across surfaces" — [platform.claude.com/agent-skills/overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview), 2026-07-10.

## 4. skill-creator oficial

[github.com/anthropics/skills/tree/main/skills/skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator), consultado 2026-07-10. Meta-skill: entrevista al usuario (intención, triggers, formato esperado) → escribe `SKILL.md` → genera 2-3 casos de prueba (`evals/evals.json`) → corre evaluaciones en paralelo (con-skill vs. baseline, vía subagentes) → grada e itera → empaqueta con `python -m scripts.package_skill <carpeta>`. Tiene modo explícito "Claude.ai (no subagents)": pruebas secuenciales, sin benchmarking cuantitativo. Extensión: ~485 líneas/32KB. Licencia: repo con licencias mixtas — la mayoría de skills de ejemplo son Apache 2.0; los skills de documentos (docx/pdf/pptx/xlsx) son "source-available, not open source" (README del repo). Nota: un fetch directo del LICENSE de la carpeta skill-creator devolvió 404 en esta pasada, mientras el reporte de spec oficial (misma fecha) sí verificó `LICENSE.txt` Apache 2.0 en esa carpeta — discrepancia anotada; si algún día se copia texto literal, confirmar primero.

## Tabla resumen

| Vía | Quién puede | Qué incluye | Qué se pierde |
|---|---|---|---|
| claude.ai personal | Cualquiera, Free–Enterprise, code execution ON | Skills .zip, activación automática, scripts Python/Node | CLAUDE.md, hooks, subagentes, slash commands, gestión centralizada |
| claude.ai Team/Ent (admin) | Organization owner | Provisión org-wide vía Organization settings, default-on, agrupable por plugin | Sigue sin hooks/subagentes/CLAUDE.md |
| Claude Code individual | Cualquiera con CLI | Kit completo: skills + CLAUDE.md + hooks + subagentes + slash commands | Nada del kit; sí, alcance limitado a quien instale el CLI |
| Claude Code equipo (marketplace) | Miembros del equipo / admin | Marketplace propio, `/plugin marketplace add` + `install`, auto-update configurable | Requiere que todos instalen Claude Code |
| Managed settings empresa | Admin IT (archivo o MDM) | Fuerza hooks, plugins, marketplaces, memoria org, permisos | Solo aplica a quienes ya usan Claude Code |
| Skills API (`/v1/skills`) | Desarrolladores sobre la API | CRUD de skills para apps propias | No es para chat; no toca claude.ai ni Claude Code |

## NO ENCONTRADO / NO VERIFICADO

- Tamaño exacto de .zip para skills en la **UI** de claude.ai (solo se confirmó 30MB general de archivos y 30MB de la API; ninguna cifra dedicada a skills-en-claude.ai).
- Límite de "200 caracteres" en el campo descripción de la UI de claude.ai: aparece en un solo resumen, sin confirmación verbatim ni segunda fuente — contradice el máximo de 1024 caracteres de la spec general.
- Cifra de "máx. ~20 skills instalables" u "8-12 recomendadas": solo en blogs no oficiales (aiwiki.ai, Stackademic), sin respaldo en documentación de Anthropic.
- Fecha exacta (día) de la expansión de Skills al plan Free — prensa la ubica "~febrero 2026", sin post oficial con fecha localizado.
- Comportamiento específico en apps desktop/móvil de claude.ai (toda la evidencia describe la web).
- **Contradicción no resuelta entre dos documentos oficiales vigentes al 2026-07-10:** [platform.claude.com/agent-skills/overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) afirma que Skills en claude.ai están disponibles solo "Pro, Max, Team, and Enterprise" y que "claude.ai does not support centralized admin management or org-wide distribution of custom Skills"; mientras que 3 artículos de support.claude.com (12512180, 12512198, 12512176) y el blog de Anthropic del 18-dic-2025 afirman lo contrario en ambos puntos. Lectura más probable: la doc de plataforma quedó desactualizada tras el lanzamiento de la consola admin y la expansión a Free, pero Anthropic no lo confirma explícitamente. Para el kit es irrelevante en la práctica: todos los usuarios son de paga.
