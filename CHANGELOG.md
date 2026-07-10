# Changelog — Kit Chema

## v1.6 — 2026-07-10
Lote de mejoras cosechadas de la comparativa con ECC y vetadas por council, todas
como adiciones de 1-2 líneas a cuerpos y checklists de skills (ninguna description
ni el núcleo se tocaron): silent-failure en kit-codigo (ningún catch/except vacío)
y test RED que falla por la razón correcta; en kit-propuestas, evaluador que
recibe solo propuesta+mandato sin el hilo completo, y postura previa del hilo
principal fijada antes de leer reportes; coherencia de cifras entre documentos de
una misma decisión (kit-presentaciones); estado real del correo declarado con
lenguaje preciso (kit-redaccion); paneles de dashboard accionables (kit-analisis-
datos); paso 0 de research que revisa primero el material ya aportado; y ciclo de
vida de la automatización (revisión periódica de que sigue viva y con dueño).
Eval-harness formalizado: banco canónico (`docs/pruebas/banco/disparo.md`),
`docs/pruebas/RUNBOOK.md` (juez Sonnet esfuerzo bajo, contexto fresco, criterio
≥ 19/21 + cero confusiones de frontera) y disparador del gate en `GOBERNANZA.md`.
Se descartó por bloat lo pesado de ECC: tablas de evidencia de TDD, roles fijos de
council, ADR en carpeta, plantillas de reporte y dependencias de MCP.

## v1.5 — 2026-07-10
Nueva skill kit-redaccion (comunicación escrita: correos, minutas/actas, memos,
comunicados, documentación y estatus informativo). Aprobada por council con
cambios y validada por un gate de disparo 10/10 sin confusiones de frontera:
"informe" se queda en kit-presentaciones y kit-propuestas reclama ahora los
mensajes que piden aprobar/autorizar (cierre de frontera por ambos lados).

## v1.4 — 2026-07-10
Hook de contexto (`hooks/kit-chema-contexto.sh`, evento `SessionStart`): autocarga
el contenido de `~/.claude/contexto/` (empresa, personal y base de conocimiento)
al abrir cada sesión, para no depender de que Claude recuerde leerlo. Cierra el
hueco de la regla "leer el contexto antes de un trabajo sustantivo". Se instala
por defecto (bajo riesgo, alto valor); el hook anti-secretos sigue opt-in. Envuelve
el texto en JSON con python3 (`json.dumps`), no con `jq`, para no añadir una
dependencia extra y ser consistente con el resto del kit; si falta python3 sale 0
sin romper la sesión (falla segura, solo se pierde la autocarga). Añadido a las dos
vías de instalación: `instalar.sh` (fusiona la entrada `SessionStart` en
`settings.json`) y plugin (`hooks/hooks.json` con `${CLAUDE_PLUGIN_ROOT}`).
Documentado en INSTRUCTIVO (fila del mapa y señal de que funciona).

## v1.3 — 2026-07-09
Licencia MIT (LICENSE + campo license en plugin.json y marketplace.json): el
repo público ya es legalmente reutilizable. Bloque de compatibilidad en
kit-codigo que zanja tres choques reales con superpowers/pr-review-toolkit
cuando están instalados (TDD proporcional vs Ley de Hierro, arranque por
tamaño, carriles de revisión con veredicto homologado). Sin acoplamiento duro:
la sección solo aplica si esos plugins existen.

## v1.2 — 2026-07-09
Plugin híbrido de Claude Code: se empaquetan las 7 skills y el hook anti-secretos
como plugin (`.claude-plugin/plugin.json` + `marketplace.json`, `hooks/hooks.json`,
slash command `/kit-chema:init-contexto`). El núcleo sigue instalándose aparte
como `~/.claude/CLAUDE.md` porque un CLAUDE.md en la raíz de un plugin no se carga
como contexto (doc oficial). La vía `git clone` + `./instalar.sh` sigue viva para
todo. Ambas vías documentadas en README e INSTRUCTIVO.
Salvaguardas anti-degradación: CI (`.github/workflows/ci.yml`) que corre en PR y
en push a ramas != main con dos jobs, límites (`verificar.sh`) y secretos
(gitleaks por binario de versión fija); `CODEOWNERS`; `GOBERNANZA.md` (cambios
solo por PR, CI en verde, revisión de CODEOWNERS, rollback por revert); la
mejora-por-corrección del núcleo entra como PR en borrador revisado por council.
Guía de contexto: límite duro y regla de oro en las plantillas de contexto,
ejemplos de tono así-sí/así-no, y sección "Cómo llenar tu contexto" en
COMO-PEDIR.md.
Bugfix: el YAML frontmatter de `kit-propuestas` se rompía por un `: ` en el
description (la skill cargaba sin metadata); se entrecomilló el valor.

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
