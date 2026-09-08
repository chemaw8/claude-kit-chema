# Council — v1.19.2 (esfuerzo antes que modelo · sintetizador en Fable)

Fecha: 2026-09-07. Estos cambios del kit salen de un council más amplio corrido sobre una propuesta
de mejora del entorno de trabajo del mantenedor (cuatro evaluadores Opus 5 independientes:
viabilidad técnica, costo/beneficio, riesgos, abogado del diablo; síntesis por Fable 5.1).
Veredicto de los cuatro: **aprobada con cambios**. El acta completa es privada; aquí, lo que toca
al kit y las cifras solo de forma cualitativa.

## Qué paga cada línea nueva del núcleo
La medición semanal del entorno mostró que la gran mayoría de los tokens de una semana fueron del
modelo más caro, corriendo como sesión principal y no como juez. La escalera del núcleo decía
"Fable solo para síntesis y juicio" pero ninguno de los tres agentes del kit usaba Fable, y no había
ninguna regla sobre el esfuerzo. La guía oficial de modelos pide subir el esfuerzo en Opus antes de
pagar Fable.

## Hallazgos del council que aplican al kit
- **Costo/beneficio:** la regla de esfuerzo era el ítem con más palanca y viajaba como nota
  documental → entra al núcleo, y el entorno la mide. (Así se redactó en su momento, con una
  condicional "si tu entorno mide el reparto por modelo"; al incorporar la medición esa frase se
  retiró del todo y el núcleo final no menciona ningún reporte ni indicador externo.)
- **Costo/beneficio:** asignar Fable a más agentes en el mismo cambio que pide frenar Fable exige
  un árbitro → el `sintetizador` queda acotado a integrar veredictos (entrada corta).
- **Abogado del diablo / auditoría interna:** la decisión del 2026-08-29 de "declarar el modelo por
  etapa" nunca se ejecutó → entra en kit-orquestacion en la misma línea.

## Hallazgos del revisor del gate (primera revisión, un bloqueante y cinco avisos)
- **Bloqueante, aplicado:** la primera versión de esta acta publicaba cifras de consumo del entorno
  privado y una ruta interna. Retiradas; las cifras quedan cualitativas.
- **Aviso, aplicado:** subir `lector-fresco` a Fable sin evidencia de que Opus 5 a `--effort max` se
  queda corto contradecía la regla nueva → `lector-fresco` sigue en Opus 5.
  **Medido antes de fusionar** (`docs/pruebas/medicion-esfuerzo-v1.19.2.md`): en ese material **no
  se detectó que Opus 5 a `--effort max` se quede corto**. La batería está saturada, así que eso no
  prueba igualdad de calidad; sí quita la evidencia que haría falta para subir de modelo por
  calidad, y con eso la decisión de dejar `lector-fresco` en Opus 5 queda respaldada. La medición
  añadió además una excepción que la regla no contemplaba —Fable 5.1 sale más rápido— y esa
  excepción entró al núcleo enunciada como criterio, no como cifra (su brazo no es limpio).
- **Aviso, aplicado:** el núcleo prometía un reporte semanal que vive fuera del kit → reformulado
  como condicional. **Al incorporar la medición, esa condicional se retiró del todo**: la regla ya
  no menciona ningún reporte ni indicador externo, así que el aviso queda cubierto más estrictamente.
- **Unidades, para que no se lean como contradicción:** el núcleo habla de costo **por corrida
  medida** y lo enuncia sin cifras (solo la dirección y que el margen es estrecho);
  kit-orquestacion habla del precio **por token** (Fable 5.1 el doble, tabla de arriba); y las
  cifras viven en `docs/pruebas/medicion-esfuerzo-v1.19.2.md`. Tres magnitudes, cada una en su
  lugar y con su unidad.
- **Aviso, aplicado:** la description del `sintetizador` decía ser "el" escalón Fable → ahora "el
  agente del escalón Fable".
- **Aviso, aplicado:** el gate de disparo (`docs/pruebas/RUNBOOK.md`) es obligatorio al tocar el
  núcleo o añadir una description → corrido; resultado abajo.
- **Aviso, aplicado:** el acta verificaba el alias `fable` pero no `--effort` ni el valor `max` que el
  núcleo manda usar → verificados en la misma versión (abajo).
- **Aviso de la segunda revisión, aplicado:** «Fable cuesta el doble por token» iba sin fuente →
  precios oficiales (platform.claude.com/docs/en/about-claude/models/overview, consultado
  2026-09-07): Fable 5.1 $10 / $50 por millón de tokens de entrada / salida; Opus 5 $5 / $25. El doble
  en ambos. Ambos con 1M de contexto y 128K de salida.
- **Bloqueante de la segunda revisión, aplicado:** el cuerpo del primer commit de la rama repetía la
  cifra privada → la rama se reescribió limpia antes de subirse. (Después se le sumaron los
  commits de la medición de esta misma tanda; el conteo exacto se lee en `git log`, no aquí.)

## Verificaciones en la máquina (Claude Code 2.1.263)
- `fable` es alias válido de modelo (lista de alias en el binario). ✓
- `--effort <level>` existe en `claude --help`; los niveles en el binario son low / medium / high /
  xhigh / max. ✓
- `bash verificar.sh` en verde; núcleo 133/150 líneas.
- Gate de disparo (`docs/pruebas/disparo.py --paralelo 6 --modelo sonnet`, 2026-09-07): **núcleo 21/21 (criterio ≥ 19/21) · confusiones de frontera no benignas: 0 · PASA**.
- **Re-corrido el 2026-09-08 sobre el núcleo de `df8cb12`**, que es el último commit que lo toca
  en esta rama: **21/21 (criterio ≥ 19/21) · confusiones de frontera no benignas: 0 · PASA**.
  `verificar.sh` en verde y núcleo 133/150. Se fija el hash y no solo la fecha porque el núcleo
  se editó tres veces en la rama y una nota fechada no dice cuál texto se probó: la corrida
  anterior (tras `79d6480`) quedó obsoleta por eso.

## Veredicto para el kit
`aprobada con cambios` (aplicados). Reversible con `git revert`; la regla no cambia ningún default de
Claude Code, solo el criterio escrito y los agentes.
