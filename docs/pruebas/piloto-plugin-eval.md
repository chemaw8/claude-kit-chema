# Piloto de `claude plugin eval` — 2026-09-29

**Conclusión:** `plugin eval` **complementa** al gate de disparo; no lo sustituye. Mide otra cosa: si el modelo, de
verdad y con herramientas, llama a la skill (`tool_used: Skill`), mientras que el gate pregunta a un juez qué skill
*debería* cargar leyendo solo las descriptions. En los 3 casos el gate dijo ✓ y la activación real fue bastante menor.

## Qué se corrió
- Claude Code 2.1.283, modelo `opus`, kit v1.23.1 como plugin (copia en `/tmp`, `--trust-plugin`, `--no-publish`).
- 3 casos del banco canónico (`banco/disparo.md`): #5 (datos), #16 (finanzas) y #27 (frontera aprobación ↔ redacción).
  Casos en `plugin-eval/`, con graders sin costo: `tool_used: Skill` con `input_match` al nombre de la skill; el #27
  suma que `kit-redaccion` NO se active.
- `--ablation none`: un grader de Skill no puede pasar sin el plugin, así que el brazo sin plugin no informa nada.
- Reproducir: `claude plugin eval . --eval-dir docs/pruebas/plugin-eval --ablation none --runs 3 --model opus --no-publish`.

## Resultado (corridas que activaron la skill esperada)
| Caso | Gate de disparo | Real, sin núcleo | Real, con núcleo |
|---|---|---|---|
| #5 datos («¿Por qué bajaron las ventas en junio? Te paso el CSV») | ✓ | 2/3 | 0/3 |
| #16 finanzas («¿Cuánto le cobramos al cliente por el portal?») | ✓ | 0/4 | 2/3 |
| #27 frontera aprobación → propuestas, sin redacción | ✓ | 3/3 | — |

Costo: 1.79 USD nominales en 16 corridas (~0.11 por corrida con Opus), 136 s la primera tanda.

## Qué se aprendió
1. **No hay contaminación por el kit instalado** (la duda del 2026-09-28): cada corrida arranca con HOME, cwd y
   configuración temporales, sin `~/.claude`, CLAUDE.md, skills ni MCP del usuario (doc oficial, «How runs are
   isolated»). La comparación con y sin plugin es limpia.
2. **Tampoco carga el núcleo.** El plugin trae skills, agentes y hooks; el núcleo lo instala `instalar.sh` en
   `~/.claude/CLAUDE.md`. Para medirlo como se usa, la variante «con núcleo» lo pasa en `append_system_prompt` (se
   genera al vuelo desde el núcleo instalado; no se versiona para que no envejezca).
3. **Por qué falló #16 sin núcleo** (trace revisado): leyó «¿cuánto le cobramos?» como *recuperar* una cifra, buscó
   con Grep/Glob, no halló nada y pidió el alcance. Nunca cargó `kit-finanzas`. Con núcleo la cargó primero en 2 de 3.
4. **Por qué bajó #5 con núcleo:** el caso dice «te paso el CSV», pero el directorio está vacío. Con núcleo, Claude
   buscó el archivo, no lo halló y lo pidió, sin cargar la skill. Es un defecto del **caso**: sin el archivo, pedirlo
   es la respuesta correcta. Un caso de datos necesita el CSV en el workspace (`scaffold_script` con `--scaffold`).
5. Con 3 corridas por caso el ruido es alto; nada de esto basta para cambiar una description.

## Recomendación
- El **gate de disparo sigue** como control barato de cada cambio a descriptions (un juez Sonnet, centavos).
- `plugin eval` va como **medición periódica de activación real**, con casos que traigan su material (CSV, contexto)
  y el núcleo en `append_system_prompt`. El banco completo (30 casos × 3 corridas) costaría del orden de 10 USD por pasada.
- **Hallazgo que vigilar:** `kit-finanzas` no se activó en la pregunta de cobro sin núcleo (0/4). Si se repite con más
  corridas y con el núcleo, es candidato a ajustar su description («cuánto cobrar», «cuánto le cobramos»).
