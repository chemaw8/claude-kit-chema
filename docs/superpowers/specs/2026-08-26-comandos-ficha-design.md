# `/proyecto-init` y `/cierre` — diseño

Fecha: 2026-08-26
Estado: diseño aprobado por José, pendiente de construcción (PR + council).
Antecedente: `2026-08-22-fichas-de-proyecto-design.md` (rama `spec-fichas-de-proyecto`),
que definió la arquitectura de fichas y esbozó estos dos comandos. Este documento
los aterriza y resuelve lo que aquel dejó abierto.

## 1. Problema

Las fichas de proyecto funcionan: 7 proyectos migrados (olas 1-2) bajaron el
arranque de sesión ~85%. Pero el método depende de que Claude las construya a mano
en cada proyecto, dirigido por José. Faltan las dos piezas que lo vuelven
auto-servicio y lo sostienen en el tiempo:

- **Sin `/proyecto-init`**, la ola 3 (~17 proyectos restantes) no arranca: cada
  ficha es un trabajo manual de sesión completa.
- **Sin `/cierre`**, las fichas envejecen. Es el modo de falla ya observado tres
  veces: una ficha decía "sin remoto" cuando el proyecto ya tenía remoto desde
  hacía días. El dato no era falso al escribirse; se pudrió.

### La pregunta que este diseño tuvo que resolver

> "Cuando cierro, ¿cómo lo continúo si es que se necesita continuar?"

El spec anterior definió **cómo se recorta** `CONTINUAR.md` (tope de 40 líneas),
pero nunca definió **qué debe garantizar** para que alguien —o Claude en frío—
reanude sin perder el hilo. Un tope de líneas es una regla de *tamaño*; le faltaba
la de *contenido*. Un council de 4 evaluadores confirmó que ese hueco es real.

## 2. Objetivo

Que reanudar trabajo cortado sea confiable **aunque `/cierre` nunca se haya
corrido**, y que crear una ficha nueva sea un comando, no una sesión de trabajo.

Criterio de éxito medible:

- Abrir un proyecto tras 3 semanas y saber en ≤2 minutos qué sigue y cómo retomar,
  sin leer la bitácora ni el historial de git a mano.
- Un `CONTINUAR.md` cuyo estado quedó rancio **se delata solo** al reanudar, en vez
  de mentir en silencio.
- La ola 3 se hace proyecto por proyecto con un comando, sin diseño ad-hoc.

## 3. Hallazgos del council (2026-08-26)

Cuatro evaluadores independientes (`evaluador-council`, Opus 5, contexto fresco,
lentes: modos de falla · viabilidad de flujo · abogado del diablo · contrato de
reanudación). **Veredicto unánime: `aprobada con cambios`.**

Lo que cambió el diseño:

| Hallazgo | Origen | Resolución |
|---|---|---|
| Atar la reanudación a que `/cierre` corra es un punto único de falla: la sesión que muere (segfault, cerrar terminal, agotar contexto) nunca cierra | 3 de 4 | `CONTINUAR` lleva **ancla a git**; al reanudar se **reconcilia** y se detecta el estado rancio |
| El tope de 40 líneas puede **amputar** estado necesario en trabajo complejo a medias | 3 de 4 | Tope **blando**: blinda el contrato mínimo, recorta solo el detalle |
| `CONTINUAR` repite hechos estables (repo, remoto, stack) que envejecen ahí | contrato | **Prohibición explícita**: los hechos estables viven en `CLAUDE.md`. Esto mata la causa raíz del bug "sin remoto" |
| Lo rotado a bitácora se pierde de la *atención* aunque no del disco; nadie la lee | 2 de 4 | El flujo de reanudar **lee la cola de bitácora y DECISIONES** cuando aplica |
| `/cierre` como ceremonia de 5 pasos se saltará bajo prisa | flujo | `/cierre` **silencioso en los no-ops**: solo actúa sobre lo que cambió |
| `/proyecto-init` "verifica comandos corriéndolos" es peligroso en repos con NDA, PCI, pentest o BD de producción | 2 de 4 | **Puerta de seguridad**: en repos marcados, lista y confirma; nunca corre a ciegas |

