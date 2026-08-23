# Diseño — Fichas de proyecto

Fecha: 2026-08-22
Autor: José M. Loyola + Claude
Estado: aprobado por José, pendiente de plan de implementación
Destino: kit v1.11 (entra por PR + council, ver `GOBERNANZA.md`)

Capa 1 del "ambiente de ingeniería de IA". Frentes B–E quedan fuera (ver §9).

---

## 1. Problema

Cada sesión de trabajo en cualquiera de los 24 proyectos de `~/Trabajo/proyectos/`
arranca reconstruyendo a mano el mismo contexto: qué es el proyecto, cuál es el
stack, cómo se corren sus scripts, dónde están los datos, qué trampas ya conocemos
y qué material es confidencial. Ese trabajo se repite íntegro en cada sesión y en
cada proyecto.

### Evidencia (medida el 2026-08-22)

| Hecho | Medición |
|---|---|
| Proyectos en `~/Trabajo/proyectos/` | 24 |
| Con `CLAUDE.md` propio | **2** (uno de ellos es solo `@AGENTS.md`) |
| Con carpeta `.claude/` (permisos, skills) | **0** |
| Con repo propio y remoto | 13 |
| Con repo propio local (sin remoto) | 8 |
| **Sin git alguno** | **3** — `pentest-ordenaris`, `kreditera-bait`, `catalogo-conceptos-cdmx` |
| Con `CONTINUAR.md` | 25 |
| Con `DECISIONES.md` | 19 |
| Líneas totales de `CONTINUAR.md` | 3,609 |
| El más largo (`callcenter-converzia`) | 911 líneas (~12k tokens) |
| Segundo (`ventas-sucursales`) | 603 líneas (~8k tokens) |

Dos lecturas de esos números:

1. **La disciplina de continuidad funciona** — 25 CONTINUAR y 19 DECISIONES son
   evidencia de que la regla del núcleo se cumple. No hay que tocarla.
2. **Pero `CONTINUAR.md` se degradó a bitácora append-only.** Mezcla el estado
   actual con toda la historia, así que para saber "dónde vamos" hay que cargar
   cientos de líneas de historia ya cerrada.

Y falta por completo la capa estable: ningún archivo responde "cuál es el stack y
cómo se corre esto", que es justo lo que no cambia y lo que más se re-deduce.

### Precedente de fracaso que el diseño debe respetar

`~/Trabajo/CLAUDE.md` ya tiene una sección "Proyectos activos" que era exactamente
este mecanismo, centralizado. Hoy lista **5 de 24 proyectos con estado
desactualizado**. Se degradó porque actualizarla era un acto de disciplina
*separado* de terminar el trabajo. Cualquier diseño que dependa de acordarse de
actualizar algo repetirá ese resultado.

---

## 2. Objetivo

Que al entrar a cualquier proyecto vivo, Claude sepa **sin preguntar** qué es, cómo
correrlo, dónde están los datos, qué trampas hay y qué no puede salir de ahí — con
un costo de contexto de arranque menor al 20% del actual.

---

## 3. Diseño

### 3.1 Principio: separar los archivos por vida útil

La causa raíz es que un solo archivo lleva cuatro cosas que cambian a ritmos
distintos. El diseño las separa por **cada cuánto cambia cada una**:

| Archivo | Vida útil | Cuándo cambia | Cuándo se carga |
|---|---|---|---|
| `CLAUDE.md` | estable (meses) | al cambiar stack o descubrir una trampa | **siempre, automático** |
| `CONTINUAR.md` | volátil (sesión) | en cada cierre | al retomar — tope 40 líneas |
| `docs/bitacora.md` | histórico | append en cada cierre | solo si se pregunta por la historia |
| `DECISIONES.md` | decisiones | al decidir algo caro | antes de reabrir una discusión |

`CONTINUAR.md` y `DECISIONES.md` conservan su rol actual del núcleo. Lo único que
cambia es que la historia larga sale de CONTINUAR hacia `docs/bitacora.md`.

### 3.2 La ficha (`CLAUDE.md` de proyecto)

Plantilla. **Tope duro: 40 líneas.**

```markdown
# <proyecto>
<1-2 líneas: qué es y para quién>

## Estado
Estado actual en CONTINUAR.md · decisiones cerradas en DECISIONES.md ·
historia larga en docs/bitacora.md. Léelos antes de proponer cambios.

## Stack y cómo correr
- <runtime + versión exacta si importa>
- <comandos literales, verificados: instalar / correr / probar>

## Datos
- <dónde viven, formato, corte, qué NO tocar>

## Trampas conocidas
- <lo que ya nos mordió, una línea cada una>

## Confidencialidad
<público | interno | NDA> — <qué no puede salir>

## Convenciones
<solo lo que se aparta del estándar de ~/Trabajo; si nada, se omite la sección>
```

