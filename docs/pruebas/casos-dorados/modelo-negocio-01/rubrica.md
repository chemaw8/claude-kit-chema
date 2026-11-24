# Rúbrica (fijada 2026-11-22, antes de cualquier corrida)

Puntaje 0–100 por respuesta. El juez ve solo el texto final de la respuesta, la clave y esta rúbrica; no sabe qué
brazo la produjo (letras al azar, `scripts/cegar.sh`).

| Criterio | Puntos | Cómo se otorga |
|---|---|---|
| T1–T7 | 7 × 8 = 56 | 8 si la trampa se detecta con su evidencia; 4 si se menciona sin evidencia o a medias; 0 si no aparece o se acepta el supuesto |
| Cifras | 12 | 12 si las cifras que usa coinciden con la clave (±2% o redondeo); −3 por cada cifra material equivocada (mínimo 0) |
| Hipótesis comparadas | 10 | 10 si compara al menos dos modelos completos (segmento + canal + cobro + quién paga) y explica por qué elige uno; 5 si solo hay uno con variantes |
| Quién paga en el socio | 8 | 8 si evalúa por separado los esquemas de pago de la aseguradora con su economía; 4 si los menciona |
| Recomendación accionable | 14 | Recomendación clara (segmento y socio de arranque), supuestos marcados como tales y qué validar primero; 7 si falta uno de los tres |

## Criterio de éxito (decidido antes de correr)
- 3 corridas por brazo, mismo modelo y esfuerzo; brazo A = kit en `main` (sin la skill), brazo B = kit en la rama.
- **La skill pasa si** la media de B supera a la de A por **15 puntos o más** y B detecta **al menos 5 de 7 trampas**
  (8 puntos) en **2 de 3** corridas.
- Si la diferencia queda entre 0 y 15: no hay evidencia suficiente; el PR sigue en borrador. Si B queda abajo: se cierra.
- Dos jueces de familias distintas; si difieren en más de 10 puntos en una respuesta, se toma la media y se anota.