**Hallazgo descartado en la síntesis:** dos evaluadores pidieron un hook `Stop` que
persista estado. Se rebaja a **migaja de fin de sesión**: un hook que escribe en
cada Stop se dispara decenas de veces por sesión — sobre-ingeniería que el propio
mandato del council prohíbe. La migaja da el grueso del beneficio sin el thrashing.

**Desviación de protocolo, declarada:** la skill `kit-propuestas` pide sintetizar el
veredicto con Fable 5 (escalón de síntesis y juicio crítico). Esta síntesis se hizo
con el modelo de sesión (Opus 4.8). No se repitió porque los 4 reportes convergieron
sin contradicciones y los hallazgos se verificaron uno a uno, pero queda anotado.

## 4. Diseño

### 4.1 El contrato de reanudación

`CONTINUAR.md` **siempre** garantiza estos campos tras un `/cierre`. Ocupan ~15
líneas, así que caben holgados bajo el tope.

| # | Campo | Obligatorio | Por qué |
|---|---|---|---|
| 1 | Fecha absoluta + ancla de git en el H1 | sí | Distingue estado fresco de rancio; permite reconciliar |
| 2 | Dónde vamos (1 frase) | sí | Orienta al lector en frío |
| 3 | Siguiente paso (verbo + objeto + criterio de terminado) | sí | Es el propósito entero de reanudar |
| 4 | Cómo retomar (abrir X · correr Y · verificar Z) | sí | Claude en frío no recuerda el layout |
| 5 | Bloqueadores / esperas | sí (puede decir "Ninguno") | Un bloqueador silencioso es una trampa |
| 6 | Frentes abiertos (tabla) | solo si hay >1 | Con un frente se disuelve en #2 y #3 |
| 7 | Última decisión relevante (puntero, no copia) | recomendado | Evita reabrir lo cerrado |

**Dos reglas que sostienen el contrato:**

1. **`CONTINUAR.md` no repite hechos estables.** Repo, remoto, stack y "qué es el
   proyecto" viven en `CLAUDE.md`. `CONTINUAR` solo carga lo que cambia entre
   sesiones. Esta regla es la que mata el caso "sin remoto": ese dato envejeció
   *porque vivía donde no debía*.
2. **El estado se sobrescribe, no se acumula.** `CONTINUAR` es siempre una foto
   fresca; lo desplazado va a `docs/bitacora.md`. Nunca sedimenta.

### 4.2 Esqueleto que produce `/cierre`

La línea `---` es el corte operativo: **arriba blindado, abajo recortable.**

```markdown
# CONTINUAR — <proyecto>  ·  cierre 2026-08-26  ·  commit a1b2c3d  ·  cierre limpio: sí
> Estado vivo de sesión. Los hechos estables (repo, remoto, stack) viven en
> CLAUDE.md, no aquí.

## Dónde vamos
<una frase: en qué punto está el trabajo>

## Siguiente paso
- [ ] <verbo + objeto + criterio de terminado>

## Cómo retomar
- Abrir:    <archivo / carpeta>
- Correr:   <comando>
- Verificar arranque: <comando o qué debe verse>

## Bloqueadores / esperas
- <qué + de quién depende + desde qué fecha>        (o "Ninguno")

## Frentes abiertos          ← solo si hay >1
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|

## Última decisión relevante
- 2026-08-DD  <qué>  → DECISIONES.md

---
## Detalle vivo              ← ZONA RECORTABLE (lo viejo → docs/bitacora.md)
- ...
```

### 4.3 Regla de recorte

`/cierre` recorta **por prioridad, no por antigüedad ciega**:

- Los campos 1-5 del contrato **nunca se recortan**, cueste lo que cueste.
- El overflow sale **solo** de "Detalle vivo".
- Criterio de rotación: *"¿hace falta para el siguiente paso?"*, no *"¿es viejo?"*.
  Lo no resuelto se **arrastra hacia adelante**; solo se archiva lo ya cerrado.
