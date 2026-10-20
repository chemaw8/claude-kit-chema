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
| Presupuesto de contexto | 11 | Control parcial: `guardia-lecturas` (opt-in) | Ningún fallo confirmado del tema (ver corrección) | Se queda |
| Terminado = verificado | 9 | Medición en curso: v1.32 (estado primero) hasta el 2026-11-07; control `verificar-cierre` (pi) | **Lo más incumplido:** 75 fallos confirmados de cifras o hechos sin respaldo y 30 de «subido/pruebas» sin respaldo; correcciones de «cierre sin jerga» **cada semana** (3, 3, 4, 3, 3) pese a v1.23 y v1.32 | Se queda; el texto no basta: **controles** |
| Cero residuos | 5 | Control parcial: `backstop-cierre` | Ningún fallo confirmado del tema (ver corrección) | Se queda |
| Continuidad | 13 | Control fuerte: `rotar-continuar` (contrato, reconciliar), hooks de apertura y cierre | Fechas relativas: ningún fallo confirmado ni corrección; en los CONTINUAR y DECISIONES, «hoy» casi siempre significa «actualmente» dentro de un bloque ya fechado | Se queda; **sin control nuevo** |
| Subagentes | 29 | Medición (esfuerzo antes que modelo, v1.19.2); control: política de subagentes y `/ultracode` en pi | — | Se queda; es la sección más larga y repite detalle de kit-orquestacion (poda opcional, ~5 líneas) |
| Estructura de proyectos | 8 | Ruteo a kit-codigo (council 2026-08-31) | — | Se queda (el council de la v1.34 confirmó que rutea) |
| Mejora del kit | 7 | Control: GOBERNANZA, rama protegida, CI | — | Se queda |
| Playbooks | 13 | Ruteo medido por el gate | 83/90 | Se queda |

## Corrección (2026-10-19, misma sesión)
La primera versión daba «8 fallos de fechas relativas», «6 de residuos» y «6 de contexto». Venían de clasificar los
fallos confirmados por palabras clave; al leerlos, **ninguno trata de esos temas**: todos son afirmaciones sin
respaldo en el turno («borré X», «el commit trae Y», «cuarto mes seguido» con tres alzas). Se retiran esos tres
controles propuestos. El patrón dominante es uno solo: **afirmar sin respaldo en el turno.**

## Conclusión

1. **No hay una poda grande que hacer.** 11 de 12 secciones tienen control, medición o ruteo medido.
2. **Casi todo lo que falla en la práctica es una sola cosa: afirmar sin respaldo en el turno** (cifras, «subido»,
   «borré», «probado»), más el cierre con jerga (corrección semanal del dueño). El texto no lo ha cambiado.
3. **El control que corresponde es ampliar `verificar-cierre`** (que ya compara «subido» y «terminó» contra datos) a
   las afirmaciones comprobables con datos: «borré <ruta>», «las pruebas pasan». Pero **no antes de re-medirlo el
   2026-10-26**: su primera semana dio 0 de 6 aciertos y ampliarlo antes contaminaría esa medición.
4. **Una sección sin ninguna evidencia: Evaluación crítica.** Medirla con casos-trampa (el usuario propone una idea
   con un error comprobable; pasa si el agente lo señala antes de ejecutar). Es lo único que se puede hacer ya sin
   contaminar nada.
5. Poda opcional, sin urgencia (137/150): el detalle medido de «Subagentes» puede remitir a kit-orquestacion.
6. Jerga en el cierre: después de que termine la vigilancia de la v1.32 (2026-11-07).
