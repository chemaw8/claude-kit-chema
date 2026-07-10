# Guion del deck — Kit Chema

Documento de trabajo del deck `kit-chema.pptx`. Define, lámina por lámina, el
título, la idea única que defiende y el contenido concreto que la sostiene.

## Marco (kit-presentaciones aplicado a sí mismo)

- **Audiencia:** colegas de Innovattia, niveles técnicos mixtos (desde quien
  programa hasta quien nunca abrió una terminal).
- **Objetivo:** que instalen el kit y lo usen — no solo que entiendan qué es.
- **Narrativa en tres actos:**
  - Situación (láminas 1–2): hoy Claude nos ayuda, pero repite fallos.
  - Complicación (lámina 2): esos fallos cuestan tiempo y confianza.
  - Resolución (láminas 3–12): el kit los ataca, así funciona, así se instala,
    y está respaldado.
- **Regla de títulos:** cada título afirma algo; leídos en fila cuentan el
  argumento completo, sin necesidad del contenido.

## Paleta (extraída del deck 2026-07-grupo-ia)

`~/Trabajo/recursos/marca/` está vacía, así que se reutiliza la paleta del deck
del grupo para mantener consistencia visual con su material:

| Rol | Hex | Uso |
|---|---|---|
| Navy profundo | `0C2A3E` | fondo de portada y cierre, franjas de sección |
| Azul primario | `105687` | títulos sobre claro, elementos dominantes |
| Azul suave | `2E7CB8` | apoyos, iconografía secundaria |
| Ámbar acento | `DD8533` | acento único, numeración, subrayados de énfasis |
| Ámbar suave | `EFA95E` | degradado de marca (con el azul) |
| Base clara | `F5F7F9` | fondo de láminas de contenido |
| Papel | `FFFFFF` | tarjetas |
| Tinta | `1A1D21` | texto principal |
| Gris apagado | `8A99A6` | texto secundario, pies |
| Línea | `DCE4EA` | separadores finos |
| Verde verificado | `1E8A4C` | señales positivas / verificado |
| Rojo alerta | `EC2229` | dolores (uso mínimo) |

Tipografía: Inter (títulos en negrita con tracking cerrado y cuerpo) y
JetBrains Mono (comandos y peticiones de ejemplo). Son las dos fuentes de marca
del deck del grupo; Space Grotesk se sustituye por Inter en negrita porque no
está disponible en el sistema y no todos los colegas la tendrían instalada.

---

## Lámina 1 — Portada

**Título:** Kit Chema: que Claude trabaje bien para todo Innovattia

**Idea:** un estándar de calidad portable, no la configuración personal de una
persona.

**Contenido:**
- Subtítulo: instrucciones de calidad que cualquiera instala y usa, sin depender
  de la configuración de nadie.
- Sello inferior: repositorio `claude-kit-chema` · versión v1.0 · 2026-07-09.
- Fondo navy con el degradado de marca (azul→ámbar) como acento.

---

## Lámina 2 — El problema

**Título:** Hoy Claude repite cinco fallos que nos cuestan tiempo

**Idea:** sin un estándar, cada quien pelea solo los mismos cinco problemas.

**Contenido (los 5 dolores, uno por tarjeta):**
1. Respuestas genéricas — ignora el contexto de la empresa.
2. Supuestos no consultados — asume en vez de preguntar.
3. Inconsistencia entre sesiones — cada conversación repite errores ya
   corregidos.
4. Complacencia — dice "sí" a propuestas débiles en vez de señalar el problema.
5. Código contaminado — duplicados, residuos y estilos mezclados en lo generado.

---

## Lámina 3 — La solución en una lámina

**Título:** El kit lo ataca con cuatro piezas que encajan

**Idea:** una arquitectura simple: lo universal siempre, lo especializado
cuando hace falta, lo no negociable por máquina, y una guía para la persona.

**Contenido (cuatro bloques):**
- **Núcleo** — `CLAUDE.md` de menos de 80 líneas que carga en toda conversación: las
  reglas universales.
