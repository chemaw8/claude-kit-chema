# CONTINUAR — claude-kit-chema  ·  cierre 2026-10-08  ·  commit 772f794 (rama texto/rayas-y-prefijos)  ·  cierre limpio: sí
> Estado vivo de sesión. Hechos estables en README.md, GOBERNANZA.md y CLAUDE.md; registro histórico en docs/bitacora.md.

## Dónde vamos
Estado al 2026-10-08: v1.31.1 preparada para publicar, con limpieza ortográfica, YAML corregido y pruebas completas.
Council aprobada con cambios, aplicados; informes originales y contraste de dos síntesis en `docs/pruebas/council-v1.31.1.md`.
El PR #82 (v1.32) queda separado y no se aprueba con este trabajo. La línea base de entregables sigue con `skills`
por decisión del dueño; se mide otra vez cuando el tripwire detecte la instalación de este parche.

## Siguiente paso
- [ ] Publicar v1.31.1 por PR con sello y CI; instalar y comprobar copias de Claude Code y traducciones de pi.
- [ ] Tras instalar, ejecutar el tripwire y la línea base en evals-entregables si avisa; registrar resultado allí.
- [ ] `cegar.sh`: falta un uso real (2 de 3; ambos falsos positivos). Mantener el criterio de retiro de v1.31.
- [ ] `/por-que`: anotar los usos reales en el acta v1.30; el anuncio de José no cuenta como uso verificado.
- [ ] Arenas desde Claude Code: documentar las primeras dos, sin inventar corridas para cumplir el conteo.
- [ ] Segunda corrida real de `/crear-verificacion`, en otro proyecto con interfaz.
- [ ] Revisar el PR #82 por su propia decisión; no fusionarlo por arrastre.
- [ ] Vigía de v1.25 y revisión programada del 2026-10-28: conservan sus criterios, fuera de esta limpieza.

## Cómo retomar
- Abrir: `docs/pruebas/council-v1.31.1.md`, `DECISIONES.md`, `git status` y el estado de los PR.
- Correr: `bash verificar.sh` → código 0 y sin FALLA.
- Disparo: `python3 docs/pruebas/disparo.py --modelo sonnet --paralelo 3` → banco completo, sin errores de ejecución,
  con proporcional y fronteras aprobados. La corrida final íntegra está en `docs/pruebas/council-v1.31.1-crudos/gate-disparo.txt`.

## Bloqueadores / esperas
- Ningún bloqueo de autenticación pendiente: pi/Anthropic respondió OK tras renovar acceso el 2026-10-08.
- Publicación e instalación todavía deben comprobarse; no basta que el código esté commiteado.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Limpieza v1.31.1 | terminada y verificada en rama | publicar e instalar | sello y CI |
| Clasificación del council | informes archivados; clases coinciden en 5/6 acciones, mismo veredicto | cerrado como sonda, no prueba de superioridad | ninguno |
| Piezas de pstack | solo falta evidencia de uso real | tabla de siguientes pasos | trabajo real apropiado |
| Evals | con skills; mejoras experimentales cerradas por sus criterios | vigilar regresiones, no perseguir 13/13 | tripwire |

## Última decisión relevante
- 2026-10-08: limpieza de forma sin nuevas reglas; la sintaxis YAML también se verifica contra el consumidor.
- 2026-10-07: la línea base sigue con skills y el PR #81 se cierra sin fusionar (evals-entregables/DECISIONES.md).

---
## Detalle vivo
- El repo es público: no copiar casos, ids privados de clientes, recibos de modelos ni cifras de negocio.
- El falso positivo de `muletillas.sh` junto a código y sus falsos negativos están documentados, no corregidos aquí.
- Fusionar con `gh api -X PUT …/pulls/<n>/merge`, no `gh pr merge`.
