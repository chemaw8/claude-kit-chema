# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-01  ·  commit 593663f  ·  cierre limpio: sí
> Estado vivo. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md y GOBERNANZA.md, no aquí.

## Dónde vamos
**v1.17 en main e instalada.** El estándar de estructura de proyectos entró
completo: skill + plantillas (v1.16, PR #24) y núcleo (v1.17, PR #26), por
council de 5 con las 3 evidencias (piloto sql-natural 18/18 · sonda conductual
7/7 · gate 27/27). El congelamiento sigue vigente para todo lo demás.

## Siguiente paso
- [ ] Correr los evals de entregables con v1.17 cuando el tripwire avise
      (`~/Trabajo/proyectos/evals-entregables/correr.sh`; base actual: 4/4
      con v1.15, mismo modelo Fable 5 para comparar limpio).
- [ ] PR del fix de bitácora del helper: las líneas hijas se archivan sin su
      padre cuando el padre sobrevive reescrito (reproducido 2026-08-31;
      diagnóstico en la sesión, falta el fix con tests en `cmd_rotar`).

## Cómo retomar
- Abrir:    CHANGELOG.md (v1.17) y DECISIONES.md (entrada 2026-08-31).
- Correr:   `bash verificar.sh` — todo el CI local en un comando.
- Verificar arranque: `head -2 ~/.claude/CLAUDE.md` debe decir v1.17.

## Bloqueadores / esperas
- Ninguno.

## Última decisión relevante
- 2026-08-31  Matiz al congelamiento: para fallos invisibles al reporte de
  salud, la evidencia aceptada es un piloto medido  → DECISIONES.md

---
## Detalle vivo
- Evidencias del estándar archivadas en el laboratorio:
  `~/Trabajo/proyectos/sdd-proyectos/specs/001-estandar-v1/` (sonda, gate,
  validación) y el veredicto del council en `propuestas/`.
- La sonda dejó 2 bugs de harness anotados (prompt "crea" se cuelga en
  headless; `while read` pierde la última fila de un TSV sin salto final) —
  útiles para la próxima sonda.
