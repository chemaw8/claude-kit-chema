# Investigación: pstack y el mercado de skills (2026-09-30)

Insumo de la ronda «pstack» (rama `pstack/ronda-1`). Fuentes abiertas el 2026-09-30:
repo oficial `cursor/plugins/pstack` (commit fae2c6e, 2026-09-29, licencia MIT © Lauren Tan),
port `michael-denyer/pstack-claude` (MIT), flaviocopes.com/pstack (act. 2026-09-29), video
youtube.com/watch?v=lUhXa8GiXns (transcripción; solo audio, lo que se ve en pantalla no se revisó),
devopstales.github.io/ai/three-skill-philosophies-compared, samuellawrentz.com/blog/reading-the-best-claude-skills.
Estrellas y licencias: API de GitHub, 2026-09-30. Conteos de skills y palabras: clon y `wc`, mismo día.

## 1. pstack frente al kit

pstack es más profundo en una sola cosa: ingeniería de software sobre un repo ya existente
(26,771 palabras en SKILL.md + 15,446 en playbooks; 47 skills, 46 con `disable-model-invocation`).
El kit va adelante en gobierno de cambios (council + A/B + umbral de retiro), gate de push sellado,
control de costo y dominios no-código. Carga por tarea estimada en bug fix: ~8,500 palabras contra
~2,600 del kit (estimación sobre archivos, no medida en corrida). `poteto-mode` suma ~235 oraciones
imperativas activas y persistentes entre turnos: el riesgo es número de instrucciones, no longitud.

Candidatos a adaptar: (1) verificación por proyecto (`create-verification-skill`), (2) `unslop` como
script, (3) clasificación de hallazgos del lead en `interrogate`, (4) `why`/`recall` con sesiones,
(5) `arena`, (6) bitácora de decisiones auditada, (7) «si la duda se resuelve corriendo algo, córrelo»,
(8) reglas de cegado de su playbook `eval`. No adaptar: «never block on the human» por defecto,
«no planning», «redesign from first principles» como licencia de refactor, playbooks de GitHub/Graphite.

## 2. Mercado (API de GitHub, 2026-09-30)

| Repo | ★ | Skills | Palabras | Rasgo | Licencia |
|---|---|---|---|---|---|
| obra/superpowers | 293k | 15 | 26k | flujo autónomo diseño→worktree→TDD→revisión | MIT |
| mattpocock/skills | 273k | 37 | 26k | piezas chicas; interroga requisitos | MIT |
| affaan-m/ECC | 270k | 1,027 | 993k | catálogo | MIT |
| garrytan/gstack | 135k | 63 | 351k | equipo por roles; skills de 11–18 mil palabras | MIT |
| addyosmani/agent-skills | 100k | 25 | 52k | evals en 3 niveles, choque de descriptions en CI, casos de presión | MIT |
| anthropics/knowledge-work-plugins | 26k | 252 | 312k | dominios de negocio (finanzas, datos, ventas, legal, pymes) | Apache-2.0 |
| EveryInc/compound-engineering-plugin | 25k | 43 | 40k | ciclo que cierra en «captura lo aprendido» | MIT |

Ninguno de los revisados combina varios dominios en español con cambios medidos y gobernados.
Por pieza, varios son más profundos. Comparación medida de terceros (devopstales, una feature):
dos enrutadores activos a la vez chocan; elegir uno como primario.

## 3. Medición de la pieza (2): revisor de señales de IA en español

**Primera versión (lista léxica traducida de `unslop`):** 0 hallazgos sin raya en 17,416 palabras de 11
entregables reales. Se descartó el enfoque, no el problema.

**Fuentes para la segunda versión** (abiertas el 2026-09-30; los buscadores web bloquearon la red, se fue
directo a las fuentes): Wikipedia:Signs_of_AI_writing (en), Wikipédia:Sinais_de_texto_gerado_por_inteligência_artificial
(pt), y la norma de la raya de la Ortografía RAE 2010 citada en es.wikipedia «Raya (puntuación)» (rae.es
bloqueó con Cloudflare). Tres ideas que cambian el diseño:
- Una palabra suelta no delata nada; delata la **densidad** (pt: «essas expressões não devem ser proibidas
  nem removidas automaticamente»). Humanos detectan texto de IA al nivel del azar (en, estudio 2025).
- La raya de IA **va con espacio a ambos lados**, contra la tipografía (en, WP:AIDASH). En español la norma
  es el inciso pegado: «texto —inciso— texto» (RAE 2010). Eso separa la raya buena de la mala.
- El repertorio léxico envejece: la sección de rayas de en.wikipedia ya se marca como posible indicador
  histórico (septiembre de 2026) porque los modelos nuevos las suprimen.

