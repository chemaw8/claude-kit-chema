# CONTINUAR — Kit Chema

Actualizado: 2026-07-10

## Estado: EN USO — v1.6, `main` con branch protection activa

El kit está completo, verificado, instalado en el `~/.claude` de José y público
en github.com/chemaw8/claude-kit-chema. Historia por versión en `CHANGELOG.md`
(v1.0 → v1.6). Desde el **2026-07-10** `main` tiene **branch protection activa**:
todo cambio —incluido el del dueño— entra por PR con los dos checks de CI en
verde (`límites del kit`, `escaneo de secretos (gitleaks)`); ver `GOBERNANZA.md`.
v1.0 se declaró el 2026-07-09 con los 8 criterios de aceptación del spec
cumplidos (rama de construcción `construccion-v1.0`, ya eliminada).

## Qué contiene el kit

- **Núcleo** `nucleo/CLAUDE.md` (81 líneas): reglas universales que cargan en
  toda conversación (arranque, evaluación crítica, esfuerzo por riesgo,
  terminado = verificado, continuidad, escalera de modelos).
- **8 skills** en `skills/`: presentaciones, análisis-datos, research, código, redacción,
  propuestas (con el Council), finanzas, automatización.
- **Dos hooks**: `kit-chema-contexto.sh` (SessionStart, autocarga tu contexto,
  por defecto) y `anti-secretos.sh` (opt-in, bloquea commits con credenciales).
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

## Hecho después de v1.0

- v1.1 contexto generalizado (empresa + personal); v1.2 plugin híbrido +
  salvaguardas (CI, CODEOWNERS, GOBERNANZA); v1.3 licencia MIT + compatibilidad
  con superpowers/pr-review-toolkit; v1.4 hook de contexto (SessionStart); v1.5
  skill kit-redaccion (8ª skill, gate de disparo 10/10); v1.6 mejoras de cuerpos
  cosechadas de ECC y vetadas por council + eval-harness formalizado.
- Contexto real de Innovattia ya cargado en `~/.claude/contexto/` (empresa +
  personal + base de conocimiento); el hook de contexto lo autocarga.
- **Branch protection activada en `main`** (2026-07-10) y el plugin quedó
  sincronizado en 1.6.0.

## Siguiente paso (José)

1. Presentar el deck `presentacion/kit-chema.pptx` a los colegas del grupo.
2. Decidir si activa el hook anti-secretos (`KIT_HOOKS=s ./instalar.sh`); el de
   contexto ya se instala por defecto.
3. Cuando haya 2+ colaboradores, subir aprobaciones requeridas a 1–2 y activar
   `require_code_owner_reviews` (ver `GOBERNANZA.md`).

## Futuro (no bloqueante)

- `desinstalar.sh` (quitar el kit limpio).
- Aviso de drift de versión (avisar si el `~/.claude/` instalado quedó atrás).
- Vía de instalación en Windows.
- Plugin "lean" y hook anti-secretos sin dependencia de python3.
- Marca oficial cuando existan activos en `~/Trabajo/recursos/marca`.

## Historial (comprimido)

Diseño con José 2026-07-08; deep-research 25/25 afirmaciones confirmadas.
Lecciones de reanudación de workflows: el resume NO guarda `args` (repasarlos
idénticos o falla la caché); `args` puede llegar como string JSON (parsear con
`typeof args === 'string' ? JSON.parse(args) : args`); los votos de verificación
van en Sonnet esfuerzo bajo, no en Fable (la corrida original quemó ~727k tokens
por eso). Estado íntegro de la investigación en
`investigacion/estado-investigacion-2026-07-08.json`.
