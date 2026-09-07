# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-06  ·  commit b3ba89b  ·  cierre limpio: sí
> Estado vivo. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**v1.19 en main desde 2026-09-06.** Ese día se fusionaron en orden #29 (v1.18, hook
rutas-fantasma), #30 (v1.19: backstop-cierre opt-in, presupuesto del núcleo,
destructivo=simulacro; council aplicado, acta en `docs/pruebas/council-v1.19.md`) y
#31 (ficha `CLAUDE.md` del repo). Instalado en la máquina de José con
`KIT_HOOKS=s KIT_BACKSTOP=s bash instalar.sh`; `verificar.sh` en verde en main.
Queda abierto solo el PR #12 (julio, kit-propuestas acercamiento): decisión de José.

## Siguiente paso
- [ ] **Fase 3 — gate de push local.** Spec, plan y tareas en
  `~/Trabajo/proyectos/claude-entorno/specs/002-gate-de-push/` (diseño por workflow
  de 8 agentes; D1-D4 decididas el 2026-09-06: revisor `opus`, base = main, ficha del
  kit = la de #31, ledger `~/.claude/kit-chema/gate.jsonl`). Rama `fase-3-gate-push`
  desde main; T1-T14 (2 sesiones) → piloto 2 semanas en este repo → council de 5.
- [ ] Primer lunes con el kit v1.19 activo (2026-09-07): `/revisar-salud` en
  claude-entorno decide si rutas-fantasma y backstop cruzan la puerta de la fase 1.

## Cómo retomar
- `bash verificar.sh` (todo OK) · `bash hooks/test-backstop-cierre.sh` · `bash scripts/rotar-continuar.sh autotest`.
- Ver qué hay en la máquina: `head -2 ~/.claude/CLAUDE.md` (v1.19) y `jq '.hooks|map_values(length)' ~/.claude/settings.json`.
- Antes de construir el gate: leer la spec 002 completa y `GOBERNANZA.md` (todo por PR + council; el PR del gate sale en borrador).

## Bloqueadores / esperas
- Ninguno para la fase 3. PR #12: José decide cerrarlo o retomarlo.

## Última decisión relevante
- 2026-09-06 Gate de push = Sello de push v2 (hook PreToolUse + helper + comando), no Esclusa ni check de GitHub → DECISIONES.md de claude-entorno.
