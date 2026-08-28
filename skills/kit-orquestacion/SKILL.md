---
name: kit-orquestacion
license: MIT
description: 'Estándar Kit Chema para repartir un trabajo entre varios agentes en paralelo — barridos amplios ("revisa los 24 proyectos", "todos los archivos de"), auditorías, migraciones, verificación de un entregable desde varios lentes, y material que no cabe en una ventana. Úsala ANTES de lanzar un workflow, un fan-out de subagentes o una corrida "ultracode", y también para decidir si NO conviene repartir. Frases gatillo "ultracode", "en paralelo", "reparte esto", "lanza varios agentes", "audita todo", "barre el repo", "revisa cada uno de", "compara estas 5 opciones", "es mucho material", "desde varios ángulos". Define la topología (quién lee y quién escribe), cuántos agentes, el contrato de cada uno y la verificación; el núcleo decide CUÁNDO delegar y con qué modelo. No sustituye a la skill del dominio: va junto con kit-research si es investigación con fuentes, y con kit-propuestas si se pidió council o evaluar una decisión — esas ponen el estándar del entregable, esta solo el reparto.'
---

# Orquestación multi-agente — estándar Kit Chema

Playbook para repartir un trabajo entre varios agentes. El núcleo ya dice cuándo
vale delegar y con qué modelo; aquí se decide la forma de la corrida. La regla que
sostiene todo lo demás: **paralelizar lecturas, nunca escrituras**. Varios agentes
buscando, midiendo y verificando se suman; varios escribiendo el mismo entregable
se estorban, porque cada uno toma decisiones implícitas que los otros no ven.

**Compone, no reemplaza.** La skill del dominio sigue mandando sobre el contenido
—qué estándar cumple el entregable, qué se cita, qué se verifica—; ésta solo sobre
el reparto. Un barrido de repos usa kit-codigo y ésta; una investigación amplia usa
kit-research y ésta.

## Bien hecho significa

- **Un solo escritor.** El fan-out solo lanza agentes que leen, miden, verifican o
  critican, y devuelven un resumen. El entregable lo redacta un hilo, después.
- **Cada agente sabe qué entregar.** Objetivo, formato de salida, límites y qué NO
  hacer. Un agente con instrucción ambigua no falla ruidosamente: entrega algo
  plausible que nadie pidió.
- **Hay una etapa de verificación explícita**, no una suposición de que salió bien.
- **El costo se declaró antes.** Repartir cuesta del orden de cuatro veces los
  tokens de resolverlo en un solo hilo con herramientas. (La cifra que se cita a
  menudo, ~15×, mide contra una conversación sin herramientas; un hilo agéntico ya
  gasta ~4× de esa base.) Se justifica cuando el trabajo no cabe en una ventana o
  son piezas de verdad independientes; no cuando solo se siente más rápido.

## Cuánto repartir

Escalera de topología, del trabajo más chico al más grande:

| El trabajo es… | Agentes | Forma |
|---|---|---|
| Pregunta puntual, o el material ya está en contexto | 0 | Hazlo en el hilo |
| Un entregable que hay que revisar | 1 | Un verificador con contexto limpio |
| Investigar un tema desde ángulos distintos | 2–4 | Un lector por ángulo, ciegos entre sí |
| Decisión cara o irreversible | 3–5 | Council (el protocolo lo define kit-propuestas) |
| Barrido que no cabe en una ventana (auditar N repos, N archivos, un corpus) | 5+ | Uno por pieza, encadenando etapas por pieza |

Arriba de 5 agentes, escribe **qué lee cada uno que los demás no**. Si dos briefs se
parecen, sobra uno. Y pasando una decena de piezas, agrupa varias por agente en vez
de sumar agentes: la concurrencia real está topada, y los de más solo hacen fila
pagando contexto completo.

Antes de repartir, considera la alternativa barata: **subir de modelo o de esfuerzo
en un solo hilo**. En cadenas donde cada paso depende del anterior sobre el mismo
material y todo cabe en contexto, un hilo con más esfuerzo gana; el fan-out ahí paga
el sobrecosto sin cobrar nada.

**Cuando el usuario pidió una corrida grande** (por ejemplo "ultracode", confirmado
por un aviso del sistema), el presupuesto ya lo fijó él: ahí esta skill decide la
**forma** del reparto —topología, contrato, verificación, confidencialidad— y la
escalera sirve para dimensionar, no para frenar el gasto.

## Antes de lanzar

Tres preguntas. Cubren de dónde vienen casi todas las fallas medidas de estos
sistemas — que no son del modelo, sino del reparto:

