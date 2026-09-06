# Hooks (`hooks/`)

Los hooks son el mecanismo del kit para las reglas que no pueden depender de
que Claude las recuerde. Reflejan el principio P3 de la investigación del
kit: `CLAUDE.md` es consultivo — Claude puede leerlo, olvidarlo bajo presión
de contexto o priorizar otra instrucción. Lo que debe cumplirse siempre, sin
excepción, va en un hook: código que Claude Code ejecuta de forma
determinista, no en prosa que Claude interpreta.

## Qué trae el kit

Dos hooks de guardia y uno de contexto (`kit-chema-contexto.sh`, que carga
tu contexto al abrir sesión).

### `rutas-fantasma.sh` — por defecto

`PreToolUse` sobre `Read|Write|Edit`. El modelo a veces alucina rutas de otro
entorno en tu máquina —`/home/user/...`, `/mnt/user-data/...`, `/repo/...` son del
sandbox de claude.ai— o intenta leer `/` a secas; cada intento es un error, un
reintento y contexto quemado. El hook bloquea esas lecturas y le devuelve al
modelo el cwd real. **Solo actúa si el prefijo no existe en tu disco**: si de
verdad tienes `/home/user`, no estorba una lectura legítima (un `Write` que
pretenda *crear* ese prefijo desde cero sí se bloquea; el mensaje dice cómo
seguir). Si falta python3 o el JSON no se puede leer, deja pasar (bloquear toda
lectura sería peor). Prueba: `bash hooks/test-rutas-fantasma.sh` (la corre
`verificar.sh`). Cubre `Read`, `Write` y `Edit`, que es donde se midió el fallo;
no revisa `Bash`, `Glob`, `Grep` ni `NotebookEdit`.

Por qué hook y no prosa: no es indisciplina que una regla pueda corregir, es el
modelo inventando un entorno; ninguna instrucción lo frena, un chequeo
determinista sí. Evidencia en CHANGELOG v1.18.

### `anti-secretos.sh` — opt-in

Es un hook
`PreToolUse` sobre `Bash` que revisa el diff staged antes de un `git commit`;
si encuentra un patrón de credencial (clave API, token, llave
privada), bloquea el comando con salida 2 y explica por qué en stderr, que
Claude ve y puede corregir. Cualquier otro comando pasa sin tocarlo. Ojo: esto
protege solo dentro de Claude Code (commits hechos a mano fuera de él no
pasan por el hook) y solo escanea el diff staged del repo en el directorio de
trabajo de la sesión — un `git commit` que apunte a otro repo (`cd /otro/repo
&& git commit` o `git -C /otro/repo commit`) no queda escaneado.

## Eventos disponibles en Claude Code

| Evento | Cuándo se dispara |
|---|---|
| `PreToolUse` | Antes de ejecutar una herramienta; puede bloquearla (exit 2) |
| `PostToolUse` | Justo después de que la herramienta terminó, con su resultado |
| `Stop` | Cuando Claude termina de responder al usuario |
| `SessionStart` | Al abrir o reanudar una sesión, antes del primer turno |

Hay más eventos en Claude Code; este catálogo cubre los más útiles para el kit.

## Instalación y cómo desactivarlo

`kit-chema-contexto.sh` y `rutas-fantasma.sh` se instalan por defecto (bajo
riesgo, alto valor). `hooks/anti-secretos.sh` es opt-in: `instalar.sh` pregunta
antes de activarlo. Si aceptas, copia el script a `~/.claude/hooks/anti-secretos.sh` y
fusiona `hooks/settings-fragment.json` dentro de `~/.claude/settings.json`,
sin pisar hooks que ya tengas configurados ahí. Para desactivar cualquiera, quita su
entrada (`anti-secretos.sh` o `rutas-fantasma.sh`) dentro de `hooks.PreToolUse`
en `~/.claude/settings.json` — y, en el caso de `rutas-fantasma.sh`, reinstala
después con `KIT_RUTAS_FANTASMA=n ./instalar.sh` (o exporta esa variable), porque
si no el instalador la repone en la siguiente actualización. Ojo: revertir el PR
en el repo no desinstala nada de las máquinas donde ya se instaló; el kit no
tiene desinstalador (pendiente desde v1.1) (borra el bloque entero si queda vacío); el script
puede quedarse en `~/.claude/hooks/` sin efecto, solo actúa si
`settings.json` lo invoca.

## Cuándo escalar una regla a hook

No toda regla merece un hook: cada uno añade latencia y una fuente más de
falsos positivos. Escala una regla del kit a hook solo cuando se cumplen las
dos condiciones: se violó dos o más veces a pesar de estar en el núcleo o
una skill, y el costo de que se vuelva a violar es alto (credenciales
filtradas, dato irreversible, entrega equivocada a un cliente). Hay una segunda
vía, más estrecha: cuando el fallo no es de disciplina sino del modelo (una
alucinación que ninguna regla en prosa alcanza), el reporte semanal de salud lo
muestra recurrente, y el hook que lo ataja es determinista, está condicionado
al estado real de la máquina (no puede bloquear una lectura legítima), falla
abierto y trae prueba que corre `verificar.sh`. Las cinco a la vez; si falta
una, no es hook — es el caso de `rutas-fantasma.sh`. Si solo
pasó una vez o el costo es bajo, corrígelo en prosa: sale más barato de
mantener y no bloquea flujos legítimos.