- **Playbooks** — 8 skills de dominio que se activan solas cuando la tarea las
  necesita.
- **Hook anti-secretos** — regla determinista (opt-in) que la ejecuta la
  máquina, no la memoria de Claude.
- **Guía humana** — `COMO-PEDIR.md` e `INSTRUCTIVO.md` + contexto de empresa
  editable.

---

## Lámina 4 — Qué pasa en cada conversación

**Título:** En cada tarea: aclara, evalúa, calibra por riesgo y verifica

**Idea:** el núcleo cambia el comportamiento de Claude en cuatro momentos
visibles.

**Contenido (flujo de 4 pasos):**
1. **Arranque** — confirma propósito, audiencia, formato y criterio de éxito
   antes de trabajar (máx. 2-3 preguntas; trivial → responde directo).
2. **Evaluación crítica** — ante tu idea responde qué está bien, qué le preocupa
   y qué haría él, antes de ejecutar. Callar un error es el peor fallo.
3. **Esfuerzo por riesgo** — trivial → directo; entregable estándar → playbook;
   decisión cara o material que sale de la empresa → council.
4. **Terminado = verificado** — nada se declara listo sin comprobarlo; reporta
   lo que falló o quedó fuera.

---

## Lámina 5 — Los ocho playbooks

**Título:** Ocho playbooks: cada dominio con lo que garantiza

**Idea:** la calidad específica de cada tipo de trabajo vive en su skill, que
se carga sola por la descripción de la tarea.

**Contenido (tabla dominio → qué garantiza):**
| Dominio | Qué garantiza |
|---|---|
| Presentaciones | audiencia y objetivo antes del diseño; una idea por lámina; cada cifra con fuente |
| Análisis de datos | revisa la calidad del dato antes de concluir; separa el hecho de la interpretación |
| Research | cada afirmación con fuente y fecha; cruza dos fuentes; marca lo de una sola |
| Código | lee el código antes de escribir; corre con datos reales; higiene anti-contaminación |
| Propuestas | problema, opciones, costos, recomendación y reversión; council con veredicto |
| Finanzas | supuestos aparte; recalcula cada cifra; escenarios, no un número único |
| Redacción | correo con pedido claro; minuta con acuerdos, responsables y fechas; sin invadir deck ni propuesta |
| Automatización | define disparador, entradas y salidas; deja escrito cómo apagarlo |

- Pie: no tienes que nombrarlas; basta describir la tarea.

---

## Lámina 6 — El Council

**Título:** El Council juzga lo que importa, sin inventar problemas

**Idea:** un panel de evaluadores independientes da un veredicto claro y solo
señala lo que de verdad cambia la decisión.

**Contenido:**
- **Cuándo corre:** dices "council"; la decisión es cara o irreversible; o el
  material sale de la empresa.
- **Cómo:** 3–5 evaluadores independientes, contexto fresco, un lente cada uno
  (viabilidad técnica, costo/beneficio, riesgos, abogado del diablo, dominio).
- **Mandato acotado con proporcionalidad:** solo hallazgos con evidencia que
  cambien la decisión, ponderados contra el tamaño y la reversibilidad. "Sin
  hallazgos relevantes" es una salida válida.
- **Veredictos:** aprobada · aprobada con cambios · rechazada.
- **Probado:** detectó un error de cálculo 50× plantado (rechazada) y aprobó una
  propuesta sólida sin inventarle objeciones.

---

## Lámina 7 — Anti-contaminación de código

**Título:** El código no se contamina: seis reglas de higiene

**Idea:** lo que evita que el código generado por IA se vuelva basura
acumulada.

**Contenido (6 reglas):**
1. Reutilizar antes de crear — grep primero, escribir después.
2. Respetar el estilo y naming del repo, aunque no te guste.
3. Nada de refactors no pedidos — lo que convenga cambiar se propone aparte.
4. Cero residuos — sin código muerto, prints de debug ni archivos de prueba.
5. Dependencias justificadas — cada una en una línea y sin duplicar lo que ya hay.
6. Revisar el diff completo antes del commit — lo que no aporta, fuera.

