---
name: kit-analisis-datos
description: Estándar Kit Chema para analizar o explorar datos — ventas, métricas, encuestas, archivos CSV/Excel, bases de datos, dashboards. Úsala antes de abrir los datos, al pedir "analiza estos datos", "qué dicen estas ventas", "explora este archivo", "hazme un dashboard o gráfica". Obliga a evaluar la calidad del dato antes de sacar conclusiones y a entregar hallazgos con evidencia, magnitud e implicación accionable.
---

# Análisis de datos — estándar Kit Chema

Playbook para analizar o explorar datos y presentar lo que dicen. La regla que
sostiene todo lo demás es entender el dato antes de analizarlo: una conclusión
sacada de datos que no revisaste primero no vale nada, por buena que se vea la
gráfica.

## Bien hecho significa

- Las conclusiones sobreviven a un "¿y cómo lo sabes?". Cada afirmación se puede
  rastrear hasta el dato que la sostiene; si alguien pregunta de dónde salió, hay
  respuesta. Una conclusión que no aguanta esa pregunta es una opinión disfrazada
  de análisis.
- Cada hallazgo es evidencia + magnitud + "y qué". La evidencia es el dato
  concreto; la magnitud es cuánto (número, porcentaje, no "mucho" ni "poco"); el
  "y qué" es la implicación accionable, qué debería hacer quien lo lee. Sin las
  tres partes no es un hallazgo, es un comentario.
- El hecho está separado de la interpretación. "Las ventas cayeron 18% en junio"
  es un hecho; "cayeron porque subió el precio" es una hipótesis. Se marcan como
  cosas distintas y no se mezclan en la misma frase.
- El análisis es reproducible. Otra persona (o tú en un mes) puede volver a
  correrlo sobre los mismos datos y llegar al mismo número. Nada de cálculos
  hechos a mano en una celda que nadie puede repetir.

## Proceso

Este es el orden. El primer paso es el que más se salta y el que decide si el
resto sirve.

1. Entender el dato antes de analizarlo. Antes de calcular nada, revisa qué
   tienes: el esquema (qué columnas hay y qué significan), el periodo que cubre,
   los huecos (valores vacíos, fechas faltantes), los duplicados y las unidades
   (pesos o dólares, con o sin IVA, diario o mensual). Reporta lo que encuentres:
   la calidad del dato es parte del entregable, no un paso escondido.
2. Preguntas que el análisis debe responder. Escribe las preguntas concretas
   antes de sumergirte en los números. Sin preguntas, "explorar" se vuelve pasear
   por gráficas sin saber qué buscas ni cuándo terminaste.
3. Análisis con scripts guardados. Haz los cálculos en un script que quede
   guardado, no en operaciones al vuelo irrepetibles. Si un número entró al
   informe, el código que lo produjo tiene que existir y poder re-ejecutarse.
4. Hallazgos rankeados por impacto. Ordena lo que encontraste de mayor a menor
   relevancia para quien decide. Lo que cambia una decisión va arriba; la
   curiosidad estadística sin consecuencia, al final o fuera.
5. Gráficas honestas. Ejes numéricos desde cero, salvo que haya una razón que
   declaras junto a la gráfica. Nada de recortar el periodo para que la tendencia
   se vea como quieres (cherry-picking): se muestra el rango completo y
   representativo. La gráfica sirve para entender, no para convencer con trucos.

## Checklist final

Antes de entregar, con los datos y el análisis delante:

- ¿Reporté la calidad del dato (huecos, duplicados, periodo, unidades)?
- ¿Cada hallazgo tiene su evidencia y su magnitud en números?
- ¿Separé el hecho de la hipótesis, marcados como cosas distintas?
- ¿Los scripts están guardados y se pueden re-ejecutar para llegar al mismo
  resultado?
- ¿Las gráficas van sin trucos visuales (ejes desde cero, periodo completo)?

## Errores típicos

- Analizar sin mirar huecos ni duplicados. Sacar promedios y tendencias de datos
  que tienen filas repetidas o meses faltantes: el número sale, pero está mal y
  no te enteras.
- Promedios que esconden la distribución. Reportar "el ticket promedio es $340"
  cuando la mitad compra $80 y unos pocos $2.000. El promedio solo no dice nada;
  mira también la mediana y la dispersión.
- Correlación vendida como causa. "Subieron las dos cosas a la vez, luego una
  causó la otra." Que dos series se muevan juntas no prueba que una explique la
  otra; dilo como correlación mientras no tengas más.
- Gráficas con ejes recortados. Empezar el eje en 90 en vez de 0 para que una
  diferencia pequeña parezca enorme. Es la forma más común de mentir con una
  gráfica siendo técnicamente cierto el dato.
