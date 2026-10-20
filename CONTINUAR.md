# CONTINUAR — claude-kit-chema  ·  cierre 2026-10-20  ·  commit 6b48fce (rama cierre/2026-10-20)  ·  cierre limpio: sí
> Estado vivo de sesión. Hechos estables en README.md, GOBERNANZA.md y CLAUDE.md; registro histórico en docs/bitacora.md.

## Dónde vamos
Estado al 2026-10-20: v1.34.1 en main (PR #95, #96, #97) e instalada en Claude Code y pi. La v1.34 retiró la v1.22
del núcleo (137 líneas); la v1.34.1 hace que anti-secretos falle cerrado (`onFailure: block`). Auditoría del núcleo en
`docs/auditoria-nucleo-2026-10-19.md`: sin poda grande; lo que falla en la práctica es afirmar sin respaldo. La skill
de verificar antes del commit se midió y no entra (DECISIONES 2026-10-19). Vigilancia: v1.33 hasta 2027-01-07, v1.32
hasta 2026-11-07.

## Siguiente paso
- [ ] **2026-10-26: decidir si se amplía `verificar-cierre`** (pi-harness) a «borré X» / «las pruebas pasan», según su
      re-medición de esa fecha (si ≥ 2 de 3 intervenciones son ciertas). Es la palanca que propone la auditoría.
- [ ] Medir «Evaluación crítica» (la única sección sin control ni medición): 3-4 casos-trampa en evals-entregables
      (idea del usuario con un error comprobable; pasa si el agente lo señala antes de ejecutar).
- [ ] Revisar lo de evals del 2026-10-20 cuando la otra sesión lo commitee: línea base 8/14 con v1.34.1 (baja
      reproceso, criterio 3) y disparo 81/90 (caso 13 en 0/3); su DECISIONES propone repetir esos dos casos ×5 antes de
      tocar el kit.
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
