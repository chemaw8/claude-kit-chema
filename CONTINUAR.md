# CONTINUAR — claude-kit-chema  ·  cierre 2026-10-30  ·  commit 4c8bcc2 (rama cierre/2026-10-30)  ·  cierre limpio: sí
> Estado vivo de sesión. Hechos estables en README.md, GOBERNANZA.md y CLAUDE.md; registro histórico en docs/bitacora.md.

## Dónde vamos
Estado al 2026-10-27: v1.34.3 en main (PR #99 regla «recorrer el camino del usuario», v1.34.2; PR #100 asistente con
una sola copia de pi, v1.34.3). Vigilancia: v1.33 hasta 2027-01-07, v1.32 hasta 2026-11-07. La auditoría del núcleo
(`docs/auditoria-nucleo-2026-10-19.md`) sigue vigente: lo que falla en la práctica es afirmar sin respaldo.

## Siguiente paso
- [x] Aviso cosmético del PR #100: resuelto en v1.34.4 (2026-10-30); el plan lee `~/.local/bin/pi` por su ruta
      (`test_12g`).
- [x] **`verificar-cierre` NO se amplía (2026-10-29):** re-medida en pi-harness, 0 de 4 avisos ciertos tras su arreglo
      y, sobre 1,429 cierres reales, atrapa 1 de 4 «subido» falsos con ~13 falsas alarmas por acierto: quedó APAGADA
      (pi-harness DECISIONES 2026-10-29, `herramientas/medir-verificar-cierre.py`). La palanca de la auditoría
      («afirmar sin respaldo») queda en el advisor.
- [ ] Medir «Evaluación crítica» (la única sección sin control ni medición): 3-4 casos-trampa en evals-entregables
      (idea del usuario con un error comprobable; pasa si el agente lo señala antes de ejecutar).
- [ ] Evals del 2026-10-20 (línea base 8/14 con v1.34.1; disparo 81/90, caso 13 en 0/3): su DECISIONES propone repetir
      esos dos casos ×5 antes de tocar el kit. Ya hay línea base con v1.34.3: 10/14, 106/132, sin regresión (evals
      2026-10-27); el disparo del caso 13 sigue sin repetir.
- [x] `KIT_SELLO=omitir` sin registro (2026-10-30): no era el hook. En ese clon el gate no tenía llave
      (`kit-chema.gate`), y el hook solo anota `omitido` en repos con llave; la config del gate no viaja con el clon.
      Reproducido con el comando original: con llave, `omitido` se anota.
- [ ] **Hueco del gate por momento de evaluación (2026-10-30):** el PreToolUse revisa el push cuando se LANZA el
      comando; si entra un commit entre eso y el push real (llamadas en paralelo: pi prepara todas antes de ejecutar;
      o un comando largo `sello …; git push`), sube sin sello. Pasó una vez (commit de papeleo, sellado después).
      Opciones: (a) disciplina, nunca commit en paralelo con un push; (b) segunda capa en el momento real del push
      que exija sello del sha empujado (la «esclusa» con `pre-receive` de la spec 002, que no obedece `--no-verify`).
      Decide el dueño; (b) entra por PR + council.
- [ ] Vigilancia v1.33 hasta el 2027-01-07 (`reglas-vigiladas.json`, id `kit-v1.33-buscar-lo-hecho`): suspensión con 1
      lectura fuera de las áreas de trabajo o 1 uso de datos de otro cliente; retiro con ≥2 reincorporaciones o falsas
      pérdidas que el dueño corrija en 30 días. Re-medir las trampas si cambia el modelo productor.
- [ ] Vigilancia v1.32 hasta el 2026-11-07: clasificar a mano las correcciones «¿quedó o no?» que agrupe el juez; se
      retira con ≥2 confirmadas por el dueño.
- [ ] Avisos abiertos del sello de la v1.33.1 (no bloquean; ver PR #92): `*git*commit*` puede bloquear `git log --grep
      commit` con un secreto ya preparado; un mensaje con `GIT_DIR=` bloquea; una marca `.pid` del sello puede quedar
      huérfana. Atender solo si estorban en uso real.
- [ ] Sobrebloqueo conocido de anti-secretos (2026-10-19): analiza también el texto de un heredoc; un script escrito
      con `cat <<EOF` que contiene `cd $VAR … git commit` se bloquea por «no pude ubicar el repo». Atender si estorba.
- [ ] `cegar.sh`: falta un uso real (2 de 3; ambos falsos positivos). Mantener el criterio de retiro de v1.31.
- [ ] `/por-que`: anotar los usos reales en el acta v1.30; anunciar un uso no acredita su resultado.
- [ ] Arenas desde Claude Code y segunda corrida real de `/crear-verificacion`: cuando haya trabajo adecuado.
- [ ] Vigía de v1.25 y revisión programada del 2026-10-28: conservan sus criterios.

## Cómo retomar
- Abrir: `CHANGELOG.md` (v1.34, v1.34.1), `docs/auditoria-nucleo-2026-10-19.md`, `DECISIONES.md` y el estado real de los PR (`gh pr list`).
- Correr: `bash verificar.sh` → código 0 y sin FALLA (incluye `hooks/test-anti-secretos.sh` y la reinstalación en un
  directorio desechable).
- Comprobar instalación: `diff -q` de `hooks/` y `scripts/` contra `~/.claude/hooks` y `~/.claude/scripts`.

## Bloqueadores / esperas
- Ninguno.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Reglas v1.32 / v1.33 | en vigilancia; v1.22 retirada (v1.34) | clasificar correcciones v1.32 | hasta 2026-11-07 |
| Piezas de pstack | esperan evidencia de uso real | tabla de siguientes pasos | trabajo real apropiado |
| Agregar al kit | 4 palancas de texto no generalizaron | capacidades (pi-harness: esperar-imagen, verificar-cierre) | medir en uso real |
| Evals | v1.34.1 medida el 2026-10-20 por otra sesión (8/14; disparo 81/90), sin commitear | repetir reproceso y caso 13 ×5 | otra sesión |

## Última decisión relevante
- 2026-10-19: retiro de la v1.22 (council 3 × con cambios); skill de verificar antes del commit no entra → DECISIONES.md

---
## Detalle vivo
- **`sello-push.sh revisar` en un paso aparte del commit, nunca en el mismo bloque de llamadas paralelas**: el
  2026-10-13 y 10-19 pasó seis veces (el sello leyó el HEAD anterior). Comprobar en la salida que el sha sellado es el HEAD.
- Repo público: no copiar casos, ids privados de clientes, recibos de modelos, cifras de negocio ni rutas de una sola
  máquina.
- Fusionar con `gh api -X PUT …/pulls/<n>/merge`, no `gh pr merge` (trampa en CLAUDE.md).
