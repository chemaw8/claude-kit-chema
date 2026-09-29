# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-29  ·  commit 41968dd (rama main)  ·  cierre limpio: sí
> Estado vivo de sesión. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**Estado al 2026-09-29:** v1.23.1 en main e instalado. `sello-push revisar` fija HEAD y sale con 4 si hubo un commit
mientras revisaba (PR #57). Piloto de `plugin eval` hecho: complementa al gate de disparo, no lo sustituye
(`docs/pruebas/piloto-plugin-eval.md`).

## Siguiente paso
- [ ] `plugin eval` como medición periódica: casos con su material (CSV vía `scaffold_script`) y núcleo en
      `append_system_prompt`; empezar por repetir #16 (kit-finanzas no se activó en «¿cuánto le cobramos?», 0/4 sin núcleo).
- [ ] 2026-10-28: revisar la vigilancia de «cierre en palabras llanas» (`~/.claude/kit-chema/reglas-vigiladas.json`,
      respaldado desde el 2026-09-29 en claude-entorno `kit-estado/`): se retira si hubo 2 o más correcciones del tema.

## Cómo retomar
- Abrir:    CHANGELOG.md (v1.23 → v1.23.1) · `docs/pruebas/piloto-plugin-eval.md`
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
- 2026-09-29  `plugin eval` complementa al gate de disparo, no lo sustituye → `docs/pruebas/piloto-plugin-eval.md`
- 2026-09-28  Reglas v1.23 aprobadas por council (3 × con cambios, aplicados) → `docs/pruebas/council-v1.23.md`, CHANGELOG

---
## Detalle vivo
- Fusionar SIEMPRE por `gh api -X PUT …/pulls/<n>/merge` (trampa en la ficha): `gh pr merge` cerró #52 y #54 sin fusionar.
- La auditoría completa vive en `claude-entorno/docs/auditorias/2026-09-28-prompt-audit-kit.md` (privada: cita el
  entorno). No entraron a propósito: nombres de versión del núcleo (council 2026-09-27) y la poda de `kit-propuestas`.
