# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-07  ·  commit 054efb6  ·  cierre limpio: sí
> Estado vivo. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**v1.19 en main. Fase 3 (gate de push) construida en la rama `fase-3-gate-push` y en
PILOTO desde 2026-09-07**, como PR en borrador v1.20 (spec y evidencia en claude-entorno,
`specs/002-gate-de-push/`). El gate está activo en la máquina de José y en este repo
(`sello-push.sh estado`); **este mismo PR pasó por su gate**: revisiones reales con Opus
(al escribir esto, 7 en el ledger; 65-97k tokens y de 3 a 11 min cada una) que cazaron los defectos sembrados de la prueba
y varios reales del propio gate (`saltar`, escape en comentarios, `timeout -k`, `git push >
archivo`, `--tags` con refspec, base irresoluble), todos corregidos antes de subir. Cifras
en `docs/pruebas/RUNBOOK.md` y en `~/.claude/kit-chema/gate.jsonl`.

**v1.19.2 EN MAIN E INSTALADO (PR #35 fusionado el 2026-09-08): regla de esfuerzo + agente `sintetizador`,
con la medición hecha antes de fusionar.** El aviso del council pedía evidencia de que Opus 5
a `--effort max` se queda corto; se midió (`docs/pruebas/medicion-esfuerzo-v1.19.2.md`): a
calidad no distinguible, subir el esfuerzo es 16 % más barato y 2.3 veces más lento que saltar
de modelo (n = 2, la única lectura limpia que enfrenta los dos escalones: se lee como dirección,
no como cifra). De ahí que la regla lleve excepción de latencia, que `lector-fresco` siga en Opus 5
y que `sintetizador` se quede en Fable 5.1 por latencia, no por calidad. La rama pasó por varias
vueltas del gate de push; los hallazgos y su cierre están en los mensajes de commit (el conteo se
lee en `git log`, no aquí).

## Siguiente paso
- [ ] **Piloto de dos semanas** en este repo: trabajar normal; cada push pasa por
  `/revisar-antes-de-subir`. Los lunes 2026-09-14 y 2026-09-21 el reporte semanal de
  claude-entorno trae la columna `Gate` (`sello-push.sh metricas 7`).
- [ ] **Puerta de la fase 3** (tras el segundo lunes): council de 5 (kit-propuestas) con la
  columna `Gate` → por defecto / opt-in / retiro, y aceptar o no la "tercera vía" de
  `hooks/README.md`. Solo entonces el PR sale de borrador.
- [ ] Si aparece un `omitido` sin petición del usuario o `sin sello en remoto` crece:
  endurecer (pausa con caducidad) según la spec 002.
- [ ] PR #12 (julio, kit-propuestas acercamiento): decisión de José, sigue abierto.

## Cómo retomar
- `bash verificar.sh` (todo OK; incluye `hooks/test-sello-push.sh` y el autotest del helper).
- `bash scripts/sello-push.sh estado . --contra-remoto` · `bash scripts/sello-push.sh metricas 7 .`
- Antes de subir cualquier cosa aquí: `/revisar-antes-de-subir` (timeout 600000 en el Bash).
  Si el revisor no responde, el push sigue bloqueado: `KIT_SELLO=omitir` es de José, no del modelo.

## Bloqueadores / esperas
- Dos lunes de métrica antes del council (2026-09-14 y 2026-09-21).

## Última decisión relevante
- 2026-09-07 El gate se construyó y se probó sobre sí mismo; entra opt-in con dos llaves y
  puerta de dos reportes → DECISIONES.md de claude-entorno (2026-09-06 y 2026-09-07).
