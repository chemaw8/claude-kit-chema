# Clave del caso dorado modelo-negocio-02 (fijada 2026-11-22, antes de cualquier corrida)

No la ven los brazos. Convención de referencia: activos(t) = activos(t−1) × 0.95 + 800, mes 1 = 800. Otra
convención razonable de altas y bajas (por ejemplo, bajas desde el mes de alta) se acepta con ±3%.

## Cifras de referencia (pesos sin IVA)
| Concepto | Valor |
|---|---|
| Comisión de cobro por profesionista | $14.17 al mes (349 × 3.5% × 1.16) |
| Contribución por profesionista, meses 1–6 / desde el 7 | $176.69 / $166.69 |
| Contribución por asegurado activo | $5.00 ($35 − $30) → $40,000 al mes desde el mes 4 |
| Profesionistas activos mes 12 / mes 24 | 7,354 / 11,328 |
| Utilidad del mes 12 | −$654 mil (v1 decía +$2.37 M) |
| Primer mes con utilidad positiva | mes 24 (≈ +$8 mil) |
| Aportación máxima (punto más bajo del acumulado) | ≈ $16.96 M, en el mes 23 |
| Utilidad acumulada a 24 meses | ≈ −$16.95 M |
| Ingreso total a 24 meses (profesionistas) | ≈ $50.8 M |
| Marketing | $720 mil al mes (800 × $900) |

## Problemas sembrados en el modelo v1 y en las novedades
| Id | Problema | Se detecta si la respuesta… |
|---|---|---|
| P1 | Canal de escuelas con comisión de $450 sigue en el canvas aunque estudiantes se descartó | lo quita o lo señala como huérfano |
| P2 | Promesa «disponibles 24/7» con horario 8–20 y 4 de 12 nativos (el caso dice certificados C2) | la quita o la corrige |
| P3 | El P&L v1 suma 8,000 asegurados a los alumnos y les cobra $300.86 | separa asegurados (a $35) de profesionistas |
| P4 | Pago de la aseguradora bajó de $45 a $35 | usa $35 |
| P5 | Comisión de cobro 3.5% + IVA ahora sí está en el insumo | la incluye en la cifra base |
| P6 | Costo de profesor sube a $120 desde el mes 7 | lo modela como cambio en el tiempo, no como constante |
| P7 | El P&L v1 no incluye marketing ($720 mil al mes) | lo incluye |
| P8 | Conclusión v1 «da desde el primer año» | la corrige: no da en el año 1; equilibrio mensual hasta ≈ mes 24 y aportación ≈ $17 M |
