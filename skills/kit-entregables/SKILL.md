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

## Las cinco fallas que más se repiten (A/B del 2026-11-23, con y sin esta skill)

1. **El arranque no trae el porqué.** Las dos primeras oraciones (después del saludo, si es un discurso) dicen la
   decisión **y la cifra que la sostiene**: «Recomiendo abrir WhatsApp: la recuperación subió de 18.4 % a 24.1 %». La
   recomendación sola, sin su número, no basta; el número aparte en una tabla más abajo, tampoco.
2. **Se cuela el proceso.** El entregable empieza con el contenido. Nada de «abajo va el guion», «recalculé con un
   script», notas del verificador, estados de trabajo ni metacomentarios: eso va en tu respuesta, fuera del entregable.
3. **Se agregan datos que el insumo no trae** (fases, fechas «por ejemplo», rangos de costo, distancias, nombres). Todo
   dato sale del insumo. Si hace falta una estimación, va en «Supuestos» con su cálculo y marcada como estimación.
4. **El formato se desborda.** Un one-pager cabe en una página (≈500 palabras contando tablas) y no lleva secciones
   extra; si sobra material, se queda fuera o va como anexo aparte, no dentro.
5. **El cierre no tiene dueño.** La acción final nombra un responsable (un rol o área) y una fecha absoluta; «el comité
   decide» o «en unas semanas» no son cierre.

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
   Si algo sale con gravedad «alta», corrígelo y vuelve a verificar. Las láminas se verifican por JSON en stdin:
   `{"formato":"presentacion","laminas":[{"titulo":…,"cuerpo":…}]}` (ahí aplica el tope de 60 palabras por lámina).

## Checklist antes de entregar

- [ ] Elegí UNA estructura del catálogo por el objetivo y la dije.
- [ ] El verificador no marca nada «alta».
- [ ] Revisé a ojo que no quede relleno (el script avisa solo cuando ya son varias frases); ningún caso o cifra inventados.

## Límites honestos

El verificador revisa forma y orden; el fondo lo cuidan las otras skills. Un título de tema largo (6 palabras o más)
puede pasar. StoryBrand, Pitch Anything y las reglas finas de TED no entran hasta tener fuente primaria.
Fuentes: `references/fuentes.md`.
