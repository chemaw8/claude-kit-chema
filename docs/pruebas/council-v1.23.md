# Council — reglas v1.23 (2026-09-28)

Panel de tres familias en paralelo, sin verse entre sí; cada una recibió solo el diff, la entrada del CHANGELOG y su
ángulo. Síntesis del hilo principal (los tres veredictos convergían en los mismos cambios).

| Evaluador | Ángulo | Veredicto |
|---|---|---|
| Anthropic Opus 5.5 | eficacia y costo en contexto | aprobada con cambios |
| OpenAI Astra | seguridad y corrección técnica | aprobada con cambios |
| Kimi K3 | evidencia y proceso | aprobada con cambios |

**Cambios pedidos y aplicados (ed0923d):**
1. Núcleo: alcance «al cerrar una tarea» (no cada turno) y «si algo queda en manos del usuario» (sin relleno cuando no
   hay nada que decidir); se funde con «Reporta lo que falló o quedó fuera». Fuera «explicar el término técnico»: la
   evidencia no hablaba de jerga y chocaba con el trato al equipo técnico. (Anthropic, Kimi)
2. Evidencia contada como es: dos correcciones del tema, un mismo día, juez con precisión 0.5. (Anthropic, Kimi)
3. Vigilancia con criterio por conteo y revisión a mano, no solo el conteo del juez. (Kimi, Anthropic)
4. `kit-codigo`: distinguir inspeccionar lo descargado de trabajar en el proyecto del encargo; `-I` aísla importaciones,
   no archivos ni red; instalar, construir o probar algo ajeno ejecuta su código. (Astra, Anthropic)
5. Citar la fuente del ataque con URL y fecha, y apoyar la regla en el mecanismo, no en la tasa. (Kimi, Astra)
6. Gate de disparo del núcleo corrido y anotado. (Anthropic, Kimi)

**No aplicado, declarado:** la regla no se repite en `kit-analisis-datos` (hueco aceptado en el CHANGELOG).
