# Council v1.25 — «lo que no cuadra gobierna el resultado» (2026-09-29)

Regla nueva en el cuerpo de dos skills (`kit-analisis-datos` y `kit-finanzas`): un punto en «Bien hecho significa» y
otro en el checklist de cada una. Núcleo y descriptions intactos, así que el gate de disparo no aplica.

Los casos del eval son privados (datos de trabajo real). Aquí van descritos sin cifras ni identificadores; el detalle
está en el repo privado `evals-entregables`, en `docs/ab-kit-v1.25-anomalia.md`.

## De dónde sale
La línea base de entregables del 2026-09-29 (Kit Chema v1.24) dejó dos casos con el mismo patrón:

- **Caso 1, canal mal etiquetado en un P&L.** Parte de las filas que la base marca como un canal pertenecen a otro, y
  eso se ve por el remitente y la campaña. Las 3 veces el agente **lo detecta** (una vez hasta calcula las cifras
  correctas como «vista B»), pero el titular sigue en la lectura literal: una brecha sin facturar que no existe. Lee
  «dilo, no lo resuelvas en silencio» como «no lo resuelvas». Línea base: 0/3.
- **Caso 2, monto declarado que no cuadra con su cálculo.** Un formato contractual dice que su monto «corresponde a»
  horas × tarifa, y la multiplicación da otra cifra. Las 3 veces el agente **recalcula** y cuantifica la diferencia,
  pero escoge por su cuenta una cifra como cobrable: la declarada como «tope firmado», o una tercera salida de una
  hipótesis de IVA que el documento no dice. Línea base: 1/3.

El patrón es: **detecta la anomalía, pero no deja que gobierne el resultado.**

## Texto
`kit-analisis-datos`, «Bien hecho significa»:
> Lo que descubres en el dato gobierna el resultado; no se queda en una nota. Si el propio insumo prueba que una
> etiqueta o una cifra está mal (filas marcadas como venta que por su folio y su serie son devoluciones), corrige antes
> de calcular. El titular y las tablas salen de la lectura corregida, y dices qué corregiste y cuánto movió; la lectura
> literal va como referencia. Decirlo explícitamente no es dejarlo sin resolver. Si la evidencia no alcanza para saber
> qué lectura vale, no escojas una ni inventes una tercera: el resultado queda como discrepancia, con las dos cifras y
> la diferencia a la vista.

`kit-finanzas`, «Bien hecho significa»:
> Una cifra que no cuadra gobierna el renglón; no se queda en una nota. Si un documento declara un total que dice
> salir de un cálculo (cantidad × precio, suma de partidas) y el cálculo no da, o el insumo prueba que parte de los
> datos no pertenece a lo que se calcula, eso decide el resultado. Si el propio insumo prueba cuál lectura vale,
> corrige antes de calcular y el resultado principal sale corregido, diciendo qué cambiaste y cuánto movió. Si no
> alcanza para saberlo, no escojas la cifra que te parece más defendible ni inventes otra con una hipótesis que el
> documento no dice (IVA incluido, un descuento): el renglón queda como discrepancia por aclarar, con las dos cifras y
> la diferencia a la vista. Las hipótesis van como posibles explicaciones, no como monto.

Más una pregunta en el checklist de cada skill. Los ejemplos del texto (ventas que son devoluciones, cantidad ×
precio) no copian los casos del eval, a propósito.

## Medición antes de fusionar (2026-09-29)
**Hallazgo del instrumento:** la línea base de entregables no carga skills. El productor corre con la instrucción «No
tienes herramientas ni archivos que consultar» y en una sola iteración, así que la línea base mide el núcleo, no las
skills. Por eso el A/B **inyecta el texto de las dos skills** en el system prompt, con el mismo encabezado en los dos
brazos: A = skills de v1.24, B = skills con la regla. El disparo real ya muestra que calcular dinero carga
`kit-finanzas` (v1.24: 16/16). Productor Opus, juez Sonnet, criterios sin tocar.

| Caso | Línea base (solo núcleo) | A: skills v1.24 | B: skills + regla |
|---|---|---|---|
| 1. Canal mal etiquetado en un P&L | 0/3 | **0/3** | **2/3**; 3/3 con el titular correcto |
| 2. Monto declarado vs su cálculo | 1/3 | **0/3** | **3/3** |
| Control: reaseguro, lo que cae en la capa vs lo que se recupera | 3/3 | — | 3/3 |
| Control: rampa de apertura fuera de la banda estable | 1/1 | — | 3/3 |

- **Atribución:** con las mismas skills sin la regla, los dos casos quedan en 0/3. La mejora es de la regla, no de
  inyectar la skill.
- **La falla que queda en el caso 1 (B):** cifras y titular correctos; falla porque la recomendación no pide corregir
  la extracción de origen. Queda fuera del alcance de la regla.
- **Controles:** dos casos que hoy pasan y donde lo correcto no es corregir el dato; ninguno empeora. No hay control
  de «dos fuentes que no deben cuadrar» que hoy pase (el caso de ese tipo está en 0/3 y no sirve para ver una
  regresión). Riesgo abierto: que la regla lleve a declarar discrepancias donde no las hay.
- **Costo:** inyectar las skills multiplica el trabajo del productor. El caso 1 pasa de ~1.5 min y 0.40 USD a 6–7 min
  y ~2.4 USD por corrida; el caso 2, de ~1 a ~2.3 min. Se descartaron 4 corridas por timeout (INFRA, sin veredicto);
  con 900 s de timeout no hubo más. En total, 22 corridas y 30.91 USD nominales del plan.