---

## Lámina 8 — Cómo pedir bien

**Título:** Pedir bien es la mitad del resultado

**Idea:** una buena petición responde por adelantado lo que Claude tendría que
adivinar; el kit trae la guía y dos palabras clave que cambian el trabajo.

**Contenido:**
- **Anatomía de una petición** (de `COMO-PEDIR.md`): objetivo, contexto,
  audiencia, formato, criterio de éxito (y fecha límite cuando la haya).
- **Dos palabras estrella:**
  - `council` → fuerza el panel de evaluación con veredicto.
  - `final` → exige el checklist completo del playbook, versión lista para
    entregar.
- Pie: `COMO-PEDIR.md` trae plantillas por dominio para copiar y rellenar.

---

## Lámina 9 — Demo

**Título:** La misma tarea, floja y bien pedida: se nota

**Idea:** el efecto del kit se ve al comparar dos peticiones y sus resultados.

**Contenido (comparación lado a lado):**
- **Petición floja:** "Hazme una presentación bonita sobre IA."
  - Resultado: algo bonito y vacío que tendrás que rehacer.
- **Petición buena:** "Deck para el comité de Ordenaris (no técnicos); objetivo:
  que aprueben un piloto de IA. Contexto: informe adjunto. Formato: 12 láminas
  con marca Innovattia. Está bien si entienden el retorno y los riesgos. Fecha:
  viernes."
  - Resultado: algo que puedes llevar a la reunión.
- Cierre: la diferencia no es el modelo, es cómo pides.

---

## Lámina 10 — Instalación

**Título:** Se instala en tres pasos, sin pisar tu configuración

**Idea:** la barrera de entrada es mínima y no destruye nada de lo tuyo.

**Contenido:**
- **Tres pasos:**
  1. `git clone https://github.com/chemaw8/claude-kit-chema.git claude-kit-chema`
  2. `cd claude-kit-chema`
  3. `./instalar.sh`
- **No pisa nada:** si ya tienes un `~/.claude/CLAUDE.md`, añade una sección
  marcada al final sin tocar lo tuyo; en actualizaciones posteriores respalda
  antes de reescribir su sección.
- **Hooks:** el de contexto se instala por defecto; el anti-secretos es opt-in con `KIT_HOOKS=s ./instalar.sh`.
- **claude.ai web también:** pega el núcleo como instrucciones del proyecto y
  sube los `SKILL.md` que uses (versión degradada, mismo criterio).

---

## Lámina 11 — El kit aprende

**Título:** El kit aprende: una corrección repetida se vuelve regla

**Idea:** no es estático; mejora con el uso y todos se benefician.

**Contenido:**
- Si corriges dos veces lo mismo (un tono, un formato, una cifra que calcula
  mal), esa corrección se propone como regla permanente del kit.
- Queda registrada en el `CHANGELOG` del repo, con fecha.
- Traer la última versión: `git pull && ./instalar.sh` (no destructivo; respeta
  tu `CLAUDE.md` y tu contexto de empresa).
- Dejas de pelear con el mismo error para siempre.

---

## Lámina 12 — Respaldo

**Título:** No es opinión: está probado y respaldado

**Idea:** el criterio del kit se sostiene en verificación real, no en
intuición; instálalo con confianza.

**Contenido (tres pruebas + cierre):**
- **Investigación verificada:** 25 de 25 afirmaciones confirmadas contra fuentes
  primarias de Anthropic (24 unánimes, 1 por mayoría), 0 refutadas.
- **Prueba de disparo:** 20 de 21 peticiones naturales activaron la skill
  correcta (criterio ≥ 19/21, cumplido).
- **Council probado:** cazó un error de 50× plantado y aprobó una propuesta
  sólida sin inventar objeciones.
- Cierre: instálalo hoy — `git clone` + `./instalar.sh`.
