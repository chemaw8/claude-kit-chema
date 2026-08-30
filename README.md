# Kit Chema

Kit Chema es un paquete distribuible de instrucciones para Claude que produce
respuestas consistentes, específicas y verificables para cualquier persona de
Innovattia, sin depender de la configuración personal de nadie.

## Qué es

El kit ataca cinco dolores concretos al trabajar con Claude: respuestas
genéricas que ignoran el contexto de la empresa, supuestos que Claude asume en
vez de consultar, inconsistencia entre sesiones (cada conversación repite
errores ya corregidos), complacencia ("yes sir" ante propuestas débiles) y
contaminación del código generado por IA (duplicados, residuos, estilos
mezclados). Además de las instrucciones para Claude, incluye una guía para que
la persona que pide aprenda a pedir mejor (`COMO-PEDIR.md`).

La arquitectura tiene tres piezas: un núcleo corto que carga siempre con lo
universal, skills de dominio que cargan solo cuando la tarea las necesita, y
hooks que convierten en mecanismo determinista las reglas que no admiten
excepción.

## Qué hace bien — con la medición, no con la promesa

Lo que distingue a este kit de una colección de instrucciones bien redactadas es
que **cada afirmación de abajo está medida**, y las mediciones se vuelven a correr
cuando algo cambia.

**1. Las skills se disparan cuando deben, y bajo competencia real.**
El banco de disparo son 27 peticiones escritas como las diría un colega no
técnico, sin nombrar la skill. Juzgadas por un agente de contexto fresco que solo
ve los pares nombre+descripción: **27/27, incluidas las 7 fronteras** entre
dominios vecinos (correo↔propuesta, informe↔deck, código↔automatización). Y no en
laboratorio: con las **70 skills** que compiten de verdad en la máquina, no solo
las del kit. En uso real, las skills del kit son el **51% de todas las
invocaciones** (119 en 60 días).

**2. El que verifica el trabajo está verificado.**
Un juez que nadie midió produce un "listo" falso con sello de calidad. El de este
kit se mide contra entregables cuyo veredicto ya se conoce: **28/28, cero falsos
positivos** — incluidas 12 trampas escritas por agentes adversarios con el encargo
explícito de colar trabajo malo (memorias de cálculo fiscal inventadas,
"recomendaciones condicionadas" con condiciones huecas, bandas estadísticas que
cumplen la letra del criterio y fallan el fondo).

**3. El council no es teatro.**
Un panel que siempre encuentra algo no es riguroso, es decorativo. Éste corre con
evaluadores independientes y ciegos entre sí, con un mandato que declara "sin
hallazgos relevantes" como respuesta válida. Evidencia de que muerde: **rechazó
por unanimidad una skill que el propio autor propuso** (v1.12) y reubicó su valor
en el núcleo; y en v1.14 obligó a corregir una cifra que sesgaba una decisión.

**4. El estado del trabajo no se pierde entre sesiones.**
`CONTINUAR.md` cumple un contrato mínimo (dónde vamos, siguiente paso ejecutable,
cómo retomar, bloqueadores) con una **ancla de git** que delata cuando el estado
escrito ya no describe la realidad. La rotación del detalle viejo a la bitácora
**verifica línea por línea que nada se pierde** y aborta sin tocar nada si algo se
perdería.

**5. Sabe cuándo NO hacer algo.**
`DECISIONES.md` registra lo descartado y por qué. Cinco propuestas razonables de
mejora se midieron y se descartaron con datos, en vez de acumularse: el kit crece
solo cuando la evidencia lo pide.

## Dos formas de instalar

Hay dos vías y ambas funcionan; elige una:

- **(A) Como plugin de Claude Code** — la más cómoda si usas Claude Code. Trae
  las skills y los dos hooks; el núcleo se añade en un paso corto aparte.
- **(B) Con `git clone` + `./instalar.sh`** — instala todo el kit de una vez
  (núcleo, skills, plantillas de contexto y el hook de contexto por defecto; el
  hook anti-secretos es opcional). Es la vía de siempre y sigue viva.

## (A) Instalación como plugin de Claude Code

Desde v1.2 el kit se distribuye también como plugin. El plugin empaqueta las
9 skills de dominio y los dos hooks (contexto y anti-secretos). Dentro de Claude Code:

```
/plugin marketplace add chemaw8/claude-kit-chema
/plugin install kit-chema@kit-chema
```

Con el plugin instalado, las skills se invocan con namespace —por ejemplo
`/kit-chema:kit-codigo` en vez de `kit-codigo`— pero el auto-disparo por
descripción sigue igual: describes la tarea y Claude elige la skill sola.

