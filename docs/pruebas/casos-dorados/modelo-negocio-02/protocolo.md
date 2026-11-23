# Protocolo — caso dorado modelo-negocio-02 (actualizar un modelo y entregar el P&L)

Mide lo que el caso 01 no midió: retomar un modelo aprobado, incorporar información nueva sin heredar sus errores y
entregar un P&L en Excel que se pueda mover. Mismo negocio ficticio («Habla»), otra etapa.

## Encargo (idéntico para los dos brazos)
> Hace dos semanas armamos el modelo de Habla; está en `modelo-v1/`. Después llegaron dos cosas (`novedades/`).
> Actualiza el modelo y entrégame el P&L a 24 meses en Excel, que pueda mover los supuestos, más un resumen para
> dirección: ¿da o no da, y cuánto dinero hay que poner?

## Ejecución
- Igual que el caso 01 (`claude plugin eval`, opus, 3 corridas por brazo, núcleo en `append_system_prompt`, insumo por
  `scaffold_script`), con `max_turns` 80 y 40 minutos por corrida; Bash, Write y Edit permitidos.
- Tras cada corrida, `revisar_excel.py` recalcula el `.xlsx` entregado con LibreOffice y escribe el reporte objetivo.
- Cegado con `scripts/cegar.sh etiquetar`; jueces codex y kimi con `rubrica.md` (sin el criterio de éxito) y `clave.md`.
