# Clave del caso dorado modelo-negocio-03 (fijada 2026-11-23, antes de cualquier corrida)

No la ven los brazos. Pesos sin IVA salvo que se diga.

## Cifras de referencia
| Concepto | Valor |
|---|---|
| Precio A vigente | $799 con IVA (DECISIONES 2026-10-20) → $688.79 sin IVA. El memo de finanzas («$799 sin IVA») contradice la decisión vigente |
| Costo por bici activa al mes | $604.17 depreciación (14,500 / 24) + $180 + $95 = $879.17 |
| Robo y pérdida | 1.5% × $14,500 = $217.50 por bici activa al mes |
| Contribución A | −$190.37 sin robo; **−$407.87 con robo** |
| Contribución B ($499 con IVA → $430.17) | −$666.49 con robo |
| Contribución A por la plataforma (comisión 12% recurrente) | −$490.53 |
| Precio de equilibrio por unidad (sin fijos) | $1,096.67 sin IVA → **$1,272.13 con IVA** |
| Churn del piloto | semanal 1.95% → **mensual ≈ 8.2%**, excluyendo la semana 12 (3 días) y la semana 7 duplicada; con ellas ≈ 7.5% |
| Base de la plataforma | 30 mil empleados (la columna está en miles) × 3% = **900 usuarios**, no 30 × 3% |
| P&L v2 | valores pegados, sin depreciación ni robo; su «contribución positiva» ($524) es falsa |

## Problemas sembrados
| Id | Problema | Se detecta si la respuesta… |
|---|---|---|
| Q1 | Decisiones que se sustituyen en el tiempo | usa $799 con IVA para A y B reactivado con débito (las entradas más recientes) |
| Q2 | Memo de finanzas dice «$799 sin IVA» | señala la contradicción con DECISIONES y la resuelve o la declara como supuesto |
| Q3 | Costo unitario mayor que el precio | calcula contribución A negativa (≈ −$190 sin robo o ≈ −$408 con robo, ±3%) |
| Q4 | Robo 1.5% mensual sin seguro | lo incluye como costo por bici activa (o equivalente en el P&L) |
| Q5 | Piloto con semana parcial y fila duplicada | churn mensual ≈ 8.2% (±0.5) o explica que excluyó la semana 12 y la duplicada |
| Q6 | Comisión de la plataforma sobre cada cobro | la aplica de forma recurrente, no solo en el alta |
| Q7 | Empleados en miles | 900 usuarios potenciales (30,000 × 3%) |
| Q8 | P&L v2 pegado y sin depreciación/robo | no lo reutiliza: lo señala y lo reconstruye con fórmulas |
| Q9 | Conclusión | no arrancar en enero con estos precios; precio de equilibrio ≈ $1,272 con IVA (±3%) o cambiar costo de la bici |
| Q10 | B reactivado | concluye que B empeora el resultado (contribución más negativa); si lo descarta, quita también su canal de universidades |
| Q11 | P&L que se mueve | según el reporte objetivo del Excel: ≥ 50 fórmulas, 0 errores y cambiar un supuesto mueve el resultado |
