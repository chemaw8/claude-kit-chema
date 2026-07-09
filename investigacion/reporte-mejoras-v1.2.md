# Kit Chema: ¿plugin? Reporte de recomendación

## 1. Decisión: HÍBRIDO

**Empaquetar como plugin todo lo que encaja nativamente (las 7 skills y el hook de enforcement) y dejar el núcleo como el CLAUDE.md siempre-activo que hoy tiene.** No es "sí" puro ni "no" — y la razón es un hecho técnico, no una preferencia.

### El hecho que lo decide
Un plugin **no puede** aportar un CLAUDE.md que se cargue en toda conversación. La documentación oficial es literal:

> "A CLAUDE.md file at the plugin root is not loaded as project context. Plugins contribute context through skills, agents, and hooks rather than CLAUDE.md. To ship instructions that load into Claude's context, put them in a skill."
> — https://code.claude.com/docs/en/plugins-reference

Los CLAUDE.md siempre-activos solo existen en 4 ubicaciones fijas (managed-policy, `~/.claude/CLAUDE.md`, `./CLAUDE.md`, `./CLAUDE.local.md`) y **ninguna la provee un plugin** (https://code.claude.com/docs/en/memory). El corazón del Kit Chema es exactamente eso: `nucleo/CLAUDE.md` (78 líneas), instalado hoy como bloque marcado dentro de `~/.claude/CLAUDE.md`.

### Se puede emular, pero cuesta
Hay dos vías documentadas para meter el núcleo desde un plugin, y ninguna es gratis:

- **Hook SessionStart** que emite `hookSpecificOutput.additionalContext` (matcher `startup|resume|clear|compact`). Reinyecta el núcleo tras cada arranque, `/clear` y compactación. Pero se entrega como *system-reminder* — contexto blando — y la propia doc dice: *"For static context that doesn't require a script, use CLAUDE.md instead"* (https://code.claude.com/docs/en/hooks). Es el fallback, no la vía preferida; y frasear el núcleo como órdenes imperativas puede disparar las defensas anti-inyección de Claude.
- **Clave `agent` del settings.json del plugin**, que activa un agente propio como hilo principal con su system prompt (*"This lets a plugin change how Claude Code behaves by default when enabled"*). Más cercano a fijar comportamiento, pero cambia el comportamiento base de Claude Code y esos agentes de plugin **no admiten** `hooks`, `mcpServers` ni `permissionMode` (https://code.claude.com/docs/en/plugins-reference). Demasiado pesado para lo que se busca.

### Por qué híbrido y no forzar todo al plugin
El principio rector del propio kit es **brevedad y proporcionalidad: no meter un script donde un archivo estático nativo hace el trabajo.** El núcleo es estático y pequeño (78 líneas, bajo control). El mecanismo nativo, preferido por la doc y sin riesgo anti-inyección para contexto estático, es un CLAUDE.md. Meterlo en un hook sería sobre-ingeniería salvo que la instalación-de-un-comando del núcleo sea un requisito duro.

Al mismo tiempo, el resto del kit **sí gana mucho** como plugin: las 7 skills ya están en formato `skills/<n>/SKILL.md` (nativo), y el hook `PreToolUse` anti-secretos es enforcement real. El plugin aporta instalación de un comando, actualizaciones versionadas y auto-habilitación para el equipo — un patrón que el `settings.json` del usuario **ya usa** (`enabledPlugins` + `extraKnownMarketplaces`).

## 2. Arquitectura recomendada

| Componente | Hoy | Con el híbrido |
|---|---|---|
| Núcleo (`nucleo/CLAUDE.md`, 78 líneas) | Bloque marcado en `~/.claude/CLAUDE.md` vía `instalar.sh` | **Sigue como CLAUDE.md siempre-activo** (instalar.sh mínimo, o `./CLAUDE.md` comprometido en el repo del equipo). Alternativa si se exige un-comando: hook SessionStart en el plugin. |
| 7 skills | `~/.claude/skills/kit-*` vía copia | **Plugin** (`skills/<n>/SKILL.md`), namespace `/kit-chema:kit-codigo` |
| Hook anti-secretos (`PreToolUse` en Bash) | Fragmento en `settings.json` del usuario | **Plugin** (`hooks/hooks.json`, ruta `${CLAUDE_PLUGIN_ROOT}/hooks/anti-secretos.sh`) — enforcement real, viaja versionado |
| Plantillas de contexto | Copia a `~/.claude/contexto/` si no existen | Comando `/kit-chema:init-contexto` (o paso mínimo de instalar.sh); un plugin no escribe en el home del usuario |

**Lo que se pierde (poco):** las skills pasan a namespace largo (afecta la invocación manual, no el auto-trigger). Y el núcleo, si se emula por hook, es contexto blando — pero **el CLAUDE.md de hoy también lo es**, así que el cumplimiento no empeora. Lo único duro que se pierde es la carga directa de un CLAUDE.md de *usuario*; se sustituye por CLAUDE.md de proyecto o por el hook.

## 3. Ruta de migración
Ver la lista de pasos concretos en el campo `ruta_plugin`. En resumen: `plugin.json` sin versión durante desarrollo interno; mover skills (ya listas); convertir el fragmento del hook a `hooks/hooks.json` con `${CLAUDE_PLUGIN_ROOT}`; decidir la entrega del núcleo (CLAUDE.md recomendado); shippear el contexto vía comando; probar con `claude --plugin-dir ./` + `claude plugin validate` + auditar coste con `/context`; publicar por `marketplace.json`; auto-habilitar comprometiendo `extraKnownMarketplaces` + `enabledPlugins`; borrar duplicados de `~/.claude/`.

## 4. Distribución y versionado
- Marketplace en GitHub (privado si es interno): `/plugin marketplace add innovattia/kit-chema` + `/plugin install kit-chema@kit-chema`. Reemplaza `git clone` + `./instalar.sh` (https://code.claude.com/docs/en/plugin-marketplaces).
- **Versionado**: durante desarrollo interno, omitir `version` (cada commit se propaga). Al estabilizar, semver + CHANGELOG.md y **subir la versión en cada release** o el equipo no recibe cambios (https://code.claude.com/docs/en/plugins-reference).
- Repo privado + auto-updates: documentar `GITHUB_TOKEN` de solo-lectura.

## 5. Salvaguardas contra la degradación del kit
El riesgo real es la combinación de: (a) merge a main sin revisión, (b) un PR de fork con acceso a secretos, (c) nadie valida tamaño/contradicciones/activación de skills, y (d) el "aprender de correcciones" infla el archivo hasta degradar el comportamiento (*context rot*) o alguien inyecta una instrucción maliciosa plausible. El vector de mayor impacto es precisamente el núcleo: se carga sin el filtro anti-inyección que Claude aplica a otros archivos, por diseño (https://pete-builds.github.io/articles/harden-claude-code-prompt-injection/).

Las defensas priorizadas están en el campo `salvaguardas`. Las de mayor apalancamiento (ALTA): branch protection con *include administrators*, CODEOWNERS sobre `nucleo/` y `skills/`, CI de forks sin secretos (nunca `pull_request_target` con checkout del fork), linter de límites/anti-bloat, y **council obligatorio + la regla nunca escribe directo** (siempre PR en borrador). Como recuerda la investigación: ningún control de GitHub detecta una instrucción maliciosa bien escrita — **el control de más alto valor sigue siendo humano** (revisores designados que entiendan el propósito del kit).

Fuentes de gobernanza: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches · https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners · https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target · https://securitylab.github.com/resources/github-actions-preventing-pwn-requests/ · https://www.trychroma.com/research/context-rot · https://www.promptfoo.dev/docs/red-team/owasp-llm-top-10/ · https://github.com/BerriAI/self-improving-agent · https://yoheinakajima.com/better-ways-to-build-self-improving-ai-agents/

## 6. Guía de contexto
Ver `guia_contexto_md`. En una frase: cada línea debe pasar la prueba *"¿Claude fallaría sin esto?"*; priorizar audiencias + ejemplos "así sí/así no" + glosario; límite duro (empresa 100-150 líneas, personal 60-80); dejar vacío antes que rellenar de relleno. Fuentes: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents · https://code.claude.com/docs/en/memory · https://code.claude.com/docs/en/best-practices

## 7. Fuentes principales
- Plugins: https://code.claude.com/docs/en/plugins
- Plugins reference: https://code.claude.com/docs/en/plugins-reference
- Memory / CLAUDE.md: https://code.claude.com/docs/en/memory
- Hooks: https://code.claude.com/docs/en/hooks
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces
- Best practices (tamaño, hooks vs texto): https://code.claude.com/docs/en/best-practices

*Nota de verificación: las 6 afirmaciones clave sobre plugins fueron verificadas contra la doc oficial en vivo y ninguna quedó refutada; el único matiz es de citación (la frase del `agent` está en /plugins, no en /plugins-reference), no de sustancia.*