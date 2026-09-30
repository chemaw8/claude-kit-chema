# Council v1.26 — ronda pstack: verificación por proyecto y revisor de slop en español (2026-09-30)

Rama `pstack/ronda-1` (`git diff main...pstack/ronda-1`). Origen: análisis de pstack (skills de Lauren Tan para
Cursor, MIT) y del mercado de skills, en `investigacion/2026-09-30-pstack-y-mercado.md`. Rige el congelamiento del
2026-08-29 («nada entra sin evidencia»): cada pieza trae su medición. No toca el núcleo ni ninguna description de
skill, así que el gate de disparo no aplica. Agrega un comando.

## Qué entra

1. **Comando `/crear-verificacion`** (`commands/crear-verificacion.md`, adaptado de `create-verification-skill` y
   `maintain-verification-skill`). Le deja a un proyecto con interfaz o servicio un mapa (`docs/verificacion/`) y un
   script (`scripts/verificar-app.sh doctor | recorrer | limpiar`) que recorren la app como usuario, guardan evidencia
   fuera del repo y limpian; se prueban una vez con un defecto sembrado. Además, una línea en la plantilla de ficha
   de `/proyecto-init`, una en el árbol de `skills/kit-codigo/estandar-proyectos.md`, la fila del README y los
   manifiestos del plugin.
2. **`scripts/muletillas.sh`**, revisor determinista de señales de texto de IA en español (adaptado de `unslop`,
   reescrito con Wikipedia «Signs of AI writing» en inglés y portugués y la norma de la raya de la RAE). Una línea
   en el checklist de `kit-redaccion`: correrlo antes de entregar a dirección o a un cliente.

Adiciones por skill en esta ronda: `kit-redaccion` 1, `kit-codigo` 1 (tope 2). Esto es la propuesta tal como
llegó al panel; tras el acta (abajo), la línea de `kit-redaccion` se retiró y esa skill queda en 0 adiciones.

## Evidencia

**Pieza 1.** Censo de fichas locales: los proyectos que generan entregables ya declaran cómo verificar la salida;
el hueco está en apps con interfaz o servicio. Piloto en una app web (Next.js + Postgres), en clon aislado:

| Defecto sembrado | Suite de pruebas | Script de verificación |
|---|---|---|
| Export infla el precio 27.51 % | lo detecta | lo detecta |
| Ruta de matching nunca pasa a «revisión» | 72/72 en verde | lo detecta |

Sonda con 6 agentes nuevos (Opus 5.5), mismo defecto de la ruta y encargo redactado como reporte de usuario; el
grupo B tenía el mapa y el script en el repo. Cegado según el playbook `eval` de pstack. Calificado por efectos en
disco y por lo que afirma cada reporte (las transcripciones de subagentes no se guardan aparte).

| | A: ficha actual (3) | B: con mapa (3) |
|---|---|---|
| Arreglo correcto | 3/3 | 3/3 |
| Prueba de regresión nueva | 3/3 | 2/3 |
| Recorrió la app real con evidencia en disco | 0/3 | 3/3 |

El script se probó después contra el entorno real de desarrollo del proyecto: sale 0. Ahí apareció que el matching
llama a una API de pago si la clave está en `.env` (se corrió una vez sin avisar; el comando ahora exige pedir
permiso y el script lo avisa), y que la contraseña entre comillas rompía el login (corregido).

**Pieza 2.** Primera versión (lista léxica): 0 hallazgos en 11 entregables reales; se cambió el enfoque. Segunda
versión: 11 señales fuertes y 5 de densidad con umbral. Calibración:

| Corpus | Señales fuertes | Viñetas «**Tema:** texto» (umbral 6) | Rayas (umbral 5) |
|---|---|---|---|
| 5 artículos humanos de es.wikipedia, revisión de 2021 | 0 | 0 de 5 | 0 de 5 |
| 5 textos de Sonnet sin el kit | 2 | 4 de 5 | 0 de 5 |
| 11 entregables reales hechos con el kit | 11 de 11 con raya espaciada | 1 de 11 | 9 de 11 |

