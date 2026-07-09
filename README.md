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

## Instalación rápida

```bash
git clone <url-del-repositorio> claude-kit-chema
cd claude-kit-chema
./instalar.sh
```

El instalador copia el núcleo, las skills y la plantilla de contexto a
`~/.claude/`. Nunca sobrescribe un `~/.claude/CLAUDE.md` existente: si ya hay
uno, añade una sección marcada al final en vez de reemplazarlo.

¿No usas terminal? Ve directo a la sección de claude.ai web más abajo.

## Instalación manual

Si prefieres no correr el instalador, copia cada pieza a mano:

```bash
cp nucleo/CLAUDE.md ~/.claude/CLAUDE.md
cp -r skills/kit-* ~/.claude/skills/
mkdir -p ~/.claude/contexto && cp contexto/* ~/.claude/contexto/
```

Si ya tienes un `~/.claude/CLAUDE.md` propio, pega el contenido de
`nucleo/CLAUDE.md` al final del tuyo en vez de sobrescribirlo: el núcleo del
kit está pensado para convivir con instrucciones personales.

## Uso en claude.ai web

claude.ai web no lee `~/.claude/`, así que ahí el kit se instala a mano, por
proyecto: pega el contenido de `nucleo/CLAUDE.md` como instrucciones del
proyecto y sube como archivos del proyecto los `SKILL.md` de las skills que
vayas a usar. Como en la web no existe `~/.claude/contexto/`, pega también el
contenido de `contexto/CONTEXTO-EMPRESA.md` (ya rellenado con tus datos) al
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
