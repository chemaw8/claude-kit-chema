# Auditoría del núcleo — 2026-10-19

**Núcleo auditado:** el de la v1.34 (137 líneas, sin la v1.22). **Regla de la auditoría:** una sección se sostiene si
tiene al menos uno de estos respaldos: un **control** que la aplica (hook, herramienta, CI), una **medición** con
efecto, un **ruteo** medido por el gate de disparo, o una **trampa concreta** que la motivó. Lo que no tiene ninguno se
mide antes de decidir, no se poda a ciegas: la literatura no muestra que acortar mejore por sí solo
(`claude-entorno/docs/2026-10-19-investigacion-skills-reglas.md`, privado).

**Fuentes de uso real** (30 días, contadas con scripts, sin contenido): sesiones de pi; fallos del advisor
confirmados por el panel de jueces; correcciones del dueño agrupadas por aprender-semanal.

## Por sección

| Sección | Líneas | Respaldo | Evidencia de uso real | Veredicto |
|---|---|---|---|---|
| Contexto | 8 | Control: hook `SessionStart` que inyecta el contexto | — | Se queda (el texto es el respaldo cuando no hay hook, p. ej. el plugin) |
| Arranque de tarea | 12 | Control: herramienta `preguntar_alcance` en pi | Se usa en 56 de 86 sesiones (183 llamadas) | Se queda |
| Evaluación crítica | 8 | **Ninguno** | Sin medir | **Medir** (es la regla que el dueño marca como «el peor fallo posible») |
| Esfuerzo proporcional | 10 | Ruteo: disparador de kit-finanzas (v1.24, gate) | Gate de disparo 83/90 | Se queda |
| Presupuesto de contexto | 11 | Control parcial: `guardia-lecturas` (opt-in) | 6 fallos confirmados del tema | Se queda; revisar si el hook atrapa algo |
| Terminado = verificado | 9 | Medición en curso: v1.32 (estado primero) hasta el 2026-11-07; control `verificar-cierre` (pi) | **Lo más incumplido:** 75 fallos confirmados de cifras o hechos sin respaldo y 30 de «subido/pruebas» sin respaldo; correcciones de «cierre sin jerga» **cada semana** (3, 3, 4, 3, 3) pese a v1.23 y v1.32 | Se queda; el texto no basta: **controles** |
| Cero residuos | 5 | Control parcial: `backstop-cierre` | 6 fallos confirmados | Se queda; **control de residuos** al cierre |
| Continuidad | 13 | Control fuerte: `rotar-continuar` (contrato, reconciliar), hooks de apertura y cierre | Fechas relativas: 8 fallos confirmados, **sin control** | Se queda; **control de fechas relativas** |
| Subagentes | 29 | Medición (esfuerzo antes que modelo, v1.19.2); control: política de subagentes y `/ultracode` en pi | — | Se queda; es la sección más larga y repite detalle de kit-orquestacion (poda opcional, ~5 líneas) |
| Estructura de proyectos | 8 | Ruteo a kit-codigo (council 2026-08-31) | — | Se queda (el council de la v1.34 confirmó que rutea) |
| Mejora del kit | 7 | Control: GOBERNANZA, rama protegida, CI | — | Se queda |
| Playbooks | 13 | Ruteo medido por el gate | 83/90 | Se queda |

## Conclusión

1. **No hay una poda grande que hacer.** 11 de 12 secciones tienen control, medición o ruteo medido. Lo que falla en
   la práctica no es que sobre texto: es que **«Terminado = verificado» se incumple mucho y el texto no lo cambia**.
2. **Lo que sigue son controles, no reglas:** fechas relativas sin fecha (cierre y CONTINUAR), residuos al cierre y,
   después de que termine la vigilancia de la v1.32 (2026-11-07), jerga en el cierre.
3. **Una sección sin ninguna evidencia: Evaluación crítica.** Antes de tocarla, medirla con casos-trampa (el usuario
   propone una idea con un error comprobable; pasa si el agente lo señala antes de ejecutar).
4. Poda opcional, sin urgencia (137/150): el detalle medido de «Subagentes» puede remitir a kit-orquestacion.
