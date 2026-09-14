---
name: auditoria-git
license: MIT
description: Auditoría de disciplina de push/pull en git para uno o varios repos — si el equipo respeta rama+PR (nunca push/merge directo a main), higiene de commits, ramas huérfanas, secretos colados en el historial — y si Claude mismo ha seguido las reglas de seguridad al operar git en la sesión (confirmar antes de acciones irreversibles, no saltarse --no-verify, no push/reset sin avisar). Úsala con frases como "audita nuestro push y pull", "revisa la disciplina de git de [repo]", "¿estamos respetando rama+PR?", "auditoría de cómo manejamos git". Todo con evidencia verificable (gh api, git log, gh pr list) — nunca por impresión.
---

# Auditoría de push/pull — disciplina de git

Checklist de segunda opinión sobre cómo se usa git, en dos ejes. No sustituye
las reglas de git ya definidas en cada repo (ej. `como-trabajamos.md` del
vault) — esta skill verifica si se están cumpliendo, con evidencia.

## Los dos ejes

1. **Disciplina del equipo.** ¿Los repos respetan rama + PR para llegar a
   main? ¿Los commits son legibles? ¿Hay ramas abandonadas, archivos
   colados que no debieron versionarse, o secretos en el historial?
2. **Cómo opera Claude.** ¿Las sesiones de Claude Code que tocaron ese repo
   confirmaron contigo antes de acciones irreversibles (push --force, reset
   --hard, merge/push directo a main, --no-verify)? Esto es lo que ya exige
   la sección "Executing actions with care" del propio sistema — esta
   auditoría comprueba si se cumplió, no lo repite como regla nueva.

Nunca reportes una violación por impresión: cada hallazgo lleva su evidencia
(hash de commit, fecha, comando de `gh`/`git` que lo muestra).

## Repos y acceso — verificar antes de auditar, no asumir

1. Si el usuario no da una lista de repos, pregúntale o usa
   `gh repo list <owner> --limit 100` para enumerar los que administra.
2. Antes de auditar un repo confirma acceso real: `gh repo view <owner>/<repo>`.
   Si da 404/permission denied, repórtalo así tal cual (puede ser que falte
   una invitación de colaborador) y sigue con el resto — no lo trates como
   bug tuyo ni lo omitas en silencio del reporte final.
3. **No asumas que el repo está clonado localmente.** La mayoría de las
   comprobaciones de esta skill funcionan sin clon, vía `gh api` / `gh pr
   list` / `gh api repos/<owner>/<repo>/commits`. Los chequeos que sí
   requieren clon local (`git reflog`, por ejemplo) solo corren si
   encuentras el repo en disco — si no, dilo explícitamente en el reporte
   ("no se pudo revisar reflog: repo no clonado localmente") en vez de
   omitirlo sin más.

## Proceso

1. **Enumerar y confirmar acceso** a cada repo en alcance (ver arriba).
2. **Eje 1, por repo:**
   - `gh api repos/<owner>/<repo>/commits?sha=main --paginate` (o el
     branch por defecto real) y compara contra `gh pr list --state merged`:
     ¿hay commits en el default branch que no vienen de un merge de PR?
     Repórtalos con hash y fecha.
   - `gh api repos/<owner>/<repo>/branches` — ¿ramas sin actividad reciente
     y sin PR abierto ni cerrado asociado?
   - Mensajes de commit de los últimos ~30: ¿descriptivos o genéricos
     ("fix", "wip", "update")? Da 2-3 ejemplos de cada tipo si aplica.
   - Búsqueda de patrones de secretos en el historial (API keys, tokens,
     contraseñas, `.env` con valores reales) — si encuentras algo, reporta
     solo archivo/commit/hash, nunca el secreto en claro.
   - Archivos binarios o pesados colados en el historial que no debieron
     versionarse (imágenes, PDFs, dumps).
3. **Eje 2, por repo (solo si hay evidencia disponible):**
   - Si el repo está clonado localmente: `git reflog` — busca
     `push --force`, `reset --hard`, o push directo a main sin rama previa.
   - Compara el autor/fecha de commits recientes contra lo que exige el
     repo (ej. vault: rama `aporte/<tema>` + PR, nunca push directo a main).
   - Si no hay evidencia suficiente para juzgar este eje en un repo, dilo
     explícitamente — no concluyas "todo bien" por default.
4. **Síntesis.** Un reporte por repo: hallazgos con evidencia, nivel de
   riesgo (bajo/medio/alto), recomendación concreta. Cierra con un resumen
   de 3-5 líneas de qué corregir primero.

## Confidencialidad

Si algún repo en alcance tiene material NDA o datos internos (ej. el vault
del equipo de IA), el reporte de esta auditoría es igual de sensible que el
repo mismo: no sale del equipo, no se pega en herramientas externas.

## Checklist final

- ¿Cada hallazgo tiene evidencia verificable (hash, fecha, comando), no solo
  una impresión?
- ¿Confirmaste acceso real a cada repo antes de auditarlo (nada de 404
  silenciosos)?
- ¿Dejaste explícito qué NO se pudo verificar (repo no clonado, sin acceso,
  sin historial suficiente) en vez de omitirlo?
- ¿El reporte de repos confidenciales se mantiene dentro del equipo?
- ¿El resumen final prioriza qué corregir primero, no solo lista todo por
  igual?

## Errores típicos

- Reportar una violación de "nunca push a main" sin el hash del commit que
  la prueba.
- Asumir que un repo está clonado localmente y fallar en silencio al correr
  `git reflog` sin decir por qué no hay resultado.
- Tratar un 404 de acceso como si el repo estuviera limpio, en vez de
  reportar que no se pudo auditar.
- Pegar un secreto encontrado en el historial dentro del reporte, en vez de
  solo referenciar dónde está.

## Nota de gobernanza

Esta skill es una adición personal, igual que `auditoria-presentaciones` —
no modifica `kit-codigo` ni `kit-automatizacion` ni ningún archivo del repo
`claude-kit-chema`. Si se quiere que sea parte del kit compartido (para que
`instalar.sh` la instale automáticamente a cualquier persona del equipo),
eso es un cambio al repo gobernado y pasa por PR + council según
`GOBERNANZA.md` — no se hizo aquí a propósito.
