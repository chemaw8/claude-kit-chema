# CONTINUAR — claude-kit-chema  ·  cierre 2026-08-30  ·  commit 6320308  ·  cierre limpio: sí
> Estado vivo. Los hechos estables (qué es, cómo instalar, gobernanza) viven en
> README.md y GOBERNANZA.md, no aquí.

## Dónde vamos
**v1.15 en main e instalada, kit congelado** (ver DECISIONES.md: cinco propuestas de
mejora medidas y descartadas). El README ya explica **qué hace bien el kit con sus
mediciones**, no con adjetivos — es lo que lo distingue de un kit de prosa.

## Siguiente paso
- [ ] Nada en el kit. El siguiente trabajo está **fuera**: llevar el harness de
      `evals-entregables` al bot de Converzia. Terminado = 2-3 casos dorados del bot
      escritos y el juez midiendo si Sofía hace bien su trabajo, no solo si el código
      corre (hoy: 0 capturas en ~4,600 llamadas con las pruebas en verde).

## Cómo retomar
- Abrir:    `DECISIONES.md` primero (dice qué ya se descartó y por qué), luego `CHANGELOG.md`
- Correr:   `bash verificar.sh` y `bash scripts/rotar-continuar.sh autotest`
- Verificar arranque: ambos deben dar exit 0

## Bloqueadores / esperas
- Ninguno.

## Frentes abiertos
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|
| Kit v1.15 | congelado por decisión medida | nada hasta que el reporte semanal muestre un fallo recurrente | — |
| Regla de modelo en workflows | identificada, no aplicada | una línea en kit-orquestacion, por PR | decisión de José |
| Hábito `lector-fresco` | 1 uso en 60 días | invocarlo antes de que un entregable salga a dirección | — |

## Última decisión relevante
- 2026-08-29  Congelar el kit; sandbox fuera del kit; sobrecosto de repartir es ~4× → DECISIONES.md

---
## Detalle vivo
- **Mediciones que sostienen el congelamiento**: banco de disparo 27/27 con las 70
  skills reales · 119 invocaciones de skills del kit en 60 días (51% del total) ·
  compactación en 8 de 1,145 sesiones · 83% de solape vault↔memoria · `verificador`
  0 usos, `evaluador-council` 8, `lector-fresco` 1.
- El **primer lunes con el reporte de salud arreglado es el 31-ago**: el falso
  positivo de `[cyber]` ya está corregido en `claude-entorno` (contaba su propio
  MEMORY.md; 101 coincidencias del grep contra 20 eventos reales).
- Ola 3 de fichas (~18 proyectos): con `/proyecto-init` al reentrar, nunca en lote.
- Investigación de respaldo en `~/Trabajo/investigacion/`:
  `2026-08-28-vanguardia-para-ultracode.md` (incluye la config de sandbox probada) y
  `2026-08-28-speculative-ptc-y-huecos-eficiencia.md`.