El plugin **no** trae el núcleo. Un `CLAUDE.md` en la raíz de un plugin no se
carga como contexto (doc oficial de Claude Code: *"A CLAUDE.md file at the
plugin root is not loaded as project context"*). Por eso el núcleo se instala
aparte, en `~/.claude/CLAUDE.md`, con cualquiera de estas dos opciones:

- Corre `./instalar.sh` desde un clon del repo: instala el núcleo entre
  marcadores sin pisar tu `CLAUDE.md`. Puedes responder "no" al hook, porque el
  plugin ya lo trae.
- O pega a mano el contenido de `nucleo/CLAUDE.md` al final de tu
  `~/.claude/CLAUDE.md`.

Las plantillas de contexto las deja el slash command del plugin:
`/kit-chema:init-contexto` copia `contexto/*.md` a `~/.claude/contexto/` solo si
no existen y te recuerda rellenarlas.

## (B) Instalación con git clone

```bash
git clone https://github.com/chemaw8/claude-kit-chema.git claude-kit-chema
cd claude-kit-chema
./instalar.sh
```

El instalador copia el núcleo, las skills, los subagentes, los comandos con sus
scripts y la plantilla de contexto a `~/.claude/`. Nunca sobrescribe un
`~/.claude/CLAUDE.md` existente: si ya hay uno, añade una sección marcada al final
en vez de reemplazarlo. Esta vía instala el kit completo, con o sin plugin.

## Comandos

| Comando | Cuándo |
|---|---|
| `/proyecto-init` | Una vez por proyecto: le crea su ficha `CLAUDE.md` (qué es, stack, cómo correr, trampas, confidencialidad) y propone permisos. Verifica los comandos corriéndolos; en repos sensibles pide confirmación antes de ejecutar. |
| `/cierre` | Al terminar o pausar el trabajo: deja `CONTINUAR.md` con el estado mínimo para reanudar en frío y archiva el detalle viejo en `docs/bitacora.md` sin perder nada. |
| `/revisar-salud` | Revisa el reporte de observabilidad y propone arreglos a los errores recurrentes. |
| `/init-contexto` | Copia las plantillas de contexto a `~/.claude/contexto/` sin pisar las tuyas. |

`/proyecto-init` y `/cierre` son un par: el primero crea la ficha, el segundo la
mantiene viva. Se apoyan en `scripts/rotar-continuar.sh`, que garantiza —y
verifica— que al archivar el detalle viejo no se pierda ninguna línea.

¿No usas terminal? Ve directo a la sección de claude.ai web más abajo.

## Instalación manual

Si prefieres no correr el instalador, copia cada pieza a mano.

Si ya tienes un `~/.claude/CLAUDE.md`, no uses `cp` (lo pisaría) — usa
`./instalar.sh` o pega el contenido de `nucleo/CLAUDE.md` al final a mano.

```bash
mkdir -p ~/.claude/skills ~/.claude/contexto
cp nucleo/CLAUDE.md ~/.claude/CLAUDE.md
cp -r skills/kit-* ~/.claude/skills/
cp contexto/* ~/.claude/contexto/
```

## Uso en claude.ai web

claude.ai web no lee `~/.claude/`, así que ahí el kit se instala a mano, por
proyecto: pega el contenido de `nucleo/CLAUDE.md` como instrucciones del
proyecto y sube como archivos del proyecto los `SKILL.md` de las skills que
vayas a usar. Como en la web no existe `~/.claude/contexto/`, pega también el
contenido de tus archivos de `contexto/` (empresa y, si lo usas, personal) al
final de esas instrucciones del proyecto. Es una versión degradada (sin hooks
ni carga automática de skills por descripción), pero conserva el criterio y el
vocabulario del kit.

## Más documentación

- `INSTRUCTIVO.md` — qué es cada pieza del kit, dónde se instala y cómo saber
  que está funcionando.
- `COMO-PEDIR.md` — guía humana para pedir bien: anatomía de una petición,
  plantillas por dominio y palabras clave.
- `docs/superpowers/specs/2026-07-08-claude-kit-design.md` — spec de diseño
  completo, con los principios y el respaldo empírico detrás de cada decisión.

## Cómo verificar

El repo incluye su propio verificador de límites cuantitativos (núcleo por
debajo de 150 líneas, descriptions dentro de rango, sin mayúsculas de énfasis,
etc.):

```bash
bash verificar.sh
```

Sale con código 0 si todos los chequeos pasan y con 1 si alguno falla,
imprimiendo una línea `OK` o `FALLA` por cada chequeo.
