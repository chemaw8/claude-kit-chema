# CONTINUAR — claude-kit-chema  ·  2026-10-06  ·  rama pstack/ronda-5 (v1.31, council aprobada con cambios, PR en borrador)  ·  cierre limpio: sí
> Estado vivo de sesión. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**Estado al 2026-10-06:** v1.30 en main e instalada. v1.31 (ronda pstack 3, candidatos 5 a 8) en la rama
`pstack/ronda-5`, con council (aprobada con cambios, aplicados; `docs/pruebas/council-v1.31.md`) y PR en borrador: entran arena y cegado en `kit-orquestacion` con `scripts/cegar.sh`; el registro
TSV y «córrelo antes de preguntar» quedan como ya cubiertos. Acta `docs/pruebas/pstack-ronda-3.md`, nota de la arena
`docs/pruebas/ARENA-uc-202610061430-aogq.md`. `/crear-verificacion` lleva 1 de 2 corridas reales.

## Siguiente paso
- [ ] v1.31: José saca el PR de borrador, fusiona con `gh api … /merge` (CI en verde) y reinstala con `bash instalar.sh`.
- [ ] `/por-que`: anotar en el acta v1.30 los primeros 5 usos reales (umbral de retiro).
- [ ] Próximo council: archivar los reportes crudos para medir la clasificación de hallazgos (resíntesis v1.11).
- [ ] Segunda corrida real de `/crear-verificacion`, en otro proyecto (umbral de retiro: 2 corridas).
- [ ] Limpiar el texto del kit: 39 rayas espaciadas y 15 prefijos con guion (toca descriptions: gate de disparo).
- [ ] Vigía de v1.25 (umbral de retiro en `docs/pruebas/council-v1.25.md`).
- [ ] 2026-10-28: revisar la vigilancia de «cierre en palabras llanas» (`~/.claude/kit-chema/reglas-vigiladas.json`).

## Cómo retomar
- Abrir:    `investigacion/2026-09-30-pstack-y-mercado.md` (secciones 3 y 4) · `git log --oneline -5`
- Correr:   `bash verificar.sh` → código 0 y ninguna línea `FALLA`
- Verificar: `bash scripts/muletillas.sh autotest` → «todo en verde»

## Bloqueadores / esperas
- Ninguno.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Ronda pstack 3 (v1.31) | council aprobada con cambios (aplicados); PR en borrador | fusionar e instalar | José |
| Ronda pstack 2 (v1.30) | en main e instalada | 5 usos reales de `/por-que` (umbral de retiro) | ninguno |
| Entorno portable (v1.29) | asistente de un comando en main y en el CI | probar el asistente en Fedora | ninguno |
| Debilidades de la línea base | «dato literal» atacado en v1.25 | siguiente patrón: «se cubre en vez de afirmar» (reclasificación, onepager 0/3) | José elige |
| Auditoría prompt-audit | mecánicos hechos (v1.22.4) | topes de extensión de agentes y comandos: probar con el banco antes de quitar | ninguno |
| `omitClaudeMd` en `lector-fresco` | sin tocar | A/B con 5 entregables; el lector dejaría de cargar la confidencialidad | medir primero |
| Pendientes v1.19.2 | sin revisar desde 2026-09-08 | ver `docs/pruebas/medicion-esfuerzo-v1.19.2.md` (a, b, c) | ninguno |

## Última decisión relevante
- 2026-10-06  v1.31 (propuesta): arena y cegado entran, el 6 y el 7 ya están cubiertos; base A de la arena, contra el juez → `DECISIONES.md`
- 2026-10-01  v1.30: `/por-que` entra con criterio de retiro tras la prueba de uso real → `docs/pruebas/council-v1.30.md`
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
