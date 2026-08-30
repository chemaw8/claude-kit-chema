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
