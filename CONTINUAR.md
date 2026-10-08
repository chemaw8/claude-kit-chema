# CONTINUAR — claude-kit-chema  ·  cierre 2026-10-08  ·  commit d6a269a (rama cierre/v1.31.1)  ·  cierre limpio: sí
> Estado vivo de sesión. Hechos estables en README.md, GOBERNANZA.md y CLAUDE.md; registro histórico en docs/bitacora.md.

## Dónde vamos
Estado al 2026-10-08: v1.31.1 fusionada por PR #83 e instalada en Claude Code y pi. Limpieza ortográfica terminada,
YAML corregido y pruebas completas. Informes originales y contraste de clasificación en `docs/pruebas/council-v1.31.1.md`.
El tripwire detectó la instalación y pidió medir entregables y disparo real. Ese seguimiento pertenece a
evals-entregables: su CONTINUAR y sus archivos de estado son la fuente del resultado, no se duplica aquí.

## Siguiente paso
- [ ] `cegar.sh`: falta un uso real (2 de 3; ambos falsos positivos). Mantener el criterio de retiro de v1.31.
- [ ] `/por-que`: anotar los usos reales en el acta v1.30; anunciar un uso no acredita su resultado.
- [ ] Arenas desde Claude Code: documentar las primeras dos cuando haya trabajo adecuado.
- [ ] Segunda corrida real de `/crear-verificacion`, en otro proyecto con interfaz.
- [ ] PR #82 (v1.32): conserva su aprobación pendiente; después del parche GitHub lo marca con conflictos.
      Actualizar su base y resolver metadatos antes de cualquier fusión, sin reintroducir el YAML inválido.
- [ ] Vigía de v1.25 y revisión programada del 2026-10-28: conservan sus criterios, fuera de esta limpieza.

## Cómo retomar
- Abrir: `docs/pruebas/council-v1.31.1.md`, `DECISIONES.md` y el estado real de los PR.
- Correr: `bash verificar.sh` → código 0 y sin FALLA.
- Disparo: `python3 docs/pruebas/disparo.py --modelo sonnet --paralelo 3` → banco completo, sin errores de ejecución,
  con proporcional y fronteras aprobados. Salida final: `docs/pruebas/council-v1.31.1-crudos/gate-disparo.txt`.
- Comprobar instalación: comparar el núcleo entre marcadores y las copias del kit, no solo la versión de la cabecera.

## Bloqueadores / esperas
- Ninguno para v1.31.1. La autenticación Anthropic respondió OK tras renovar acceso el 2026-10-08.
- El PR #82 es otra decisión y no está incluido en este cierre.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Limpieza v1.31.1 | fusionada e instalada | cerrado | ninguno |
| Clasificación del council | informes archivados; 5/6 clases de acciones coinciden, mismo veredicto | cerrado como sonda, no prueba de superioridad | ninguno |
| Piezas de pstack | esperan evidencia de uso real | tabla de siguientes pasos | trabajo real apropiado |
| Evals | siguen con skills y banco firmado de 13 | seguimiento en evals-entregables | tripwire |

## Última decisión relevante
- 2026-10-08: limpieza publicada e instalada; no se incorporan reglas ni el PR #82.
- 2026-10-07: la línea base sigue con skills y el PR #81 se cierra sin fusionar (evals-entregables/DECISIONES.md).

---
## Detalle vivo
- Repo público: no copiar casos, ids privados de clientes, recibos de modelos ni cifras de negocio.
- Los puntos ciegos de muletillas quedan documentados como mejora opcional; no se añadió una ronda nueva.
- Fusionar con `gh api -X PUT …/pulls/<n>/merge`, no `gh pr merge`.
