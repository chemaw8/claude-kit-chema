# Council v1.9 — plantilla `contexto/BASE-CONOCIMIENTO.md`

Fecha: 2026-07-15. Origen: mejora por uso — al conectar a un colega a una base
de conocimiento compartida (vault por el MCP basic-memory), su Claude no la
consultaba porque faltaba el tercer archivo de contexto que el hook ya espera.

## Propuesta

El hook `kit-chema-contexto.sh` hace `cat` de tres archivos al iniciar sesión
(`CONTEXTO-EMPRESA.md`, `CONTEXTO-PERSONAL.md`, `BASE-CONOCIMIENTO.md`), pero el
kit solo trae plantillas de los dos primeros. Se propone añadir una plantilla
genérica fill-in de `BASE-CONOCIMIENTO.md` (estilo `CONTEXTO-PERSONAL`), que el
instalador copie en instalaciones nuevas. Opciones: A) añadir la plantilla
genérica (recomendada); B) solo documentarlo en el INSTRUCTIVO; C) añadirla ya
rellena para basic-memory+vault (opinionada).

Postura inicial del hilo principal: A — cierra un hueco real, bajo riesgo,
genérica (no impone basic-memory).

## Panel (3 evaluadores independientes, Opus 4.8, contexto fresco)

- **Viabilidad técnica — a favor.** El instalador añade el archivo sin pisar
  instalaciones existentes (copia solo si no existe); el hook ya lo espera con
  guarda `[ -f ]`; el CI pasa (verificar.sh no escanea `contexto/`; gitleaks no
  ve secretos). Reversión limpia.
- **Riesgos — a favor.** Sin fuga de confidencialidad: los ejemplos
  (basic-memory, ~/vault, Obsidian) son open-source y genéricos, menos sensibles
  que lo ya publicado en el repo público. Compatible hacia atrás, no destructivo.
  Apunte menor no bloqueante: la plantilla sin rellenar se autoinyecta, ya
  mitigado por "si no tienes una, borra este archivo".
- **Abogado del diablo — a favor.** No hay argumento sólido en contra. La única
  asimetría (BASE-CONOCIMIENTO es de minoría vs. EMPRESA/PERSONAL universales)
  no alcanza el nivel de condición al ponderarla contra el bajo costo y la
  reversibilidad. Nota opcional: alinear la plantilla con las otras dos
  (regla de oro + límite de líneas).

## Veredicto: aprobada con cambios

Cambio aplicado: alinear la plantilla al estilo de las otras dos (añadida la
"regla de oro" por línea y el límite de 40-60 líneas). El ejemplo basic-memory
se mantiene, claramente etiquetado como ejemplo y dentro de corchetes
(el evaluador de riesgos lo despejó como no sensible).

El council confirmó la dirección del hilo principal y le sumó la mejora de
alineación de estilo (no la tenía en la propuesta original).
