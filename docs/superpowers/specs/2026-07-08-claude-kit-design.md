# Spec — Kit Innovattia para Claude

Fecha: 2026-07-08 · Estado: borrador para revisión de José
Respaldo empírico: `investigacion/reporte-mejores-practicas.md` (25 afirmaciones
verificadas adversarialmente contra fuentes primarias de Anthropic; fecha de
consulta 2026-07-08).

## 1. Objetivo

Un paquete distribuible que haga que Claude produzca output de alta calidad de
forma consistente para cualquier persona de Innovattia, y que enseñe a esa
persona a pedir bien. Ataca cinco dolores concretos: respuestas genéricas,
supuestos no consultados, inconsistencia entre sesiones, complacencia ("yes
sir") y contaminación del código generado por IA.

## 2. Requisitos (acordados con José)

- R1. Doble audiencia: instrucciones automáticas para Claude + guía para humanos.
- R2. Dominios cubiertos: presentaciones/documentos, análisis de datos, research,
  código y development, propuestas (de desarrollo y de decisión), finanzas,
  automatización.
- R3. Anti-complacencia: evaluación crítica de toda propuesta; protocolo
  "council" para decisiones de alto impacto.
- R4. Intensidad proporcional al riesgo (trivial → directo; estándar → checklist;
  alto impacto → council), con palabra clave para forzar o saltar.
- R5. Portable: cualquier colega lo instala sin depender de la configuración
  personal de José; funciona degradado en claude.ai web.
- R6. Higiene anti-contaminación de código (duplicados, residuos, estilos
  mezclados, dependencias injustificadas).
- R7. Continuidad entre sesiones (CONTINUAR.md, DECISIONES.md, fechas absolutas).
- R8. Contexto de empresa editable (plantilla) para eliminar output genérico.
- R9. Instructivo del kit + presentación (deck) para colegas, dentro del repo.
- R10. Ciclo de mejora versionado (CHANGELOG; 2 correcciones iguales → regla).
- R11. Escalera de modelos: Haiku (trivial) → Sonnet (mecánico) → Opus 4.8
  (pesado intermedio) → Fable 5 (síntesis y juicio crítico).
- R12. Todo en español.

## 3. Principios de diseño (derivados de la investigación)

Cada componente del kit obedece estas reglas, todas verificadas contra fuente
primaria (ver reporte):

- P1. **Brevedad ante todo.** CLAUDE.md inflado hace que Claude ignore
  instrucciones. Núcleo < 150 líneas (límite oficial: 200). Prueba de poda por
  línea: si quitarla no causaría errores, se corta.
- P2. **Núcleo transversal, dominio en skills.** Es la arquitectura oficial:
  CLAUDE.md carga siempre (solo lo universal); las skills cargan bajo demanda
  con divulgación progresiva. No usar imports `@ruta` para contenido de dominio
  (se cargan enteros al arranque y no ahorran nada).
- P3. **Regla dura → mecanismo determinista.** CLAUDE.md es consultivo. Lo que
  deba cumplirse siempre va en hooks o scripts, no en prosa.
- P4. **La `description` es el interruptor.** Cada skill dice QUÉ hace y CUÁNDO
  usarla con frases gatillo literales del usuario, < 1024 caracteres. SKILL.md
  < 5.000 palabras; el detalle (plantillas, checklists largos) va en
  `references/`.
- P5. **Redacción concreta y verificable, sin gritos.** "Cifras con fuente y
  recalculadas" en vez de "sé riguroso". Nada de MAYÚSCULAS ni "CRITICAL:" —
  sobreactivan a los modelos actuales.
- P6. **Posición importa.** Lo crítico al inicio de cada archivo; en prompts
  largos, material arriba e instrucciones al final.
- P7. **Sin contradicciones.** Claude elige arbitrariamente entre reglas que
  chocan. El ciclo de mejora incluye un chequeo de consistencia núcleo↔skills↔
  CLAUDE.md de proyecto en cada cambio del kit.
- P8. **Revisores acotados.** Un revisor al que se le pide hallar fallos, los
  inventa. El council solo reporta hallazgos que cambien la corrección o la
  decisión, con evidencia; "sin hallazgos relevantes" es salida válida.
- P9. **El aliento va en el prompt humano.** "Tómate tu tiempo", "calidad sobre
  velocidad" funcionan mejor dichos por el usuario → van en COMO-PEDIR.md, no
  en el kit estático.
- P10. **Altitud correcta.** Heurísticas que guían, no lógica rígida exhaustiva;
  el conjunto mínimo de tokens de alta señal.

## 4. Arquitectura del paquete

```
claude-kit-innovattia/
├── README.md                  → qué es, filosofía, instalación (3 pasos + manual)
├── INSTRUCTIVO.md             → qué es cada pieza y cómo se usa a diario
├── COMO-PEDIR.md              → guía humana: anatomía de una buena petición,
│                                plantillas por dominio, palabras clave, aliento
├── CHANGELOG.md               → versiones del kit
├── nucleo/
│   └── CLAUDE.md              → núcleo universal (< 150 líneas) → ~/.claude/CLAUDE.md
├── contexto/
│   └── CONTEXTO-EMPRESA.md    → plantilla editable (empresa, clientes, tono,
│                                glosario, confidencialidad) → se referencia
│                                desde el núcleo instalado
├── skills/                    → 7 playbooks → ~/.claude/skills/
│   ├── presentaciones/SKILL.md [+ references/]
│   ├── analisis-datos/SKILL.md
│   ├── research/SKILL.md
│   ├── codigo/SKILL.md        [incluye higiene anti-contaminación]
│   ├── propuestas/SKILL.md    [incluye protocolo Council]
│   ├── finanzas/SKILL.md
│   └── automatizacion/SKILL.md
├── hooks/
│   ├── README.md              → cuándo convertir una regla en hook
│   └── anti-secretos.json     → ejemplo opcional: PreToolUse que bloquea
│                                `git commit` si el diff contiene patrones de
│                                credenciales (API keys, tokens)
├── presentacion/              → deck del kit para presentarlo a colegas
├── instalar.sh                → instala núcleo+skills+contexto; NUNCA pisa un
│                                CLAUDE.md existente (añade sección o avisa)
└── investigacion/             → reporte y veredictos que respaldan el diseño
```

## 5. Especificación por componente

### 5.1 Núcleo (`nucleo/CLAUDE.md`)

Secciones, en este orden (lo crítico primero, P6), total < 150 líneas:

1. **Identidad y contexto**: leer `~/.claude/contexto/CONTEXTO-EMPRESA.md` al
   inicio de trabajo sustantivo para audiencia/tono/confidencialidad.
2. **Protocolo de arranque**: antes de trabajo sustancial, confirmar propósito,
   audiencia, formato y criterio de éxito; si falta algo crítico, preguntar
   (máximo 2-3 preguntas). Tareas triviales: directo.
3. **Anti-complacencia**: toda propuesta del usuario se evalúa antes de
   ejecutarse con el formato *qué está bien / qué me preocupa / qué haría yo*.
   Ejecutar sin evaluar solo si el usuario dice "hazlo directo".
4. **Calibración por riesgo**: trivial → directo; entregable estándar →
   checklist del playbook del dominio; decisión cara, irreversible o material
   que sale de la empresa → council (ver skill propuestas). Palabras clave:
   "council" lo fuerza, "rápido" lo salta.
5. **Terminado = verificado**: nada se declara listo sin comprobarlo (código
   ejecutado, cifras recalculadas, fuentes abiertas, archivos revisados);
   reportar con honestidad lo que falló o quedó fuera.
6. **Cero residuos**: al cerrar una tarea se eliminan archivos temporales,
   pruebas sueltas y código muerto; el diff final solo contiene lo que aporta.
7. **Continuidad**: trabajo a medias deja `CONTINUAR.md` (estado + siguiente
   paso); decisiones importantes se anotan en `DECISIONES.md` (fecha, razones,
   alternativas descartadas); fechas siempre absolutas.
8. **Escalera de modelos** (para subagentes/workflows): Haiku trivial, Sonnet
   mecánico, Opus 4.8 pesado intermedio, Fable 5 solo síntesis/juicio crítico.
9. **Índice de playbooks**: tabla dominio → skill (una línea por skill).

Redacción: concreta y verificable (P5), sin mayúsculas de énfasis, español.

### 5.2 Skills (anatomía común)

Frontmatter: `name` + `description` con QUÉ + CUÁNDO + frases gatillo en
español (< 1024 caracteres). Cuerpo (< 5.000 palabras, ideal < 1.500):

1. Qué es "bien hecho" en este dominio (estándar de calidad, 5-8 reglas).
2. Proceso (pasos, con el orden crítico primero).
3. Checklist de verificación final (verificable, no aspiracional).
4. Errores típicos a evitar (los 3-5 reales, no lista exhaustiva — P10).

Contenido esencial por skill:

- **presentaciones**: audiencia y objetivo antes que láminas; narrativa (qué
  debe pensar/sentir/hacer el público); una idea por lámina; cifras con fuente;
  identidad Innovattia (desde CONTEXTO-EMPRESA); checklist visual y de datos.
  `references/`: estructura narrativa tipo y checklist extendido.
- **analisis-datos**: entender el dato antes de analizar (esquema, calidad,
  huecos); hallazgo = evidencia + magnitud + "y qué"; separar hecho de
  interpretación; gráficas honestas (ejes desde cero salvo razón declarada);
  scripts reproducibles guardados; conclusiones accionables.
- **research**: multi-fuente; verificación cruzada de afirmaciones clave;
  citas con URL y fecha; distinguir consenso/controversia/dato único; resumen
  ejecutivo primero.
- **codigo**: flujo completo (entender → plan → TDD cuando aplica → implementar
  → review → verificación end-to-end real); git disciplinado (commits atómicos,
  mensajes claros); debugging sistemático (reproducir antes de arreglar).
  Higiene anti-contaminación: reutilizar antes de crear; respetar patrones del
  repo; cambios mínimos (nada de refactors no pedidos); cero residuos;
  dependencias justificadas; nada sensible en código ni commits.
- **propuestas**: estructura problema → opciones (2-3) → costos → riesgos →
  recomendación con razones. Protocolo Council (ver 5.3).
- **finanzas**: toda cifra se recalcula (nunca se confía en cifras del prompt
  ni de memoria); supuestos explícitos y listados; escenarios base/optimista/
  pesimista para proyecciones; formato de cifras consistente; doble suma de
  totales.
- **automatizacion**: definir trigger/entrada/salida antes de construir; manejo
  de errores explícito (qué pasa cuando falla); idempotencia; probada en real
  al menos una vez antes de entregar; documentada (cómo correrla, mantenerla y
  apagarla).

### 5.3 Protocolo Council (dentro de skills/propuestas)

- **Disparo**: (a) el usuario dice "council"; (b) decisión cara o irreversible;
  (c) material que sale de la empresa (cliente, grupo directivo).
- **Mecánica**: 3-5 evaluadores independientes de contexto fresco, cada uno con
  un lente distinto (viabilidad técnica, costo/beneficio, riesgos, abogado del
  diablo, y opcionalmente el dominio de la skill relevante). En Claude Code:
  subagentes en paralelo con modelo Opus 4.8; veredicto sintetizado en el hilo
  principal. En claude.ai web: evaluación secuencial por lentes en la misma
  conversación.
- **Mandato acotado (P8)**: reportar solo hallazgos que cambien la corrección o
  la decisión, cada uno con evidencia concreta; "sin hallazgos relevantes" es
  una salida válida y esperada; prohibido rellenar por cumplir.
- **Veredicto**: aprobada / aprobada con cambios (lista) / rechazada (razones),
  más qué evidencia falta si el council no pudo decidir.
- El council consulta `DECISIONES.md` del proyecto antes de opinar para no
  reabrir lo ya decidido.

### 5.4 Contexto de empresa (`contexto/CONTEXTO-EMPRESA.md`)

Plantilla con secciones: qué hace Innovattia (y su relación con Ordenaris);
clientes y audiencias tipo; tono y marca (referencia a recursos/marca si
existen); glosario de términos internos; qué es confidencial y NUNCA sale en
ejemplos, commits o servicios externos; perfil del usuario (rol, para qué usa
Claude). Se instala en `~/.claude/contexto/` y el núcleo lo referencia. José
llena la versión Innovattia; cada colega ajusta su perfil.

### 5.5 Guía humana (`COMO-PEDIR.md`)

- Anatomía de una buena petición: objetivo + contexto + audiencia + formato +
  criterio de éxito (+ fecha límite si existe).
- Qué adjuntar: archivos, ejemplos de lo que te gusta, el "no quiero que…".
- Palabras clave del sistema: "council" (evaluación adversarial), "rápido"
  (salta protocolo), "borrador" vs "final", "hazlo directo" (salta evaluación
  crítica).
- Frases de aliento que funcionan (P9): "tómate tu tiempo y hazlo a fondo",
  "la calidad importa más que la velocidad", "no saltes pasos de verificación".
- Una plantilla de petición por dominio (7 plantillas cortas).
- Errores comunes: pedir "algo bonito" sin audiencia; no dar criterio de éxito;
  corregir a mano en vez de decirle a Claude qué regla cambiar (el kit aprende
  — ver ciclo de mejora).

### 5.6 Instructivo (`INSTRUCTIVO.md`)

Mapa del kit pieza por pieza: qué es, dónde se instala, cuándo actúa, cómo
saber que está funcionando (p.ej. "si Claude no pregunta audiencia antes de un
deck, el núcleo no está instalado"). Incluye sección para usuarios de claude.ai
web: pegar el núcleo como instrucciones de proyecto y usar los playbooks como
documentos del proyecto.

### 5.7 Hooks (`hooks/`)

README que explica P3 (regla dura → hook) con el catálogo de eventos, y un
ejemplo instalable opcional: `anti-secretos` — PreToolUse sobre Bash que
bloquea `git commit`/`git push` si el diff staged contiene patrones de
credenciales (claves API, tokens, cadenas de conexión). Los hooks son
opt-in: `instalar.sh` pregunta antes de activarlos.

### 5.8 Instalador (`instalar.sh`)

1. Copia `nucleo/CLAUDE.md` a `~/.claude/CLAUDE.md`; si ya existe uno, NO lo
   pisa: añade el contenido bajo un marcador `<!-- kit-innovattia vX.Y -->` (y
   si el marcador ya existe, reemplaza solo esa sección → actualizaciones
   limpias).
2. Copia (no symlink, para que sobreviva a borrar el clone) cada skill a
   `~/.claude/skills/`.
3. Copia la plantilla de contexto a `~/.claude/contexto/` solo si no existe.
4. Pregunta si instalar hooks opcionales.
5. Imprime un resumen de qué instaló y cómo verificarlo.
   README documenta el equivalente manual (copiar 3 carpetas) para quien no
   usa terminal.

### 5.9 Presentación (`presentacion/`)

Deck (pptx, plantilla/marca Innovattia si hay recursos) para presentar el kit:
el problema (los 5 dolores), la solución (arquitectura en 1 lámina), qué hace
cada pieza, demo de flujo (petición → protocolo → entregable verificado),
cómo instalarlo, cómo mejora con el uso. 10-14 láminas.

### 5.10 Ciclo de mejora

- `CHANGELOG.md` con versiones semánticas simples (v1.0, v1.1…).
- Regla operativa (vive en el núcleo, 1 línea): si el usuario corrige dos veces
  lo mismo, Claude propone convertirlo en regla del kit.
- Al cambiar el kit: correr la prueba de poda (P1), el chequeo de contradicciones
  (P7) y verificar límites (núcleo < 150 líneas, descriptions < 1024 chars,
  SKILL.md < 5.000 palabras).

## 6. Criterios de aceptación (v1.0)

1. Núcleo < 150 líneas y pasa la prueba de poda línea a línea.
2. Las 7 skills disparan con frases gatillo naturales en español (prueba: 3
   peticiones tipo por dominio, la skill correcta se activa).
3. Council de prueba sobre una propuesta con un fallo plantado: lo detecta; y
   sobre una propuesta sólida: responde "sin hallazgos relevantes" (no inventa).
4. `instalar.sh` en un HOME limpio instala todo; en un HOME con CLAUDE.md
   existente no pisa nada y las actualizaciones reemplazan solo su sección.
5. Cero contradicciones detectadas entre núcleo, skills y el CLAUDE.md de
   ~/Trabajo de José (chequeo cruzado).
6. INSTRUCTIVO y COMO-PEDIR legibles por un colega no técnico (sin jerga sin
   explicar).
7. Deck de presentación completo y con marca.
8. El propio kit pasa un council antes de marcarse v1.0 (dogfooding).

## 7. Fuera de alcance v1

- Plugin con marketplace propio (la estructura queda lista; es la v2).
- Despliegue corporativo vía `managed-settings.json`/política de máquina
  (documentado en INSTRUCTIVO como opción futura para IT).
- Hooks avanzados (formateo automático, validaciones por proyecto).
- Sincronización automática de actualizaciones del kit.

## 8. Riesgos y mitigaciones

- **Bloat progresivo** (el kit engorda con cada mejora hasta que Claude lo
  ignora) → límites cuantitativos en criterios de aceptación + prueba de poda
  en el ciclo de mejora.
- **Skills que no disparan** → descriptions con frases gatillo probadas (C.A. 2).
- **Council teatral** (encuentra fallos inventados) → mandato acotado P8 +
  prueba de control con propuesta sólida (C.A. 3).
- **Conflicto con configuraciones personales** → instalador no destructivo +
  chequeo de contradicciones.
- **Colegas en claude.ai web** → sección de degradación en INSTRUCTIVO.
