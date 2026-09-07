# Council — PR #12: kit-propuestas, acercamiento personalizado a un contacto (2026-09-07)

Propuesta: versión corta del PR #12 de julio (sección de 5 pasos + antipatrón + frase de disparo).
Postura inicial del hilo, antes de leer los reportes: "aprobada con cambios; la duda es si el
lugar correcto es kit-propuestas o kit-redaccion".

Tres evaluadores independientes (Opus 5), solo con la propuesta y el mandato acotado:

| Lente | Veredicto | Hallazgos que cambian la decisión |
|---|---|---|
| Viabilidad y disparo | aprobada con cambios | El paso 5 repetía la frase que dispara Council en la misma skill ("sale de la empresa") → un correo de prospección habría montado un panel; el paso 1 no tenía salida sin resultados o sin buscador; kit-redaccion no remite a esta sección; description a 5 caracteres del tope |
| Costo/beneficio | aprobada con cambios | Description 1,019 chars / 1,038 bytes: recortar la frase de disparo; 3 de 5 pasos duplican al núcleo y a kit-research → comprimir a 3 conservando identidad y confirmación; la falta de recurrencia no justifica rechazo (≈45 tokens/sesión, reversible) |
| Abogado del diablo | aprobada con cambios | El caso central ("mándale un correo a fulano de X") lo captura kit-redaccion y su regla le dice quedarse: sin línea de vuelta la sección no se carga; acotar la investigación a información profesional y pública (privacidad) |

Síntesis (hallazgos verificados contra los archivos): los seis cambios se aplican —frase de disparo
corta (description 971 chars / 990 bytes), remisión desde kit-redaccion, sección comprimida a 3 pasos con
salida sin resultados, ámbito profesional y público, y cláusula de que el acercamiento no dispara
Council por sí solo. El hilo cambió de opinión en dos puntos que no tenía: el choque con el
disparador de Council y la frontera desde kit-redaccion. Veredicto: **aprobada con cambios**,
aplicados en este mismo PR.

Gate de disparo (obligatorio por tocar descriptions): `python3 docs/pruebas/disparo.py` con juez
Sonnet → 21/21 del núcleo, 0 confusiones de frontera; fronteras nuevas 28-30 del banco correctas
(28 y 29 → kit-propuestas; 30 → kit-redaccion). Resultado completo en `disparo-descriptions.md`.
Versión: v1.19.1 (el gate de push conserva la v1.20 en su rama).