- El tope de 40 líneas es **blando**: si el estado genuino no cabe, `/cierre` lo
  **marca** en vez de truncar en silencio.
- Diagnóstico: si el contrato *solo* pasa de 40 líneas, no es problema de recorte —
  son demasiados frentes y el proyecto pide partirse.

### 4.4 El ancla de git y la reconciliación

El encabezado guarda el último commit y si el cierre fue limpio. Al reanudar:

1. Comparar el ancla contra `git log -1`.
2. **Si coinciden** → `CONTINUAR` es de fiar, se lee y ya.
3. **Si divergen, o dice `cierre limpio: no`** → hubo trabajo después del último
   cierre. Reconstruir del `git diff` y los archivos tocados **antes** de creerle al
   estado escrito, y avisar a José que el estado venía rancio.
4. **Degradación con gracia:** en proyectos que trabajan sin commitear (varios de
   los activos), el ancla usa fecha de cierre vs. `mtime` de los archivos del
   proyecto. Menos preciso, misma función: detectar divergencia.

### 4.5 Flujo de reanudar (contrato completo)

> ficha `CLAUDE.md` → `CONTINUAR.md` → **reconciliar con git** → si divergió o el
> hueco es largo: cola de `DECISIONES.md` + cola de `docs/bitacora.md`

Esto responde la pregunta que disparó el diseño y resuelve de paso la bitácora de
solo-escritura: queda definido **cuándo** se lee.

### 4.6 `/proyecto-init` — genera la ficha (una vez por proyecto)

1. **Lee lo que ya existe**: `README.md`, `CONTINUAR.md`, `DECISIONES.md`,
   manifiestos de dependencias, `scripts/`, remoto de git.
2. **Puerta de seguridad (nueva).** Antes de ejecutar nada, detecta si el proyecto
   es sensible — señales: `.claude/settings.json` con reglas `deny`, material NDA
   declarado en la ficha, credenciales en `.env`, o conexión a BD de producción. En
   un proyecto sensible **lista los comandos que correría y pide confirmación**;
   nunca ejecuta a ciegas. En un proyecto normal, los ejecuta para escribir solo
   comandos verificados; si uno falla, lo reporta en vez de escribirlo.
3. **Propone permisos con evidencia**, derivados de los comandos verificados y del
   uso real. **Nunca auto-modifica `settings.json`**: propone y espera aprobación.
4. **Muestra antes de escribir**: ficha propuesta, permisos propuestos y, si
   `CONTINUAR.md` supera 60 líneas, la rotación propuesta.
5. **Escribe y commitea** tras aprobación: `CLAUDE.md` + `.claude/settings.json`,
   y deja `CONTINUAR.md` en el formato del contrato (§4.2).

*Dos umbrales distintos, a propósito:* **60 líneas** dispara la rotación única de
migración (no rota CONTINUARs ya sanos); **40** es el tope blando de régimen que
`/cierre` sostiene después.

### 4.7 `/cierre` — mantiene la ficha viva (cada sesión de trabajo)

Es la pieza que hace que **mantener sea el mismo acto que terminar**.

1. **Reconstruye desde artefactos durables**, no desde la memoria de la sesión
   (`git diff`, archivos tocados, DECISIONES). Así el estado no se degrada cuando
   la compactación de contexto ya actuó.
2. **Reescribe `CONTINUAR.md`** con el contrato de §4.1, re-estampando fecha y
   ancla de git. El detalle desplazado va a `docs/bitacora.md`.
3. **Silencioso en los no-ops.** Solo actúa sobre lo que cambió de verdad: la ficha
   solo si cambió stack, comando o apareció una trampa; `DECISIONES.md` solo si
   hubo decisión cara o irreversible; nota de vault solo si hay algo notable. Cero
   preguntas sobre lo que no cambió.
