# Banco canónico — prueba de disparo

Este es el banco de referencia del gate de disparo: peticiones tipo, redactadas
como las diría un colega no técnico y sin nombrar la skill, con la skill que
debería cargar cada una. Cómo se corre está en `docs/pruebas/RUNBOOK.md`.

Dos bloques:

- **Núcleo (1-21)** — 3 peticiones por dominio de las 7 skills originales; miden
  el acierto proporcional (criterio ≥ 19/21).
- **Fronteras (22-27)** — peticiones adversarias sobre los bordes vecinos donde
  el juez tiende a dudar; miden que no haya confusiones nuevas.

La columna "frontera?" marca las peticiones que viven en un borde ambiguo entre
dos skills; el criterio de cero-confusiones se evalúa sobre ellas.

| # | petición | skill esperada | frontera? |
|---|---|---|---|
| 1 | Necesito mostrarle a los de Ordenaris cómo vamos con el proyecto del trimestre | kit-presentaciones | no |
| 2 | Ayúdame a armar unas láminas para la junta del viernes con el cliente | kit-presentaciones | no |
| 3 | Tengo que presentar los resultados del año a dirección, ¿me ayudas? | kit-presentaciones | no |
| 4 | Aquí está el Excel de ventas de las tiendas, dime qué está pasando | kit-analisis-datos | no |
| 5 | ¿Por qué bajaron las ventas en junio? Te paso el CSV | kit-analisis-datos | no |
| 6 | Hazme un dashboard con las métricas de este archivo | kit-analisis-datos | no |
| 7 | Investiga qué sistemas de punto de venta usan las cadenas de retail en México | kit-research | no |
| 8 | ¿Qué hay sobre la nueva norma de facturación electrónica? Necesito entenderla | kit-research | no |
| 9 | Compárame opciones de proveedores de hosting para el proyecto | kit-research | no |
| 10 | Haz un script que renombre todas las fotos de la carpeta con su fecha | kit-codigo | sí (código↔automatización, benigna) |
| 11 | El sistema tira un error cuando subo el archivo, arréglalo | kit-codigo | no |
| 12 | Crea el proyecto base para la API de inventarios | kit-codigo | no |
| 13 | ¿Te parece buena idea migrar todo a la nube este año? Dame tu opinión seria | kit-propuestas | no |
| 14 | Escríbeme la propuesta para el cliente de la app de pedidos | kit-propuestas | no |
| 15 | Estoy pensando en contratar dos desarrolladores más en vez de subcontratar, evalúalo | kit-propuestas | no |
| 16 | ¿Cuánto le cobramos al cliente por el desarrollo del portal? | kit-finanzas | no |
| 17 | Hazme el presupuesto del proyecto para el próximo semestre | kit-finanzas | no |
| 18 | ¿Cuál es el margen si vendemos el paquete en 85 mil pesos? | kit-finanzas | no |
| 19 | Quiero que el reporte de ventas se mande solo cada lunes por correo | kit-automatizacion | no |
| 20 | Conecta el formulario de la página con la hoja de cálculo para que se llene solo | kit-automatizacion | no |
| 21 | Cada vez que llegue una factura al correo, que se guarde en la carpeta del cliente | kit-automatizacion | no |
| 22 | Escríbeme un correo al proveedor para pedirle la cotización actualizada | kit-redaccion | sí (correo↔redacción) |
| 23 | Haz la minuta de la junta de hoy con los acuerdos y pendientes | kit-redaccion | sí (minuta↔redacción) |
| 24 | Mándame un mensaje de estatus a dirección de cómo va el proyecto, solo para informar | kit-redaccion | sí (estatus↔redacción) |
| 25 | Documenta el proceso de cierre mensual | kit-redaccion | sí (documenta↔redacción) |
| 26 | Prepárame un informe con láminas para la reunión del viernes | kit-presentaciones | sí (informe↔deck) |
| 27 | Redacta un mensaje a dirección para que aprueben contratar dos personas | kit-propuestas | sí (aprobación↔propuesta) |

Historia y análisis de fallos previos en `docs/pruebas/disparo-descriptions.md`.
