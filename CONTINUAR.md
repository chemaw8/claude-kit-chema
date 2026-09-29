# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-29  ·  commit 380ae45 (rama main)  ·  cierre limpio: sí
> Estado vivo de sesión. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**Estado al 2026-09-29 (noche):** v1.25 en main e instalado: «lo que no cuadra gobierna el resultado» en
`kit-analisis-datos` y `kit-finanzas` (PR #63; council 2 × aprobada + 1 × con cambios, aplicado). A/B con las skills
inyectadas: 0/3 → 2/3 y 0/3 → 3/3; controles 3/3. Evidencia provisional (n=3). Hallazgo: la línea base de
evals-entregables no carga skills, mide el núcleo.

## Siguiente paso
- [ ] Vigía de v1.25 (umbral de retiro en `docs/pruebas/council-v1.25.md`): en la próxima medición con skills cargadas,
      revisar que los controles no caigan por discrepancias falsas y que el caso de «dos fuentes que no deben cuadrar» no
      fuerce reconciliaciones.
- [ ] Gate de disparo: no lee el núcleo, así que no mide cambios al núcleo. Para esos, la evidencia es el disparo
      real con banco de control (como `banco-dinero.md`). Anotarlo en RUNBOOK/GOBERNANZA si se repite.
- [ ] Alinear el núcleo con `CLAUDE_CONFIG_DIR` (sigue nombrando `~/.claude/contexto/`): va con council.
- [ ] 2026-10-28: revisar la vigilancia de «cierre en palabras llanas» (`~/.claude/kit-chema/reglas-vigiladas.json`).

## Cómo retomar
- Abrir:    CHANGELOG.md (v1.24 → v1.25) · `docs/pruebas/council-v1.25.md` · `~/Trabajo/proyectos/evals-entregables/docs/ab-kit-v1.25-anomalia.md`
- Correr:   `bash verificar.sh` → código 0 y ninguna línea `FALLA`
- Verificar arranque: `head -2 ~/.claude/CLAUDE.md` → dice la versión del primer `## v` del CHANGELOG

## Bloqueadores / esperas
- Ninguno.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Debilidades de la línea base | «dato literal» atacado en v1.25 | siguiente patrón: «se cubre en vez de afirmar» (reclasificación, onepager 0/3) | José elige |
| Auditoría prompt-audit | mecánicos hechos (v1.22.4) | topes de extensión de agentes y comandos: probar con el banco antes de quitar | ninguno |
| `omitClaudeMd` en `lector-fresco` | sin tocar | A/B con 5 entregables; el lector dejaría de cargar la confidencialidad | medir primero |
| Pendientes v1.19.2 | sin revisar desde 2026-09-08 | ver `docs/pruebas/medicion-esfuerzo-v1.19.2.md` (a, b, c) | ninguno |

## Última decisión relevante
- 2026-09-29  v1.25: la regla va en las skills, medida por A/B con inyección (no en el núcleo) → `docs/pruebas/council-v1.25.md`
- 2026-09-29  v1.24: el dinero carga kit-finanzas; la regla va en el núcleo, no en la description → `docs/pruebas/council-v1.24.md`
- 2026-09-29  `plugin eval` complementa al gate de disparo, no lo sustituye → `docs/pruebas/piloto-plugin-eval.md`

---
## Detalle vivo
- Fusionar SIEMPRE por `gh api -X PUT …/pulls/<n>/merge` (trampa en la ficha): `gh pr merge` cerró #52 y #54 sin fusionar.
- El repo es PÚBLICO: los casos de evals-entregables son `privado-local` (cifras de contratos reales). En el kit van
  descritos sin cifras ni ids; el detalle, en el repo privado. En v1.25 casi se cuelan en el acta; se detectó antes del push.
- La auditoría completa vive en `claude-entorno/docs/auditorias/2026-09-28-prompt-audit-kit.md` (privada: cita el
  entorno). No entraron a propósito: nombres de versión del núcleo (council 2026-09-27) y la poda de `kit-propuestas`.
