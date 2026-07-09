# Changelog — Kit Chema

## v1.1 — 2026-07-09
Contexto generalizado: el núcleo ahora lee toda la carpeta `~/.claude/contexto/`
(empresa + nueva plantilla opcional `CONTEXTO-PERSONAL.md` para proyectos y
preferencias personales); el instalador copia cada plantilla solo si no existe.
Anonimizado el nombre de un cliente en los documentos de prueba (repo público).

## v1.0 — 2026-07-09
Primera versión completa. Criterios de aceptación del spec: 8/8 —
con dos notas ratificadas: C.A.2 quedó en 20/21 disparos (el caso frontera
script-de-una-vez→kit-automatizacion es benigno: ese playbook aplica
kit-codigo al construir) y C.A.7 se cumple en forma condicional (paleta del
deck del grupo 2026-07; la marca oficial se aplicará cuando existan activos
en ~/Trabajo/recursos/marca). Pruebas en docs/pruebas/.
Pendiente para v1.1: desinstalar.sh, aviso de drift de versión, vía Windows.

## v0.9 — 2026-07-08
Construcción inicial: núcleo, 7 skills, hooks, instalador, guías.
(v1.0 se declara cuando pasen los 8 criterios de aceptación del spec.)
