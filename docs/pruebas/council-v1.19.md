# Council v1.19 — fase 1: backstop-cierre + presupuesto del núcleo + simulacro por defecto (PR #30) — 2026-09-06

Tres evaluadores independientes (agente `evaluador-council`, Opus 5, contexto
fresco, mandato acotado de kit-propuestas), lentes: viabilidad técnica, riesgos,
abogado del diablo. Síntesis con Fable 5. Postura inicial del hilo, antes de leer
los reportes: "apruebo; lo discutible es si el backstop debe bloquear o solo avisar,
y si el umbral <10 líneas es demasiado rígido".

## Veredicto: aprobada con cambios — todos aplicados en el mismo PR

Los tres lentes coincidieron en el veredicto y **los tres encontraron el mismo
defecto grave** por caminos distintos: el hook bloqueaba con una razón que el
helper nunca había determinado.

### Hallazgos condicionantes (y qué se hizo)

| # | Hallazgo | Lentes | Verificado | Aplicado |
|---|---|---|---|---|
| 1 | `rotar-continuar.sh reconciliar` devolvía 1 tanto para "rancio" como para "no se puede reconciliar" (sin ancla / ancla fuera del historial); **13 de 32 CONTINUAR reales no tienen ancla** → bloqueo en falso afirmando "hubo trabajo después del último cierre" | 3/3 | reproducido con el helper real (`harness-agentes`, `handover-ivonne`, `verne-web` → rc 1 "no se puede reconciliar") | el helper devuelve **3** para "no se puede reconciliar" (booleano intacto; autotest OK); el hook bloquea **solo con 1** y cita el motivo literal del helper en la razón; caso de prueba con rc 3 y dos casos de integración con el helper real |
| 2 | `Stop` es fin de cada turno, no cierre de sesión: con una sola edición el estado ya es rancio → el único bloqueo se gastaba en el primer turno (mid-task, empujando a cierres prematuros que escriben bitácora) y en el cierre real quedaba desarmado | viabilidad, riesgos | reproducido (turno 1 block, turno 2 aviso) | **umbral** (≥3 escrituras o ≥1 commit) + **re-armado**: la marca guarda el índice del último CONTINUAR; si se cierra y se sigue trabajando, vuelve a bloquear una vez; la razón dice "si estás a mitad de la tarea, continúa". Riesgos proponía degradar a `systemMessage`: **descartado** porque el aviso llega al usuario, no al agente, y el fallo medido es del agente |
| 3 | Si el directorio de marcas no es escribible, bloqueaba en TODOS los turnos | viabilidad, riesgos | reproducido | `mkdir`/escritura de marca fallan → `exit 0`; caso de prueba |
| 4 | El PR sorteaba la puerta que el kit fijó en v1.18 para escalar a hook: no cerrar es indisciplina (no fallo del modelo) y el costo es medio (un estado rancio se recupera) → no califica para "por defecto" | abogado | lectura de `hooks/README.md` v1.18 | el backstop entra **opt-in** (`KIT_BACKSTOP=s`); pasa a por defecto solo si dos reportes semanales muestran menos rancios sin falsos positivos; párrafo "por qué hook y no prosa, y por qué opt-in" en el README, honesto con la puerta |
| 5 | "José" incrustado en la razón del hook (kit público); `kit-codigo` afirmaba que `rotar-continuar.sh` es "ejemplo vivo" del simulacro por defecto, y su default es `DRY=0` | riesgos | `grep` + línea 22 del helper | "el usuario"; frase corregida: es estándar hacia adelante, el helper cumple fallo cerrado y cero pérdida, su simulacro es opt-in |

### Sugerencias aplicadas (no condicionaban)

- `git -C <repo> commit` no contaba como commit (`"git commit" in cmd`): regex
  `\bgit\b.*\bcommit\b`.
- Marcas: `${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}` (macOS no tiene `XDG_RUNTIME_DIR`) y
  limpieza de marcas con más de 7 días.
- Presupuesto del núcleo: se dice qué NO cubre (cuerpos de skill, comandos, hooks:
  tienen sus topes propios) y que aplica a adiciones, no a fixes que no crecen.
- Al menos una prueba con el helper real, no solo con el veredicto inyectado.

### Medido por los lentes (y conservado)

Rendimiento: 77-90 ms en un transcript sintético de 54 MB (viabilidad), 0.38 s en
42 MB y 118 ms en 146 MB (riesgos, abogado): el `grep -F` previo evita parsear el
JSON pesado. `decision: block` + `reason` es el contrato correcto de `Stop`;
`stop_hook_active` corta el bucle. Instalador idempotente; `SOLO_CMD` inserta
solo su entrada. Privacidad: solo lee el transcript de la sesión propia. Las dos
reglas de texto no tuvieron objeción técnica.

### Descartado por los propios lentes

Tres cambios de distinta naturaleza en un PR (dos son texto, el revert está
documentado); latencia; `SubagentStop` es otro evento, el backstop no toca
subagentes.

## ¿Cambió la postura del hilo?

Sí, en dos puntos de fondo: (1) yo lo quería **por defecto** y el abogado mostró
que eso sorteaba una regla del propio kit aprobada un día antes; (2) no había visto
que el helper mezclaba "rancio" con "no sé" — el hallazgo más grave, y lo
encontraron los tres. En lo que yo creía discutible (bloquear vs avisar) el council
se dividió: viabilidad pidió arreglar el bloqueo, riesgos pidió degradarlo; elegí
arreglarlo y dejé escrito por qué. El council aportó; no fue teatral.
