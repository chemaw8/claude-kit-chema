# Council v1.33 (borrador) — «buscar lo que ya se hizo antes de dar un dato por inexistente» (2026-10-09)

**Estado (2026-10-09): re-medición cumplida (5 de 5 condiciones); listo para que el dueño fusione.** Historia: La v4 del texto no cumplió su prerregistro; el dueño abrió el PR como excepción
para que el council pesara beneficio contra falla. El council aprobó con cambios **condicionado a re-medir** el texto
definitivo (el de este PR). Los casos de medición son privados (repo `evals-entregables`); aquí van sin cifras de negocio.

## De dónde sale
Un reporte mensual interno para dirección se rehízo con un archivo nuevo de un canal que traía solo mayo–septiembre. El
agente dio enero–abril por inexistentes: existían, dibujados como imagen (sin cifras) en una gráfica de un PDF viejo en
Descargas, que el agente había listado sin abrir. Se recuperaron solo porque el dueño se acordó. El reporte del mes
anterior ya había perdido ese canal sin que nadie lo notara. El dueño pidió: «que el propio agente pueda buscar si hubo
datos, ya sea PDF, CSV, Excel, bases de datos o cualquier otra cosa que se haya hecho en anterior ocasión».

## Medición (cinco intentos, todos prerregistrados)
1. Texto v1, instrumento textual: 3/6 contra 3/6. El instrumento no veía el fallo (nada que buscar).
2. Instrumento nuevo `archivos` (carpeta + Bash aislado; al construirlo se cerró una fuga del aislamiento): 0/6 → 2/6.
3. v2: trampa 0/6 → 4/6, pero sobrecorrige un control (lo declarado «único» tratado como pérdida, 2/3 → 0/3).
4. v3 (+ excepción): no entra; la tumbaron una rúbrica del proponente y autocontradicciones del juez Sonnet.
5. v4, objetivo redefinido por el dueño (buscar, no solo usar), casas simuladas con ruido, rúbricas y texto firmados
   por el dueño antes de correr, juez Opus calibrado 15/15:

| Caso | Sin regla | Con v4 | ¿Cumple? |
|---|---|---|---|
| Datos solo en una gráfica sin cifras dentro de un PDF viejo en Descargas | 0/6 | 5/6 | sí |
| Datos en una base SQLite de otra carpeta de trabajo | 1/6 | 6/6 | sí |
| Señuelo: el dato no existe; gráfica de otra métrica | 3/3 | 3/3 | sí |
| Sección temporal retirada según lo previsto | 3/3 | 3/3 | sí |
| Lámina declarada única | 3/3 | 2/3 (reincorpora una fila en 1 de 3) | **no** |

## Council (2026-10-09)
Tres familias en paralelo, sin verse: Anthropic Opus 5.5 (eficacia y costo/beneficio), OpenAI Astra (riesgos y abogado
del diablo), Kimi K3 (gobernanza y medición). Síntesis: agente `sintetizador` (Fable 5.1).
**Veredicto: aprobada con cambios** (3 × aprobada con cambios; Kimi pasa a rechazada si no se re-mide).

Postura inicial del hilo principal, antes de leer al panel: «aprobar con cambios; beneficio grande y consistente; me
preocupan la sobrecorrección del control y que los casos los escribió el proponente; vigilancia con umbral de retiro».
**Qué cambió:** se endureció. La postura inicial no exigía re-medir; el panel mostró que los cambios de texto invalidan
la v4 y que aprobar sin medir repetiría el precedente que el prerregistro prohíbe. Se agregó el frente de
confidencialidad y alcance, que la postura inicial no contemplaba.

| # | Hallazgo | Quién | Clase |
|---|---|---|---|
| 1 | El texto empujaba a reincorporar («insumo», «es un hallazgo»): solo completar lo faltante; lo perdido se reporta y se pregunta | las tres | actuar (aplicado) |
| 2 | Alcance: de cerca a lejos y parar al encontrar; solo lectura; Descargas filtrada al proyecto; buscar ≠ cargar; mismo entregable o su familia; nunca otro cliente ni carpetas personales | las tres | actuar (aplicado) |
| 3 | «Lo que de verdad no existe» → «no localizado en las fuentes revisadas», con cuáles | Astra | actuar (aplicado) |
| 4 | La excepción solo vale como cumplimiento diferido: re-medir el texto definitivo; la v4 queda como ensayo fallido | Kimi, Astra, Opus | actuar (pendiente: condición de fusión) |
| 5 | Reportar tokens y tiempo A vs B | Opus | actuar (en la re-medición) |
| 6 | Caso de «retiro decidido después» | Astra | considerar |
| 7 | Pedir permiso antes de salir del alcance; tope de 10 min | Astra | considerar: contradice el pedido del dueño; el riesgo lo cubre #2 |
| 8 | Piso documentado para futuras excepciones al prerregistro | Kimi | considerar (gobernanza, fuera de este PR) |
| 9 | «n ≤ 3 en controles: un fallo aislado obliga a re-medir» | Opus | considerar (repo de evals) |
| 10 | Validez externa: casos del proponente, productor = juez (Opus), «pasa» de calibración a mano | Opus, Kimi | anotado → vigilancia |

## Condición de fusión
Re-correr el frente completo con el texto de este PR, prerregistrado antes de correr: 2 trampas y 3 controles, n=6 por
brazo. Criterio original intacto: cada trampa B ≥ 4/6 y B − A ≥ 3; cada control B ≥ 4/6 y su criterio de falsas
pérdidas / señuelo B ≥ A. Registrar tokens y tiempo mediano A vs B.

## Vigilancia y retiro (si se fusiona)
Piloto de 90 días con contadores: activaciones, hallazgos útiles, reincorporaciones no pedidas, falsas pérdidas, lecturas
fuera de alcance, tiempo por tarea.
- **Suspensión inmediata:** 1 lectura fuera de las áreas de trabajo del grupo o 1 uso de datos de otro cliente.
- **Retiro (revertir el PR):** ≥ 2 reincorporaciones o falsas pérdidas que el dueño corrija en 30 días, o 1 con impacto
  material.
- **Revisión:** tiempo mediano +30 % sin hallazgos; 90 días sin activación útil; cambio del modelo productor (re-correr).

## Re-medición del texto definitivo (2026-10-09) — condición de fusión cumplida
Prerregistrada antes de correr, n=6 por brazo, criterio original. Brazos A de las trampas: los de la v4 (mismos casos y
skills instaladas). Completa, sin INFRA ni errores del juez.

| Caso | Sin regla | Con v1.33 | ¿Cumple? |
|---|---|---|---|
| Gráfica sin cifras en un PDF viejo de Descargas | 0/6 | 5/6 | sí |
| Base SQLite en otra carpeta de trabajo | 1/6 | 6/6 | sí |
| Señuelo de otra métrica (no usarlo) | 6/6 | 6/6 | sí |
| Lámina declarada única (no ver pérdidas) | 6/6 | 6/6 | sí (la v4 había dado 2/3) |
| Sección temporal retirada | 6/6 | 6/6 | sí |

Costo de buscar (pedido del council): tiempo mediano +21 % a +36 % y costo por corrida +16 % a +29 % solo en los casos
donde faltaba un dato; en los que no, sin cambio. Los tokens no se registraron (el runner no los guarda).
