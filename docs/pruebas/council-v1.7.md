# Council — lote v1.7 "arquitectura de skills" (2026-07-10)

Propuesta evaluada: cinco mejoras derivadas de la investigación del ecosistema
de skills (spec oficial, comunidad y distribución; reportes en
`investigacion/2026-07-10-skills-*.md`). Contexto de usuarios aportado por el
dueño antes de lanzar el panel: todos los usuarios son de paga y la mayoría usa
Claude Code; que las skills sirvan en claude.ai "estaría bien pero no es
prioridad".

Panel: 4 evaluadores independientes (Opus 4.8, contexto fresco — solo propuesta
+ mandato acotado, nunca el hilo), lentes: valor-vs-bloat, viabilidad/diseño,
costo/mantenimiento y abogado del diablo. Síntesis en el hilo principal
(Fable 5). Postura inicial del hilo, fijada antes de leer reportes: *"aprobada
con cambios — meta-skill y presupuesto de disparo son lo valioso; license MIT y
juez Haiku entran por baratos; la vía claude.ai se reduce a documentación mínima
o se difiere"*.

## Veredicto: aprobada con cambios (desagregada, no como lote temático)

| Ítem propuesto | Resultado |
|---|---|
| 1. Meta-skill `kit-crea-skills` (9ª skill) | Cambia de forma: sección "Crear una skill nueva" en GOBERNANZA. La skill se difiere con detonante explícito: que exista un segundo autor real del kit |
| 2. Vía claude.ai (script `empaquetar.sh` + guía) | Solo corrección del INSTRUCTIVO §3 — la doc enseñaba el método degradado (pegar archivos sin disparo) cuando existe la subida real con disparo automático. Enlace a la doc oficial viva; sin script |
| 3. Presupuesto de disparo en `verificar.sh` | Procede: total de descriptions siempre visible + aviso no bloqueante si > 6,000 chars. El doc no promete blindaje del bug global (#13099) |
| 4. `license: MIT` en frontmatter de las 8 | Procede: campos extra verificados inofensivos en vivo; el linter lo exige; se declara como metadato SPDX, no como arreglo legal de copias sueltas |
| 5. Segundo juez Haiku en el gate | Rechazado como gate. Queda como sonda opcional no bloqueante documentada en el RUNBOOK |

## Hallazgos que cambiaron la decisión (con su evaluador)

- **Meta-skill (valor-vs-bloat + abogado del diablo):** la audiencia "colegas
  autores" no existe hoy según la propia GOBERNANZA ("único mantenedor",
  equipo 2+ diferido); el proceso de alta ya vive en GOBERNANZA; una 9ª skill
  crea una frontera de disparo permanente ("créame una skill" ↔ kit-codigo) y
  consume el mismo presupuesto que el ítem 3 protege. Rinde ~90% de su valor
  como doc. Steelman registrado: cuando exista el 2º autor, la skill es
  coherente con la filosofía del kit (cargar en el momento) y superior al doc.
- **claude.ai (valor-vs-bloat + costo):** el INSTRUCTIVO §3 subestimaba la web
  (mandaba pegar archivos a mano, sin disparo); la corrección vale más que el
  script: un zip bajo demanda es un comando de una línea, y el click-path es de
  Anthropic (que lo mantenga su doc, no la nuestra).
- **Presupuesto (viabilidad + costo + valor):** el aviso solo ve las 8
  descriptions del kit; la falla real (#13099) es del total instalado (~16k,
  dominado por lo no-kit). Se implementa como higiene del footprint propio,
  advisory —un gate duro bloquearía PRs legítimos de una futura 9ª skill— y el
  doc dice la verdad sobre el alcance.
- **Frontmatter (viabilidad + abogado del diablo):** riesgo de campos extra
  resuelto empíricamente (skills instaladas con `license:`/`metadata:` cargan
  bien); el riesgo real es sintaxis YAML — precedente v1.2 en este mismo repo
  (un `: ` en una description rompió el frontmatter en silencio) → verificación
  de carga tras editar, obligatoria.
- **Juez Haiku (3 de 4 lentes):** el RUNBOOK ya fija que el juez iguala al
  lector real (prohíbe jueces más listos con esa lógica); el argumento es
  simétrico — un juez más débil que el router real produce falsos rechazos cuyo
  remedio natural es engordar descriptions: un artefacto de test empujando
  bloat. Además reintroduce sabor de "roles fijos" vetado en v1.6 sin brecha
  evidenciada (ningún falso-pase registrado del gate).
- **Contexto del banco corregido (costo):** el banco real es 21 casos de núcleo
  + 6 de frontera (27), y kit-redaccion sentó el precedente: una skill nueva se
  cubre con 1-2 casos de frontera sin mover el criterio ≥ 19/21.

## Cambio de opinión del hilo principal (obligación del protocolo)

Sí, en tres puntos: (1) la meta-skill era el ítem estrella de la postura
inicial y cayó de forma — skill → doc hasta que haya segundo autor; (2) Haiku
venía como "barato" y era un error de diseño como gate; (3) la corrección de
claude.ai valía más de lo estimado (era un doc nuestro enseñando el camino
peor), aunque en forma más chica (párrafo, no script).

## Notas de calidad del panel

Panel no teatral: dos evaluadores hicieron verificación empírica en vivo
(frontmatter con campos extra cargando; conteo real de chars) y todos citaron
el repo con archivo:línea (RUNBOOK, banco, GOBERNANZA, CHANGELOG v1.2/v1.6).
El abogado del diablo formuló el mejor caso en contra ("mejoritis
post-investigación: 4 de 5 ítems nacen de hallazgos, no de fallas") y su
remedio —desagregar y exigir problema-presente— quedó incorporado al veredicto.
