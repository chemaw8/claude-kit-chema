# Decisiones — claude-kit-chema

Decisiones cerradas del kit, con sus razones y lo que se descartó. Consúltalo antes
de reabrir una discusión: si algo está aquí y no hay evidencia nueva, ya se decidió.

## 2026-08-29 · Congelar el kit: no se le agrega nada por ahora

Tras una sesión larga de mejoras y dos barridos de vanguardia (13 agentes cada uno),
**cinco propuestas razonables se midieron y las cinco se descartaron con datos**. El
kit queda congelado: se usa, no se le agrega.

| Propuesta | Medición que la descartó |
|---|---|
| Podar el campo de skills | Banco de disparo **27/27** (7/7 en fronteras) con las **70 skills reales** compitiendo, mejor que el 20/21 original con 7. El campo grande no confunde al router |
| Que el kit "no se usa" | **119 invocaciones** de skills `kit-*` en 60 días = **51%** de todas las invocaciones. kit-research 46, kit-codigo 19, kit-redaccion 13 |
| Hook `PreCompact` | La compactación ocurre en **8 de 1,145 sesiones** (0.7%). La defensa existente (ficha que se recarga + CONTINUAR + reconciliar) funcionó de hecho en la sesión que compactó |
| Regla para usar más el vault | **19 de 23** proyectos del vault también están en la memoria auto-cargada (83% de solape). El uso bajo de `vault-buscar` es correcto, no un fallo |
| Cuarto subagente / más especializados | `verificador` lleva **0 usos** en 60 días — y es correcto: el núcleo dice verificar inline cuando el material ya está en contexto |

**Alternativa descartada:** seguir agregando capas (hooks nuevos, MCP de métricas,
headless en CI, perfiles de permisos). Todas evaluadas contra evidencia externa; el
retorno marginal no justifica el costo, y ~28% del presupuesto de la semana previa
ya se había ido en construir el entorno en vez de usarlo.

**Lo único que queda anotado como pendiente, no como trabajo:** usar `lector-fresco`
antes de que un entregable salga a dirección o a un cliente (1 uso en 60 días), y la
regla de declarar el modelo explícitamente en cada etapa de un workflow.

**Cuándo revisar esta decisión:** si el reporte semanal de salud muestra un fallo
recurrente y concreto que ninguna pieza actual atrapa. Sin eso, la respuesta a
"¿qué le agrego?" es: nada.

## 2026-08-29 · El sandbox de Bash NO forma parte del kit

Se probó un día en la máquina de José y **se revirtió**: rompía `git push` (el token
de `gh` vive en el llavero del sistema, inalcanzable dentro del sandbox), `git add -A`
fallaba por los artefactos `/dev/null` que monta sobre rutas protegidas, y con
`strictAllowlist` cada herramienta nueva fallaba como error de red.

**Decisión:** el sandbox es configuración **personal del entorno**, nunca del kit
distribuible. El kit no lo trae ni lo traerá por defecto.

**Razón de fondo:** el hueco que decía cubrir ya está cerrado donde importa — los 5
proyectos con material NDA deniegan WebFetch/WebSearch/scrapling desde su propia
ficha. Beneficio no medido contra costo medido.

**Configuración probada, por si el contexto cambia** (corridas desatendidas en
máquina ajena): documentada en
`~/Trabajo/investigacion/2026-08-28-vanguardia-para-ultracode.md`.

## 2026-08-28 · La cifra del sobrecosto de repartir es ~4×, no 15×

El ~15× que se cita mide un sistema multi-agente contra una **conversación sin
herramientas**. Un hilo agéntico ya gasta ~4× de esa base, así que el sobrecosto real
de repartir frente a resolverlo en un hilo es del orden de **4×**.

**Por qué importa:** inflada a 15× sesgaba en contra de repartir, justo dentro de la
skill que enseña a repartir bien. Tres de cuatro evaluadores del council lo cazaron
por separado. Corregido en `kit-orquestacion`.

## 2026-08-26 · Ola 3 de fichas: bajo demanda, nunca en lote

Los ~18 proyectos sin ficha se atienden con `/proyecto-init` **al reentrar a cada
uno**, no fabricando fichas de golpe.

**Razón:** varios están dormidos o cerrados. Una ficha hecha en frío para un proyecto
que no se toca en meses nace vieja — es fabricar el mismo desfase que el sistema de
fichas existe para evitar. El comando verifica comandos corriéndolos, y eso exige
tener el proyecto fresco en las manos.

## 2026-08-31 — El estándar de estructura de proyectos entra en dos etapas (council)

**Qué:** entra a kit-codigo el estándar de estructura de proyecto
(`estandar-proyectos.md` + `plantillas/` + regla de escalado en el cuerpo +
mención en /proyecto-init). Las líneas de núcleo NO entran todavía: esperan la
evidencia del piloto (proyecto sql-natural) más una sonda conductual de 6-8
sesiones frescas con casos positivo, negativo y de umbral.

