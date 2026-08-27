# CONTINUAR — claude-kit-chema  ·  cierre 2026-08-27  ·  commit 626ccea  ·  cierre limpio: sí
> Estado vivo. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md y GOBERNANZA.md, no aquí.

## Dónde vamos
v1.13 mergeada a main (comandos `/proyecto-init` y `/cierre` + fichas de proyecto).
v1.14 lista en la rama `fix-auditoria-v114`: arregla lo que una auditoría adversarial
de 13 agentes encontró en el sistema de fichas. Falta su PR + merge.

## Siguiente paso
- [ ] Abrir el PR de `fix-auditoria-v114` hacia main y mergear. Terminado = v1.14 en
      main y reinstalada en ~/.claude con `bash instalar.sh`.

## Cómo retomar
- Abrir:    `CHANGELOG.md` (entrada v1.14) y `docs/superpowers/specs/2026-08-26-comandos-ficha-design.md`
- Correr:   `bash verificar.sh` y `bash scripts/rotar-continuar.sh autotest`
- Verificar arranque: ambos deben dar exit 0

## Bloqueadores / esperas
- Ninguno técnico. El merge de v1.14 es decisión de José (gobernanza: PR + council).

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| v1.14 (arreglos del audit) | lista en rama, verde | PR + merge | decisión de José |
| Decisiones para José | 2 abiertas | PII de callcenter · ola 3 bajo demanda vs lote | — |

## Última decisión relevante
- 2026-08-26  Comandos de ficha aprobados por council 4/4 (con cambios) → CHANGELOG v1.13

---
## Detalle vivo
- El audit (ultracode, 13 agentes) confirmó ~17 hallazgos y refutó 1; todos con
  arreglo proporcional ya aplicado en v1.14.
- Loops de mejora pendientes (bajo demanda, no urgentes): cerrar el lazo
  observabilidad→evals en `/revisar-salud`; scan de frescura semanal colgado del
  timer de observabilidad ya existente.
- Ola 3 (~17 proyectos sin ficha): hacer con `/proyecto-init` AL REENTRAR a cada
  uno, no en lote (varios están dormidos y una ficha en frío nace vieja).
