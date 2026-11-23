# Resultados — caso dorado modelo-negocio-02 (2026-11-23)

**Conclusión, por la letra del criterio fijado: el brazo B (commit `aaa35e5`) quedó en 85.0 contra 86.2 del brazo A
(−1.2). La regla dice que si B queda abajo, el PR se cierra.** En esas corridas la skill no llegó a activarse, así
que B midió la description, no el cuerpo de la skill. El brazo C se agregó **después** de ver ese resultado, con
la description corregida: 92.0 contra 86.2 (+5.8), por debajo del +15 que pide el criterio. Las tres corridas de C
sacaron 20 de 20 en Excel. Decide el dueño; ninguna de las dos lecturas justifica sacar el PR de borrador.

## Qué pasó
1. **Brazo B (commit `aaa35e5`, congelado antes del caso): la skill no se activó en ninguna de las 3 corridas.** Las
   tres cargaron kit-finanzas, igual que el brazo A. Su description no cubría «actualiza el modelo y dame el P&L».
2. Se amplió la description (fila 38 del banco; gate de disparo 21/21 y 8/8 en las filas 31-38) y se corrió un
   brazo C con ese commit (`6279e94`). El cuerpo de la skill es el mismo de `aaa35e5`; solo cambió la description.
   En C se activó en 3 de 3.
3. Las 9 entregas (A, B y C) se calificaron juntas, cegadas con letras al azar, por dos jueces (codex y kimi).

Ningún brazo podía instalar librerías: los nueve entregaron el libro en XML de hoja de cálculo 2003, que Excel abre.
El extractor de la corrida lo convirtió a `.xlsx` con LibreOffice antes de pasarlo a `revisar_excel.py`, que desde
este commit también hace esa conversión por su cuenta.

## Puntajes (codex / kimi)
| Corrida | Skill activa | P1 huérfano | P2 24/7 | P5 comisión | Excel | Total codex | Total kimi |
|---|---|---|---|---|---|---|---|
| A1 | no | 6 | 0 | 3 | 20 | 91 | 91 |
| A2 | no | 0 | 0 | 3 | 15 / 20 | 80 | 85 |
| A3 | no | 0 | 0 | 3 | 20 | 85 | 85 |
| B1 | no (description vieja) | 0 | 0 | 3 | 20 | 85 | 85 |
| B2 | no (description vieja) | 0 | 0 | 3 | 20 | 85 | 85 |
| B3 | no (description vieja) | 0 | 0 | 3 | 20 | 85 | 85 |
| C1 | sí | 6 | 0 | 3 | 20 | 91 | 91 |
| C2 | sí | 6 | 0 | 3 | 20 | 91 | 91 |
| C3 | sí | 6 | 0 | 6 | 20 | 94 | 94 |

| Brazo | Media | Costo (3 corridas) | Duración media |
|---|---|---|---|
| A (sin skill) | 86.2 | $10.34 | 918 s |
| B (skill sin activarse) | 85.0 | $6.82 | 574 s |
| C (skill activa) | 92.0 | $8.28 | 719 s |

## Lectura
- **La diferencia viene de actualizar el modelo.** El canal de escuelas que quedó huérfano lo quitaron las 3 corridas
  con la skill, 1 de 3 sin ella y 0 de 3 con la skill inactiva. Corresponde a la regla nueva «Actualizar un modelo que
  ya existe».
- **Nadie corrigió la promesa «24/7»** (P2): ni con la skill ni sin ella. Las corridas con la skill la señalan, pero la
  dejan en el canvas.
- **Excel, cifras y resumen empataron.** Con Opus y kit-finanzas el P&L ya sale bien hecho: 0 errores, de 458 a
  1,778 fórmulas, supuestos separados y sensible al precio.
- **Costo:** con la skill fue 20% más barato y 22% más rápido que el brazo A.
- **Los dos casos juntos:** caso 01 −9.0 y luego +4.5 tras corregir; caso 02 +5.8. El signo es positivo cuando la skill
  está bien disparada, pero ninguna medición llega a +15.

## Después de medir
Se agregó a «Errores típicos»: una promesa que los recursos no cubren se quita o se reescribe, no basta con señalarla
(P2). Este cambio no está medido.