1. **¿Cada agente tiene objetivo inequívoco y formato de salida declarado?** Cuando
   el resultado cruza de una etapa a otra, va con estructura, no en prosa libre.
2. **¿Qué contexto tengo yo que el agente no tiene y le hará falta?** Arranca en
   blanco: lo que no le pases, lo inventa o lo re-deduce mal.
3. **¿Quién verifica?** Si nadie, la corrida entrega una conclusión sin respaldo.

## Cómo se verifica

- **Verificador con contexto limpio.** Quien revisa nunca hereda el contexto de quien
  produjo. Pedirle a un agente que revise su propio trabajo no corrige: ratifica.
- **Lentes distintos, no copias.** Si algo puede fallar de varias formas, dale a cada
  verificador un ángulo propio (cifras, fuentes, lógica, formato). Tres verificadores
  idénticos solo repiten el mismo punto ciego.
- **Verificación adversarial donde hay verdad comprobable** — código que corre,
  cifras recalculables, fuentes que se abren. Para juicio subjetivo, un lector fresco
  vale más que un panel: no hay nada que refutar objetivamente.
- **Verifica los hallazgos antes de heredarlos.** Que venga de un agente no lo hace
  verdad; un hallazgo que no resiste comprobación se descarta explicando por qué.

## Lo que no se hace

- **Rondas de debate entre agentes.** Suena a más rigor y no lo compra: la evidencia
  de que mejore el acierto es mixta, mientras que el costo de las réplicas es cierto
  (del doble al triple) y el conformismo está documentado — los agentes se alinean
  entre sí en vez de sostener su lectura. Cada evaluador opina por separado y la
  agregación se hace fuera, contando.
- **Volcar datos crudos al contexto.** Un agente que consulta una base, una carpeta
  o páginas web no devuelve el contenido: escribe un script que filtra y agrega
  fuera, y devuelve el resultado. Traer diez mil renglones para sacar un total
  degrada el acierto de toda la corrida, no solo el costo.
- **Escritura en paralelo sobre lo mismo.** Si de verdad hay que escribir en
  paralelo, se parte por archivos disjuntos con interfaces acordadas y cada agente
  trabaja en su propia copia aislada del repo; cuesta preparación y disco, así que
  es último recurso, no atajo.
- **Personajes decorativos.** Un rol sin una tarea distinta que hacer no aporta
  juicio; solo consume presupuesto y ensucia la síntesis.

## Disciplina de la corrida

- **Cadena por pieza, sin esperas.** Cuando cada pieza pasa por varias etapas
  (hallar → verificar), encadénalas por pieza: la pieza A puede ir en la etapa 3
  mientras la B sigue en la 1. Esperar a que todas terminen una etapa antes de
  empezar la siguiente desperdicia el tiempo de las rápidas. La espera solo se
  justifica cuando la etapa siguiente necesita todos los resultados juntos:
  deduplicar, comparar entre hallazgos, o abortar si el total es cero.
- **Una tanda, un mismo arranque.** Dentro de una misma etapa en paralelo, mismo
  modelo, mismo esfuerzo y mismas instrucciones base: así el arranque se reutiliza y
  la tanda sale mucho más barata. La escalera de modelos se aplica *entre* etapas, no
  dentro de una.
- **Permisos por rol.** Cada agente lleva solo las herramientas que su tarea pide;
  en una corrida se consigue apuntando a un subagente ya registrado con herramientas
  acotadas, no pidiéndoselo en el prompt.
- **El agente que toca material externo no toca material confidencial.** Quien lee
  internet o archivos ajenos no debe llevar acceso al vault, al correo ni a
  publicación: un contenido preparado puede llegar por ahí, y en una corrida en
  paralelo nadie ve el paso intermedio.
- **Presupuesto declarado.** Antes de una corrida grande, corre una rebanada chica y
  extrapola. Si la corrida se puede reanudar, reanúdala en vez de repetirla.

## Errores típicos

- **Repartir lo secuencial.** Si cada paso necesita el resultado del anterior sobre
  el mismo material, no se paraleliza: se le sube el esfuerzo. Distinto es tener N
  piezas independientes que pasan por las mismas etapas — eso sí se encadena por
  pieza.
- **Fan-out sin verificación.** Muchos hallazgos rápidos y ninguno comprobado es
  peor que pocos y firmes: la conclusión llega con apariencia de respaldo.
- **Cadena larga sin puertas.** Cinco etapas encadenadas al 95% de acierto cada una
  no dan 95%. Pon comprobaciones baratas entre etapas —como una etapa más de la
  cadena por pieza—, no solo al final.
- **Confiar en un revisor nunca medido.** Antes de creerle a un verificador, pásalo
  por casos con respuesta conocida y mide si acierta.
