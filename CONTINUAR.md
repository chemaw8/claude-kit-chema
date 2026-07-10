# CONTINUAR — Kit Chema

Actualizado: 2026-07-09

## Estado: CONSTRUIDO y probado — v1.0

El kit está completo y verificado. La versión **v1.0** se declaró el
**2026-07-09** (ver `CHANGELOG.md`), con los 8 criterios de aceptación del spec
cumplidos y dos notas ratificadas por el council de dogfooding (C.A.2 en 20/21
disparos y C.A.7 condicional a la marca oficial). Rama de construcción:
`construccion-v1.0`.

## Qué contiene el kit

- **Núcleo** `nucleo/CLAUDE.md` (77 líneas): reglas universales que cargan en
  toda conversación (arranque, evaluación crítica, esfuerzo por riesgo,
  terminado = verificado, continuidad, escalera de modelos).
- **8 skills** en `skills/`: presentaciones, análisis-datos, research, código, redacción,
  propuestas (con el Council), finanzas, automatización.
- **Hook opt-in** `hooks/anti-secretos.sh`: bloquea `git commit` con
  credenciales dentro de Claude Code.
- **Guías humanas**: `COMO-PEDIR.md`, `INSTRUCTIVO.md` y la plantilla
  `contexto/CONTEXTO-EMPRESA.md`.
- **Instalador** `instalar.sh` (no destructivo) y verificador `verificar.sh`.
- **Presentación** en `presentacion/` (deck `kit-chema.pptx` + `guion.md`).

## Pruebas pasadas (evidencia en docs/pruebas/)

1. **`verificar.sh`** → exit 0: núcleo < 150 líneas, descriptions < 1024
   caracteres, skills < 5000 palabras, sin énfasis gritado.
2. **Disparo de descriptions** → 20/21 peticiones naturales activaron la skill
   correcta (criterio ≥ 19/21). `docs/pruebas/disparo-descriptions.md`.
3. **Council plantado/control** → cazó un error de cálculo 50× (rechazada) y
   aprobó una propuesta sólida sin inventar objeciones. `docs/pruebas/council.md`.
4. **Dogfooding del propio kit** → council adversarial sobre el manual;
   hallazgos aplicados en esta v1.0. `docs/pruebas/aceptacion.md` resume los 8
   criterios y su evidencia.

## Estado final (2026-07-09)

Hecho: revisión final de rama ("ready to merge"), merge a `main`, tag `v1.0`,
rama de construcción eliminada, e **instalado en el `~/.claude` de José**
(sin hook). Las 8 skills `kit-*` ya aparecen activas en Claude Code.

## Siguiente paso (José)

1. Rellena `~/.claude/contexto/CONTEXTO-EMPRESA.md` con los datos reales de
   Innovattia (es lo que elimina el output genérico).
2. Decide el hook anti-secretos: `KIT_HOOKS=s ./instalar.sh` para activarlo.
3. Sube el repo a GitHub (privado) y rellena la URL en el README para que
   los colegas instalen con `git clone`.
4. Presenta el deck `presentacion/kit-chema.pptx`.

## Futuro — v1.1

- `desinstalar.sh` (quitar el kit limpio).
- Aviso de drift de versión (avisar si el `~/.claude/` instalado quedó atrás).
- Vía de instalación en Windows.
- Marca oficial cuando existan activos en `~/Trabajo/recursos/marca`.

## Historial (comprimido)

Diseño con José 2026-07-08; deep-research 25/25 afirmaciones confirmadas.
Lecciones de reanudación de workflows: el resume NO guarda `args` (repasarlos
idénticos o falla la caché); `args` puede llegar como string JSON (parsear con
`typeof args === 'string' ? JSON.parse(args) : args`); los votos de verificación
van en Sonnet esfuerzo bajo, no en Fable (la corrida original quemó ~727k tokens
por eso). Estado íntegro de la investigación en
`investigacion/estado-investigacion-2026-07-08.json`.
