# Estándar de estructura de proyecto

Cómo se organiza un proyecto para que ninguna sesión re-deduzca su alcance.
Extiende las piezas que el kit ya instala (ficha, CONTINUAR, DECISIONES,
/proyecto-init, /cierre) con la capa que faltaba: **specs por feature**.
Adopción parcial de Spec-Driven Development (origen: curso hello-sdd de
MoureDev, 2026-08; se descartaron EARS obligatorio y spec-as-source).

## El árbol

```
proyecto/
├── CLAUDE.md              ficha ≤40 líneas (la genera /proyecto-init)
├── CONTINUAR.md           estado de reanudación — pasa `contrato` del helper
├── DECISIONES.md          decisiones fechadas con alternativas descartadas
├── README.md              qué es y cómo correr
├── .gitignore             desde el primer commit (secretos y datos fuera)
├── .claude/settings.json  permisos (propuestos, aprobados por el usuario)
├── specs/NNN-nombre/      por feature sustantiva: spec.md · plan.md · tasks.md
└── docs/bitacora.md       historia append-only (la alimenta el helper)
```

## Cuándo se abre una spec

**Cuando una feature va a cruzar sesiones y toca lógica de negocio o un
entregable con audiencia → `specs/NNN-nombre/` antes de escribir código.**
Es un escalado desde el plan corto de kit-codigo, no una puerta previa: un fix
de una línea, un ajuste o un script de un solo uso siguen con plan corto,
aunque el proyecto sea grande.

**Cuando el proyecto entero es muy chico** (script de un uso, exploración
puntual) → **pregunta al usuario** si estructura completa o mínima (ficha +
CONTINUAR). Nunca lo decidas en silencio.

## El flujo por feature

1. **Spec** — requisitos numerados (RF-n) y verificables: una comprobación
   concreta puede decidir si cada uno se cumple. Plantilla: `plantillas/spec.md`.
2. **Clarificación** — releer la spec como QA: ambigüedades, contradicciones,
   casos límite ausentes. Solo detectar, no resolver.
3. **Plan** — módulos, datos, y cada decisión con su alternativa descartada.
4. **Tareas** — de ~30 min, con sus RF y una línea "Hecho cuando:" verificable.
5. **Implementación** — una tarea a la vez; TDD según kit-codigo.
6. **Validación** — recorrer la spec RF por RF: qué comprobación cubre cada uno.
7. **Cambio** — nuevo requisito → primero el diff de la spec, luego el código.

## Qué no es esto

Ni notación EARS obligatoria, ni spec-as-source, ni ceremonia para tareas
chicas. Las plantillas se **copian** al proyecto, nunca se enlazan: un proyecto
no debe romperse si el estándar cambia.
