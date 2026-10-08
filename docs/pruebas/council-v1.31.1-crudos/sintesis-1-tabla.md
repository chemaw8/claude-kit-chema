# Tabla de la primera síntesis (2026-10-08)

Extracto literal de la tabla final devuelta por `sintetizador` (Anthropic Fable 5.1, esfuerzo observado max).
No es el reporte completo. Recibió los tres reportes del panel, la propuesta y la postura inicial del autor.
La segunda síntesis corrió en paralelo, sin ver esta salida. Veredicto de ambas: **aprobada con cambios**.

| Hallazgo (una línea) | Clase | Quién |
|---|---|---|
| Descriptions con `: ` sin comillas → YAML inválido; pi descarta 5 skills y 3 comandos | actuar | Codex, Anthropic |
| Quedan rayas espaciadas en el conjunto medido que el script no ve (núcleo:48, sintetizador:26, proyecto-init:130) | actuar | Anthropic |
| Resultado del gate no pegado en `disparo-descriptions.md` como pide el RUNBOOK | actuar | Anthropic |
| Añadir a `verificar.sh` una FALLA para description sin comillas con `: ` | considerar | Anthropic |
| `muletillas.sh`: código inline y raya a inicio de línea dan falsos positivos y negativos | considerar | Kimi, Anthropic |
| Rayas y prefijos fuera del conjunto medido (`estandar-proyectos.md`, plantilla de `proyecto-init`) | considerar | Anthropic |
| Diff solo forma; frases gatillo byte-idénticas; sin cambios de obligación o alcance | anotado | Kimi, Codex |
| Conteos reproducidos al dígito y `verificar.sh` rc=0 | anotado | Kimi |
| Merge limpio con #82 en ambos órdenes; rama limpia desde `654a009` | anotado | Kimi, Anthropic |
| Mandato del evaluador cambia una palabra; actas viejas intactas; `anti-secretos` como código correcto | anotado | Kimi, Anthropic, Codex |
| Confidencialidad limpia; instalaciones existentes sin riesgo | anotado | Kimi |
| Beneficio casi no medido; la comparación relevante es aún más débil que el p≈0.47 citado | anotado | Anthropic |
| Conflicto de interés de familia declarado | anotado | Anthropic |
