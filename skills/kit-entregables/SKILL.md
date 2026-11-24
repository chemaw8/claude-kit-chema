---
name: kit-entregables
license: MIT
description: 'Estándar Kit Chema para la ESTRUCTURA de un entregable según su objetivo, tomada de autores reconocidos, y para quitarle el relleno típico de IA («slop»): informe o memo de decisión, estatus a dirección, one-pager, brief, postmortem, PR/FAQ, propuesta comercial, pitch que replantea el problema, discurso, exposición y entregable académico. PILOTO: úsala cuando el encargo nombre el FORMATO one-pager, brief (también de decisión o para un comité), postmortem, PR/FAQ, discurso, exposición en vivo, estatus o informe para dirección, o entregable académico; si el encargo además pide aprobar algo o lleva números, cárgala JUNTO con kit-propuestas o kit-finanzas, no en su lugar: esta pone el esqueleto y el revisor de relleno, la del dominio manda en el fondo (opciones, reversibilidad, cifras). Cuándo no usarla: un correo, minuta o mensaje sin uno de esos formatos (kit-redaccion o kit-propuestas solas); deck con identidad visual (kit-presentaciones). No decide el diseño visual.'
---

# Entregables: estructura correcta y sin relleno

<!-- pih-verificadores: scripts/firma.py@entregable -->

> **Piloto (council 2026-11-23, PR #114):** fuera de la tabla del núcleo. El A/B prerregistrado v2 (2026-11-24) cumplió su regla (+10
> criterios de 135); entra a la tabla solo si lo aprueba el dueño. La skill del dominio manda; esta solo aporta el esqueleto.

La forma de un entregable no es decoración: decide si la audiencia entiende y actúa. Esta skill hace dos cosas. Elige la
estructura que corresponde al objetivo (no la misma para todo) y quita el relleno que delata un texto hecho sin pensar.
Las dos se comprueban con un script, no a ojo.

## Regla central: una estructura por objetivo

| Estructura | Úsala para | Modo | Autor |
|---|---|---|---|
| `informe-decision` | informe o memo para que alguien decida | lectura | Minto (pirámide, SCQ); BLUF |
| `estatus` | avance o estatus a dirección | lectura | BLUF; semáforo (práctica) |
| `one-pager` | presentar una idea en una página | lectura | Minto; lenguaje llano |
| `brief` | brief de política o decisión (≤1,500 palabras) | lectura | IDRC; r4d |
| `propuesta-challenger` | vender replanteando el problema del cliente | en vivo | Dixon y Adamson (Challenger) |
| `propuesta-b2b` | propuesta comercial por escrito | lectura | síntesis de SPIN y Challenger |
| `discurso` | mover a la acción en vivo | en vivo | Monroe |
| `exposicion` | contrastar el hoy con lo posible | en vivo | Duarte (Resonate) |
| `academico` | paper o reporte académico | lectura | IMRaD |
| `postmortem` | incidente o proyecto que salió mal, sin culpables | lectura | Google SRE (cap. 15, apéndice D) |
| `pr-faq` | proponer un producto o iniciativa antes de construirla | lectura | Amazon, *Working Backwards* |

Las secciones de cada una, en orden y con su guía: `python3 "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude}/skills/kit-entregables/scripts/firma.py" --plantilla <estructura>`.

**Dónde va la conclusión.** Los autores se contradicen y la contradicción se resuelve por modo:
- **Lectura** (alguien lo lee sin ti): conclusión primero, en el título y en el primer párrafo (Minto, BLUF).
- **En vivo** (lo presentas): tensión; la solución se desarrolla al final (Duarte, Monroe, Challenger). Pero la
  petición se anuncia arriba: después del saludo, la primera oración da el logro o el problema con su cifra y la segunda
  dice qué vas a pedir («Hoy les vengo a pedir dos cosas: …»). El público que no oye la petición al principio no
  escucha el resto como argumento. Al final se repite con lo que hay que hacer y cómo. En un discurso no se dice al
  público una fecha que el insumo no trae (no se puede marcar «propuesta» en voz alta): se pide la acción y se dice
  cómo hacerla; la fecha que falta va en tu respuesta, fuera del discurso. Tampoco se inventan detalles para que suene
  concreto: ni plazos («la primera semana de enero»), ni cómo funciona un beneficio más allá de lo que dice el
  encargo, ni procesos, promesas o anécdotas. Lo emotivo sale de las cifras del encargo dichas a escala humana, no de
  datos nuevos.

## Las fallas que más se repiten (A/B del 2026-11-23 y del 2026-11-24, con y sin esta skill)

