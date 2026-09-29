# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-29  ·  commit 28732e8 (rama main)  ·  cierre limpio: sí
> Estado vivo de sesión. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**Estado al 2026-09-29 (tarde):** v1.24 en main e instalado: calcular o analizar dinero del negocio carga
`kit-finanzas` (council 3 × con cambios; A/B 7/16 → 16/16 y controles 0/16 → 1/16). Disparo real con v1.24: 86/90
(`evals-entregables` spec 005). Claude Code 2.1.284: `sonnet` es Sonnet 5.5; el gate de disparo ya corrió con él (21/21).

## Siguiente paso
- [ ] Gate de disparo: no lee el núcleo, así que no mide cambios al núcleo. Para esos, la evidencia es el disparo
      real con banco de control (como `banco-dinero.md`). Anotarlo en RUNBOOK/GOBERNANZA si se repite.
- [ ] Alinear el núcleo con `CLAUDE_CONFIG_DIR` (sigue nombrando `~/.claude/contexto/`): va con council.
- [ ] 2026-10-28: revisar la vigilancia de «cierre en palabras llanas» (`~/.claude/kit-chema/reglas-vigiladas.json`).

## Cómo retomar
- Abrir:    CHANGELOG.md (v1.23 → v1.24) · `docs/pruebas/council-v1.24.md` · evals-entregables spec 005
- Correr:   `bash verificar.sh` → código 0 y ninguna línea `FALLA`
- Verificar arranque: `head -2 ~/.claude/CLAUDE.md` → dice la versión del primer `## v` del CHANGELOG

## Bloqueadores / esperas
- Ninguno. Los PR #48 y #37 quedaron resueltos el 2026-09-29 (#59).

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Auditoría prompt-audit | mecánicos hechos (v1.22.4) | topes de extensión de agentes y comandos: probar con el banco antes de quitar | ninguno |
| `omitClaudeMd` en `lector-fresco` | sin tocar | A/B con 5 entregables; el lector dejaría de cargar la confidencialidad | medir primero |
| Pendientes v1.19.2 | sin revisar desde 2026-09-08 | ver `docs/pruebas/medicion-esfuerzo-v1.19.2.md` (a, b, c) | ninguno |

## Última decisión relevante
- 2026-09-29  v1.24: el dinero carga kit-finanzas; la regla va en el núcleo, no en la description → `docs/pruebas/council-v1.24.md`
- 2026-09-29  #48 entra integrado sobre main; de #37 solo la evidencia de GOBERNANZA (el párrafo de la skill era n=1) → CHANGELOG v1.23.2
- 2026-09-29  `plugin eval` complementa al gate de disparo, no lo sustituye → `docs/pruebas/piloto-plugin-eval.md`
- 2026-09-28  Reglas v1.23 aprobadas por council (3 × con cambios, aplicados) → `docs/pruebas/council-v1.23.md`, CHANGELOG

---
## Detalle vivo
- Fusionar SIEMPRE por `gh api -X PUT …/pulls/<n>/merge` (trampa en la ficha): `gh pr merge` cerró #52 y #54 sin fusionar.
- La auditoría completa vive en `claude-entorno/docs/auditorias/2026-09-28-prompt-audit-kit.md` (privada: cita el
  entorno). No entraron a propósito: nombres de versión del núcleo (council 2026-09-27) y la poda de `kit-propuestas`.
