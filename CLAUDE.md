# claude-kit-chema
Kit Chema: paquete distribuible de instrucciones para Claude (núcleo + skills por
dominio + subagentes + hooks + comandos) que produce respuestas consistentes y
verificables para cualquier persona del grupo. Repo PÚBLICO.

## Estado
Estado actual en CONTINUAR.md · decisiones cerradas en DECISIONES.md ·
historia larga en docs/bitacora.md. **Al retomar, corre primero
`bash ~/.claude/scripts/rotar-continuar.sh reconciliar .`**: si sale rancio,
reconstruye del git diff antes de creerle. Luego léelos antes de proponer cambios.

## Stack y cómo correr
Solo bash + python3, sin dependencias.
- `bash instalar.sh` — instala o actualiza en `~/.claude` (núcleo, skills, agents, hooks, commands, scripts) y fusiona `hooks/settings-fragment.json` en settings.json.
- `bash verificar.sh` — límites cuantitativos: núcleo < 150 líneas, descriptions en rango, sin énfasis gritado, autotest del helper. Verificado 2026-09-05: todo OK.
- Gate de disparo (`docs/pruebas/RUNBOOK.md`): obligatorio si el PR toca el núcleo, una description o agrega una skill.

## Datos
No hay datos. `contexto/` son PLANTILLAS vacías (las reales viven en
`~/.claude/contexto`, fuera del repo). `investigacion/` y `presentacion/` son
material de apoyo y no se instalan.

## Trampas conocidas
- Todo cambio entra por PR contra rama + CI en verde + CODEOWNERS; nunca push a main, ni el dueño (GOBERNANZA.md). Los cambios de fondo se revisan por council y se anotan en CHANGELOG.md.
- Lo instalado en `~/.claude` es una COPIA: editar ahí no cambia el kit y se pierde con `instalar.sh`. Se edita aquí y se reinstala.
- El núcleo tiene tope de 150 líneas: cada regla nueva desplaza otra o se va a una skill.
- Un hook nuevo va en `hooks/` + `hooks/settings-fragment.json` + `instalar.sh`; si solo se copia a `~/.claude/hooks`, `bootstrap.sh` (claude-entorno) no lo reinstala.

## Confidencialidad
Repo PÚBLICO (github.com/chemaw8/claude-kit-chema): cero nombres de clientes,
cifras, credenciales ni rutas con material de la empresa — ni en ejemplos, ni en
docs, ni en commits. Lo privado del entorno va en claude-entorno.

## Convenciones
Versionado semántico en CHANGELOG.md; una skill = `skills/<kit-dominio>/SKILL.md`
con description en el rango que mide `verificar.sh`; español de México en todo el
texto; nada entra sin evidencia (piloto, sonda o gate) mientras dure el
congelamiento anotado en CONTINUAR.
