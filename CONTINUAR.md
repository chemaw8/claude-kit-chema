# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-07  ·  commit 382ce00  ·  cierre limpio: sí
> Estado vivo. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**v1.19.1 — kit-propuestas gana "Acercamiento personalizado a un contacto"** (PR #12 de
julio cerrado en versión corta, council de 3 aplicado, gate de disparo 21/21; acta en
`docs/pruebas/council-pr12.md`); kit-redaccion remite a esa sección cuando el correo va a un
contacto de otra empresa para vender o proponer. Entra a main con el PR #12 (2026-09-07).
**Fase 3 (gate de push) en la rama `fase-3-gate-push`, PR #33 en borrador (v1.20) y PILOTO
desde 2026-09-07**; el gate está activo en la máquina de José y en este repo, y este mismo
PR #12 pasó por él.

**v1.19.2 (rama `vanguardia-tanda1`, PR #35): regla de esfuerzo + agente `sintetizador`,
con la medición hecha antes de fusionar.** El aviso del council pedía evidencia de que Opus 5
a `--effort max` se queda corto; se midió (`docs/pruebas/medicion-esfuerzo-v1.19.2.md`): a
calidad no distinguible, subir el esfuerzo es 16 % más barato y 2.3 veces más lento que saltar
de modelo (n = 2, la única lectura limpia que enfrenta los dos escalones: se lee como dirección,
no como cifra). De ahí que la regla lleve excepción de latencia, que `lector-fresco` siga en Opus 5
y que `sintetizador` se quede en Fable 5.1 por latencia, no por calidad. La rama pasó por varias
vueltas del gate de push; los hallazgos y su cierre están en los mensajes de commit (el conteo se
lee en `git log`, no aquí).

## Siguiente paso
- [ ] **Pendientes que abre v1.19.2** (los tres viven en
  `docs/pruebas/medicion-esfuerzo-v1.19.2.md`): (a) **re-juzgar el caso divergente** leyendo el
  archivo que produjo el agente, para saber si la diferencia era de comportamiento o de calidad —
  hoy queda fuera del conteo y su exclusión favorece la lectura que conviene; (b) **re-correr los
  brazos 1 y 3 bajo el mismo núcleo**, para que la comparación con Fable 5.1 no dependa de n = 2;
  (c) **medir calidad en síntesis** (pide un caso dorado nuevo y firma del mantenedor): es lo único
  que bajaría a `sintetizador` de escalón, porque hoy se justifica solo por latencia.
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
