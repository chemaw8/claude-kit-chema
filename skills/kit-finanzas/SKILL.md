---
name: kit-finanzas
license: MIT
description: Estándar Kit Chema para trabajo con dinero y números de negocio — cotizaciones, presupuestos, proyecciones, márgenes, costos, análisis financiero. Úsala al pedir "cotiza", "presupuesto para", "proyección de", "cuánto nos cuesta", "margen de". Obliga a recalcular toda cifra (nunca confiar en números de memoria o del prompt), declarar supuestos y presentar escenarios.
---

# Finanzas y números de negocio — estándar Kit Chema

Playbook para trabajar con dinero: cotizaciones, presupuestos, proyecciones,
márgenes y costos. La regla que sostiene todo lo demás es que ninguna cifra se
confía a ojo: toda la que entra al entregable se recalcula aquí, nunca se copia
del prompt ni se recupera de memoria. Un número que suena razonable pero no
recomputaste es una adivinanza con formato de dato.

## Bien hecho significa

- Toda cifra está recalculada, no copiada ni recordada. Cada monto del entregable
  salió de una operación que hiciste en esta sesión, no de un número que traía el
  prompt ni de uno que "recuerdas" de otro trabajo. Los modelos de lenguaje
  inventan cifras que suenan bien; la única defensa es volver a computar cada una.
- Los supuestos están listados y son cuestionables. Precios, tasas, plazos y
  volúmenes que usaste aparecen escritos aparte, donde el lector puede verlos y
  discutirlos. Un supuesto que nadie puede señalar es un supuesto que nadie puede
  corregir.
- Las proyecciones traen escenarios. Nada que mire al futuro se entrega como un
  solo número: hay al menos un rango que refleja que el futuro no se conoce. Una
  cifra única para lo que aún no pasa finge una precisión que no existe.
- Los totales cuadran. Cada suma se verificó dos veces, idealmente por caminos
  distintos (por fila y por columna, o con una segunda fórmula), de modo que un
  error de dedo no llegue al entregable. Un total sin verificar es donde se
  esconden los errores más caros.

## Proceso

Este es el orden; el primer paso es el que más se salta y el que decide si el
resto sirve.

1. Listar supuestos primero. Antes de calcular nada, escribe los supuestos con su
   valor: precios unitarios, tasas (interés, impuestos, comisión), plazos y el
   tipo de cambio con su fecha. Si los números de entrada vienen de fuera (el
   Excel del cliente, una lista de precios, un estado financiero), revísalos
   antes de calcular: sin campos vacíos ni valores implausibles (costo en cero,
   margen negativo sin explicación) — recalcular perfecto sobre entrada corrupta
   da resultado corrupto. Sin esta lista, el cálculo es una caja negra que
   nadie puede auditar ni actualizar.
2. Construir el cálculo con pasos visibles. Haz las operaciones en una tabla o un
   script que quede a la vista, no en aritmética mental. Cada monto debe poder
   rastrearse hasta la operación que lo produjo; un número sin su cálculo detrás
   no es verificable.
3. Escenarios para las proyecciones. Cuando el entregable mira al futuro, arma
   tres versiones —base, optimista y pesimista— cambiando los supuestos que más
   pesan. Así el lector ve el rango de resultados posibles y de qué dependen, no
   una sola apuesta disfrazada de certeza.
4. Verificación: recomputar los totales por otra vía. Antes de entregar, vuelve a
   sumar por un camino distinto al que usaste. Si las dos vías no dan lo mismo,
   hay un error: encuéntralo, no promedies.
5. Presentar con formato consistente. Toda cifra sale con la misma moneda, los
   mismos decimales y separadores de miles. Mezclar formatos hace que el lector
   compare mal y desconfíe del resto.

## Checklist final

Antes de entregar, con los números y el cálculo delante:

- ¿Los supuestos están explícitos y listados aparte?
- ¿Los cálculos están a la vista y se pueden re-ejecutar? Si el entregable es
  una hoja de cálculo: fórmulas vivas en las celdas calculadas, no valores
  pegados — cambiar un supuesto debe actualizar el resultado sin rehacer nada.
- ¿Los totales se verificaron dos veces, por caminos distintos?
- ¿Las proyecciones traen escenarios, no una sola cifra?
- ¿Están declaradas la moneda y la fecha del tipo de cambio?

## Errores típicos

- Aritmética mental en los montos. Sumar o multiplicar dinero "de cabeza" y
  escribir el resultado: es donde más entran los errores y nadie puede
  rastrearlos. Todo monto sale de una operación visible.
- Supuestos enterrados en el texto. Meter el precio o la tasa en medio de un
  párrafo en vez de listarlos: el lector no los encuentra para discutirlos y el
  cálculo queda imposible de actualizar.
- Una sola cifra puntual para el futuro. Entregar "venderemos $2.400.000 el
  próximo año" como dato firme, sin rango ni escenarios, finge una precisión que
  no se tiene.
- Mezclar monedas o IVA sin decirlo. Sumar pesos con dólares, o montos con IVA
  incluido junto a otros sin IVA, sin declararlo: el total resultante no
  significa nada.
