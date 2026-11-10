# Medición — Fable 5.2 contra Opus 5.5  (evidencia de v1.35.0)

Se midió el 2026-11-09, el día que Fable 5.2 quedó disponible, antes de mover cualquier escalón de
la escalera de modelos. Igual que en `medicion-esfuerzo-v1.19.2.md`, solo van resultados
**relativos**: el kit es público y no publica cifras de consumo, nombres de casos ni rutas de la
máquina donde se midió.

## Método

- **Dos baterías del mantenedor**, privadas:
  - **Entregables**: 14 casos de negocio con respuesta auditada y trampa plantada, 32 corridas
    (algunos casos se repiten 3 veces). Un agente fresco con el kit produce el entregable y un juez
    fijo (Sonnet) lo califica contra el criterio auditado. Se corrió con dos instrumentos: solo el
    núcleo, y núcleo + skills + python.
  - **Disparo**: 30 peticiones × 3 corridas. Cuenta si se activa la skill correcta (`claude plugin eval`).
- **Referencia**: Opus 5.5 con el mismo instrumento. En disparo, los dos brazos corrieron seguidos el
  mismo día, con el mismo kit (v1.34.4) y el mismo Claude Code.
- **Regla fijada antes de correr** (entregables): gana si sube al menos 3 casos; pierde si baja al
  menos 3; lo demás es inconcluso. El ruido medido de una corrida es de ±2 casos.

## Resultados

| Batería | Opus 5.5 | Fable 5.2 | Lectura |
|---|---:|---:|---|
| Entregables, solo núcleo: casos | 10/14 | 10/14 | inconcluso |
| Entregables, solo núcleo: criterios | 77 % | 83 % | a favor, dentro del ruido |
| Entregables, núcleo + skills + python: casos | 10/14 | 10/14 | inconcluso |
| Entregables, núcleo + skills + python: criterios | 80 % | 84 % | a favor, dentro del ruido |
| Disparo | 81/90 | **90/90** | Fable no falla ninguno; Opus falla en 6 de 30 peticiones |
| Costo por corrida | 1× | 2.0× (entregables) · 2.35× (disparo) | precio de lista exactamente 2× (abajo) |
| Latencia | 1× | ≈ 1.1× (mediana por entregable) · 1.27× (disparo completo) | **ya no es más rápido** |

- **Precio de lista**, consultado el 2026-11-09 en platform.claude.com/docs/en/about-claude/pricing:
  Fable 5.2 cuesta $8 por millón de tokens de entrada y $40 de salida; Opus 5.5, $4 y $20. Las
  lecturas de caché cuestan $0.20 en los dos. Coincide con el costo que reporta Claude Code en cada
  corrida.
- Las mismas tres trampas siguen sin resolverse con los dos modelos: es un hueco del kit o del caso,
  no del modelo.
- El 81/90 de Opus 5.5 repite exactamente el de la línea base anterior (kit v1.34.1): es estable. La
  ventaja de Fable en disparo es la única diferencia de la medición que no cabe en el ruido.

## Gate de disparo de esta rama

Núcleo v1.35.0 sin instalar (`DISPARO_NUCLEO`), Opus, 30 × 3, el mismo día: **80/90, sin regresiones**, contra
81/90 de v1.34.4. La diferencia de 1 corrida cabe en el ruido: el texto nuevo no mueve el disparo.

## Qué cambia en el kit

1. **Fable 5.2 reemplaza a Fable 5.1** en el escalón de síntesis y juicio (`sintetizador`). Es
   continuidad provisional: esta medición no incluye síntesis, y el disparo no aplica a un agente
   que no elige skills.
2. **La latencia deja de justificar el salto.** Con Fable 5.1 era el motivo; con 5.2 no se sostiene.
   La regla «esfuerzo antes que modelo» sigue igual.
3. **El costo pasa de 2.5× a 2×** por token, frente a Opus 5.5.

## Qué no cambia

- **Los productores siguen en Opus 5.5** (borradores, evaluadores, código): en el trabajo mismo hay
  empate, a doble precio.
- **El hilo principal no lo decide el kit**, porque es la configuración del usuario. El disparo sugiere
  que Fable 5.2 elige mejor qué skill aplicar, que es trabajo del hilo principal y del orquestador. Se
  anota como hallazgo, no como regla: falta medirlo en un orquestador completo con tareas largas.