4. **Verifica el siguiente paso**: ¿un lector en frío sabría exactamente qué
   teclear o abrir? Si no, lo reescribe.
5. **Cero residuos**: lista los temporales creados en la sesión y los borra.

### 4.8 Piezas y responsabilidades

| Pieza | Qué hace | Tipo |
|---|---|---|
| `commands/proyecto-init.md` | Orquesta: lee, evalúa sensibilidad, redacta, muestra, aprueba | prompt (juicio) |
| `commands/cierre.md` | Orquesta: reconstruye, reescribe, decide qué cambió | prompt (juicio) |
| `scripts/rotar-continuar.sh` | **Compartido por ambos.** Cuenta líneas, mueve el detalle a bitácora, **verifica con `diff` que no se perdió nada**, re-estampa fecha y ancla | bash (determinista) |
| Migaja de fin de sesión | Deja estado mínimo si `/cierre` nunca corrió | hook, **opcional** |

El helper es compartido a propósito: la rotación es la misma operación en los dos
comandos, y duplicarla es la clase de cosa que se desincroniza.

**La migaja es un refinamiento, no un cimiento.** El diseño *no depende* de ella:
el caso "`/cierre` nunca corrió" ya queda cubierto por el ancla y la reconciliación
(§4.4), que detectan el estado rancio al reanudar. La migaja solo reduce cuánto hay
que reconstruir del `git diff`. Se construye **después** de que los dos comandos
funcionen, y solo si la reconciliación resulta insuficiente en la práctica. Se
descarta si dispara más de una vez por sesión de trabajo.

**Por qué híbrido:** la rotación es donde la corrección importa y no puede depender
de que el modelo tenga cuidado esa vez; un script que preserva y un `diff` que lo
prueba es el método que ya funcionó en las 4 rotaciones de la ola 2 (cero pérdida
verificada). La redacción de la ficha, en cambio, es juicio y no se scriptea bien.

## 5. Riesgos

| Riesgo | Prob. | Mitigación |
|---|---|---|
| `/cierre` no se corre nunca | alta | Ancla + reconciliación detectan el estado rancio; migaja de fin de sesión |
| El estado no cabe en 40 líneas y se ampute | media | Tope blando: blinda el contrato, marca el exceso, nunca trunca en silencio |
| La bitácora crece y nadie la lee | media | §4.5 define cuándo se lee (hueco largo o divergencia) |
| `/proyecto-init` toca producción o secretos | baja pero grave | Puerta de seguridad §4.6.2: lista y confirma en repos sensibles |
| Los dos comandos se desincronizan | media | Helper de rotación compartido |
| `/cierre` se siente ceremonia y se salta | media | Silencioso en los no-ops |

## 6. Gobernanza

| Artefacto | Dónde | Cómo entra |
|---|---|---|
| `/proyecto-init`, `/cierre`, helper | `claude-kit-chema` → `commands/`, `scripts/` | **PR + council** |
| Este spec | `docs/superpowers/specs/` | rama `spec-comandos-ficha` → PR |

Rama de trabajo: `spec-comandos-ficha`. No se commitea a `main` (branch protection).
Al aprobarse, anotar en `CHANGELOG.md`.

## 7. Fuera de alcance

- **Skills por proyecto** (`.claude/skills/`): diferido en el spec anterior, sigue
  diferido. Primero fichas, luego se observa qué playbook se re-deduce.
- **Ola 3 en sí**: este diseño la habilita; ejecutarla es trabajo posterior, y se
  hace al reentrar a cada proyecto, no de golpe.
- **Scan de frescura como comando propio**: la reconciliación de §4.4 cubre el caso
  principal (estado rancio). Un scan general de fichas queda para después, con
  evidencia de que hace falta.

## 8. Deuda detectada de paso

`commands/revisar-salud.md` invoca la skill `kit-sugerencias`, que el council de
v1.12 eliminó y fundió en el núcleo. Es una referencia muerta. Fuera del alcance de
este spec; arreglar en un PR aparte.
