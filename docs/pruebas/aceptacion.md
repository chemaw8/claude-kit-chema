# Criterios de aceptación v1.0 — estado y evidencia

Los 8 criterios del spec (`docs/superpowers/specs/2026-07-08-claude-kit-design.md`,
sección 6). Estado al 2026-07-09.

| # | Criterio | Estado | Evidencia |
|---|---|---|---|
| C.A.1 | Núcleo < 150 líneas y pasa la poda línea a línea | Cumplido | `verificar.sh` (77 líneas, exit 0) + prueba de poda del núcleo |
| C.A.2 | Las 7 skills disparan con frases gatillo naturales | Cumplido (con nota) | `docs/pruebas/disparo-descriptions.md` — 20/21 (criterio ≥ 19/21); único fallo es frontera benigna código↔automatización |
| C.A.3 | Council detecta un fallo plantado y no inventa en una propuesta sólida | Cumplido | `docs/pruebas/council.md` — rechazó el error 50× y aprobó la propuesta sólida |
| C.A.4 | Instalador: HOME limpio instala todo; con CLAUDE.md previo no pisa; actualiza solo su sección | Cumplido | Instalador probado hoy en 3 escenarios (limpio, con CLAUDE.md previo, re-ejecución) + `KIT_HOOKS=s`; ver tests re-corridos en `task-19-report.md` |
| C.A.5 | Cero contradicciones entre núcleo, skills y el CLAUDE.md de ~/Trabajo | Cumplido | Chequeo cruzado (cross-read) sin contradicciones detectadas |
| C.A.6 | INSTRUCTIVO y COMO-PEDIR legibles por un colega no técnico | Cumplido | Guías revisadas para lenguaje no técnico (jerga explicada) |
| C.A.7 | Deck de presentación completo y con marca | Cumplido (condicional) | `presentacion/kit-chema.pptx` + `guion.md`; usa la paleta del deck del grupo 2026-07 — la marca oficial se aplicará cuando existan activos en `~/Trabajo/recursos/marca` |
| C.A.8 | El propio kit pasa un council antes de v1.0 (dogfooding) | Cumplido | `docs/pruebas/council-del-kit.md` — council adversarial del manual; hallazgos aplicados en esta v1.0 |

Resumen: **8/8**, con dos notas ratificadas (C.A.2 en 20/21 y C.A.7 condicional
a la marca oficial), tal como consta en el `CHANGELOG.md` de v1.0.
