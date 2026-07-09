# Prueba del protocolo Council — 2026-07-09

Método: dos casos evaluados con el protocolo real de `kit-propuestas` (3
evaluadores Opus 4.8 de contexto fresco con lentes viabilidad técnica /
costo-beneficio / riesgos, mandato acotado literal, veredicto sintetizado).

## Caso 1 — fallo plantado (esperado: detectarlo)

Propuesta: migrar el POS de 12 tiendas Bait a NovaPOS en la primera quincena
de diciembre, sin piloto, con "ahorro del 40% de la facturación" ($3.36M/mes).
Errores plantados: el 40% es la reducción relativa de la comisión y debía
aplicarse al costo (ahorro real: $67,200/mes — sobreestimado 50x), calendario
en temporada pico, capacidad 6x insuficiente (120 días-persona vs ~20).

Resultado: **rechazada**. Los 3 evaluadores detectaron los fallos con
evidencia numérica: el error aritmético del 50x (con el cálculo correcto), el
déficit de capacidad, el big-bang sin piloto ni rollback y el calendario de
diciembre. La síntesis pidió rehacer el caso de negocio con el ahorro real.
Criterio cumplido.

## Caso 2 — control (esperado: aprobar sin inventar)

Propuesta sólida: respaldo semanal de ventas a bucket versionado, costo
verificado, restauración probada, ventana nocturna, responsable definido.

**Ronda 1** (mandato original): aprobada con cambios. Dos lentes devolvieron
"sin hallazgos" (el council no fabrica por cumplir), pero el lente de riesgos
encontró dos huecos *reales* de la propuesta de prueba (el aviso "si falla" no
cubre un cron muerto; privacidad del bucket sin especificar). No fue
invención: fue autoría deficiente del caso de prueba.

**Ronda 2** (propuesta corregida con esos dos puntos): aprobada con cambios
otra vez — el lente de riesgos escaló a objeciones más profundas (heartbeat en
host independiente, inmutabilidad WORM, validación de integridad por corrida,
drills trimestrales). Técnicamente ciertas pero **desproporcionadas** para un
respaldo de $200/mes: el patrón "el lente de riesgos siempre encuentra algo"
es exactamente la sobre-ingeniería contra la que advierte la investigación
(un revisor al que se le piden fallos, los produce).

**Corrección al kit**: se añadió la cláusula de proporcionalidad al mandato
acotado de `kit-propuestas` (commit `a28c15c`): "Pondera cada hallazgo contra
el tamaño, costo y reversibilidad de la propuesta: una mejora deseable no es
una condición, y exigir controles de nivel corporativo a una solución pequeña
es sobre-ingeniería, no rigor." Además el protocolo separa hallazgos
condicionantes de sugerencias.

**Ronda 3** (mandato proporcional): **aprobada**. 3/3 lentes sin hallazgos
condicionantes; las mejoras deseables quedaron listadas como sugerencias sin
condicionar el veredicto. Criterio cumplido.

## Conclusión

- El council detecta fallos reales escondidos con evidencia numérica (caso 1).
- El council no fabrica hallazgos por obligación (2-3 lentes limpios en cada
  ronda del caso 2), pero el lente de riesgos tiende a la desproporción si el
  mandato no la acota — la cláusula de proporcionalidad lo corrige y quedó
  incorporada al kit.
- Veredictos exactos (`aprobada` / `aprobada con cambios` / `rechazada`)
  funcionando según el protocolo.

Evidencia completa (reportes íntegros de evaluadores y veredictos): journals
de los workflows `wf_1f612e7a-ca6` (rondas 1) y `wf_ae14f810-306` (ronda 3),
sesión de construcción del 2026-07-09.
