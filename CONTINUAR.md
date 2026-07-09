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
2. 🔄 Deep-research en curso: mejores prácticas de CLAUDE.md/prompts/kits
   corporativos/verificación multi-agente.
   - Run ID: `wf_c55ab737-fbd`
   - Script: `~/.claude/projects/-home-chema/7ed46562-6128-418f-894a-f796055bdf11/workflows/scripts/deep-research-wf_c55ab737-fbd.js`
   - Journal (resultados parciales): `~/.claude/projects/-home-chema/7ed46562-6128-418f-894a-f796055bdf11/subagents/workflows/wf_c55ab737-fbd/journal.jsonl`
   - Para reanudar (misma sesión): `Workflow({scriptPath: <script>, resumeFromRunId: "wf_c55ab737-fbd"})` — lo completado sale de caché.
   - Si la sesión se perdió: el journal conserva los resultados; leerlo y sintetizar
     desde ahí en lugar de repetir las búsquedas.
3. ⬜ Incorporar hallazgos de la investigación al diseño.
4. ⬜ Escribir spec formal en `docs/superpowers/specs/2026-07-08-claude-kit-design.md`,
   auto-revisión, revisión de José.
5. ⬜ Plan de implementación (skill superpowers:writing-plans).
6. ⬜ Implementar el kit (núcleo, playbooks, guías, instalador, presentación).
7. ⬜ Council/revisión adversarial del propio manual antes de v1.0.

## Reglas de trabajo acordadas con José

- Nada de "yes sir": evaluar críticamente sus propuestas antes de ejecutar.
- Escalera de modelos en subagentes: Haiku (trivial) → Sonnet (mecánico) →
  Opus 4.8 (pesado intermedio) → Fable 5 (síntesis/juicio crítico únicamente).
- Todo en español; portable a colegas (no depender de la config personal de José).
