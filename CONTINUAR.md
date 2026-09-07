# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-06  ·  commit 46c1405  ·  cierre limpio: sí
> Estado vivo. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**v1.17 en main e instalada; v1.18 lista en PR #29** (rama `hook-rutas-fantasma`,
fuera de borrador): hook `rutas-fantasma.sh` por defecto, council de 3 lentes
aprobada con cambios y todos aplicados (`docs/pruebas/council-v1.18.md`). Es el
primer cambio que entra por la vía que el congelamiento del 2026-08-29 dejó
abierta: fallo recurrente en el reporte semanal de salud (46/148 errores en 5
días). La ficha del repo (CLAUDE.md) va aparte en PR desde la rama
`ficha-proyecto`. El congelamiento sigue vigente para todo lo demás.

## Siguiente paso
- [ ] José revisa y mergea PR #29 (CODEOWNERS); después `bash instalar.sh` en la
      máquina para que `~/.claude/CLAUDE.md` diga v1.18. Terminado cuando
      `head -2 ~/.claude/CLAUDE.md` muestre v1.18 y `verificar.sh` pase en main.
- [ ] Abrir PR de la rama `ficha-proyecto` (solo CLAUDE.md; sin gate, sin council:
      es papeleo del repo).
- [ ] Correr los evals de entregables con v1.17/v1.18 cuando el tripwire avise
      (`~/Trabajo/proyectos/evals-entregables/correr.sh`; base 5/5 con v1.17).
- [ ] PR del fix de bitácora del helper: las líneas hijas se archivan sin su
      padre cuando el padre sobrevive reescrito (reproducido 2026-08-31).

## Cómo retomar
- Abrir:    CHANGELOG.md (v1.18), `docs/pruebas/council-v1.18.md`, PR #29.
- Correr:   `bash verificar.sh` — todo el CI local en un comando.
- Verificar arranque: `gh pr view 29 --json state,mergedAt`.

## Bloqueadores / esperas
- Merge de PR #29 (decisión de José).

## Última decisión relevante
- 2026-09-06  Un hook entra al kit por defecto solo si cumple cinco condiciones a
  la vez (fallo del modelo, recurrente en salud, determinista, condicionado al
  estado de la máquina, fail-open con prueba) → `hooks/README.md`, council v1.18.
