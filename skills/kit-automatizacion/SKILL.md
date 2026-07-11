---
name: kit-automatizacion
license: MIT
description: Estándar Kit Chema para automatizar procesos — tareas recurrentes, integraciones, cron jobs, flujos que corren solos, bots, scripts programados. Úsala al pedir "automatiza", "que se haga solo", "cada semana genera", "conecta X con Y", "un proceso que corra". Obliga a definir disparador, entradas y salidas antes de construir, manejar errores explícitamente y probar en real antes de entregar.
---

# Automatización — estándar Kit Chema

Playbook para automatizar procesos: tareas recurrentes, integraciones, cron
jobs y flujos que corren solos. La regla que sostiene todo lo demás es definir
disparador, entrada y salida antes de construir. Automatizar un proceso que aún
no tienes claro a mano no lo arregla: lo multiplica a velocidad de máquina.

## Bien hecho significa

- Se sabe exactamente cuándo corre, con qué entra y qué produce. El disparador
  (horario, evento o ejecución manual), las entradas que consume y las salidas
  que genera están definidos por escrito antes de construir. Una automatización
  cuyo cuándo, con qué y para qué no puedes nombrar es una caja negra suelta.
- Cuando falla, alguien se entera. Un error detiene el proceso o avisa a un
  humano; no se traga en silencio para que "siga corriendo". Una falla que nadie
  ve es peor que una visible: produce resultados mal durante días sin que nadie
  lo note.
- Correrla dos veces no duplica efectos (idempotencia). Re-ejecutarla con la
  misma entrada no manda el correo dos veces, no cobra dos veces ni inserta filas
  repetidas. Si no es idempotente, cualquier reintento o re-lanzamiento es un
  riesgo.
- Existe una forma documentada de apagarla. Está escrito cómo detenerla y dónde
  se controla, para que quien no la construyó pueda pararla el día que haga falta.

## Proceso

Este es el orden; el primer paso es el que más se salta y el que decide si el
resto sirve.

1. Definir disparador, entrada y salida. Antes de construir, escribe qué la
   dispara, qué datos consume, qué produce y qué pasa si la entrada viene mal o
   vacía. Si no puedes responder esto, todavía no hay nada que automatizar.
2. Diseñar el manejo de errores. Decide antes de programar qué ocurre cuando algo
   falla: cuántos reintentos, a quién se avisa y por qué medio, y dónde queda el
   registro de lo que pasó. El manejo de errores se diseña, no se improvisa
   cuando ya reventó. Y como el manejo de errores dentro del proceso no detecta
   el proceso que nunca corrió, define además una señal externa —un heartbeat o
   una marca de "última corrida exitosa" que alguien revise— que avise si la
   ejecución no ocurrió cuando tocaba.
3. Construir. Aquí aplica kit-codigo: entender lo que ya hay, plan corto, TDD
   donde haya lógica y cero residuos. La automatización es código y se sostiene
   con esas mismas reglas.
4. Probar en real al menos una vez. Ejecútala con datos verdaderos y mira la
   salida y el comportamiento ante un error provocado. Si produce efectos
   visibles hacia afuera (correo, mensaje, cobro, publicación), la prueba usa
   destinatarios o datos seguros, o pide confirmación explícita antes de correr:
   la prueba no debe disparar el efecto real. Que el código parezca correcto no
   prueba que el flujo completo funcione; probarlo una vez de verdad, sí.
5. Documentar. Deja escrito cómo correrla, cómo saber que funcionó, cómo apagarla
   y quién la mantiene. Sin esto queda una automatización que solo su autor
   entiende y nadie más puede operar.

## Checklist final

Antes de entregar, con la automatización corriendo delante:

- ¿Está probada en real, ejecutada con datos verdaderos al menos una vez?
- ¿Falla con aviso a un humano, no en silencio?
- ¿Es idempotente: correrla dos veces no duplica efectos?
- ¿Está documentada (cómo correrla, cómo verificarla, cómo apagarla)?
- ¿El dueño humano que la mantiene está definido?
- Si lleva tiempo corriendo, ¿alguien verifica periódicamente que sigue
  funcionando, sigue siendo necesaria y no quedó huérfana (dueño vigente)?

## Errores típicos

- Automatizar un proceso que aún no está claro a mano. Si el flujo no funciona
  hecho manualmente, automatizarlo solo reproduce el problema más rápido y más
  veces.
- Tragarse los errores con un try/except vacío. Atrapar la excepción y seguir
  como si nada convierte la falla en silencio: el proceso "termina bien" mientras
  produce basura.
- Efectos duplicados al re-ejecutar. Un reintento o un doble disparo que manda el
  correo, cobra o inserta dos veces porque el proceso no se diseñó idempotente.
- Automatización huérfana. Un flujo que corre solo desde hace meses, que nadie
  documentó y que nadie sabe cómo apagar cuando empieza a estorbar.
