# Comparativa de cuerpos: las 8 skills del kit vs otros autores (2026-07-10)

Insumo del council v1.8 (`docs/pruebas/council-v1.8.md`). Método: 4 subagentes
comparadores (Sonnet) por grupo de dominio, cada uno leyendo NUESTRAS skills del
repo y los SKILL.md crudos de los mejores equivalentes externos (fuentes con URL
+ fecha de consulta 2026-07-10 + licencia verificada por carpeta/repo, no
asumida). Regla: solo mejoras de CUERPO (1-2 líneas); cambios de description
solo con brecha de disparo evidenciada (no se encontró ninguna). ECC excluido
(cosechado en v1.6; sin cambio mayor desde 2026-07-08: solo rename y release
v2.0.0 de 2026-06-10).

## Fuentes revisadas y licencias

| Fuente | Licencia | Uso |
|---|---|---|
| obra/superpowers v6.1.1 (test-driven-development + testing-anti-patterns, systematic-debugging, verification-before-completion, requesting-code-review, receiving-code-review, brainstorming, writing-plans) | MIT | C1, C2, C3, C7 |
| anthropics/skills: doc-coauthoring, internal-comms, theme-factory | Apache 2.0 | C4 (idea Reader Testing), C6 (idea formato 3P) |
| anthropics/skills: pptx, xlsx | All rights reserved | Solo ideas re-expresadas (C12); prohibido copiar texto |
| coreyhaines31/marketingskills (copywriting) | MIT | C5 |
| daymade/claude-code-skills (deep-research, 1,261★) | MIT | C8 |
| nimrodfisher/data-analytics-skills (programmatic-eda, root-cause-investigation) | Sin licencia → ideas re-expresadas | C9, C10 |
| alirezarezvani/claude-skills (financial-analyst) | MIT | C11, C13 |
| czlonkowski/n8n-skills (workflow-patterns, error-handling) | MIT | C14, C15 |
| mgechev/skills-best-practices (2,111★) | Sin licencia | Nada a cuerpos (es manual de meta-autoría; sus límites ya los cumplimos) |
| hamelsmu/evals-skills | MIT | Nada (calibra jueces contra datasets etiquetados; el Council juzga decisiones irrepetibles) |
| Weizhena/Deep-Research-skills (1,594★, el más popular del dominio) | MIT | Nada — su propio SKILL.md carece de verificación de fuentes; kit-research ya es más riguroso en el eje que importa |
| 199-biotechnologies/claude-deep-research-skill (840★) | Sin licencia | Nada — su regla "encuentra ≥3 problemas o re-examina" fabrica objeciones (el "council teatral" que el kit prohíbe) |
| EveryInc/charlie-cfo-skill | — | Nada — umbrales de sector SaaS: bloat de dominio para una skill genérica |

## Las 15 candidatas y su destino (veredicto del council v1.8)

| # | Skill | Candidata | Destino |
|---|---|---|---|
| C1 | kit-codigo | Mocks solo para aislar (no afirmar sobre el mock; sin métodos test-only en producción) | Entra (Higiene) |
| C2 | kit-codigo | 3 fixes fallidos → parar y replantear | Entra ajustada ("hipótesis de origen o diseño de fondo", no "arquitectura") |
| C3 | kit-codigo | Verificar diff/output real del subagente, no su "listo" | Entra (Checklist) |
| C4 | kit-presentaciones | Lector fresco sin contexto | Entra FUSIONADA en el ensayo de flujo §6 |
| C5 | kit-redaccion | Números concretos, no adjetivos, en estatus | Entra (Bien hecho §Estatus) |
| C6 | kit-redaccion | Esqueleto del formato Estatus | Entra (Proceso §3) — corrección de inconsistencia interna |
| C7 | kit-propuestas | Hallazgo de evaluador que no resista verificación se descarta con razón | Entra (Veredicto) |
| C8 | kit-research | Señalar fuentes viejas | Entra FUSIONADA en el ítem URL+fecha del checklist (estaba triple-sombreada) |
| C9 | kit-analisis-datos | El grano del dato (qué es una fila) | Entra (Proceso §1) |
| C10 | kit-analisis-datos | Explicar ruido como si fuera señal | Entra ajustada (Errores típicos) |
| C11 | kit-finanzas | Validar entrada externa antes de calcular (GIGO) | Entra (Proceso §1) |
| C12 | kit-finanzas | Fórmula viva en hojas de cálculo, no valores pegados | Entra (checklist "re-ejecutables", no §5) |
| C13 | kit-finanzas | Contraste de plausibilidad contra referencia externa | FUERA (2 de 3 lentes): tercera capa sobre verificación ya completa; implausibilidad ya entra por C11 |
| C14 | kit-automatizacion | La prueba no dispara el efecto real (correo/cobro/publicación) | Entra (§4) — corrección de contradicción interna |
| C15 | kit-automatizacion | Señal externa de última corrida (heartbeat) | Entra ajustada (§2, fraseo proporcional) |

## Notas de honestidad de los comparadores

- Descartes documentados con razón en cada dominio (no se forzaron mejoras).
- Ningún cambio de description propuesto: no se halló brecha de disparo
  evidenciada en ninguna de las 8.
- Regla derivada para futuras rondas (council): tope de cosecha ≤ 2 adiciones
  netas por skill por ronda + prueba "¿ya está dicho?" — ver GOBERNANZA.
