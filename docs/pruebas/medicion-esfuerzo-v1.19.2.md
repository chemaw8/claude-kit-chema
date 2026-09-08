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
- **Lo que se compara:** la batería es pasa/no pasa y estaba saturada, así que el veredicto por sí
  solo no ordena dos configuraciones. Lo que las ordena es **costo y latencia a calidad igual**,
  medidos por corrida (`--output-format json`).

## Resultado

En los **4 casos que los tres brazos pudieron entregar**, los tres pasan los 4: la calidad medible
es idéntica. Relativo al primer brazo:

| Brazo | Costo por corrida | Tiempo |
|---|---:|---:|
| Opus 5, esfuerzo por defecto | referencia | referencia |
| Opus 5, `--effort max` | **+32 %** | **+46 %** |
| Fable 5.1 | **+44 %** | **−35 %** |

## Qué se concluye, y qué no

1. **El aviso del council queda cerrado:** Opus 5 a `--effort max` **no** se queda corto en este
   material. Por eso `lector-fresco` sigue en Opus 5.
2. **La regla acierta por costo, con margen estrecho:** subir el esfuerzo cuesta menos que saltar
   de modelo (+32 % contra +44 %), pero la diferencia no es holgada.
3. **La regla necesitaba una excepción, y ahora la lleva escrita:** Fable 5.1 resultó **un tercio
   más rápido**. La regla razonaba solo en costo por token; donde manda la latencia —algo
   interactivo, o un paso que bloquea a alguien— el escalón "barato" es el lento.
4. **Un caso quedó sin veredicto en los dos brazos de Opus** y sí pasó con Fable 5.1. No cuenta
   como diferencia de calidad: la causa es una limitación del arnés de medición (el juez solo
   recibe el último mensaje del agente, y un entregable que se va a un archivo no le llega).
   Queda anotado como defecto del arnés, no del modelo.

## Límites de esta medición

- **No cubre síntesis ni juicio crítico.** Los 5 casos son entregables de negocio. Por eso el
  agente `sintetizador` se justifica en Fable 5.1 **por latencia** y no por calidad, y su ficha
  declara la condición que lo bajaría de escalón.
- **Un solo material y un solo juez.** Cuatro casos comparables son pocos para afirmar más que un
  orden de magnitud; los porcentajes se leen como "un tercio", "cerca de la mitad", no como
  precisión de dos decimales.
- **Fable 5.1 se midió con una versión del núcleo distinta** en parte de su brazo (la instalada
  cambió a mitad de la corrida). Sus cifras sirven como referencia, no como brazo limpio.
