# CONTINUAR — claude-kit-chema  ·  cierre 2026-11-24  ·  commit b154de1 (rama main)  ·  cierre limpio: sí
> Estado vivo de sesión. Hechos estables en README.md, GOBERNANZA.md y CLAUDE.md; registro histórico en docs/bitacora.md.

## Dónde vamos
v1.36.1 en main e instalada en las dos máquinas (2026-11-24): `/cierre` exige y comprueba la línea `Vault:`
(PR #118, council 3 familias con cambios aplicados). La auditoría del núcleo (`docs/auditoria-nucleo-2026-10-19.md`)
sigue vigente: lo que falla en la práctica es afirmar sin respaldo.

## Siguiente paso
- [ ] Observar los primeros `/cierre` reales con v1.36.1: que la línea `Vault:` salga sola y el backstop bloquee solo
      cuando falta. Terminado cuando 5 cierres de proyectos distintos pasen `rotar-continuar.sh vault` sin intervención.
- [ ] Avisos de borde del sello en PR #118: (1) un `rotar` de OTRO proyecto en la misma sesión marca cerrado al del cwd;
      (2) `rotar --dry-run && rotar` en un solo comando no cuenta como cierre. Atender si estorban en uso real.
- [ ] Contar los «Vault: sin cambios» por proyecto con nota muy atrasada en el reporte semanal (`claude-entorno/scripts/frescura.py`),
      para ver el uso por reflejo sin bloquear. Entra por PR + council.
- [ ] Medir «Evaluación crítica» (la única sección sin control ni medición): 3-4 casos-trampa en evals-entregables
      (idea del usuario con un error comprobable; pasa si el agente lo señala antes de ejecutar).
- [ ] Evals: la versión cambió (v1.36.1); correr `evals-entregables/correr.sh --linea-base` y, con presupuesto (~14 USD),
      `disparo.sh --ejecutar`; la última medición de disparo trae regresión en 13 y 20.
- [ ] **Hueco del gate por momento de evaluación (2026-10-30):** el PreToolUse revisa el push cuando se LANZA el
      comando; si entra un commit entre eso y el push real, sube sin sello. Opciones: (a) disciplina, nunca commit en
      paralelo con un push; (b) segunda capa en el push real (`pre-receive` de la spec 002). Decide el dueño; (b) entra por PR + council.
- [ ] Vigilancia v1.33 hasta el 2027-01-07 (`reglas-vigiladas.json`, id `kit-v1.33-buscar-lo-hecho`): suspensión con 1
      lectura fuera de las áreas de trabajo o 1 uso de datos de otro cliente; retiro con ≥2 reincorporaciones o falsas
      pérdidas que el dueño corrija en 30 días.
- [ ] Vigilancia v1.32: venció el 2026-11-07; clasificar a mano las correcciones «¿quedó o no?» que agrupe el juez y
      decidir retiro (≥2 confirmadas por el dueño).
- [ ] Avisos abiertos del sello de la v1.33.1 (PR #92) y sobrebloqueo de anti-secretos con heredocs que contienen
      `cd $VAR … git commit` (volvió a estorbar el 2026-11-24; se rodeó escribiendo el parche a archivo). Atender si estorban.
- [ ] `cegar.sh` (falta un uso real), `/por-que` (anotar usos en el acta v1.30), arenas y segunda corrida de
      `/crear-verificacion`: cuando haya trabajo adecuado.

## Cómo retomar
- Abrir: `CHANGELOG.md` (v1.36.1), `DECISIONES.md` y el estado real de los PR (`gh pr list`).
- Correr: `bash verificar.sh` → código 0 y sin FALLA (incluye los autotest de scripts y `hooks/test-*.sh`).
- Verificar arranque: `bash scripts/rotar-continuar.sh autotest` → termina con código 0 y sin líneas ✗.
- Comprobar instalación: `diff -q` de `hooks/` y `scripts/` contra `~/.claude/hooks` y `~/.claude/scripts`.

## Bloqueadores / esperas
- Ninguno.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Vault al cerrar | v1.36.1 instalada | observar cierres reales | uso real |
| Reglas v1.32 / v1.33 | v1.32 vencida sin clasificar; v1.33 en vigilancia | clasificar v1.32 | dueño |
| Evals | versión nueva sin medir | línea base + disparo | presupuesto del disparo |

## Última decisión relevante
- 2026-11-24  automatizar la verificación del vault al cerrar, no la redacción de notas → CHANGELOG v1.36.1, PR #118

Vault: actualizado `proyectos/claude-kit-chema/claude-kit-chema.md`

---
## Detalle vivo
- **`sello-push.sh revisar` en un paso aparte del commit y nunca en paralelo con otro comando**: el 2026-11-24 volvió a
  leer el HEAD anterior al lanzarse junto con un commit. Comprobar que el sha sellado es el HEAD.
- Si el revisor del sello da «no disponible» con `duration_api_ms: 0`, probar `claude -p`: la causa del 2026-11-24 fue
  la sesión OAuth de Claude Code vencida (se arregla con `/login`).
- Repo público: no copiar casos, ids privados de clientes, recibos de modelos, cifras de negocio ni rutas de una sola máquina.
