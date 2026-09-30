# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-30  ·  commit b105ebc (rama pstack/ronda-2)  ·  cierre limpio: sí
> Estado vivo de sesión. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**Estado al 2026-09-30:** v1.27 en PR (rama `pstack/ronda-2`): el revisor de señales de IA vuelve al checklist de
`kit-redaccion`, regla F12 (prefijo con guion) y «Probar de verdad» se corre solo. Council v1.27: aprobada con cambios,
aplicados. Proponer `/crear-verificacion` espera su primera corrida real.

## Siguiente paso
- [ ] Primera corrida real de `/crear-verificacion` (sesión nueva, clon limpio, defecto sembrado) → anotar en
      `docs/pruebas/council-v1.26.md`.
- [ ] Limpiar el texto del kit: 39 rayas espaciadas y 15 prefijos con guion (toca descriptions: gate de disparo).
- [ ] Vigía de v1.25 (umbral de retiro en `docs/pruebas/council-v1.25.md`).
- [ ] 2026-10-28: revisar la vigilancia de «cierre en palabras llanas» (`~/.claude/kit-chema/reglas-vigiladas.json`).

## Cómo retomar
- Abrir:    `investigacion/2026-09-30-pstack-y-mercado.md` (secciones 3 y 4) · `git log main..pstack/ronda-2`
- Correr:   `bash verificar.sh` → código 0 y ninguna línea `FALLA`
- Verificar: `bash scripts/muletillas.sh autotest` → «todo en verde»

## Bloqueadores / esperas
- Ninguno. Lo siguiente es fusionar v1.27 y la primera corrida real de `/crear-verificacion`.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Ronda pstack (v1.26) | council aprobada con cambios, aplicados | fusionar; luego primera corrida del comando y A/B de la raya | ninguno |
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
