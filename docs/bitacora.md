# Bitácora

Historia del proyecto. Se lee al retomar tras un hueco
largo o cuando CONTINUAR.md no basta. Append-only: no se edita.

## 2026-08-27 — rotado desde CONTINUAR.md

Actualizado: 2026-08-22
## SIGUIENTE PASO (leer esto primero)
Hay **tres ramas sin mergear** esperando decisión de José. Ninguna se subió ni
tiene PR abierto todavía.
| Rama | Qué trae | Qué necesita |
|---|---|---|
| `v1.11-mecanismo` | 3 subagentes + regla de presupuesto de contexto + puerta de delegación | **council** (toca el núcleo) |
| `spec-fichas-de-proyecto` | diseño de fichas de proyecto | que José revise el spec |
| `investigacion-context-engineering` | investigación que respalda las otras dos | nada, es soporte |
**Orden de ejecución recomendado** (detalle en §5 de la investigación):
1. Council sobre `v1.11-mecanismo` → merge.
2. José revisa el spec de fichas → plan de implementación → piloto en
   `ventas-sucursales`.
3. `MEMORY.md` jerárquico — la propuesta ya está escrita en
   `~/.claude/projects/-home-chema/memory/MEMORY.md.propuesta` (el original
   intacto). **No adoptar sin correr la prueba de recall de 10 preguntas que
   viene en el propio archivo; criterio ≥9/10.**
4. Apagar vercel y pr-review-toolkit globalmente y encenderlos por proyecto —
   **solo después** de que existan las fichas de esos proyectos.
Efecto acumulado si todo entra: arranque de sesión de 35,692 → ~29,200 tokens
(−18%), y las 444 delegaciones cada seis semanas dejan de ser genéricas.
**Resuelto el 2026-08-23 (fuera del kit):** los tres proyectos que no tenían
git ya lo tienen, y los 24 del directorio de trabajo quedaron con remoto privado
en GitHub. Detalle en la memoria `repos-y-respaldos`, no aquí: este repo es
público.
## Estado: EN USO — v1.10 en `main`; v1.11 en rama, pendiente de council
El kit está completo, verificado, instalado en el `~/.claude` de José y público
en github.com/chemaw8/claude-kit-chema. Historia por versión en `CHANGELOG.md`
(v1.0 → v1.10). Desde el **2026-07-10** `main` tiene **branch protection activa**:
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
- v1.7 (2026-07-10): ajustes del council de arquitectura de skills — sección
  "Crear una skill nueva" en GOBERNANZA (meta-skill diferida hasta que haya 2º
  autor), vía real de claude.ai corregida en el INSTRUCTIVO, presupuesto de
  descriptions en `verificar.sh` (aviso no bloqueante), `license: MIT` en las 8
  skills (exigido por el linter) y sonda Haiku opcional en el RUNBOOK.
- v1.8 (2026-07-11): cosecha de cuerpos vs otros autores (superpowers,
  anthropics/skills, comunidad) — 14 adiciones de 1-2 líneas repartidas en las
  8 skills tras council de veto (1 cortada por redundancia); regla "Rondas de
  cosecha" en GOBERNANZA (tope prospectivo 2/skill/ronda).
- v1.9 (2026-07-16): plantilla `contexto/BASE-CONOCIMIENTO.md` (3er archivo de
  contexto que el hook ya esperaba pero el kit no traía; salió del onboarding de
  colegas al vault); council a favor por unanimidad. Plugin 1.9.0.
- v1.10 (2026-07-25): escalera de modelos **Opus 4.8 → Opus 5** en el escalón de
  trabajo pesado intermedio (núcleo + evaluadores de council en kit-propuestas);
  Fable 5 sigue en la cima para síntesis y juicio. Cambio de nombre factual, no
  de lógica; sin gate de disparo. Plugin 1.10.0.
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

## 2026-08-29 — rotado desde CONTINUAR.md

v1.13 mergeada a main (comandos `/proyecto-init` y `/cierre` + fichas de proyecto).
v1.14 lista en la rama `fix-auditoria-v114`: arregla lo que una auditoría adversarial
de 13 agentes encontró en el sistema de fichas. Falta su PR + merge.
- [ ] Abrir el PR de `fix-auditoria-v114` hacia main y mergear. Terminado = v1.14 en
      main y reinstalada en ~/.claude con `bash instalar.sh`.
- Abrir:    `CHANGELOG.md` (entrada v1.14) y `docs/superpowers/specs/2026-08-26-comandos-ficha-design.md`
- Ninguno técnico. El merge de v1.14 es decisión de José (gobernanza: PR + council).
| v1.14 (arreglos del audit) | lista en rama, verde | PR + merge | decisión de José |
| Decisiones para José | 2 abiertas | PII de callcenter · ola 3 bajo demanda vs lote | — |
- 2026-08-26  Comandos de ficha aprobados por council 4/4 (con cambios) → CHANGELOG v1.13
- El audit (ultracode, 13 agentes) confirmó ~17 hallazgos y refutó 1; todos con
  arreglo proporcional ya aplicado en v1.14.
- Loops de mejora pendientes (bajo demanda, no urgentes): cerrar el lazo
  observabilidad→evals en `/revisar-salud`; scan de frescura semanal colgado del
  timer de observabilidad ya existente.
- Ola 3 (~17 proyectos sin ficha): hacer con `/proyecto-init` AL REENTRAR a cada
  uno, no en lote (varios están dormidos y una ficha en frío nace vieja).

## 2026-08-30 — rotado desde CONTINUAR.md

**v1.15 en main e instalada** (9 skills con `kit-orquestacion`, 4 comandos, 3 agentes).
El kit quedó **congelado a propósito**: cinco propuestas de mejora se midieron y las
cinco se descartaron con datos (ver DECISIONES.md). No hay trabajo pendiente en el kit.
- **Mediciones de esta sesión** (las que sostienen el congelamiento): banco de disparo
  27/27 con las 70 skills reales · 119 invocaciones de skills del kit en 60 días (51%
  del total) · compactación en 8 de 1,145 sesiones · 83% de solape vault↔memoria ·
  `verificador` 0 usos, `evaluador-council` 8, `lector-fresco` 1.
- El **primer lunes con el reporte de salud arreglado es el 31-ago**: el falso positivo
  de `[cyber]` ya está corregido en `claude-entorno` (contaba su propio MEMORY.md).
  `2026-08-28-vanguardia-para-ultracode.md` (incluye la config de sandbox probada,
  por si el contexto cambia) y `2026-08-28-speculative-ptc-y-huecos-eficiencia.md`.