**Reglas de contenido:**

- **Cero cifras de resultado.** El `CLAUDE.md` se autocarga en toda sesión y se
  trata como instrucción autoritativa: una cifra ahí no trae fecha ni fuente al
  lado, así que se repite con confianza mucho después de haber caducado. Los
  resultados viven en `datos/` (vivos) o en el entregable sellado (PDF, deck), y
  en la ficha va un **puntero** a dónde están.
- **Sí se permiten constantes de definición**, con fuente y fecha: restricciones
  contractuales, regulatorias o de plataforma que si cambian rompen el proyecto
  entero (p. ej. un requisito legal vigente desde una fecha, o un límite de
  contrato). No son resultados; son el terreno.
- **Cero estado.** "Vamos en la fase 2" es `CONTINUAR.md`.
- **Comandos literales y probados**, nunca inventados: `/proyecto-init` los ejecuta
  antes de escribirlos.
- **Protección de entregables sellados.** Donde existan (informes o PDFs ya
  entregados a cliente), la ficha lo dice explícitamente: son fotos con su fecha de
  corte, no se recalculan; si piden actualización se genera uno nuevo con su propia
  fecha.

Si algo no cabe en 40 líneas, es porque es estado (→ CONTINUAR) o historia
(→ bitácora). El tope es la defensa contra que la ficha se infle hasta volverse
otro CONTINUAR.

### 3.3 Permisos por proyecto

| Archivo | Se commitea | Contenido |
|---|---|---|
| `.claude/settings.json` | sí — compartido con colaboradores | permisos específicos y seguros: `Bash(npm test:*)`, `Bash(npx prisma:*)`, `Bash(python3 scripts/*.py)` |
| `.claude/settings.local.json` | no (gitignored) | lo personal: rutas absolutas de la máquina, `docker`, lo adyacente a credenciales |

**Restricción dura:** 13 de los 24 proyectos tienen repo propio con remoto, así que
su `settings.json` se publica en GitHub. Por lo tanto `settings.json` nunca lleva un
allow amplio (`Bash(*)` o equivalente).

`~/Trabajo` también tiene remoto (`github.com/chemaw8/trabajo`) y colaboradores,
pero su `.gitignore` excluye `proyectos/` completo — **verificado el 2026-08-22:
ningún proyecto confidencial está rastreado por el repo padre**. Los proyectos sin
git propio (los 3 de §1) quedan por tanto fuera de todo control de versiones: sus
fichas no se versionan hasta que se les inicialice repo.

**Prerrequisito detectado:** `pentest-ordenaris`, `kreditera-bait` y
`catalogo-conceptos-cdmx` no tienen git, lo cual viola la regla de
`~/Trabajo/CLAUDE.md` ("una carpeta por repo, con git inicializado") y los deja sin
historial ni respaldo. El caso de `pentest-ordenaris` es el más serio por el
material que contiene. Inicializarles repo local (sin remoto, por el material) es
prerrequisito de su ficha, pero **no** de este diseño: los tres caen en la ola 2 o 3.

**Alcance de plugins por proyecto (añadido 2026-08-22).** Verificado en la
documentación oficial: la clave `enabledPlugins` tiene alcance **"Any file"**, así
que el `.claude/settings.json` de la ficha también decide **qué plugins carga este
proyecto**. Eso convierte la ficha en la palanca de contexto más grande del setup:

| Plugin | Costo por sesión | Uso medido en 6 semanas | Dónde debería vivir |
|---|---:|---:|---|
| vercel (30 skills + 3 agentes) | ~2,220 tok | 2 invocaciones | `homologador-tpu`, `verne-web`, `broukn-web` |
| pr-review-toolkit (6 agentes) | ~1,570 tok | 0 invocaciones | donde se revise código de verdad |

Medición sobre 1,487 transcripts; detalle en
`investigacion/2026-08-22-context-engineering-attention-rag.md`.

**Orden obligatorio:** primero las fichas de esos proyectos, después se apaga el
plugin globalmente. Al revés es una regresión — el proyecto se queda sin la
capacidad antes de tener dónde recuperarla.

**Guardarraíl de confidencialidad (nuevo).** En los proyectos con material NDA o
sensible (`pci-innovattia`, `poc-memoria-contratos`, `seguimiento-mensajeria`,
`pentest-ordenaris`), el `settings.json` incluye:

```json
{ "permissions": { "deny": ["WebFetch", "WebSearch"] } }
```

Esto convierte "acuérdate de que este material no sale" en un candado del harness.
Es la única parte del diseño que reduce un riesgo real de fuga, no solo de tiempo.

