# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-06  ·  commit 7ca6b37  ·  cierre limpio: sí
> Estado vivo. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md (rama `ficha-proyecto`), no aquí.

## Dónde vamos
**v1.17 en main. Dos PR apilados pendientes de merge:** #29 (v1.18, hook
rutas-fantasma, council aprobada con cambios aplicados) y #30 (v1.19, fase 1 del
programa: backstop-cierre opt-in + presupuesto del núcleo + destructivo=simulacro;
council de 3 aprobada con cambios, todos aplicados, acta en
`docs/pruebas/council-v1.19.md`). El council de #30 cazó un defecto del helper:
`reconciliar` devolvía 1 tanto para "rancio" como para "no se puede reconciliar";
ahora devuelve 3 (13 de 32 CONTINUAR reales no tienen ancla). El congelamiento
sigue vigente para todo lo demás; estos dos entran por la vía que el congelamiento
dejó abierta (fallo recurrente en el reporte de salud).

## Siguiente paso
- [ ] José mergea #29 y después #30 (GitHub recalcula el diff de #30 al fusionar #29). Luego `bash instalar.sh` en su máquina con `KIT_HOOKS=s KIT_BACKSTOP=s`. Terminado cuando `head -2 ~/.claude/CLAUDE.md` diga v1.19 y `verificar.sh` pase en main.
- [ ] Abrir PR de la rama `ficha-proyecto` (solo CLAUDE.md; sin gate, sin council: papeleo del repo).
- [ ] Puerta de la fase 1 (programa en claude-entorno/specs/001): el reporte del lunes 2026-09-07 y el siguiente deciden si el backstop pasa a por defecto (menos rancios, sin falsos positivos) — anotar en CHANGELOG cuando toque.
- [ ] Correr los evals de entregables con v1.19 cuando el tripwire avise (`~/Trabajo/proyectos/evals-entregables/correr.sh`; base 5/5 con v1.17).
- [ ] PR del fix de bitácora del helper: las líneas hijas se archivan sin su padre cuando el padre sobrevive reescrito (reproducido 2026-08-31).

## Cómo retomar
- Abrir:    CHANGELOG.md (v1.18, v1.19), `docs/pruebas/council-v1.18.md` y `docs/pruebas/council-v1.19.md`, PRs #29 y #30.
- Correr:   `bash verificar.sh` — todo el CI local en un comando (incluye las pruebas de los tres hooks).
- Verificar arranque: `gh pr view 30 --json state,mergedAt,isDraft`.

## Bloqueadores / esperas
- Merge de #29 y #30 (decisión de José).

## Última decisión relevante
- 2026-09-06  Un hook entra por defecto solo si cumple la puerta de v1.18; el backstop no la cumple (indisciplina, costo medio) → opt-in hasta que dos reportes semanales lo respalden (council v1.19).
