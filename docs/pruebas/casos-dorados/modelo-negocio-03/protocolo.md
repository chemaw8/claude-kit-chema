# Protocolo — caso dorado modelo-negocio-03 (retomar un proyecto de varias sesiones)

Negocio ficticio «Lumen» (suscripción de bicicletas eléctricas), distinto de «Habla» para medir generalización. El
insumo es un proyecto ya empezado: CONTINUAR, DECISIONES que se sustituyen en el tiempo, un modelo v1, hipótesis y un
P&L v2 preliminar de la sesión 2, más documentos nuevos (costos, memo de finanzas, contrato de la plataforma, piloto).

## Encargo (idéntico para los dos brazos)
> Retoma Lumen donde lo dejamos (está todo en la carpeta `lumen/`, empieza por el CONTINUAR). Termina el modelo v3 con
> la plataforma de beneficios, el P&L a 24 meses en Excel que se pueda mover, y dime si arrancamos en enero y con
> cuánto dinero. Es para dirección.

## Ejecución
Igual que el caso 02 (scaffold que copia `insumo/`, núcleo en `append_system_prompt`, Bash/Write/Edit, `max_turns` 80,
40 min), con 5 corridas por brazo y `--keep-temp`. Extracción, reporte objetivo del Excel, cegado y dos jueces como en
el caso 02.
