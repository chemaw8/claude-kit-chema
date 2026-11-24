# Resultados — caso dorado modelo-negocio-01 (2026-11-22)

**Conclusión de la primera ronda: con el criterio fijado antes de correr, la skill no demostró mejora. El brazo con
`kit-modelo-negocio` sacó 82.7 de media y el brazo sin ella 91.7 (−9.0).** Según `rubrica.md`, si B queda
abajo, el PR se cierra. Se optó por corregir la skill y repetir el mismo caso: ver «Segunda ronda».

## Cómo se corrió
- `claude plugin eval` 2.1.326, `--model opus`, 3 corridas por brazo, `--ablation none`, núcleo en
  `append_system_prompt`, insumo copiado con `scaffold_script`. A = `origin/main` (sin la skill); B = rama del PR #113.
  Ninguno de los dos brazos tenía `docs/` (no veían la clave).
- La skill se activó en 3 de 3 corridas de B y en 0 de 3 de A (grader `tool_used: Skill`).
- Se extrajo la respuesta final y los `.md` entregados por cada corrida (sin `CONTINUAR.md`, `DECISIONES.md` ni los
  JSON, que delatarían el brazo), se cegó con `scripts/cegar.sh etiquetar` y la calificaron dos jueces de familias
  distintas (codex y kimi) con `rubrica.md` y `clave.md`, sin el criterio de éxito.

## Puntajes (jueces codex / kimi)
| Corrida | Letra | T1–T7 | Cifras | Hipótesis | Quién paga | Recomendación | Total codex | Total kimi |
|---|---|---|---|---|---|---|---|---|
| A1 | E | 52 / 56 | 12 / 9 | 10 | 8 | 14 | 96 | 97 |
| A2 | B | 56 | 0 | 10 | 8 | 14 | 88 | 88 |
| A3 | A | 52 | 12 / 9 | 10 | 4 | 14 | 92 | 89 |
| B1 | F | 56 | 0 | 10 | 4 | 14 | 84 | 84 |
| B2 | C | 56 | 0 | 10 | 8 | 14 | 88 | 88 |
| B3 | D | 48 | 0 | 10 | 4 | 14 | 76 | 76 |

| Brazo | Media codex | Media kimi | Media | Corridas con ≥ 5 de 7 trampas | Costo | Duración media |
|---|---|---|---|---|---|---|
| A (sin skill) | 92.0 | 91.3 | 91.7 | 3 de 3 | $3.27 | 229 s |
| B (con skill) | 82.7 | 82.7 | 82.7 | 3 de 3 | $9.46 | 581 s |

Los jueces no difirieron en más de 10 puntos en ninguna entrega.

## Lectura
- **Efecto techo en las trampas.** Los dos brazos detectaron casi todas las trampas sembradas (T1–T6 en las 6
  corridas). Con Opus y el kit actual, el caso no separa: el kit sin la skill ya caza estos errores.
- **La diferencia sale de las cifras.** Las tres corridas de B (y una de A) restaron una comisión de cobro con tarjeta
  que el insumo no trae (supuesto marcado, «3.5% + IVA»); por eso sus contribuciones no coinciden con la clave y
  la rúbrica les da 0 en cifras. Viene de la skill («comisiones de cobro incluidas»). La rúbrica no se cambió después
  de correr.
- **Costo.** B costó 2.9 veces más y tardó 2.5 veces más: hipótesis en JSON, script de economía, CONTINUAR.
- **Qué no mide este caso.** Coherencia entre hipótesis en un caso largo de varias sesiones, P&L y presentación
  generados: el encargo era de un solo turno.

## Segunda ronda, 2026-11-22 — skill corregida, mismo caso y misma rúbrica
Cambios a la skill a partir de la primera ronda (genéricos, no del caso): la cifra base usa solo lo que trae el
insumo y un costo que falta va como sensibilidad aparte; comparar el precio con lo que el segmento ya gasta;
economía de cada esquema de pago aunque sea inviable; modo proporcional para encargos de una sola respuesta.
Se repitieron 3 corridas del brazo con skill (C) y se volvieron a calificar junto con las 3 de A ya existentes, en una
sola tanda cegada (letras nuevas), con los mismos dos jueces. Se quitaron de las entregas dos menciones a
`coherencia.py` que delataban el brazo.

| Corrida | Total codex | Total kimi |
|---|---|---|
| A1 | 96 | 100 |
| A2 | 88 | 88 |
| A3 | 89 | 93 |
| C1 | 100 | 100 |
| C2 | 100 | 100 |
| C3 | 89 | 92 |

| Brazo | Media codex | Media kimi | Media | Corridas con ≥ 5 de 7 trampas | Costo | Duración media |
|---|---|---|---|---|---|---|
| A (sin skill, recalificado) | 91.0 | 93.7 | 92.3 | 3 de 3 | $3.27 | 229 s |
| C (skill corregida) | 96.3 | 97.3 | 96.8 | 3 de 3 | $7.87 | 519 s |

**Lectura con el criterio fijado:** +4.5 puntos, entre 0 y 15 → no hay evidencia suficiente; el PR sigue en borrador.
Advertencias: con 3 corridas por brazo la diferencia está dentro del ruido (A va de 88 a 100); la skill se corrigió
después de ver los fallos de este mismo caso, así que esta ronda tiende a favorecerla; y el caso tiene techo (los
dos brazos detectan casi todas las trampas). La primera ronda (−9.0) y esta (+4.5) juntas no muestran una mejora
de 15 puntos. Lo que el caso no mide —coherencia en trabajo de varias sesiones, P&L y presentación generados— pide un
caso dorado distinto, fijado antes de correr.
