# Tabla de la segunda síntesis (2026-10-08)

Extracto literal de la tabla final devuelta por `sintetizador` (Anthropic Fable 5.1, esfuerzo observado max).
No es el reporte completo. Mismos insumos que la primera síntesis, sin ver su salida.
Veredicto de ambas: **aprobada con cambios**.

| Hallazgo (una línea) | Clase | Quién |
|---|---|---|
| 11 descriptions sin comillas con `: ` dejan de ser YAML válido; pi descarta 5 skills y 3 comandos | actuar | codex, anthropic |
| Quedan rayas espaciadas que `muletillas.sh` no ve, una en el núcleo; la cifra «55→1» es del script, no del kit | actuar | anthropic |
| Agregar a `verificar.sh` FALLA por description sin comillas con `: ` | considerar | anthropic |
| `estandar-proyectos.md` y plantilla de `proyecto-init.md:79` fuera del conjunto medido, sin corregir | considerar | anthropic |
| Mejorar `muletillas.sh` (código inline, inicio de línea) en otro PR | considerar | kimi, anthropic |
| Pegar resultado del gate en `disparo-descriptions.md` con fecha y hash final | considerar | anthropic |
| Diff solo forma: sin cambios de obligación, negación o alcance | anotado | kimi, codex |
| Frases gatillo byte-idénticas; solo `anticontaminación` y `multiagente` cambian fuera de gatillos | anotado | kimi, anthropic, codex |
| Conteos reproducidos al dígito y `verificar.sh` rc=0 | anotado | kimi |
| Sin conflicto con PR #82 (líneas distintas, merge-tree limpio, rama limpia desde `654a009`) | anotado | kimi, anthropic |
| F9 restante en `cierre.md:34` es falso positivo real | anotado | kimi, autor |
| `anti-secretos` a código como nombre de hook, correcto | anotado | codex, kimi, anthropic |
| Mandato del evaluador cambia una palabra ortográfica; actas viejas no se reescriben | anotado | kimi, anthropic |
| Confidencialidad del diff limpia; no toca hooks/scripts/instalador | anotado | kimi |
| Beneficio no medido (2/10 vs 1/10 es ruido); no es motivo de rechazo | anotado | anthropic, autor |
| Conflicto de interés de familia declarado por anthropic | anotado | anthropic |
