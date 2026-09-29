# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-29  ·  commit 3448c91 (rama main)  ·  cierre limpio: sí
> Estado vivo de sesión. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**Estado al 2026-09-29:** v1.23.2 en main e instalado. Entró el #48 (contexto sigue a `CLAUDE_CONFIG_DIR`) integrado a
mano sobre main, y de #37 solo la evidencia de GOBERNANZA; #37 cerrado. El disparo real de las skills ya es una
medición periódica, pero vive en `evals-entregables` (spec 005, `disparo.sh`), no aquí: el kit solo aporta el banco.

## Siguiente paso
- [ ] Disparo real con v1.23.2: **77/90** (núcleo 48/60, fronteras 29/30; `evals-entregables` spec 005). Flojos: #11
      código 0/3, #18 margen 0/3, #8 research 1/3, #13 propuestas 1/3. En #11 y #18 el modelo pide los datos antes de
      cargar la skill (revisado a mano): no basta para tocar descriptions. Primero, casos con material; después decidir.
- [ ] Alinear el núcleo con `CLAUDE_CONFIG_DIR` (sigue nombrando `~/.claude/contexto/`): va con gate de disparo.
- [ ] 2026-10-28: revisar la vigilancia de «cierre en palabras llanas» (`~/.claude/kit-chema/reglas-vigiladas.json`,
      respaldada en claude-entorno `kit-estado/`): se retira si hubo 2 o más correcciones del tema.

## Cómo retomar
- Abrir:    CHANGELOG.md (v1.23 → v1.23.2) · `docs/pruebas/piloto-plugin-eval.md` · evals-entregables spec 005
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
- 2026-09-29  #48 entra integrado sobre main; de #37 solo la evidencia de GOBERNANZA (el párrafo de la skill era n=1) → CHANGELOG v1.23.2
- 2026-09-29  `plugin eval` complementa al gate de disparo, no lo sustituye → `docs/pruebas/piloto-plugin-eval.md`
- 2026-09-28  Reglas v1.23 aprobadas por council (3 × con cambios, aplicados) → `docs/pruebas/council-v1.23.md`, CHANGELOG

---
## Detalle vivo
- Fusionar SIEMPRE por `gh api -X PUT …/pulls/<n>/merge` (trampa en la ficha): `gh pr merge` cerró #52 y #54 sin fusionar.
- La auditoría completa vive en `claude-entorno/docs/auditorias/2026-09-28-prompt-audit-kit.md` (privada: cita el
  entorno). No entraron a propósito: nombres de versión del núcleo (council 2026-09-27) y la poda de `kit-propuestas`.