## Riesgos que el autor ya ve

- n=3 por brazo y una sola tarea en la sonda: evidencia provisional.
- Un agente con mapa usó el recorrido en vez de la prueba de regresión; el comando y el mapa ahora lo dicen.
- No hay dato de si corregir las señales del revisor mejora cómo lee el texto la audiencia. Solo hay dato de que
  las señales separan texto humano de texto de IA y aparecen en los entregables.
- El título «con Mayúsculas a la Inglesa» (F11) da falsos positivos en resúmenes de contratos.

## Postura inicial del autor (antes de leer al panel)

Aprobada con cambios: la pieza 1 tiene evidencia de efecto real; la pieza 2 tiene evidencia de detección, no de
beneficio para la audiencia, y quizá debería entrar como herramienta opcional sin la línea en el checklist.

## Acta (2026-09-30)

Panel: council-codex (GPT-6 Astra, viabilidad técnica), council-kimi (K3, riesgos), council-anthropic (Opus 5.5,
abogado del diablo); los tres: **aprobada con cambios**. Síntesis: `sintetizador` (Fable 5.1), que verificó cada
hallazgo contra los archivos. Revisión del gate (sello-push, Opus): aprobado, 0 bloqueantes, 3 avisos.

**Veredicto: aprobada con cambios.** Aplicados en la misma rama:
1. Se retiró la línea del checklist de `kit-redaccion`: la raya espaciada aparece 11/11 en entregables con kit y 0/5
   en Sonnet sin kit, pero el kit la usa en 41 líneas de skills y núcleo (y `kit-redaccion` la prohibía mientras la
   usaba en título y cuerpo); cambiaron a la vez modelo y kit, así que la medición no separa la causa. El script
   queda como herramienta opcional, citado con `${CLAUDE_PLUGIN_ROOT:-$HOME/.claude}` para instalaciones por plugin.
2. `kit-redaccion` quitó la raya espaciada de su título y su cuerpo (la description no se toca: gate de disparo).
3. F11 (títulos con mayúsculas a la inglesa) pasa a candidata: se reporta, no cambia la salida.
4. `/crear-verificacion`, «Mantenerla viva»: un defecto de la app se conserva y se reporta; el mapa solo se ajusta
   si la app cambió a propósito.
5. `/crear-verificacion`, paso 5: el defecto se siembra en un worktree o clon desechable, nunca en el árbol del
   usuario con cambios sin commitear.
6. Aviso del gate: la ruta de artefactos en `CONTINUAR.md` nombraba un proyecto interno en este repo público; se
   quitó antes de cualquier push (única aparición en la rama, verificada con `git grep`).
7. Entrada v1.26 en el CHANGELOG y versión del manifiesto.

**Pendientes con condición:**
- **A/B de la raya** (condición para que el revisor vuelva a un checklist): mismo modelo que produce los
  entregables, mismo encargo, con y sin kit, n=3 por brazo, contar F9. Si la raya viene del kit, el arreglo es
  quitarla del texto del kit (una resta; tocar descriptions activa el gate de disparo).
- **El texto de `/crear-verificacion` no se ha ejecutado como comando** (el piloto midió el mapa y el script hechos
  a mano). Primera corrida real: sesión nueva, clon limpio, defecto sembrado; se anota aquí si lo detecta.
- **Umbral de retiro del comando:** si en las dos primeras corridas reales el script generado no detecta el defecto
  sembrado, o su corrida deja residuos (procesos, datos fuera del prefijo), el comando vuelve a borrador.

**¿El panel movió la postura del autor?** En la dirección, no: la duda sobre la pieza 2 se volvió bloqueante con
evidencia (el kit se contradecía). En la pieza 1, sí: el autor la daba por lista y el panel encontró tres defectos
de texto (ajustar el mapa a un defecto, sembrar sin guarda, comando sin ejecutar).