**Por qué:** council de 5 (2026-08-31, veredicto aprobada con cambios). El
matiz al congelamiento del 2026-08-29: esa decisión condiciona reabrir el kit a
que "el reporte semanal de salud muestre un fallo recurrente", pero el panel
verificó que esta clase de fallo (re-deducción de alcance en features
multi-sesión) es estructuralmente invisible a ese reporte — mide errores de
tool, no calidad de estructura. Para esta clase, la evidencia aceptada es un
piloto medido, no el reporte. El criterio de "mejoras medidas o nada" queda
intacto: por eso el núcleo espera al piloto.

**Descartado:** PR único con núcleo adentro (entraría sin sonda conductual), y
esperar todo al piloto (dejaba a los colegas sin las plantillas sin ganancia
de control).

## 2026-09-08 — v1.19.2: qué modelo lleva cada agente, decidido con medición

**Decidido.** (a) La regla "esfuerzo antes que modelo" entra al núcleo enunciada **por
dirección y no por cifras**, con una excepción: dentro del alcance de Fable 5.1 (síntesis y
juicio crítico), si manda la latencia y no el costo, se salta de modelo. (b) `lector-fresco`
**sigue en Opus 5**. (c) El agente nuevo `sintetizador` **se queda en Fable 5.1 por latencia,
no por calidad**, y su ficha declara la condición que lo bajaría de escalón. (d) La síntesis
del council la hace ese agente, no el hilo principal.

**Por qué:** medición propia antes de fusionar (`docs/pruebas/medicion-esfuerzo-v1.19.2.md`),
que cierra el aviso del council de v1.19.2 —faltaba evidencia de que Opus 5 a `--effort max`
se quede corto—. En la única comparación limpia que enfrenta los dos escalones (n = 2, los
tres brazos con el mismo núcleo), subir el esfuerzo es **16 % más barato y 2.3 veces más
lento** que saltar de modelo. De ahí las cuatro decisiones: el orden de la regla se sostiene
por costo, la excepción de latencia era necesaria y no estaba, y ninguna medición cubre
calidad en síntesis, así que el `sintetizador` no puede justificarse por calidad.

**Descartado:** afirmar cifras en el núcleo (el brazo de Fable quedó partido por un cambio de
versión a mitad de la corrida: la magnitud varía entre lecturas, la dirección no); mover
`sintetizador` a Opus 5 (dejaría el escalón Fable sin ningún agente, que era el hueco que el
council quiso llenar); y medir síntesis antes de fusionar (pide un caso dorado nuevo y firma
del mantenedor; queda pendiente y es lo que bajaría al agente de escalón).

## 2026-09-22 — Regla de núcleo: los resultados reportados salen de la salida de la herramienta (PR #47)

**Decidido.** Entra al núcleo, sección «Terminado significa verificado», una regla operativa:
toda tabla o lista de resultados toma sus valores de la salida que los produjo, sin volcarla
entera; lo que no se pueda comprobar tras intentarlo va como "sin comprobar", nunca de memoria.
Núcleo 133 → 136 líneas; el margen (14) la absorbe.

**Por qué al núcleo y no a una skill.** El fallo es transversal a los siete dominios y ocurrió
*con* la regla general ("cifras recalculadas… un listo falso cuesta más") ya instalada: en el
advisor, 59 de 76 hard_blockers (78 %) y 91 de 182 concerns del 2026-09-06 al 09-22 casan por
palabra clave con "afirma X y la salida no lo respalda". **Es coincidencia por palabras clave,
no errores confirmados uno a uno** (objeción de Codex, heredada); los ejemplos concretos
(pid 902125 vs 902135; tabla de 9 corridas contra 7 listadas) bastan para una adición de tres
líneas reversible por PR.

**Council** (Anthropic Opus 5, OpenAI Astra, Kimi K3; ciegos entre sí): 3 × *aprobada con
cambios*. Cambios aplicados: (1) "copia de la salida literal" era ambiguo con «Presupuesto de
contexto» y con "nunca un volcado" → "toma sus valores… sin volcarla entera" (los tres);
(2) ejemplos solo de código → se antepone "cifras" (Anthropic); (3) "sin comprobar" podía ser
muletilla que vacía la regla → "lo que no puedas comprobar **tras intentarlo**" (Kimi).
Descartado: definir "a la vista" (Anthropic lo dejó como menor; el default conservador ya es el
correcto).

**Cómo se sabrá si sirvió.** El advisor sigue midiendo; si la proporción de hard_blockers de este
patrón no baja en 30 días, la regla describe el error pero no lo cambia, y se retira (Anthropic
advirtió que previene fabricación, no mala lectura: separar los dos modos al medir).