### 3.4 Comandos

Dos comandos nuevos en `commands/` del kit.

#### `/proyecto-init` — genera la ficha (una vez por proyecto)

1. **Lee lo que ya existe**: `README.md`, `CONTINUAR.md`, `DECISIONES.md`,
   `package.json` / `requirements.txt` / `pyproject.toml`, `scripts/`, remoto de git.
2. **Verifica los comandos**: los ejecuta (instalar, probar, correr) para escribir
   solo comandos que de verdad funcionan. Si uno falla, lo reporta en vez de
   escribirlo.
3. **Propone los permisos con evidencia**: siembra el allowlist con
   `/fewer-permission-prompts`, que los deriva de los transcripts reales de uso
   (cubre llamadas Bash y MCP de solo lectura); el resto sale de los comandos
   verificados en el paso 2. Los permisos se miden, no se adivinan.
4. **Muestra antes de escribir**: ficha propuesta, permisos propuestos y, si
   `CONTINUAR.md` supera 60 líneas, la propuesta de rotación a `docs/bitacora.md`.
   Nada se escribe sin aprobación de José.

   *Dos umbrales distintos, a propósito:* **60 líneas** es el disparo de la
   rotación única de migración (evita rotar CONTINUARs que ya están sanos);
   **40 líneas** es el tope de régimen que `/cierre` sostiene después.
5. Escribe `CLAUDE.md` + `.claude/settings.json` y commitea.

#### `/cierre` — mantiene la ficha viva (cada sesión de trabajo)

Es la pieza central del diseño, no un extra: hace que **mantener sea el mismo acto
que terminar**, que es exactamente lo que le faltó a "Proyectos activos".

1. Reescribe el bloque de estado de `CONTINUAR.md` en ≤40 líneas; lo desplazado se
   añade a `docs/bitacora.md` con su fecha.
2. Si en la sesión cambió el stack, un comando, o apareció una trampa nueva →
   actualiza la ficha.
3. Si hubo una decisión cara o irreversible → la escribe en `DECISIONES.md` con
   fecha absoluta, razones y alternativas descartadas.
4. Deja nota enlazada en el vault vía `basic-memory` si el proyecto está ahí.
5. **Cero residuos**: lista los archivos temporales creados en la sesión y los borra.

### 3.5 Skills por proyecto — diferido, no descartado

Un `.claude/skills/` por proyecto tiene carga diferida (solo entra al contexto
cuando aplica), lo cual es más eficiente en tokens que el `CLAUDE.md`. Pero se
activa por juicio del modelo, no de forma determinista, y "qué es este proyecto y
cómo se corre" tiene que cargarse **siempre**. Por eso la ficha es `CLAUDE.md` y la
skill es complemento, no sustituto.

Candidatos identificados, con playbook real y repetido:

- `ventas-sucursales` — pipeline de análisis (scripts numerados, protocolo de
  validación de modelos, caveat de rampa de apertura).
- `seguimiento-mensajeria` — reglas de conteo del cliente, extractor, generación de
  reportes en inglés.
- `rcs-demo-ia` — las tres trampas donde un `code:200` no significa entrega.

**Decisión: no ahora.** Primero las fichas; después se observa qué playbook se
sigue re-deduciendo y ese se convierte en skill. Construir las tres skills antes de
tener evidencia es especular.

---

## 4. Migración de los 24 proyectos

Por olas. Nunca de golpe.

| Ola | Proyectos | Método |
|---|---|---|
| **1 — piloto** | `ventas-sucursales` | a mano, midiendo, para calibrar la plantilla y el tope de 40 líneas |
| **2 — activos** | `callcenter-converzia`, `seguimiento-mensajeria`, `rcs-demo-ia`, `homologador-tpu`, `pci-innovattia`, `pentest-ordenaris` | con `/proyecto-init` ya calibrado |
| **3 — resto** | los demás | `/proyecto-init` **al volver a entrar** al proyecto, no antes |

**Criterio de exclusión:** proyecto sin toque en 60 días y sin siguiente paso
declarado → no lleva ficha. No se paga mantenimiento por proyectos muertos.

La ola 1 es un gate: si el piloto no alcanza la meta de §5, se ajusta la plantilla
antes de tocar los otros 23.

---

## 5. Criterios de éxito

Se miden en el piloto (`ventas-sucursales`) antes de escalar.

| # | Métrica | Hoy | Meta |
|---|---|---|---|
| 1 | Líneas a leer para arrancar | 603 (~8k tokens) | ficha ≤40 + estado ≤40 = 80 (~1k) → **−85%** |
| 2 | Prompts de permiso por sesión | medir en el piloto | reducción medible |
| 3 | **¿Se pudo correr algo del proyecto sin preguntarle nada a José en la 1ª sesión post-ficha?** | no | **sí** |

