# CONTINUAR — Kit Innovattia para Claude

Actualizado: 2026-07-08

## Qué es este proyecto

Kit distribuible para que cualquier persona de Innovattia obtenga el mejor output
posible de Claude: un `CLAUDE.md` núcleo (principios universales) + skills/playbooks
por dominio + guía humana. Diseñado en conversación con José el 2026-07-08.

## Diseño aprobado (resumen)

- **Núcleo `CLAUDE.md`** (~2 págs): protocolo de arranque (aclarar propósito/
  audiencia/formato/criterio de éxito antes de trabajar; máx 2-3 preguntas),
  anti-complacencia (formato: qué está bien / qué preocupa / qué haría yo),
  calibración por riesgo (trivial→directo; estándar→checklist; alto impacto→council),
  definición de "terminado" (nada se entrega sin verificar), continuidad
  (CONTINUAR.md, fechas absolutas), escalera de modelos (Haiku→Sonnet→Opus 4.8→
  Fable 5 según peso de la tarea), índice de playbooks, regla "cero residuos".
- **7 playbooks** (skills): presentaciones, analisis-datos, research, codigo
  (flujo dev completo: entender→plan→TDD→implementar→review→verificación e2e; git
  atómico; debugging sistemático; higiene anti-contaminación: reutilizar antes de
  crear, respetar patrones del repo, cambios mínimos, cero residuos, dependencias
  justificadas, nada sensible), propuestas (estructura problema→opciones→costos→
  riesgos→recomendación; aquí vive el Council), finanzas (recalcular todo,
  supuestos explícitos, escenarios), automatizacion (trigger/input/output, manejo
  de errores, probada en real, documentada).
- **Council**: 3-5 evaluadores independientes con lentes distintos (viabilidad,
  costo/beneficio, riesgos, abogado del diablo) y mandato de refutar; veredicto
  aprobada/con cambios/rechazada. Automático en decisiones caras/irreversibles o
  material que sale de la empresa; manual con la palabra "council". Evaluadores en
  Opus 4.8, veredicto en Fable 5. En claude.ai web degrada a evaluación secuencial.
- **Extras**: `COMO-PEDIR.md` (guía humana de peticiones + plantillas + palabras
  clave), `INSTRUCTIVO.md` (qué es cada pieza del kit y cómo se usa),
  `contexto/CONTEXTO-EMPRESA.md` (plantilla: qué hace Innovattia, clientes, tono,
  glosario, confidencialidad), bitácora `DECISIONES.md` por proyecto, presentación
  del kit (deck dentro del repo), `CHANGELOG.md` + ciclo de mejora (2 correcciones
  iguales → regla nueva), `instalar.sh` (no pisa CLAUDE.md existente).

## Estado

1. ✅ Brainstorming y diseño aprobados por José.
2. ✅ Investigación deep-research COMPLETA (2026-07-08 ~21:15): 25/25
   afirmaciones confirmadas (24 unánimes, 1 por mayoría 2-1), 0 refutadas.
   Reporte final: `investigacion/reporte-mejores-practicas.md`. Veredictos:
   `investigacion/veredictos-verificacion-2026-07-08.json`.
   Historial técnico (por si hay que reanudar workflows en el futuro):
   - La corrida original (`wf_c55ab737-fbd`) terminó PARCIAL: se agotó el límite
     de gasto mensual a mitad de la verificación. Resultado rescatado: 4
     afirmaciones confirmadas 3-0, 21 extraídas sin verificar, 22 fuentes
     catalogadas. TODO el estado está guardado en este repo:
     `investigacion/estado-investigacion-2026-07-08.json`.
   - Continuación en curso: workflow `wf_17308ba1-f43` (script
     `research-kit-continuacion-*.js` en la carpeta workflows/scripts de la
     sesión) — verifica las 21 pendientes con 3 votos Sonnet esfuerzo bajo
     (lentes: fidelidad/exageración/vigencia) y sintetiza el reporte final con
     Fable. Incluye sondeo Haiku anti-"sin créditos" al inicio.
   - Al terminar: guardar el reporte en `investigacion/reporte-mejores-practicas.md`
     de este repo, actualizar este archivo y pasar al spec.
   - ⚠️ Lecciones de reanudación de workflows: (1) el resume NO guarda `args` —
     hay que repasarlos idénticos o se invalida la caché / falla el run;
     (2) `args` puede llegar como string JSON → parsear con
     `typeof args === 'string' ? JSON.parse(args) : args`;
     (3) los votos de verificación van en Sonnet esfuerzo bajo, NO en Fable
     (la corrida original quemó ~727k tokens por esto).
   - Si la sesión se perdió: el JSON del repo tiene las afirmaciones; solo falta
     verificar las 21 pendientes y sintetizar — no repetir búsquedas.
3. ✅ Hallazgos incorporados al diseño (10 principios P1-P10 en el spec).
4. 🔄 Spec escrito y auto-revisado:
   `docs/superpowers/specs/2026-07-08-claude-kit-design.md`.
   PENDIENTE: revisión de José antes de pasar al plan.
5. ⬜ Plan de implementación (skill superpowers:writing-plans).
6. ⬜ Implementar el kit (núcleo, playbooks, guías, instalador, presentación).
7. ⬜ Council/revisión adversarial del propio manual antes de v1.0.

## Reglas de trabajo acordadas con José

- Nada de "yes sir": evaluar críticamente sus propuestas antes de ejecutar.
- Escalera de modelos en subagentes: Haiku (trivial) → Sonnet (mecánico) →
  Opus 4.8 (pesado intermedio) → Fable 5 (síntesis/juicio crítico únicamente).
- Todo en español; portable a colegas (no depender de la config personal de José).
