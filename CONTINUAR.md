# CONTINUAR — claude-kit-chema  ·  cierre 2026-10-13  ·  commit 2ad62eb (rama main)  ·  cierre limpio: sí
> Estado vivo de sesión. Hechos estables en README.md, GOBERNANZA.md y CLAUDE.md; registro histórico en docs/bitacora.md.

## Dónde vamos
Estado al 2026-10-13: v1.33.1 en main (PR #92) e instalada en Claude Code (pi comparte `~/.claude/hooks` y skills).
Solo scripts y hooks: anti-secretos ya no falla abierto (diffs grandes, `-a`, `git add &&`, repo de `cd`/`-C`), el sello
no borra revisiones vivas ni sella sin worktree, rotar-continuar no anuncia éxito tras fallar, instalar actualiza hooks
registrados y la CI escanea los commits del PR con gitleaks. Salió de una auditoría de solo lectura con verificación
entre familias (2026-10-13). Reglas en vigilancia: v1.33 hasta 2027-01-07, v1.32 hasta 2026-11-07; la v1.22 se retira en la v1.34 (2026-10-19).

## Siguiente paso
- [ ] **v1.34 (PR en borrador): retiro de la v1.22.** Council 3 × aprobada con cambios (aplicados); gate de disparo 83/90 sin
      regresiones. Falta: salir de borrador y fusionar (decide José); al fusionar, marcar `kit-v1.22-resultados-literales` como
      «retirada» en `~/.claude/kit-chema/reglas-vigiladas.json` e instalar (`instalar.sh`, también llega a pi).
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
- Abrir: `CHANGELOG.md` (v1.33.1), `DECISIONES.md` y el estado real de los PR (`gh pr list`).
- Correr: `bash verificar.sh` → código 0 y sin FALLA (incluye `hooks/test-anti-secretos.sh` y la reinstalación en un
  directorio desechable).
- Comprobar instalación: `diff -q` de `hooks/` y `scripts/` contra `~/.claude/hooks` y `~/.claude/scripts`.

## Bloqueadores / esperas
- Ninguno.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Reglas v1.32 / v1.33 | en vigilancia; v1.22 se retira (v1.34) | fusionar v1.34 | José |
| Piezas de pstack | esperan evidencia de uso real | tabla de siguientes pasos | trabajo real apropiado |
| Agregar al kit | 4 palancas de texto no generalizaron | capacidades (pi-harness: esperar-imagen, verificar-cierre) | medir en uso real |
| Evals | línea base 2026-10-13: 14 casos con Python, 9/14 y 100/132 (no comparable con 7/13 en skills) | medir lo próximo contra esta | — |

## Última decisión relevante
- 2026-10-13: v1.33.1 por el flujo de script (PR + CI + sello, sin council): no toca reglas.

---
## Detalle vivo
- **`sello-push.sh revisar` en un paso aparte del commit, nunca en el mismo bloque de llamadas paralelas**: el
  2026-10-13 pasó cuatro veces (el sello leyó el HEAD anterior). Comprobar en la salida que el sha sellado es el HEAD.
- Repo público: no copiar casos, ids privados de clientes, recibos de modelos, cifras de negocio ni rutas de una sola
  máquina.
- Fusionar con `gh api -X PUT …/pulls/<n>/merge`, no `gh pr merge` (trampa en CLAUDE.md).
