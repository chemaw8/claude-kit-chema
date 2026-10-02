# Council v1.30. Ronda pstack 2: el council clasifica hallazgos y `/por-que` (2026-10-01)

Rama `pstack/ronda-4` (`git diff main...pstack/ronda-4`). Corrida ultracode uc-202610012332-fav8: un autor por
familia de modelos, cada pieza revisada por otra familia que corrió las pruebas y rompió el código a propósito.
No toca el núcleo ni ninguna description de skill: el gate de disparo no aplica. Piezas de pstack
(`cursor/plugins/pstack`, commit fae2c6e, MIT © Lauren Tan), con crédito en cada archivo.

## Qué entra

1. **El council clasifica cada hallazgo** (adaptado del «lead judgment» de `interrogate`). `agents/sintetizador.md`:
   cada hallazgo cae en una sola clase (actuar, considerar, anotado, descartado) con quién lo aportó y la razón en una
   línea; desempate: lo que propone una tarea para después es considerar, no descartado. Mapa de acuerdos entre
   evaluadores (familia y lente). Los cambios del veredicto salen solo de `actuar`; si pasan de cinco, se revisa el
   filtro. `kit-propuestas`: un párrafo en «Veredicto» con lo mismo para quien sintetiza sin el agente (1 adición neta
   de 2 permitidas por ronda).
2. **`/por-que <algo>`** (adaptado de `why` y `recall`). `scripts/por-que.sh` junta evidencia citada, sin
   interpretarla: git (log --follow y blame si es archivo; pickaxe y grep si no), `DECISIONES.md`, `CONTINUAR.md`,
   `docs/bitacora.md` y el vault (`${POR_QUE_VAULT:-$HOME/vault}`), con topes y avisos de truncado, fallo cerrado
   (error de git = salida 2). No lee transcripciones de sesiones ni `*.jsonl`, ni siguiendo enlaces.
   `commands/por-que.md` le pide al modelo estado, cadena de decisiones con fecha, inferencias marcadas y huecos, con
   cita por afirmación. Alta en plugin, marketplace y README.

## Evidencia

- **Pieza 1:** `docs/pruebas/resintesis-council-v1.11.md` rehace el acta v1.11 con el formato nuevo. El veredicto no
  cambia; 4 hallazgos cambian de trato (3 que se aplicaron como obligatorios pasan a considerar) y el filtro se
  vuelve visible: el original aplicó 13 de 14 hallazgos y no descartó ninguno. El revisor (GPT-6 Astra) recalculó
  las cifras con git (núcleo 505 → 628 → 728 palabras; 13 de 14; 19 filas) y las confirmó; encontró un solapamiento
  entre considerar y descartado por fuera de alcance, corregido con la regla de desempate. Límite: los reportes
  crudos de v1.11 no están archivados; la resíntesis trabaja sobre el acta.
- **Pieza 2:** autotest de 9 secciones sin red ni HOME real, corrido por `verificar.sh` (y por tanto el CI). El
  revisor (Kimi K3) armó un vault adversarial (transcripts/, `.jsonl`, `.claude/projects`, `.pi/agent/sessions`,
  enlace a un `.jsonl` externo): solo salió la nota normal. Inyección `$(touch /tmp/pwned)` no se ejecuta; 600
  commits y 200 notas se topan con aviso en 0.05 s. Rompió el script tres veces (sin exclusión de `.jsonl`, sin
  `transcripts`, error de git como éxito): el autotest falló las tres.
- `bash verificar.sh`: 81 OK, 0 FALLA.

## Riesgos que el autor ya ve

- La pieza 1 tiene evidencia de transparencia, no de mejores decisiones: la resíntesis dice que H-3, H-4 y H-5 siguen
  en el kit 18 versiones después. Medirla de verdad pide archivar los reportes crudos del próximo council.
- `/por-que` lee el vault local y puede poner contenido privado en la respuesta de la sesión; no sale de la máquina
  salvo que la sesión use un modelo remoto, que es el caso normal.
- La búsqueda es literal: un tema nombrado distinto no aparece (el comando lo dice y pide repetir con sinónimo).

## Postura inicial del autor (antes de leer al panel)

Aprobada con cambios: la pieza 2 está lista; la pieza 1 es barata y reversible, pero su beneficio es de forma y
quizá el párrafo en `kit-propuestas` sobra si el sintetizador ya lo trae.

## Acta (2026-10-01)

Panel: council-codex (GPT-6 Astra, viabilidad técnica): **aprobada con cambios**; council-kimi (K3, riesgos):
**aprobada**; council-anthropic (Opus 5.5, abogado del diablo): **aprobada con cambios**. Síntesis: `sintetizador`
(Fable 5.1) con el formato nuevo de la pieza 1, que así tuvo su primera corrida real. Gate (sello-push, Opus) sobre
51cc621: 1 bloqueante (el CHANGELOG citaba esta acta antes de existir) y 2 avisos.

**Reportes del panel, resumidos** (se archivan para poder rehacer la síntesis, como pidió la resíntesis de v1.11):
- codex: un archivo **borrado** se trataba como término: `por-que.sh` solo seguía la historia si el archivo existía o
  estaba rastreado; si no, caía a `git log -S`, que busca contenido y no nombres, y decía «sin coincidencias».
- kimi: sin hallazgos. Comprobó que no hay material privado en el diff, que el autotest corre en CI, que las
  exclusiones son estructurales (nombres de ruta y enlaces) y que los dos riesgos reales ya estaban declarados.
