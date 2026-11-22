# Etapa 7: P&L por segmento y presentación generada

Aprendido de un caso real terminado. La skill no incluye los scripts de P&L ni de presentación: se escriben por
proyecto con esta estructura (los nombres de abajo son ilustrativos). Entra solo con el canvas aprobado por bloque; antes, la economía es «qué tendría que ser verdad».

## P&L generado por script, con fórmulas

**Un script escribe el Excel; el Excel calcula.** Ninguna cifra del P&L va escrita a mano: todo sale de las hojas de
supuestos por referencia, para que el usuario cambie un supuesto en Excel y el libro se recalcule.

| Hoja | Qué contiene |
|---|---|
| Resumen | Indicadores clave por segmento y total |
| Supuestos generales | Calendario (mes 1 = salida comercial), impuestos, costos fijos compartidos |
| Supuestos {segmento} / P&L {segmento} | Un par por segmento del canvas, incluido el B2B2C |
| P&L agrupado / Anual | Suma de segmentos; cortes anuales |
| Inversión | Gasto preoperativo con sus meses previos, aportación máxima, mes del punto más bajo, capital de trabajo |
| WACC | TIR y VPN contra el costo de capital y contra la TIR mínima |
| Peticiones al proveedor | Lo que el modelo necesita del socio o proveedor clave |
| Escenarios aparte | Financiamiento al cliente u otros que no cambian la base |

Convenciones:
- **Supuesto = etiqueta | valor | unidad | fuente**; la fuente dice autor y fecha. Los del agente van marcados.
- Colores de modelo financiero: azul = entrada, negro = fórmula, verde = vínculo a otra hoja; amarillo = supuesto clave.
- Las mismas filas por concepto en todas las hojas de P&L (altas, bajas, churn, ingreso, costo del proveedor, cobro,
  contribución, utilidad, acumulado), para poder agregarlas y leerlas por programa.
- Costos únicos (equipo, registro) una vez por alta; comisiones de cobro e impuestos especiales explícitos.
- Una tasa mínima que Finanzas no confirmó se rotula «valor estimado».

Antes de entregar el Excel:
- Recalcularlo fuera de Python (LibreOffice sin interfaz, o la librería `formulas`) y reportar cero errores de celda.
- Probar que responde: cambiar un supuesto clave en una copia y comprobar que el resultado se mueve.
- Reportar al usuario las cifras clave del libro recalculado (utilidad acumulada, mes de equilibrio, aportación
  máxima), no las de un cálculo aparte.

## Presentación desde los datos del P&L

```
construir_pl.py           → pl.xlsx (fórmulas)
datos_presentacion.py     → recalcula (librería `formulas`) → datos-presentacion.json
construir_presentacion.py → plan-de-negocio.pptx (con el módulo de estilo de la marca)
construir_acordeon.py     → acordeon-supuestos.pptx (una lámina general y una por segmento)
```

- openpyxl no guarda valores calculados: por eso se recalcula antes de extraer.
- El acordeón lee los supuestos **por etiqueta**: si una etiqueta cambia en el Excel, el script falla en lugar de
  mostrar una cifra vieja.
- Narrativa probada: quiénes somos → un segmento por lámina → competencia → oferta → indicadores → inversión →
  resultados → lo que recibe el proveedor → lo que necesitamos de él → ruta crítica → requisitos legales → cierre →
  anexo de TIR contra WACC.

## Verificación antes de entregar

1. Correr los scripts en orden: código 0.
2. Recalcular el Excel: cero errores de celda; revisar valores fijos entre fórmulas.
3. Comparar el JSON del commit contra uno recalculado (deben ser idénticos) y trazar cada cifra de las láminas al JSON
   o a su evidencia, incluidas las derivadas (sumas, porcentajes).
4. Lector fresco de la presentación y, si sale de la empresa, council.