1. **El arranque no trae el porqué.** Las dos primeras oraciones (después del saludo, si es un discurso) dicen la
   decisión **y la cifra que la sostiene**: «Recomiendo cambiar de paquetería: el costo por envío baja de $41 a $33». La
   recomendación sola, sin su número, no basta; el número aparte en una tabla más abajo, tampoco. Fue la falla más
   frecuente aun con la skill puesta: casi siempre la cifra decisiva estaba en la **tercera** oración, o la que abría
   era otra cifra (la fecha, el contexto). La cifra que abre es la **del insumo** que motiva la decisión, tal como viene
   (la demanda contra la capacidad, el antes y el después del piloto), no un cálculo tuyo: «Recomiendo X: pedimos 2,300 y
   cabemos 2,000»; tu cálculo (costo comparado, punto de equilibrio) va después. En un estatus, las dos primeras oraciones
   dicen cómo va **y** qué hay que decidir; la decisión en la tercera oración ya no cuenta.
2. **Se cuela el proceso.** El entregable empieza con el contenido. Nada de «abajo va el guion», «recalculé con un
   script», notas del verificador, estados de trabajo ni metacomentarios. Si tu respuesta ES el entregable (no lo guardas
   en un archivo para el usuario), no le antepongas nada: ni «el one-pager ya está escrito» ni advertencias para quien
   lo pidió, ni «Notas para ti» al final. Las advertencias que importan al lector van dentro («Lo que no se puede
   concluir», riesgos); las que solo importan a quien lo pidió no van. Un preámbulo también cuenta para el largo.
3. **Se agregan datos que el insumo no trae** (una fuente que no nombra, como «según el reporte del proyecto»; fases, fechas «por ejemplo», rangos de costo, distancias, nombres, la
   moneda, una normativa, «no habrá despidos», «es reversible», la causa de un dato, lo que la empresa «ya vende»).
   Todo dato sale del insumo. Si hace falta una estimación, va en «Supuestos» con su cálculo y marcada como estimación.
   Tampoco se exagera lo que sí está: +22 % no es «duplicar»; un título con verbo fuerte se comprueba contra la cifra.
4. **El formato se desborda.** Un one-pager cabe en una página (apunta a 400 palabras; el verificador corta en 450,
   contando tablas) y no lleva secciones
   extra; si sobra material, se queda fuera o va como anexo aparte, no dentro.
5. **El cierre no tiene dueño.** La acción final nombra un responsable (un rol o área) y una fecha absoluta; «el comité
   decide», «en unas semanas», «fecha por definir» o un `[AAAA-MM-DD]` sin llenar no son cierre. Si el insumo no trae
   fecha, **propón una** y márcala «(propuesta)»: eso no es inventar un dato, es la petición; dejar el hueco sí reprueba.
   El cierre también dice qué **no** se puede concluir con estos datos.

## Relleno de construcción (lo que suena a IA aunque no tenga palabras raras)

El vocabulario típico casi desapareció con la skill; lo que quedó fue la forma de las oraciones, sobre todo en
discursos y exposiciones. Estas construcciones se quitan aunque suenen «retóricas»:

| Construcción | Ejemplo | En su lugar |
|---|---|---|
| Negación y corrección | «Eso no fue suerte. Fue trabajo.» · «No les pido un aplauso. Les pido un compromiso.» | Di solo lo que sí es: «Lo lograron 40 sucursales.» |
| Eslogan «X, no Y» | «Traigo fechas, no promesas.» | «Traigo dos fechas: 3 de marzo y 2 de junio.» |
| Fragmento enfático | «Dos.» · «De verdad.» · «Así de simple.» | Intégralo en la oración anterior o bórralo. |
| Anáfora de tres | «Piensen en… Piensen en… Y piensen en…» | Una oración con los tres datos, o una lista. |
| Tríada de adjetivos o cierre épico | «rápido, simple y seguro» · «¡Vamos por la meta!» | El dato que lo prueba; cierra con la petición. |
| Palabra de folleto | robusto, potenciar, sinergia, transformador, holístico, de manera integral | El verbo o la cifra concretos. |
| Negritas en todo | **Etiqueta:** en cada viñeta; tres o cuatro negritas por párrafo | Una negrita por sección como máximo, para la cifra que no se debe perder. |
| Flecha en la prosa | «de 5 días → 2 días» | «bajó de 5 a 2 días». En una tabla o diagrama sí va. |

Una figura retórica suelta puede servir en vivo; el problema es la densidad: si hay más de una por minuto de discurso, ya
es plantilla. El revisor `muletillas.sh` marca las cuatro primeras (F13, F14, D6, D7), el vocabulario (D1), las
negritas de más (D8) y las flechas en la prosa (D9). En el A/B del 2026-11-24, el vocabulario casi no apareció: lo que
delataba los textos era la forma (negritas a 15 por cada 1,000 palabras de mediana, viñetas con etiqueta en negritas).

## Reglas comunes