- anthropic: `/por-que` entraba sin corrida real, igual que `/crear-verificacion` en v1.26, y bajo el
  congelamiento (DECISIONES 2026-08-29 y 2026-08-31) eso no basta. Además, lo que queda sin sesiones (git log,
  blame, grep) el modelo ya lo hace con Bash: el valor neto no estaba medido. El párrafo duplicado en
  `kit-propuestas` es tolerable.

**Hallazgos clasificados** (del sintetizador; verificó cada uno contra los archivos):

| # | Hallazgo | Clase | Quién | Qué se hizo |
|---|---|---|---|---|
| H1 | Archivo borrado sin historia | actuar | codex | Corregido (`fb0b40c`); caso nuevo en el autotest; quitar el arreglo lo tumba |
| H2 | `/por-que` sin corrida real | actuar | anthropic | Dos pruebas con agentes nuevos (abajo); entra con criterio de retiro |
| H3 | Valor frente al modelo con Bash | considerar | anthropic | Se metió como brazo de la prueba de H2 |
| H4 | Párrafo duplicado en `kit-propuestas` | considerar | anthropic y el autor | Se queda: sirve a quien sintetiza sin el agente |
| H5 | La pieza 1 da transparencia, no acierto medido | anotado | kimi y el autor | Esta acta archiva los reportes del panel |
| H6 | El vault entra al contexto de la sesión | anotado | kimi, anthropic | Ya declarado; sin tarea |
| H7 | Exclusiones, CI, instalación y alta correctos | anotado | kimi | sin acción |

Mapa de acuerdos: H1 y H2 los trajo un solo evaluador cada uno, con un camino de falla concreto (H1 además
reproducido). H6 lo vieron dos familias. La única contradicción, kimi `aprobada` contra los otros dos
`aprobada con cambios`, no es desacuerdo: los cambios salen de corrección y de evidencia de uso, fuera de su lente.

**Avisos del gate, aplicados** (`fb0b40c`): un término que empieza con «/» o lleva «..» (por ejemplo `/cierre`)
abortaba como «objetivo fuera del repo» y ahora se busca como término. Un repo o un vault alcanzados por un enlace
(`/home` → `var/home` en Fedora Atomic, `/tmp` en macOS) quedaban excluidos; ahora la raíz se resuelve antes de
aplicar la política, y los nombres excluidos se revisan sobre la ruta resuelta. Dentro de la raíz, los enlaces
siguen rechazados. Cada arreglo tiene su caso en el autotest y quitarlo lo tumba.

## Prueba de uso real (condición H2, 2026-10-01)

Agentes nuevos, cada uno en su copia del repo, solo lectura, sin transcripciones. Calificador ciego de otra familia
(Kimi K3): cada afirmación se cotejó contra su cita y contra el repo. S = cita que la sostiene; N = cierta pero sin
cita; I = inventada. La clave son 4 o 5 puntos por pregunta, sacados del repo.

**Caso fácil: este repo** (actas y CHANGELOG detallados), GPT-6 Astra, 3 preguntas («¿por qué la regla de 2
adiciones netas?», «¿por qué verificar.sh vigila el manifiesto?», «¿qué pasó con el revisor de señales en
kit-redaccion?»):

| Brazo | Afirmaciones | S | I | Cobertura | Tiempo |
|---|---|---|---|---|---|
| Con `/por-que` | 22 | 22 | 0 | 15/15 | 10.0 min |
| Sin comando, pidiendo citas | 21 | 21 | 0 | 15/15 | 8.0 min |

La pregunta simple, sin pedir citas, también respondió bien; no se calificó a ciegas (se cotejaron a mano 3
afirmaciones y las 3 son ciertas).

**Caso difícil: un repo interno de configuración** (305 commits, un DECISIONES de 677 líneas, parte de las razones
solo en mensajes de commit), Sonnet 5.5, 3 preguntas sobre un script, una función y una regla:

| Brazo | Afirmaciones | S | N | I | Cobertura | Tiempo · costo |
|---|---|---|---|---|---|---|
| Con `/por-que` | 48 | 42 (88%) | 6 | 0 | 14/14 | 4.3 min · 0.35 USD |
| Pregunta simple | 44 | 32 (73%) | 11 (+1 parcial) | 0 | 12/14 | 3.7 min · 0.27 USD |

**Lectura.** Ningún brazo inventó nada. En un repo bien documentado el comando empata con el modelo solo. En el
desordenado mejora la trazabilidad, y la diferencia está donde la razón solo vive en git: en la pregunta sobre un
script, la pregunta simple dio bien el mecanismo pero no encontró los tres commits que lo explican (3/5 contra
5/5). Es evidencia modesta: 3 preguntas por caso, un modelo por caso.

**Decisión (José, 2026-10-01): entra en v1.30 con criterio de retiro.** Si en los primeros 5 usos reales no trae
al menos una vez un commit o una cita que la pregunta simple no habría dado, vuelve a borrador. Los usos se anotan
aquí.

**¿El panel movió la postura del autor?** Sí, en la pieza 2: el autor la daba por lista; tenía un defecto
reproducido (H1) y le faltaba la evidencia de uso que el kit ya le exigió a `/crear-verificacion`. Esa prueba
mostró que el valor es menor del que se suponía y solo aparece en repos desordenados. En la pieza 1, no.
