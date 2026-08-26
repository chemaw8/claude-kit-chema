---
description: Revisa el reporte de salud del agente y propone/corrige los errores recurrentes
---

Flujo de revisión-y-corrección de la observabilidad del agente. Al invocarlo:

1. **Lee el reporte más reciente** en
   `~/Trabajo/proyectos/claude-entorno/reportes-salud/` (el `.md` con fecha más
   nueva) y el `historial.md` (la tendencia semana a semana).

2. **Compara con la semana anterior** (renglones del historial): ¿la tasa de error
   subió o bajó? ¿aparecieron tipos de error nuevos? ¿algún proyecto se disparó?
   Reporta la tendencia en 2-3 líneas antes de nada.

3. **Identifica los errores RECURRENTES y ARREGLABLES.** No todos lo son: un timeout
   de disponibilidad de modelo no depende de nosotros; un "file does not exist"
   repetido o una fricción de permisos sí. Separa "arreglable por nosotros" de
   "ruido externo" y di cuál es cuál.

4. **Propón el arreglo de cada uno recurrente**, con la evidencia del reporte:
   - Fricción de permisos (WebSearch, scrapling, comandos que piden aprobación) →
     proponer allowlist con `/fewer-permission-prompts` o reglas en settings.
   - "File does not exist" repetido → revisar el flujo que abre rutas equivocadas.
   - Tracebacks recurrentes en un proyecto → ir al script y arreglarlo.
   - Switches `[cyber]` frecuentes → identificar qué lenguaje los dispara y ajustar.

5. **Aplica solo lo que el usuario apruebe.** Presenta los arreglos como opciones,
   según la regla de arranque del núcleo: qué arreglar, qué cuesta, cuál
   recomiendas. No toques
   nada sin visto bueno; los arreglos que cambian settings o permisos son sensibles.

6. **Cierra anotando** qué se arregló, para que la próxima semana se vea si bajó la
   tasa de error de ese tipo (el reporte lo medirá solo).

La meta no es tasa de error cero —algún error es sano (explorar, reintentar)— sino
que no se repitan los mismos errores arreglables semana tras semana.
