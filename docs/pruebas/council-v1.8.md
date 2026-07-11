# Council — cosecha v1.8 "cuerpos vs otros autores" (2026-07-10/11)

Propuesta evaluada: 15 candidatas de mejora a cuerpos de skill (C1-C15, todas
adiciones de 1-2 líneas, cero cambios de description), producidas por una
comparativa de las 8 skills contra los mejores equivalentes de otros autores
(superpowers, anthropics/skills, mgechev, y las top de comunidad por dominio;
detalle y fuentes en `investigacion/2026-07-10-skills-comparativa-cuerpos.md`).
ECC excluido: ya cosechado en v1.6.

Panel: 3 evaluadores independientes (Opus 4.8, contexto fresco — candidatas +
skills reales leídas del repo + mandato acotado), lentes: anti-bloat/redundancia,
corrección/calidad y abogado del diablo. Síntesis en el hilo principal (Fable 5).
Postura inicial del hilo, fijada antes de leer reportes: *"entran 13-14 de 15;
dudas en C13 (plausibilidad finanzas) y C15 (heartbeat)"*.

## Veredicto: aprobada con cambios — entran 14 (2 fusionadas), fuera 1

| Voto | Candidatas |
|---|---|
| Entra tal cual (unánime) | C1 mocks, C3 diff de subagente, C5 números concretos, C6 esqueleto de estatus, C7 verificar hallazgos de evaluador, C9 grano del dato, C10 ruido vs señal, C11 validar entrada externa, C14 prueba sin efecto real |
| Entra con ajuste de texto | C2 (tres intentos → "replantea la hipótesis de origen o el diseño de fondo", no "arquitectura": sobre-afirmaba), C10 (título "Explicar ruido como si fuera señal"), C15 (fraseo proporcional: heartbeat / marca de última corrida, no infra corporativa) |
| Entra fusionada en texto existente | C4 (lector fresco → dentro del ensayo de flujo §6: el principio "sin narrador" ya estaba escrito 3 veces, solo se añade el método), C8 (fuente vieja → dentro del ítem URL+fecha del checklist: estaba triple-sombreada) |
| Entra con colocación corregida | C12 (fórmula viva → checklist "cálculos re-ejecutables", no §5 de formato), C14 (pegada a la frase "datos verdaderos" de §4) |
| Fuera | C13 (contraste de plausibilidad, finanzas): 2 de 3 lentes la cortaron — tercera capa sobre un paso de verificación ya completo; el tema implausibilidad ya entra por C11; el propio comparador la marcó como la más prescindible |

## Hallazgos decision-relevantes

- **Dos candidatas son correcciones, no adiciones**: C6 (el Estatus era el único
  formato de primera clase sin esqueleto en el Proceso) y C14 ("prueba con datos
  verdaderos" en automatizaciones con efectos externos disparaba el efecto real
  — contradicción interna vigente).
- **C7 se autovalida**: este mismo veredicto la aplicó (los cortes y fusiones son
  hallazgos de evaluador verificados antes de heredarse; el tope inventado a
  mitad de ronda NO se retro-aplicó a candidatas con voto unánime 3-0).
- **Licencias despejadas** (lente de calidad): las 3 ideas de fuentes sin
  licencia libre (C9, C10 de nimrodfisher; C12 de anthropics xlsx all-rights-
  reserved) son conceptos estándar re-expresados en prosa propia; el copyright
  no cubre ideas ni métodos — sin bloqueo ni atribución obligatoria.
- **Regla de gobernanza nueva (del abogado del diablo)**: tope de cosecha —
  máximo 2 adiciones netas por skill por ronda, con la prueba previa "¿ya está
  dicho en el texto completo?". Responde estructuralmente a "¿dónde está el
  límite para que 5 rondas más no dejen las skills ilegibles?". Entra a
  GOBERNANZA con vigencia prospectiva (esta ronda kit-codigo llevó 3 con voto
  unánime; la regla rige desde la siguiente).

## Cambio de opinión del hilo principal (obligación del protocolo)

Confirmación con afinado: la duda sobre C13 se confirmó (fuera) y la de C15 se
resolvió (entra: los tres lentes validaron el punto ciego distinto — el manejo
de errores in-proceso no detecta el proceso que nunca corrió). Cambios que el
panel aportó y el hilo no traía: el texto de C2 sobre-afirmaba, C4/C8 iban a
duplicar principios ya escritos (entraron como fusiones), y el tope de cosecha
prospectivo no estaba en la postura inicial.

## Conteos por evaluador (para el acta)

- Corrección/calidad: 15 entran (2 con ajuste de texto).
- Anti-bloat/redundancia: 12 entran, 2 fusionadas, 1 fuera (C13).
- Abogado del diablo: 9 entran, 4 con ajuste, 2 fuera (C8, C13); mejor caso
  contra el lote: "mayor expansión de una sentada; el ~20% marginal se corta y
  el límite se pone con regla, no ítem por ítem" — incorporado al veredicto
  (C13 fuera, C8 reducida a fusión de media cláusula, tope a GOBERNANZA).
