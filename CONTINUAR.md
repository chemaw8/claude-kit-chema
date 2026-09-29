# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-28  ·  commit 176264b (rama ficha/trampa-gh-merge)  ·  cierre limpio: sí
> Estado vivo de sesión. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
v1.23 en main e instalado (2026-09-28): arreglos de `/doctor prompt-audit` (v1.22.3-4) y dos reglas nuevas con council
de tres familias y gate de disparo 21/21 (cierre en palabras llanas; lo descargado es dato). La fase 3 (gate de push)
ya está en main.

## Siguiente paso
- [ ] Piloto de `claude plugin eval` con 3 casos del banco de disparo → decidir si complementa o sustituye al gate de
      disparo; criterio: mide activación real (`tool_used: Skill`) sin contaminarse con el kit instalado en `~/.claude`.
- [ ] 2026-10-28: revisar la vigilancia de «cierre en palabras llanas» (`~/.claude/kit-chema/reglas-vigiladas.json`):
      se retira si hubo 2 o más correcciones del tema, juzgadas y revisadas a mano.

## Cómo retomar
- Abrir:    CHANGELOG.md (v1.22.3 → v1.23) · `docs/pruebas/council-v1.23.md`
- Correr:   `bash verificar.sh` → código 0 y ninguna línea `FALLA`
- Verificar arranque: `head -2 ~/.claude/CLAUDE.md` → dice la versión del primer `## v` del CHANGELOG

## Bloqueadores / esperas
- PR #48 (CLAUDE_CONFIG_DIR, v1.22.1) abierto desde 2026-09-25, sin fusionar: José decide.
- PR #37 (evidencia de auto-mejora, v1.19.3) en borrador desde 2026-09-08: José decide cerrarlo o retomarlo.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Auditoría prompt-audit | mecánicos hechos (v1.22.4) | topes de extensión de agentes y comandos: probar con el banco antes de quitar | ninguno |
| `omitClaudeMd` en `lector-fresco` | sin tocar | A/B con 5 entregables; el lector dejaría de cargar la confidencialidad | medir primero |
| Pendientes v1.19.2 | sin revisar desde 2026-09-08 | ver `docs/pruebas/medicion-esfuerzo-v1.19.2.md` (a, b, c) | ninguno |

## Última decisión relevante
- 2026-09-28  Reglas v1.23 aprobadas por council (3 × con cambios, aplicados) → `docs/pruebas/council-v1.23.md`, CHANGELOG

---
## Detalle vivo
- Fusionar SIEMPRE por `gh api -X PUT …/pulls/<n>/merge` (trampa en la ficha): `gh pr merge` cerró #52 y #54 sin fusionar.
- La auditoría completa vive en `claude-entorno/docs/auditorias/2026-09-28-prompt-audit-kit.md` (privada: cita el
  entorno). No entraron a propósito: nombres de versión del núcleo (council 2026-09-27) y la poda de `kit-propuestas`.