**Estado del PR:** gate de disparo corrido el 2026-09-22 (21/21, 0 confusiones, rc=0; ver
`docs/pruebas/disparo-descriptions.md`). Sale de borrador con CHANGELOG y CODEOWNERS; nada de
eso reabre la decisión.

**Corrección (2026-09-24), antes de fusionar:** la evidencia de arriba estaba inflada. El «78 %» contaba
alertas del advisor por palabra clave; juzgadas contra el turno real, 3 de 24 acertaban, y el ejemplo
«subido 228c8c6..d2ae0b5» es falso positivo (el push sí está en el turno). Casos que sí sostienen la regla:
una tabla con el estado de un repo que ningún comando consultó, cifras sin respaldo en el turno, y un
«probado a 5 anchos» cuando se probaron 2. José aprobó el PR con esta evidencia (2026-09-24); ver CHANGELOG v1.22.

## 2026-09-25 — El hook de contexto y /init-contexto siguen a CLAUDE_CONFIG_DIR (PR en borrador)

**Decidido.** `hooks/kit-chema-contexto.sh` y `/init-contexto` usan
`${CLAUDE_CONFIG_DIR:-$HOME/.claude}/contexto/`; con `CLAUDE_CONFIG_DIR` definido **no hay caída a
`~/.claude`**. `kit-presentaciones` y `kit-redaccion` dejan de nombrar la ruta fija, y `plugin.json`
sube de 1.15.0 a 1.22.1.

**Por qué.** Reproducción real: en una máquina con dos perfiles de Claude Code de ámbitos distintos, la
sesión del perfil lanzado con `CLAUDE_CONFIG_DIR` recibió en `SessionStart`, al instalarle el plugin, los
tres archivos de contexto del otro perfil. La prueba nueva (`hooks/test-kit-chema-contexto.sh`, 7 casos)
da TODO OK con el hook nuevo y 4 fallas con el de `main`. No reabre el congelamiento del 2026-08-29:
arregla una pieza que ya existe y falla, con reproducción y prueba de regresión, como v1.19.4 y v1.21.

**Por qué sin caída.** El hook no distingue un perfil reubicado de un segundo perfil. En el caso reportado
el perfil afectado no tiene `contexto/`, así que caer a `~/.claude` repetiría la fuga; quien pierda la
autocarga cae en el «pregunta lo mínimo» del núcleo.

**Por qué el plugin a 1.22.1.** Con `"version"` fijo en el manifiesto, `claude plugin update` deja a cada
usuario en su copia en caché por más commits que haya (docs de Claude Code, «Versions and updates»). El
manifiesto no se movía desde v1.15, así que quien actualice recibe de una vez todo v1.16–v1.22.1.

**Council** (4 evaluadores Opus, ciegos entre sí: viabilidad técnica, riesgos, costo/beneficio y
gobernanza, abogado del diablo; síntesis en el hilo principal porque el subagente `sintetizador` no estaba
registrado en la sesión): 4 × *aprobada con cambios*. Aplicados: (1) subir la versión del plugin
(costo/beneficio, abogado del diablo); (2) quitar la ruta fija de dos cuerpos de skill (riesgos); (3) acotar
INSTRUCTIVO y hooks/README a lo que hace el hook (abogado del diablo); (4) no anunciarlo como fuga cerrada:
cierra la inyección automática (los cuatro); (5) nota de migración en el CHANGELOG (riesgos,
costo/beneficio). Descartados: un `systemMessage` cuando el perfil no tiene `contexto/` y `~/.claude` sí
(deseable, no condición, y sería capacidad nueva bajo congelamiento); un chequeo en `verificar.sh` que
obligue a subir la versión del plugin (decisión del dueño, aparte).

**Queda abierto, a propósito.**
- La línea 7 del núcleo sigue diciendo «El hook de sesión ya cargó `~/.claude/contexto/`… léelo tú». En un
  perfil sin `contexto/` todavía manda al modelo a la carpeta de otro perfil. Va en un PR aparte con gate
  de disparo (GOBERNANZA §4), que además decida el default para quien usa `CLAUDE_CONFIG_DIR` con el
  contexto en `~/.claude`.
- Instalación sin plugin: `instalar.sh` usa `CLAUDE_DIR` y `hooks/settings-fragment.json` fija
  `$HOME/.claude/hooks/...`. Viene de antes y este cambio no lo empeora.
- Fuera del kit: Claude Code carga el `.claude/CLAUDE.md` de las carpetas superiores al directorio de
  trabajo, así que un perfil que vive en `~/.claude` llega como instrucciones de proyecto a toda sesión
  bajo `$HOME`. Eso se resuelve en cada máquina.

**Cuándo revisar.** Si alguien reporta haber perdido su contexto al definir `CLAUDE_CONFIG_DIR`.