La métrica 3 es la que decide. Las otras dos son proxy: se pueden cumplir las dos
primeras y aun así fallar la tercera si la ficha trae lo equivocado.

Herramienta de medición: `/context` para el consumo de ventana.

---

## 6. Artefactos y gobernanza

| Artefacto | Destino | Vía |
|---|---|---|
| `/proyecto-init`, `/cierre` | `claude-kit-chema` → `commands/` | **PR + council** |
| Plantilla de ficha | `claude-kit-chema` → `plantillas/` | PR |
| Regla "cerrar = ficha + estado + bitácora" | núcleo `CLAUDE.md` del kit | **PR + council** |
| Verificación del tope de 40 líneas | `verificar.sh` del kit | PR |
| Las fichas concretas | cada proyecto en `~/Trabajo` | commit normal |
| Este diseño | `claude-kit-chema/docs/superpowers/specs/` | PR |

Por `GOBERNANZA.md`, `main` tiene branch protection: todo entra por PR con los dos
checks de CI en verde (`límites del kit`, `escaneo de secretos`). Este cambio toca
el núcleo, así que además pasa por council.

Sería **kit v1.11** — y la primera versión que añade herramientas (comandos) en vez
de solo afinar prosa. Las v1.0–v1.10 fueron todas ajustes de redacción de skills,
cosecha de cuerpos y renombres de modelo.

---

## 7. Riesgos

| Riesgo | Severidad | Mitigación |
|---|---|---|
| **Drift** — las fichas envejecen como envejeció "Proyectos activos" | alta | `/cierre` fusiona mantener con terminar; es un solo acto, no dos |
| La ficha se infla y duplica `CONTINUAR.md` | media | tope duro de 40 líneas verificado por script en `verificar.sh` |
| Permisos amplios filtrados a colaboradores por `settings.json` | media | nada amplio en `settings.json`; lo personal a `.local.json`; los permisos se derivan de uso real |
| Fuga de material NDA a servicios externos | alta | `deny` de `WebFetch`/`WebSearch` en los proyectos confidenciales |
| Migrar 24 proyectos resulta trabajo muerto | media | olas + criterio de exclusión de 60 días |
| La plantilla resulta equivocada y se replica 24 veces | media | ola 1 es gate con criterios de §5 |

---

## 8. Decisiones tomadas en el diseño

| Decisión | Alternativa descartada | Razón |
|---|---|---|
| Ficha distribuida por proyecto | Índice central en `~/Trabajo/CLAUDE.md` | ya existe y ya se degradó (5 de 24); además carga los 24 proyectos para trabajar en uno |
| `CLAUDE.md` para lo estable | Skill por proyecto | la skill carga por juicio del modelo; "qué es y cómo se corre" debe cargar siempre |
| Cero cifras de resultado, sí constantes con fuente | Prohibir toda cifra | demasiado duro: las restricciones contractuales y regulatorias son terreno, no resultado |
| Permisos derivados de uso real | Permisos escritos a mano | `/fewer-permission-prompts` mide en vez de suponer |
| Migración por olas con gate | Migrar los 24 de una | replicar una plantilla mal calibrada 24 veces cuesta más que el piloto |

---

## 9. Fuera de alcance

Explícitamente no entran aquí. Cada uno lleva su propio diseño:

- **Frente B** — comandos de rituales del núcleo (`/arranque`, `/council`).
- **Frente C** — subagentes propios que den mecanismo a la escalera de modelos
  (hoy la regla existe en el núcleo pero `~/.claude/agents/` está vacío, así que
  nada la aplica).
- **Frente D** — automatización recurrente con `/loop` y `/schedule` (ABD de los
  viernes, dashboards semanales).
- **Frente E** — empaquetar el kit v2 para colegas del grupo.

Meter cualquiera de estos aquí convierte un diseño ejecutable en una lista de deseos.

---

## Anexo — comandos nativos ya disponibles y sin usar

Detectados durante el diagnóstico; el primero entra al diseño, el resto quedan
apuntados para los frentes correspondientes.

| Comando | Utilidad | Frente |
|---|---|---|
| `/fewer-permission-prompts` | deriva permisos por proyecto desde transcripts reales | **A (este)** |
| `/context` | mide el consumo de ventana — métrica 1 del piloto | **A (este)** |
| `/loop` | tareas recurrentes autopausadas | D |
| `/schedule` | rutinas cron en la nube | D |
| `/code-review`, `/security-review` | revisión del diff antes de PR | B |
| `/run` | levantar la app del proyecto para verla correr | A/B |
