# CONTINUAR — claude-kit-chema  ·  cierre 2026-10-09  ·  commit 02cc1d9 (rama main)  ·  cierre limpio: sí
> Estado vivo de sesión. Hechos estables en README.md, GOBERNANZA.md y CLAUDE.md; registro histórico en docs/bitacora.md.

## Dónde vamos
Estado al 2026-10-09: v1.33 en main (PR #89) e instalada en Claude Code y pi. Regla nueva en el cuerpo de
`kit-analisis-datos` y `kit-presentaciones`: buscar lo que ya se hizo antes de dar un dato por inexistente. Entró tras
cinco intentos prerregistrados, council de tres familias (aprobada con cambios, condicionada a re-medir) y re-medición
cumplida 5/5 (acta `docs/pruebas/council-v1.33.md`). En vigilancia hasta el 2027-01-07. La v1.32 sigue en vigilancia
hasta el 2026-11-07. Sin PR abiertos.

## Siguiente paso
- [ ] Vigilancia v1.33 hasta el 2027-01-07 (`reglas-vigiladas.json`, id `kit-v1.33-buscar-lo-hecho`): suspensión con 1
      lectura fuera de las áreas de trabajo o 1 uso de datos de otro cliente; retiro con ≥2 reincorporaciones o falsas
      pérdidas que el dueño corrija en 30 días. Re-medir las trampas si cambia el modelo productor.
- [ ] Vigilancia v1.32 hasta el 2026-11-07 (`~/.claude/kit-chema/reglas-vigiladas.json`): clasificar a mano las
      correcciones «¿quedó o no?» que agrupe el juez; se retira con ≥2 confirmadas por el dueño.
- [ ] `cegar.sh`: falta un uso real (2 de 3; ambos falsos positivos). Mantener el criterio de retiro de v1.31.
- [ ] `/por-que`: anotar los usos reales en el acta v1.30; anunciar un uso no acredita su resultado.
- [ ] Arenas desde Claude Code: documentar las primeras dos cuando haya trabajo adecuado.
- [ ] Segunda corrida real de `/crear-verificacion`, en otro proyecto con interfaz.
- [ ] Vigía de v1.25 y revisión programada del 2026-10-28: conservan sus criterios.

## Cómo retomar
- Abrir: `CHANGELOG.md` (v1.33 y v1.32.x), `DECISIONES.md` y el estado real de los PR (`gh pr list`).
- Correr: `bash verificar.sh` → código 0 y sin FALLA (incluye el autotest de `scripts/rotar-continuar.sh`).
- Comprobar instalación: comparar el núcleo entre marcadores y las copias del kit, no solo la versión de la cabecera;
  los scripts de `scripts/` deben ser idénticos a sus copias instaladas en `~/.claude/scripts/` (`diff -q`).

## Bloqueadores / esperas
- Ninguno.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Regla v1.32 | fusionada, instalada, en vigilancia | clasificar correcciones | hasta 2026-11-07 |
| Piezas de pstack | esperan evidencia de uso real | tabla de siguientes pasos | trabajo real apropiado |
| Evals | v1.32 medida (8/13, 79/120) en evals-entregables | próxima línea base con la siguiente versión que toque skills o núcleo | ninguno |

## Última decisión relevante
- 2026-10-08: v1.32.1 y v1.32.2 como arreglos de script por el flujo normal (PR + CI + sello), sin council: no toca reglas.
- 2026-10-08: v1.32 fusionada tras council de tres familias (acta `docs/pruebas/council-v1.32.md`).

---
## Detalle vivo
- `sello-push.sh revisar` se lanza SOLO después de que el commit terminó, nunca en paralelo: dos veces el
  2026-10-08 revisó el commit anterior y hubo que repetirlo.
- Repo público: no copiar casos, ids privados de clientes, recibos de modelos, cifras de negocio ni rutas de una sola
  máquina (aviso del sello `cf4fd61`, 2026-10-08).
- Los puntos ciegos de muletillas quedan documentados como mejora opcional; no se añadió una ronda nueva.
- Fusionar con `gh api -X PUT …/pulls/<n>/merge`, no `gh pr merge` (trampa en CLAUDE.md). El PR #85 se fusionó con
  `gh pr merge` por error el 2026-10-08; salió bien, pero no cambia la regla.
