---
name: kit-modelo-negocio
license: MIT
description: 'Estándar Kit Chema para diseñar, evaluar o actualizar un modelo de negocio (Business Model Generation): canvas de 9 bloques, mapas de empatía, hipótesis cuya coherencia revisa un programa y P&L del modelo y presentación generados por script. Úsala al pedir "modelo de negocio", "business model canvas", "mapa de empatía", "qué segmentos atacamos", "evalúa este negocio nuevo", "actualiza el modelo con lo nuevo y dame el P&L". Cuándo no: cotizar, margen o proyección sin modelo de negocio → kit-finanzas; elegir entre opciones ya armadas → kit-propuestas; datos existentes → kit-analisis-datos.'
---

# Modelo de negocio: estándar Kit Chema


El agente no llena un canvas: **propone hipótesis completas, prueba que concuerden, las compara y recomienda una**,
con fundamentos. Lo que no tiene evidencia se dice; lo que no concuerda se señala. Método: Osterwalder y Pigneur,
*Business Model Generation* (2010); se parafrasea y se cita el capítulo, no se copia texto ni imágenes del libro.

## Regla central: coherencia

Los 9 bloques y los mapas de empatía tienen que concordar. Una hipótesis es un JSON (ejemplo ficticio en
`scripts/ejemplo-hipotesis.json`) donde cada elemento declara qué **requiere**, qué **aporta** y qué **niega**, a quién va
(`para`), quién paga (`paga`), cómo se cobra (`cobro`) y su evidencia (`ev`). Las promesas de marca, las leyes y las
condiciones de los socios entran como `restricciones`, con lo que requieren (una promesa de horario requiere esa
capacidad: si ningún recurso la aporta, C4 falla). `python3 scripts/coherencia.py <hipótesis.json> --verificar`
sale con código 1 si algo choca (pruebas: `scripts/test_coherencia.py`):

| Regla | Qué falla si no se cumple |
|---|---|
| C1 | Un bloque vacío |
| C2 | Un segmento sin propuesta, canal o relación; un ingreso sin pagador o alguien que paga y no aparece en ningún ingreso (en B2B2C paga y usa pueden ser distintos) |
| C3 | Una propuesta que no atiende ningún dolor o ganancia del mapa de empatía de su segmento |
| C4 | Un requisito que nadie aporta (una promesa no se habilita sola) |
| C5 | Algo requerido o aportado que la ley, el proveedor, la marca o un socio niega |
| C6 | Recursos, actividades o socios sin partida de costo (una partida que nadie genera es aviso) |
| C7 | El cliente paga o se informa por un medio que los cobros o canales no cubren |
| C8 | Forma mínima (ids, nombres, textos), referencias rotas y duplicados; un elemento huérfano es aviso |

Si una hipótesis no concuerda, se dice qué choca y se propone la variante que lo resuelve. Lo que no se puede
tipificar (reputación, calendario, economía) va como **juicio** escrito con su evidencia.

## Proceso

Proporcional al encargo: si se pide una sola respuesta (sin proyecto que continúe), las hipótesis pueden ir en tabla y
el JSON con `coherencia.py` solo cuando haya tres o más; sin archivos de continuidad.

1. **Brief**: qué decisión alimenta, para quién, qué no se puede usar (material confidencial, precios no autorizados).
2. **Investigación con auditoría** (kit-research): frentes en paralelo y un auditor de otra familia que abre cada
   fuente. Microdatos oficiales cuando existan, calibrados contra lo publicado: si el script no reproduce la cifra
   oficial, sale con error.
3. **Segmentos con números**: en B2C, desde lo que la economía le exige al cliente (incluido qué % ya gasta el precio
   propuesto); alto valor contra volumen, CLTV contra la regla del tercio y migración entre segmentos →
   `referencias/b2c-segmentos.md`.
4. **Hipótesis completas**: 2 a 8 alternativas reales, cada una con los 9 bloques, los mapas de empatía y su chequeo de
   coherencia. En B2B2C, un mapa por actor y la economía de cada esquema de quién paga, también del que sea inviable
   por ley o contrato; la parte interna (actividades,
   recursos, alianzas, costos) con plantilla fija → `referencias/b2b2c-y-parte-interna.md`.
5. **Economía como «qué tendría que ser verdad»**: contribución por unidad, punto de equilibrio y % de la base que haría
   falta; tres escenarios. La cifra base usa solo lo que trae el insumo: un costo que falta (comisión de cobro,
   impuesto) se dice y va como sensibilidad aparte, no dentro de la base.
6. **Recomendación** (kit-propuestas): opciones con costo, una recomendada, cómo revertirla, qué decide el usuario.
7. **P&L y presentación**, solo con el canvas aprobado por bloque: scripts del proyecto (la skill da la estructura, no
   el código) → Excel con fórmulas → datos recalculados → presentación y acordeón de supuestos, sin cifras a mano → `referencias/pl-y-presentacion.md` (con kit-finanzas y
   kit-presentaciones). Antes de entregar el libro: `python3 scripts/revisar_pl.py <libro>` (recalcula, cuenta
   fórmulas y errores, avisa series pegadas y prueba que un supuesto mueve el resultado); con código ≠ 0 no se entrega.
8. **Actualizar un modelo que ya existe** (llega información nueva): leer la versión previa entera; listar qué cambió,
   con fuente y fecha; quitar lo que quedó huérfano (canales, comisiones o promesas de un segmento descartado) y lo
   que la información nueva contradice; volver a correr la coherencia y decir qué cifras se movieron y cuánto. La
   versión previa no es evidencia: hereda sus errores si no se revisa. Un segmento descartado se marca
   `"estado": "descartado"` en el JSON: `coherencia.py` falla si algo lo sigue nombrando.
9. **Verificación**: réplica independiente de las cifras, council de dos familias sobre la recomendación, lector
   fresco del entregable.

## Errores típicos

- Llenar los 9 bloques con texto genérico: cada elemento lleva evidencia o la marca «supuesto» / «dicho en junta».
- Tomar la base de clientes de un socio como clientes propios: el equilibrio se mide sobre lo que se activa y paga.
- Escoger la opción favorita sin comparar las alternativas que alguien defendería en serio.
- Confiar en un «break even bastante bueno» sin preguntar quién paga, cuánto, cada cuándo y por qué.
- Anotar la respuesta del responsable del negocio sin nombre y fecha: el supuesto queda sin dueño.
- Leer con openpyxl un Excel generado con fórmulas: las celdas salen vacías; recalcular antes de extraer cifras.
- Señalar una promesa que los recursos no cubren y dejarla en el canvas: se quita o se reescribe a lo que sí se cumple.
- Sumar los usuarios de un socio a los clientes propios en el P&L: van en filas y precios separados.
- Un costo que cambia en una fecha (aumento, fin de promoción) escrito como constante: va como serie por mes.

## Entregables

Hipótesis en JSON con su chequeo de coherencia, documento por bloque y por segmento, recomendación y, en la etapa 7,
P&L en Excel, presentación y acordeón de supuestos generados por sus scripts. Ninguna cifra escrita a mano.
