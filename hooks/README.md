# Hooks (`hooks/`)

Los hooks son el mecanismo del kit para las reglas que no pueden depender de
que Claude las recuerde. Reflejan el principio P3 de la investigación del
kit: `CLAUDE.md` es consultivo — Claude puede leerlo, olvidarlo bajo presión
de contexto o priorizar otra instrucción. Lo que debe cumplirse siempre, sin
excepción, va en un hook: código que Claude Code ejecuta de forma
determinista, no en prosa que Claude interpreta.

## Qué trae el kit

Un solo hook de ejemplo, opcional: `anti-secretos.sh`. Es un hook
`PreToolUse` sobre `Bash` que revisa el diff staged antes de un `git commit`
o `git push`; si encuentra un patrón de credencial (clave API, token, llave
privada), bloquea el comando con salida 2 y explica por qué en stderr, que
Claude ve y puede corregir. Cualquier otro comando pasa sin tocarlo.

## Eventos disponibles en Claude Code

| Evento | Cuándo se dispara |
|---|---|
| `PreToolUse` | Antes de ejecutar una herramienta; puede bloquearla (exit 2) |
| `PostToolUse` | Justo después de que la herramienta terminó, con su resultado |
| `Stop` | Cuando Claude termina de responder al usuario |
| `SessionStart` | Al abrir o reanudar una sesión, antes del primer turno |

Hay más eventos en Claude Code; este catálogo cubre los más útiles para el kit.

## Instalación y cómo desactivarlo

`hooks/anti-secretos.sh` es opt-in: `instalar.sh` pregunta antes de
activarlo. Si aceptas, copia el script a `~/.claude/hooks/anti-secretos.sh` y
fusiona `hooks/settings-fragment.json` dentro de `~/.claude/settings.json`,
sin pisar hooks que ya tengas configurados ahí. Para desactivarlo, quita la
entrada de `anti-secretos.sh` dentro de `hooks.PreToolUse` en
`~/.claude/settings.json` (borra el bloque entero si queda vacío); el script
puede quedarse en `~/.claude/hooks/` sin efecto, solo actúa si
`settings.json` lo invoca.

## Cuándo escalar una regla a hook

No toda regla merece un hook: cada uno añade latencia y una fuente más de
falsos positivos. Escala una regla del kit a hook solo cuando se cumplen las
dos condiciones: se violó dos o más veces a pesar de estar en el núcleo o
una skill, y el costo de que se vuelva a violar es alto (credenciales
filtradas, dato irreversible, entrega equivocada a un cliente). Si solo
pasó una vez o el costo es bajo, corrígelo en prosa: sale más barato de
mantener y no bloquea flujos legítimos.