**Diseño:** 11 señales fuertes (se marcan siempre) y 5 de densidad (por 1,000 palabras, con umbral).

**Calibración** (corpus: 5 artículos de es.wikipedia en su revisión de junio de 2021, antes de ChatGPT, 9,763
palabras; 5 textos de negocio de Sonnet sin el kit, 2,702 palabras; los 11 entregables reales):

| Corpus | Señales fuertes | Viñetas «**Tema:** texto» (umbral 6) | Rayas (umbral 5) |
|---|---|---|---|
| Humano 2021 | 0 en 5 docs | 0 en los 5 | 0–2 |
| IA sin kit | 2 en 5 docs | 4 de 5 sobre umbral (14–27) | 0 en los 5 |
| Entregables reales | 11 de 11 con raya espaciada | 1 de 11 sobre umbral (16) | 9 de 11 sobre umbral (hasta 17.4) |

**Lectura.** Cero falsos positivos en el corpus humano. En 2026 el vocabulario de IA (D1) no aparece en
ningún corpus: el slop actual es de **forma**, no de palabras. Las dos señales que sí separan son las
viñetas con encabezado en negritas y dos puntos y la raya al estilo inglés. Corrección del mismo día: la primera
versión de D4 contaba cualquier viñeta que abriera en negritas y daba 8 de 11 entregables; la señal de las fuentes
es la negrita con dos puntos (la negrita que abre una oración con punto y dato nuevo no lo es, `unslop` regla 16).
Con la regla corregida, los entregables quedan en 1 de 11; el corpus humano y el de IA no cambian. La raya no la trae el modelo base (Sonnet
sin kit: cero); aparece en los entregables hechos con el kit. El título con mayúsculas a la inglesa (F11)
da falsos positivos en resúmenes de contratos, donde los términos definidos van con mayúscula: precisión baja,
queda como candidato. Pendiente: medir si corregir estas señales mejora cómo lee el texto la audiencia; no
hay dato de eso.

## 4. Piloto de la pieza (1): verificación por proyecto

**Censo previo** (fichas de los proyectos locales, búsqueda por palabras y lectura de los dudosos): los proyectos
que generan entregables (reportes, PDF, Excel) ya declaran cómo verificar el entregable real, gracias al estándar de
fichas del kit. El hueco está en las apps con interfaz o servicio, donde la ficha dice solo «pruebas» y «levantar».

**Piloto:** una app web interna (Next.js + Postgres) de ese segundo tipo, en un clon aislado (BD propia, sin
credenciales de producción, sin API de IA). Se construyó a la manera de `create-verification-skill`: un mapa
(`docs/verificacion/`: arrancar, chequeo previo, recorrer, evidencia, limpieza, mapa de funciones) y un script que
recorre la app como usuario por HTTP, guarda evidencia fuera del repo, coteja el xlsx exportado contra la BD y se
niega a correr si la BD no es local.

**Lo que encontró al construirlo:** con npm 11 `npm ci` ya no genera el cliente de Prisma y 5 archivos de pruebas
fallan (la ficha no lo decía), y el script mismo tenía un error que fallaba abierto al consultar otra BD (corregido
a fallar cerrado).

**Mutaciones** (dos defectos metidos a propósito):

| Defecto | Suite de pruebas | Script de verificación |
|---|---|---|
| El export infla el precio 27.51 % | lo detecta | lo detecta |
| La ruta de matching nunca pasa el proyecto a «revisión» | **72/72 en verde** | lo detecta (salida 1) |

**Sonda con agentes nuevos** (Opus 5.5, 6 clones, mismo defecto de la ruta, mismo encargo redactado como reporte
de usuario; grupo B con el mapa y el script en el repo como si fueran nativos; cegado según el playbook `eval` de
pstack). Calificado por efectos en disco y por lo que afirma cada reporte: las transcripciones de los subagentes no
se guardan aparte, así que no se pudieron auditar paso por paso.

| | A: ficha actual (3) | B: con mapa (3) |
|---|---|---|
| Arreglo correcto | 3/3 | 3/3 |
| Prueba de regresión nueva | 3/3 | 2/3 |
| Recorrió la app real con evidencia en disco | **0/3** | **3/3** |
| Dijo con claridad que faltaba desplegar | 3/3 | 3/3 |

**Lectura.** El mapa cambia la conducta (0/3 → 3/3 en recorrer la app de verdad), con n=3 y una sola tarea:
evidencia provisional. Para este defecto, la prueba de ruta que escribió el grupo A ya bastaba para probar el
arreglo; el recorrido suma la prueba de punta a punta (liga del revisor y export). Riesgo observado: un agente del
grupo B usó el recorrido **en vez de** la prueba de regresión. Si la pieza entra al kit, el mapa debe decir que el
recorrido no sustituye la prueba que deja el bug cerrado.
