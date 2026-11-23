# Resultados — caso dorado modelo-negocio-03 (Lumen, varias sesiones)

**Conclusión, por el criterio fijado antes de correr: diferencia 0.0 (87.27 contra 87.27). La regla dice que con
Δ ≤ 0 la skill se retira del kit.** El brazo con la skill costó 28% menos.

## Cómo se corrió
- `claude plugin eval` 2.1.326, `--model opus`, 5 corridas por brazo. A = kit en `a72731d` (sin la skill); B = kit en
  `f3870ae` (con la skill, congelada). Núcleo en `append_system_prompt`; insumo `lumen/` por `scaffold_script`.
- Skill activa en 4 de 5 corridas de B (B1 no la cargó; cuenta igual). A cargó kit-finanzas en las 5.
- Extracción de respuesta y documentos, reporte objetivo del Excel (`revisar_excel.py` del caso 02), cegado con
  `scripts/cegar.sh` (se quitó de una entrega la mención a `coherencia.py` que delataba el brazo) y dos jueces (codex
  y kimi) con `rubrica.md` sin el criterio de éxito.

## Puntajes (media de los dos jueces)
| Corrida | Skill | Excel entregado | Total |
|---|---|---|---|
| A1 | no | sí | 90.9 |
| A2 | no | sí | 86.4 |
| A3 | no | no | 81.8 |
| A4 | no | sí | 81.8 |
| A5 | no | sí | 95.5 |
| B1 | no se activó | no | 81.8 |
| B2 | sí | sí | 90.9 |
| B3 | sí | no | 79.5 |
| B4 | sí | sí | 95.5 |
| B5 | sí | no | 88.6 |

| Brazo | Media | Costo (5 corridas) |
|---|---|---|
| A (sin skill) | 87.27 | $17.58 |
| B (con skill) | 87.27 | $12.67 |

Umbral para quedarse: max(8, 0.4 × 12.7) = +8. Diferencia: 0.0. Los jueces coincidieron en 9 de 10 entregas; en
la otra difirieron 4.5 puntos.

## Lectura
- **Las trampas de juicio las cazan los dos brazos** (Q1, Q2, Q4, Q6, Q7, Q9 y Q10 casi siempre). Lo que separa las
  entregas es la precisión de la contribución unitaria (Q3), reconocer que el P&L v2 estaba pegado (Q8) y entregar el
  libro (Q11).
- **La skill entregó menos libros:** 2 de 5 contra 4 de 5. En el entorno de prueba Bash no puede escribir archivos.
  Las corridas con la skill dejaron un script generador sin poder correrlo; las de A escribieron el libro en XML con la
  herramienta de escritura.
- **Defecto del instrumento:** el reporte objetivo no probó la sensibilidad en ningún libro (buscaba el precio del caso
  02). Q11 quedó en 0.5 como máximo para todos; afecta igual a los dos brazos.
- **Tres casos, la misma señal:** con el kit actual y Opus 5.5, la skill no mejora la calidad medible en estos
  encargos. En el caso 02 y en este costó menos; en el 01 costó más.