Una sección que no aplica se escribe «No aplica: <razón>»; nunca se inventa contenido para llenarla. Solo la sección
que abre la estructura y el orden bloquean; las demás faltantes solo avisan. El script comprueba las secciones y su orden, el título, la conclusión primero (si la estructura abre con ella), el
origen de las cifras (si la estructura lo lleva), que haya una fecha absoluta (aviso) y el relleno (una señal fuerte bloquea; la densidad avisa
a partir de su umbral). En estructuras para presentar en vivo (propuesta-challenger, discurso, exposición) revisa secciones, orden, título,
largo, huecos de plantilla sin llenar y relleno. En todas: cifra en las dos primeras oraciones, huecos entre corchetes
o «por definir», notas de proceso dentro del entregable (alta) y fecha del cierre (aviso; no en discurso ni académico). Que el cierre tenga responsable y que no haya relleno suelto se revisa además a ojo.

1. El título es la conclusión, no el tema: «Cerrar la tienda X ahorra $1.2 M al año», no «Análisis de tiendas».
2. Una idea por lámina proyectada (≤60 palabras); lo denso va a un documento de lectura (≤ ~6 páginas, anexos aparte).
3. Toda cifra con su origen en una sección o lámina final; un caso concreto sale del insumo, no se inventa.
4. Sección de lo que **no** se puede concluir y de supuestos con su alternativa cuando hay elecciones.
5. Cierre con acción, responsable y fecha absoluta.
6. Sin relleno: revísalo con `bash "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude}/scripts/muletillas.sh" revisar <archivo>`, el
   revisor del kit (el mismo que usa kit-redaccion). Cambiar la palabra no basta: se agrega algo concreto (cifra, nombre,
   fecha) o se borra la frase.

**Emoción sin relleno** (Heath, Knaflic, Duarte): una idea con postura y lo que está en juego; un caso concreto del
insumo; cifras grandes traducidas a escala humana y recalculables; contraste con la misma métrica en los dos estados.
Una persona inventada o un «Imagina un mundo donde…» es el mismo relleno con otro disfraz.

## Proceso

1. Elige la estructura por el objetivo del encargo. Si duda entre dos, la de lectura si alguien lo leerá sin ti.
2. Escribe con la plantilla: secciones en ese orden, con la guía de cada una.
3. Verifícalo antes de entregar pasándole el texto por stdin (no hace falta escribir un archivo, que puede pedir permiso):
   `python3 "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude}/skills/kit-entregables/scripts/firma.py" --estructura estatus - <<'EOF'`
   seguido del texto y `EOF`. También acepta un archivo en lugar de `-`. **Pega el encargo después del texto**, en una
   línea `=== INSUMO ===` y luego el encargo tal como llegó: así marca las fechas que el encargo no trae (alta en
   discurso y exposición; aviso en lo demás si no van marcadas «propuesta») y, en vivo, avisa de las cifras que no
   salen tal cual.
   Si algo sale con gravedad «alta», corrígelo y vuelve a verificar. Además de secciones y orden, marca `cifra_arranque`
   (las dos primeras oraciones sin cifra), `hueco_sin_llenar`, `proceso_colado` (notas para ti dentro del entregable)
   y avisa `cierre_sin_fecha`. **Además corre el revisor de relleno** (`muletillas.sh`) y devuelve sus señales: las
   fuertes como `relleno_F…` (alta) y las de densidad como aviso. Un solo comando revisa todo; no entregues sin correrlo. Si avisa `relleno_sin_revisar`, el revisor no
   corrió: revisa el relleno a ojo con la tabla de arriba.
   Corrige el texto, nunca el dato: si el verificador pide algo que el insumo no trae, no lo inventes ni quites una
   decisión real para que pase; déjalo y dilo en tu respuesta. Las láminas se verifican por JSON en stdin:
   `{"formato":"presentacion","laminas":[{"titulo":…,"cuerpo":…}]}` (ahí aplica el tope de 60 palabras por lámina).

## Checklist antes de entregar

- [ ] Elegí UNA estructura del catálogo por el objetivo y la dije.
- [ ] El verificador (que incluye `muletillas.sh`) no marca nada «alta».
- [ ] En un estatus, la decisión pendiente está en las dos primeras oraciones; en vivo, la petición se anuncia en la segunda.
- [ ] La cifra decisiva está en la primera o segunda oración; el cierre tiene rol y fecha (propuesta, si hace falta; en un discurso, solo la fecha que trae el encargo).
- [ ] Ningún dato, causa, promesa ni moneda que el insumo no traiga; ningún verbo que exagere la cifra.
- [ ] Revisé a ojo que no quede relleno (una señal fuerte de `muletillas.sh` ya bloquea; las de densidad solo avisan); ningún caso o cifra inventados.

## Límites honestos

El verificador revisa forma y orden; el fondo lo cuidan las otras skills. Un título de tema largo (6 palabras o más)
puede pasar. StoryBrand, Pitch Anything y las reglas finas de TED no entran hasta tener fuente primaria.
Fuentes: `references/fuentes.md`.
