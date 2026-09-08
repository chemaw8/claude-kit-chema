# CONTINUAR — claude-kit-chema  ·  cierre 2026-09-08  ·  commit 3b5c563 (rama evidencia-auto-mejora-y-arbol-subagentes)  ·  cierre limpio: sí
> Estado vivo. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md, GOBERNANZA.md y CLAUDE.md, no aquí.

## Dónde vamos
**v1.19.3 — PR #37 EN BORRADOR (2026-09-08): evidencia empírica para la auto-mejora y la
forma medida de un reparto grande.** Cosecha del paper de Prime Agent (arXiv 2608.23552),
cuyo harness se **rechazó** ese mismo día. `GOBERNANZA.md` gana el caso RCON —un harness con
auto-mejora en línea usó un atajo pese a un control anti-trampas y **lo guardó como skill**—
y, sobre todo, una **autoevaluación**: contra las tres condiciones que el paper concluye que
hacen falta, el kit cumple una, tiene otra a medias y le falta la tercera (mínimo privilegio,
que entra a Diferido). `kit-orquestacion` gana la forma observada de un reparto grande y cierra
la contradicción agrupar/oleadas. Núcleo intacto (133/150). Council de 3 lentes + síntesis:
`aprobada con cambios`, todos aplicados; acta en `docs/pruebas/council-v1.19.3.md`. CI en verde.
**18 arreglos sobre 32 líneas, y ninguna capa de revisión agotó a la siguiente** — el dato está
en el acta y es el hallazgo más reutilizable de la ronda.

**v1.19.2 EN MAIN E INSTALADO** (PR #35, 2026-09-08): regla de esfuerzo antes que modelo, con
excepción de latencia, y agente `sintetizador` (Fable 5.1). Medición previa a la fusión en
`docs/pruebas/medicion-esfuerzo-v1.19.2.md`. **v1.19.1** (PR #12): kit-propuestas gana
"Acercamiento personalizado a un contacto". **Fase 3 (gate de push)** sigue en piloto en la
rama `fase-3-gate-push`, PR #33 en borrador (v1.20); está activo en esta máquina y en el repo.

## Siguiente paso
- [ ] **PR #37: resolver los 4 avisos abiertos antes de sacarlo de borrador.** Están listados
  en el cuerpo del PR. El de fondo es el segundo: la cita de los autores enumera "auditable
  rollback of contaminated refinements" entre lo que el despliegue seguro **requiere**, así que
  deducir que Prime Agent "ya tenía" ese control sigue siendo inferencia propia — y el kit se
  acredita "Rollback auditable: sí" sin señalar que es justo el control que la evidencia muestra
  insuficiente. Los otros tres son aritmética del acta, una ruta sin enlazar y una palabra.
- [ ] **Pendientes que abre v1.19.2** (los tres en `docs/pruebas/medicion-esfuerzo-v1.19.2.md`):
  re-juzgar el caso divergente leyendo el archivo que produjo el agente; re-correr los brazos 1 y
  3 bajo el mismo núcleo para no depender de n = 2; medir calidad en síntesis (pide caso dorado
  nuevo y firma), que es lo único que bajaría a `sintetizador` de escalón.
- [ ] **Fase 3 — gate de push.** Spec, plan y tareas en
  `~/Trabajo/proyectos/claude-entorno/specs/002-gate-de-push/`. Piloto de 2 semanas en este repo
  → council de 5. Puertas: lunes 2026-09-14 y 21.
- [ ] Primer lunes con el kit v1.19 activo: `/revisar-salud` en claude-entorno decide si
  rutas-fantasma y backstop cruzan la puerta de la fase 1.

## Cómo retomar
- `bash verificar.sh` (todo OK) · `bash hooks/test-backstop-cierre.sh` · `bash scripts/rotar-continuar.sh autotest`.
- Ver qué hay en la máquina: `head -2 ~/.claude/CLAUDE.md` y `jq '.hooks|map_values(length)' ~/.claude/settings.json`.
- Todo cambio por PR + council; el PR sale en borrador. Leer `GOBERNANZA.md` antes de tocar el núcleo.

## Bloqueadores / esperas
- PR #37: espera decisión humana sobre los 4 avisos. No bloqueado técnicamente.
- **Trampa de proceso detectada el 2026-09-08:** el gate de push y el backstop de cierre se
  pisan — el hook exige actualizar `CONTINUAR.md`, y cualquier commit invalida el sello, así que
  cerrar sesión en este repo cuesta una corrida completa del gate de más. Se arregla haciendo que
  el sello ignore commits que solo tocan `CONTINUAR.md`. Sin proponer todavía.

## Última decisión relevante
- 2026-09-06 Gate de push = Sello de push v2 (hook PreToolUse + helper + comando), no Esclusa ni check de GitHub → DECISIONES.md de claude-entorno.
