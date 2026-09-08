# Medición — ¿esfuerzo antes que modelo?  (evidencia de la regla de v1.19.2)

El council de v1.19.2 aprobó la regla "antes de subir de Opus 5 a Fable, sube el esfuerzo" con un
aviso: **faltaba evidencia de que Opus 5 a `--effort max` se queda corto**. Esto es esa medición,
corrida antes de fusionar el PR.

Solo resultados **relativos**: el kit es público y no publica cifras de consumo ni rutas de la
máquina donde se midió (bloqueante de la primera revisión del acta).

## Método

- **Material:** 5 casos de entregable de negocio con respuesta auditada (numéricos y de trampa
  plantada), de una batería privada del mantenedor. Cada caso lo produce un agente **fresco**, con
  el kit cargado y sin ver la respuesta esperada.
- **Juez fijo:** el mismo juez (Sonnet) puntúa los tres brazos contra el mismo criterio auditado.
  El juez no cambia entre brazos; es la única forma de que los veredictos sean comparables.
- **Tres brazos, secuenciales** (en paralelo se contaminan las latencias):
  1. Opus 5, esfuerzo por defecto
  2. Opus 5 con `--effort max`
  3. Fable 5.1, esfuerzo por defecto
- **Lo que se compara:** la batería es pasa/no pasa y estaba saturada, así que **no discrimina
  calidad**: de que los tres brazos pasen no se sigue "igual calidad", solo **"no se detectó
  diferencia"**. Lo que sí ordena a las configuraciones es **costo y latencia**, medidos por
  corrida (`--output-format json`).
- **Una advertencia de limpieza que parte los resultados en dos.** La versión del kit instalada
  cambió a mitad de la corrida. Los brazos 1 y 2 corrieron **completos con el mismo núcleo**, así
  que su comparación es limpia. El brazo 3 (Fable 5.1) arrancó antes del cambio y terminó después:
  **2 de sus 4 casos comparables están contaminados**. Por eso abajo se dan sus dos lecturas.

## Resultado

En los **4 casos que los tres brazos pudieron entregar**, los tres pasan los 4: no se detectó
diferencia de calidad entre las tres configuraciones.

**Comparación limpia** (los dos brazos con el mismo núcleo, n = 4):

| Brazo | Costo por corrida | Tiempo |
|---|---:|---:|
| Opus 5, esfuerzo por defecto | referencia | referencia |
| Opus 5, `--effort max` | **+32 %** | **+46 %** |

**Comparación de los tres brazos, también limpia** (los 2 casos del brazo Fable 5.1 que corrieron
antes del cambio de kit; los brazos 1 y 2 corrieron completos con ese mismo núcleo, así que en esos
2 casos los tres son comparables de igual a igual). Es la **única** lectura limpia que incluye a
Fable 5.1, y es la que sostiene el orden de la regla:

| Brazo | n | Costo por corrida | Tiempo |
|---|---:|---:|---:|
| Opus 5, esfuerzo por defecto | 2 | referencia | referencia |
| Opus 5, `--effort max` | 2 | +33 % | +91 % |
| Fable 5.1 | 2 | +59 % | **−18 %** |

Cara a cara, subir el esfuerzo contra saltar de modelo: **16 % más barato y 2.3 veces más lento.**
Ahí está la regla completa en una línea — y con n = 2, así que se lee como dirección, no como cifra.

**Fable 5.1, lectura contaminada** — para referencia, contra el mismo referente:

| Lectura | n | Costo | Tiempo |
|---|---:|---:|---:|
| solo los casos anteriores al cambio de kit | 2 | +59 % | **−18 %** |
| los 4 casos comparables (2 contaminados) | 4 | +44 % | **−35 %** |

Cada fila compara **los mismos casos en los dos brazos**: la de n = 2 restringe también el
referente Opus default a esos dos, no lo compara contra sus cuatro. Por lo mismo, el +32 % del
brazo de esfuerzo (n = 4) y el +59 % de la fila de n = 2 **no son comparables entre sí**: son
subconjuntos distintos.

Lo que sobrevive a la contaminación es **la dirección** —Fable 5.1 sale más caro por corrida y más
rápido, en las dos lecturas—, **no la magnitud**: entre −18 % y −35 % de tiempo, y entre +44 % y
+59 % de costo. Por eso el núcleo enuncia la regla por dirección y no por cifra, y este documento
es el que carga los números.

## Qué se concluye, y qué no

1. **El aviso del council queda cerrado hasta donde puede:** en este material **no se detectó que
   Opus 5 a `--effort max` se quede corto**. No es lo mismo que probar igualdad —una batería
   saturada no puede—, pero era justo lo que faltaba: no hay evidencia que justifique subir de
   modelo por calidad. Por eso `lector-fresco` sigue en Opus 5.
2. **La regla acierta por costo, con margen modesto:** en la única comparación limpia que enfrenta
   los dos escalones (n = 2, tabla de tres brazos), subir el esfuerzo sale **16 % más barato** que
   saltar de modelo. Acierta, no arrasa, y descansa en dos casos.
3. **La regla necesitaba una excepción, y ahora la lleva escrita:** Fable 5.1 salió más rápido en
   las dos lecturas. La regla razonaba solo en costo por token; donde manda la latencia —algo
   interactivo, o un paso que bloquea a alguien— el escalón "barato" es el lento. La magnitud del
   ahorro de tiempo no está firme, así que la excepción se enuncia como criterio, no como número.
4. **El único caso donde los brazos divergieron queda fuera del conteo, y eso hay que decirlo
   sin adornos.** De los 5 casos, los comparables son **4**: el quinto no pudo juzgarse en
   ninguno de los dos brazos de Opus y sí pasó con Fable 5.1. La causa inmediata es del arnés
   (el juez solo recibe el último mensaje del agente, y un entregable que se va a un archivo no
   le llega), pero **con las mismas instrucciones Fable 5.1 respondió dentro del mensaje y Opus
   5 no: eso es diferencia de comportamiento, no solo ruido de medición.** Excluirlo empuja el
   resultado hacia "no se detectó diferencia", que es justo la lectura que sostiene dejar
   `lector-fresco` en Opus 5 — así que la conclusión 1 se lee con esta salvedad encima. Cerrar
   el hueco pide re-juzgar ese caso leyendo el archivo producido; queda pendiente en el arnés.

## Límites de esta medición

- **No cubre síntesis ni juicio crítico.** Los 5 casos son entregables de negocio. Por eso el
  agente `sintetizador` se justifica en Fable 5.1 **por latencia** y no por calidad, y su ficha
  declara la condición que lo bajaría de escalón.
- **Un solo material y un solo juez.** Cuatro casos comparables son pocos para afirmar más que un
  orden de magnitud; los porcentajes se leen como "un tercio", "cerca de la mitad", no como
  precisión de dos decimales.
- **El brazo de Fable 5.1 está partido:** 2 de sus 4 casos comparables corrieron con otra versión
  del núcleo. De ahí que la lectura limpia con Fable sea de **n = 2** y la de n = 4 quede solo como
  referencia. Las dos apuntan en la misma dirección (más caro, más rápido), pero la magnitud varía
  bastante entre ellas (−18 % contra −35 % de tiempo). Cerrar el hueco cuesta re-correr los brazos
  1 y 3 bajo el mismo núcleo; no se hizo porque la dirección ya es consistente en las dos lecturas
  y la regla se enuncia por dirección.
