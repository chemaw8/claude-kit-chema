# Council v1.24 — «calcular dinero del negocio no es trivial» (2026-09-29)

Panel de tres familias, cada una sin ver a las otras: Anthropic (Opus 5.5, ángulo costo/beneficio y sobre-disparo),
OpenAI (Astra, redacción y ambigüedad operativa), Moonshot (K3, evidencia y riesgo). **Veredicto: 3 × aprobada con
cambios**, con las mismas objeciones de fondo.

Texto propuesto: «Una cifra de dinero (precio, costo, margen, cotización) no es trivial aunque la cuenta lo parezca:
carga kit-finanzas».

| Objeción | Quién | Qué se hizo |
|---|---|---|
| Dispara por presencia de dinero: «¿cuánto cuesta el plan Pro?», corregir la ortografía de «100 pesos», sumar el súper | las tres | El disparador pasa a **calcular o analizar dinero del negocio**, con dos ejemplos de lo que sí es trivial |
| «Cotización» no está en la evidencia (cobrar y presupuesto ya salían 3/3) y la reclaman dos skills | Anthropic, Moonshot | Sale de la regla |
| El arreglo no está medido; n=3 es señal, no cifra | Anthropic, Moonshot | A/B real antes de fusionar: 4 positivos con costos a la mano y 4 controles triviales, 4 corridas por caso y por brazo (`evals-entregables/specs/005-disparo-real/banco-dinero.md`) |
| Criterio de retiro | Moonshot | Si los controles cargan kit-finanzas en más de 20 % de corridas, la cláusula sale del núcleo |
| La capa es la correcta: el modelo decide «trivial» antes de mirar la tabla de ruteo; la description ya dice «margen de» | las tres | Se queda en el núcleo |
| Fuera de alcance: kit-finanzas no tiene salida corta para un número puntual | Anthropic | Anotado; no entra en este PR |

Texto final (núcleo 137 → 139 líneas, 11 al tope):
> Tarea trivial → respuesta directa. Calcular o analizar dinero del negocio (precio a cobrar, costo, margen) no lo es
> aunque la cuenta sea simple: carga kit-finanzas. Consultar un precio público o convertir unidades sí es trivial.

## Medición antes de fusionar (2026-09-29)
| Grupo | Antes (v1.23.2) | Después (v1.24) |
|---|---|---|
| Positivos: margen, «¿cuánto nos queda?», «¿cuánto nos cuesta?», precio para ganar 30 % (con `costos-paquete.csv`) | 7/16 | 16/16 |
| Controles: plan Pro de Claude, 250 USD a 18.50, suma del súper, ortografía con «100 pesos» | 0/16 | 1/16 (conversión) |

Reportes en evals-entregables: `reportes/2026-09-29-0322-disparo` (antes) y `2026-09-29-0340-disparo` (después), fuera
de git. Cumple el criterio del council: los positivos suben y los controles quedan por debajo del 20 %.
