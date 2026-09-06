# Council v1.18 — hook `rutas-fantasma.sh` (PR #29) — 2026-09-06

Tres evaluadores independientes (agente `evaluador-council`, Opus 5, contexto
fresco, mandato acotado de kit-propuestas), lentes: viabilidad técnica, riesgos,
abogado del diablo. Síntesis con Fable 5. Postura inicial del hilo, fijada antes
de leer los reportes: "apruebo; lo único discutible es por defecto vs opt-in".

## Veredicto: aprobada con cambios — todos aplicados en el mismo PR

Los tres lentes coincidieron en el veredicto. Ninguno objetó el mecanismo (los
tres lo probaron corriéndolo, no leyéndolo) ni la instalación por defecto: un
hook que solo actúa cuando el prefijo no existe en disco no puede bloquear una
lectura legítima, así que la razón por la que anti-secretos es opt-in no aplica.

### Hallazgos condicionantes (y qué se hizo)

| # | Hallazgo | Lente | Verificado | Aplicado |
|---|---|---|---|---|
| 1 | `hooks/README.md:32` publicaba "Es un hook Es un hook" (línea duplicada al insertar el encabezado nuevo) | 3/3 | `grep` → 1 ocurrencia | corregido |
| 2 | CHANGELOG decía "12 casos"; la prueba corre 14 aserciones | abogado | conteo 5+3+3+2+1 | corregido a 14 |
| 3 | La "segunda vía" para escalar una regla a hook quedó sin piso de costo y contradecía el párrafo donde se insertó ("si el costo es bajo, corrígelo en prosa") — enmienda auto-servida | abogado | lectura | reescrita con cinco condiciones simultáneas: fallo del modelo (no de disciplina), recurrente en el reporte de salud, determinista, condicionado al estado real de la máquina, fail-open y con prueba en `verificar.sh` |
| 4 | La reversión declarada ("quitar la entrada o revertir el PR; sin estado") era falsa: quitar la entrada se repone en la siguiente reinstalación y revertir el PR no desinstala nada de las máquinas (no hay desinstalador) | riesgos | reproducido por el evaluador contra dir temporal | texto honesto en README y CHANGELOG + interruptor `KIT_RUTAS_FANTASMA=n` en `instalar.sh` (probado: omite y no repone) |

### Sugerencias aplicadas (no condicionaban)

- **Prefiltro en bash** antes de invocar python: dos lentes midieron 18-23 ms por
  `Read|Write|Edit`, ~9 ms de arranque de python. Con el prefiltro el camino común
  baja a ~1 ms (medido: 50 llamadas). Beneficia a todos los usuarios, siempre.
- **Acotar "no puede estorbar un flujo legítimo" a lecturas**: un `Write` que
  pretenda crear el prefijo desde cero sí se bloquea (raro; el mensaje dice cómo
  seguir). README y CHANGELOG ya lo dicen así, y que no cubre `Bash`, `Glob`,
  `Grep` ni `NotebookEdit`.
- **Criterio de éxito medible** en el CHANGELOG: el hook no evita que el modelo
  emita la ruta, mejora el error que recibe; el bloqueo también cuenta como error
  en el reporte de salud, así que lo que debe bajar son los reintentos al mismo
  destino y los "File does not exist" a esas rutas.
- **`verificar.sh` compara `hooks.json` y `settings-fragment.json`**: deriva
  probable ahora que son tres hooks (lente viabilidad, "fuera de mi ángulo").
- `${HOME:-?}` en el mensaje y nota de "prefijos sin espacios dentro".

### Objeciones consideradas y descartadas por los propios lentes

- n=1 / opt-in: la alucinación es del modelo, no de la instalación; el hook es
  no-op donde el prefijo existe.
- Código muerto si el proveedor corrige el modelo: 33 líneas que fallan abiertas.
- Subir a v1.18 por un hook: proporcionado (componente nuevo por defecto + cambio
  en el instalador).

### Diferido (fuera de alcance de este PR)

- Vía plugin (`hooks.json`) los tres hooks quedan activos sin pregunta, incluido
  anti-secretos que por instalador es opt-in: inconsistencia preexistente.
- Desinstalador del kit: pendiente desde v1.1.
- `RUTAS_FANTASMA` no admite prefijos con espacios dentro: documentado, no
  corregido (es una perilla de prueba).

## ¿Cambió la postura del hilo?

Sí, en dos puntos: la reversión que yo mismo declaré era falsa, y la segunda vía
del README la había escrito más ancha de lo que el caso justificaba. En lo que
creía discutible (por defecto vs opt-in) el council confirmó la recomendación
con evidencia. El council aportó; no fue teatral.
