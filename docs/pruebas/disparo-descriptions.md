# Prueba de disparo de descriptions — 2026-07-09

Método: 21 peticiones naturales en español (3 por dominio), redactadas como las
diría un colega no técnico y sin nombrar la skill. Cada petición fue juzgada por
un agente Sonnet de contexto fresco que solo vio los 7 pares nombre+description
y eligió qué skill cargaría (o "ninguna").

Resultado: 20/21 aciertos — criterio del spec: >= 19/21 y cero
confusiones entre dominios vecinos (datos vs finanzas vs research). Cumplido.

| # | Petición | Esperada | Obtenida | OK |
|---|---|---|---|---|
| 1 | Necesito mostrarle a los de Ordenaris cómo vamos con el proyecto del trimestre | kit-presentaciones | kit-presentaciones | sí |
| 2 | Ayúdame a armar unas láminas para la junta del viernes con el cliente | kit-presentaciones | kit-presentaciones | sí |
| 3 | Tengo que presentar los resultados del año a dirección, ¿me ayudas? | kit-presentaciones | kit-presentaciones | sí |
| 4 | Aquí está el Excel de ventas de las tiendas, dime qué está pasando | kit-analisis-datos | kit-analisis-datos | sí |
| 5 | ¿Por qué bajaron las ventas en junio? Te paso el CSV | kit-analisis-datos | kit-analisis-datos | sí |
| 6 | Hazme un dashboard con las métricas de este archivo | kit-analisis-datos | kit-analisis-datos | sí |
| 7 | Investiga qué sistemas de punto de venta usan las cadenas de retail en México | kit-research | kit-research | sí |
| 8 | ¿Qué hay sobre la nueva norma de facturación electrónica? Necesito entenderla | kit-research | kit-research | sí |
| 9 | Compárame opciones de proveedores de hosting para el proyecto | kit-research | kit-research | sí |
| 10 | Haz un script que renombre todas las fotos de la carpeta con su fecha | kit-codigo | kit-automatizacion | NO |
| 11 | El sistema tira un error cuando subo el archivo, arréglalo | kit-codigo | kit-codigo | sí |
| 12 | Crea el proyecto base para la API de inventarios | kit-codigo | kit-codigo | sí |
| 13 | ¿Te parece buena idea migrar todo a la nube este año? Dame tu opinión seria | kit-propuestas | kit-propuestas | sí |
| 14 | Escríbeme la propuesta para el cliente de la app de pedidos | kit-propuestas | kit-propuestas | sí |
| 15 | Estoy pensando en contratar dos desarrolladores más en vez de subcontratar, evalúalo | kit-propuestas | kit-propuestas | sí |
| 16 | ¿Cuánto le cobramos al cliente por el desarrollo del portal? | kit-finanzas | kit-finanzas | sí |
| 17 | Hazme el presupuesto del proyecto para el próximo semestre | kit-finanzas | kit-finanzas | sí |
| 18 | ¿Cuál es el margen si vendemos el paquete en 85 mil pesos? | kit-finanzas | kit-finanzas | sí |
| 19 | Quiero que el reporte de ventas se mande solo cada lunes por correo | kit-automatizacion | kit-automatizacion | sí |
| 20 | Conecta el formulario de la página con la hoja de cálculo para que se llene solo | kit-automatizacion | kit-automatizacion | sí |
| 21 | Cada vez que llegue una factura al correo, que se guarde en la carpeta del cliente | kit-automatizacion | kit-automatizacion | sí |

## Análisis del fallo (petición 10)

"Haz un script que renombre todas las fotos de la carpeta con su fecha" disparó
kit-automatizacion en vez de kit-codigo. La frontera es genuinamente ambigua (un
script de una sola vez vs. un proceso que corre solo) y el impacto es nulo en la
práctica: el proceso de kit-automatizacion aplica kit-codigo en su paso de
construcción, así que la higiene de código opera igual. No se reescribe ninguna
description: el criterio se cumple y engordar las descriptions por un caso
frontera va contra el principio anti-bloat del kit (P1/P4 del spec).
