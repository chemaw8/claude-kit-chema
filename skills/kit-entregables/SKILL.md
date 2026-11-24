---
name: kit-entregables
license: MIT
description: 'Estándar Kit Chema para la ESTRUCTURA de un entregable según su objetivo, tomada de autores reconocidos, y para quitarle el relleno típico de IA («slop»): informe o memo de decisión, estatus a dirección, one-pager, brief, propuesta comercial, pitch que replantea el problema, discurso, exposición y entregable académico. PILOTO: úsala cuando el encargo nombre el FORMATO one-pager, brief (también de decisión o para un comité), discurso, exposición en vivo o entregable académico, o pida la estructura de un informe para dirección. Cuándo no usarla: un mensaje, correo o propuesta para que aprueben, autoricen o compren algo (kit-propuestas manda: opciones antes de la recomendación y reversibilidad); estatus que solo informa, correo o minuta (kit-redaccion manda); deck con identidad visual (kit-presentaciones). Si la carga junto con otra skill, la del dominio manda. No decide el diseño visual.'
---

# Entregables: estructura correcta y sin relleno

> **Piloto (council 2026-11-23, PR #114):** fuera de la tabla del núcleo hasta medirla con un A/B prerregistrado contra
> el kit vigente. La skill del dominio manda; esta solo aporta el esqueleto.

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

Las secciones de cada una, en orden y con su guía: `python3 "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude}/skills/kit-entregables/scripts/firma.py" --plantilla <estructura>`.

**Dónde va la conclusión.** Los autores se contradicen y la contradicción se resuelve por modo:
- **Lectura** (alguien lo lee sin ti): conclusión primero, en el título y en el primer párrafo (Minto, BLUF).
- **En vivo** (lo presentas): tensión; la solución va al final (Duarte, Monroe, Challenger). Si es para dirección, una
  línea con la conclusión arriba y luego la secuencia.

## Las fallas que más se repiten (A/B del 2026-11-23 y del 2026-11-24, con y sin esta skill)

1. **El arranque no trae el porqué.** Las dos primeras oraciones (después del saludo, si es un discurso) dicen la
   decisión **y la cifra que la sostiene**: «Recomiendo abrir WhatsApp: la recuperación subió de 18.4 % a 24.1 %». La
   recomendación sola, sin su número, no basta; el número aparte en una tabla más abajo, tampoco. Fue la falla más
   frecuente aun con la skill puesta: casi siempre la cifra decisiva estaba en la **tercera** oración, o la que abría
   era otra cifra (la fecha, el contexto). Elige la cifra que haría cambiar de opinión al lector y ponla en la primera.
2. **Se cuela el proceso.** El entregable empieza con el contenido. Nada de «abajo va el guion», «recalculé con un
   script», notas del verificador, estados de trabajo ni metacomentarios: eso va en tu respuesta, fuera del entregable.
3. **Se agregan datos que el insumo no trae** (fases, fechas «por ejemplo», rangos de costo, distancias, nombres, la
   moneda, una normativa, «no habrá despidos», «es reversible», la causa de un dato, lo que la empresa «ya vende»).
   Todo dato sale del insumo. Si hace falta una estimación, va en «Supuestos» con su cálculo y marcada como estimación.
   Tampoco se exagera lo que sí está: +22 % no es «duplicar»; un título con verbo fuerte se comprueba contra la cifra.
4. **El formato se desborda.** Un one-pager cabe en una página (≈500 palabras contando tablas) y no lleva secciones
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
| Negación y corrección | «Eso no fue suerte. Fue cada ruta.» · «No les pido un aplauso. Les pido un compromiso.» | Di solo lo que sí es: «Lo lograron 120 rutas.» |
| Eslogan «X, no Y» | «Traigo fechas, no promesas.» | «Traigo dos fechas: febrero y abril de 2027.» |
| Fragmento enfático | «Dos.» · «De verdad.» · «Así de simple.» | Intégralo en la oración anterior o bórralo. |
| Anáfora de tres | «Piensen en… Piensen en… Y piensen en…» | Una oración con los tres datos, o una lista. |
| Tríada de adjetivos o cierre épico | «rápido, simple y seguro» · «Vamos por los 500,000.» | El dato que lo prueba; cierra con la petición. |
| Palabra de folleto | robusto, integral, potenciar, ecosistema, sinergia, transformador, clave | El verbo o la cifra concretos. |

Una figura retórica suelta puede servir en vivo; el problema es la densidad: si hay más de una por minuto de discurso, ya
es plantilla. El revisor `muletillas.sh` marca las cuatro primeras (F13, F14, D6, D7) y el vocabulario (D1).

## Reglas comunes

Una sección que no aplica se escribe «No aplica: <razón>»; nunca se inventa contenido para llenarla. Solo la sección
que abre la estructura y el orden bloquean; las demás faltantes solo avisan. El script comprueba las secciones y su orden, el título, la conclusión primero (si la estructura abre con ella), el
origen de las cifras (si la estructura lo lleva), que haya una fecha absoluta (aviso) y el relleno (aviso a partir de
varias frases). En estructuras para presentar en vivo (propuesta-challenger, discurso, exposición) revisa secciones, orden, título,
largo, huecos de plantilla sin llenar y relleno. Que el cierre tenga responsable y que no haya relleno suelto se revisa además a ojo.

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
3. Guarda el texto en un archivo y verifícalo antes de entregar:
   `python3 "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude}/skills/kit-entregables/scripts/firma.py" --estructura estatus entregable.md`
   Si algo sale con gravedad «alta», corrígelo y vuelve a verificar. Además de secciones y orden, marca `cifra_arranque`
   (las dos primeras oraciones sin cifra), `hueco_sin_llenar`, `proceso_colado` (notas para ti dentro del entregable)
   y avisa `cierre_sin_fecha`. Luego corre `muletillas.sh revisar` y quita toda señal F. **No entregues sin correr los
   dos**: en el A/B, la mitad de las corridas no los corrió y ahí se concentraron las fallas. Las láminas se verifican por JSON en stdin:
   `{"formato":"presentacion","laminas":[{"titulo":…,"cuerpo":…}]}` (ahí aplica el tope de 60 palabras por lámina).

## Checklist antes de entregar

- [ ] Elegí UNA estructura del catálogo por el objetivo y la dije.
- [ ] El verificador no marca nada «alta» y `muletillas.sh` no marca ninguna señal F.
- [ ] La cifra decisiva está en la primera o segunda oración; el cierre tiene rol y fecha (propuesta, si hace falta).
- [ ] Ningún dato, causa, promesa ni moneda que el insumo no traiga; ningún verbo que exagere la cifra.
- [ ] Revisé a ojo que no quede relleno (el script avisa solo cuando ya son varias frases); ningún caso o cifra inventados.

## Límites honestos

El verificador revisa forma y orden; el fondo lo cuidan las otras skills. Un título de tema largo (6 palabras o más)
puede pasar. StoryBrand, Pitch Anything y las reglas finas de TED no entran hasta tener fuente primaria.
Fuentes: `references/fuentes.md`.
