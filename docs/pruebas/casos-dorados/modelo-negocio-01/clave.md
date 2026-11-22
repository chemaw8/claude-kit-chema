# Clave del caso dorado modelo-negocio-01 (fijada 2026-11-22, antes de cualquier corrida)

No la ven los brazos. Valores calculados con `insumo/encuesta.csv` (semilla 20261122) y los documentos del insumo.

## Cifras de referencia
| Concepto | Valor |
|---|---|
| Estudiantes en la encuesta / pagan habitualmente con tarjeta / en efectivo | 285 / 15.1% / 73.7% |
| Estudiantes que hoy gastan $149 o más | 39.6% (mediana $131) |
| Profesionistas: n / tarjeta / gastan $349 o más / interés ≥ 4 | 273 / 76.9% / 65.6% / 65.9% |
| Oficio: interés ≥ 4 / mediana de gasto | 18.0% / $97 |
| Estudiante: precio sin IVA / contribución / CLTV (churn 12%) / un tercio del CLTV | $128.45 / $60.45 / $503.7 / $167.9 |
| Comisión de $450 a escuelas | 2.7 veces el tercio; payback 7.4 meses contra 8.3 de vida media; remanente $53.7 |
| Profesionista: precio sin IVA / contribución / CLTV (churn 5%) / payback del CAC de $900 | $300.86 / $190.86 / $3,817 / 4.7 meses |
| Profesionistas activos para cubrir $1.2 M de fijos | ≈ 6,287 |
| Aseguradora: activación esperada con la experiencia previa | 22,000 (5.5%); uso mensual ≈ 8,000 (2%), no 40,000 |
| Aseguradora esquema 1 | $15 de contribución por usuario activo (≈ $120 mil al mes con 8,000) |

## Trampas sembradas
| Id | Trampa | Se detecta si la respuesta… |
|---|---|---|
| T1 | Estudiantes solo con domiciliación a tarjeta, pero 73.7% paga en efectivo y 15.1% con tarjeta | señala el choque entre medio de cobro y medio de pago del segmento y propone otro cobro o descarta el segmento |
| T2 | «10% de 400 mil = 40 mil alumnos» | corrige con la experiencia previa (5.5% activa, 2% usa) o dice que la base del socio no son clientes propios |
| T3 | Comisión de $450 a escuelas | la compara contra el CLTV (o payback) del estudiante y concluye que es excesiva o casi se come todo el valor |
| T4 | «Profesores nativos, 24/7» | señala que solo 4 de 12 son nativos y no hay horario 24/7 (8–20, lun–sáb) |
| T5 | Esquema 2: cobrar $49 dentro de la prima | señala que la aseguradora no puede cobrarlo en la prima sin registrar un producto (9–12 meses) |
| T6 | Ingreso por publicidad sin pagador ni tarifa | lo marca como supuesto sin pagador o lo excluye de la economía |
| T7 | Precio de estudiante por encima de lo que gasta la mayoría | nota que solo 39.6% gasta $149 o más |
