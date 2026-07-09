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

## Dos formas de instalar

Hay dos vías y ambas funcionan; elige una:

- **(A) Como plugin de Claude Code** — la más cómoda si usas Claude Code. Trae
  las skills y el hook; el núcleo se añade en un paso corto aparte.
- **(B) Con `git clone` + `./instalar.sh`** — instala todo el kit de una vez
  (núcleo, skills, plantillas de contexto y, opcional, el hook). Es la vía de
  siempre y sigue viva.

## (A) Instalación como plugin de Claude Code

Desde v1.2 el kit se distribuye también como plugin. El plugin empaqueta las
7 skills de dominio y el hook anti-secretos. Dentro de Claude Code:

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

El instalador copia el núcleo, las skills y la plantilla de contexto a
`~/.claude/`. Nunca sobrescribe un `~/.claude/CLAUDE.md` existente: si ya hay
uno, añade una sección marcada al final en vez de reemplazarlo. Esta vía instala
el kit completo, con o sin plugin.

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
