<!-- Reporte crudo, sin editar. council-anthropic (anthropic/claude-opus-5-5, esfuerzo max), lente abogado del diablo, 2026-10-08. Se archiva para poder rehacer la síntesis (pedido de la resíntesis v1.11 y del acta v1.30). -->

## Veredicto: **aprobada con cambios**

Corregir la ortografía del kit es razonable, barato y se puede revertir. Pero tal como está, la rama rompe la carga de 5 de las 9 skills en pi, y ni el gate de disparo ni `verificar.sh` pueden detectarlo.

**Conflicto de interés:** soy de la familia Anthropic. Lo más probable es que el autor también lo sea.

**Límite de esta revisión:** no tuve shell, así que no corrí `git diff`, `verificar.sh` ni `muletillas.sh`. Revisé los archivos de la rama directamente (HEAD `dba520f`, basada en main `654a009`). Para comparar con main usé las copias instaladas en `~/.claude`, que son las de main.

## Hallazgos

### 1. (Grave) Cinco descriptions de skills dejan de ser YAML válido, y pi las descarta

**Qué pasa.** Donde había raya, ahora hay dos puntos seguidos de espacio dentro de un texto sin comillas en el frontmatter. En YAML, «`description: texto: más texto`» es un mapeo anidado que no está permitido, así que el parser falla.

**Evidencia:**
- Busqué `^description: [^'"].*: ` y da estas skills sin comillas:
  - `skills/kit-research/SKILL.md:4` («investigar con fuentes: comparativas»)
  - `skills/kit-finanzas/SKILL.md:4`
  - `skills/kit-codigo/SKILL.md:4` («tocar código: al crear»)
  - `skills/kit-analisis-datos/SKILL.md:4`
  - `skills/kit-automatizacion/SKILL.md:4`
- En main esas descriptions no llevaban dos puntos. Por ejemplo, `~/.claude/skills/kit-research/SKILL.md:4` dice «con fuentes — comparativas».
- Las tres que ya tenían dos puntos (`kit-orquestacion`, `kit-redaccion`, `kit-propuestas`) van entre comillas simples. El problema ya se conocía y se resolvió así en esas tres.
- pi lee las descriptions con YAML estricto:
  - `~/.npm-global/lib/node_modules/@earendil-works/pi-coding-agent/dist/utils/frontmatter.js` usa `parse` del paquete `yaml`.
  - En `dist/core/skills.js:221-229`, si ese `parse` falla, la skill se descarta: `return { skill: null, diagnostics }` y solo queda un aviso.
- Ya había pasado antes. `pi-harness/docs/validacion-001.md:143` dice: «las descripciones del kit llevan `: ` dentro → `YAMLParseError` … Claude Code es laxo con eso». Por eso `traducir-agentes.py:13-14` entrecomilla las descriptions de los agentes, pero ese arreglo no cubre las skills.
- pi es un consumidor real del kit: esta misma sesión corre en pi con `~/.pi/agent/AGENTS.md` y lista las skills desde `~/.claude/skills/kit-*`.
- Al reinstalar, pi perdería, entre otras, `kit-research`, que es la skill más usada (46 invocaciones según DECISIONES 2026-08-29), y `kit-codigo`.

**Por qué el gate no lo vio:** `docs/pruebas/disparo.py:16` lee la description con una expresión regular, y `verificar.sh:21` con awk. Ninguno de los dos interpreta YAML. El 21/21 sigue siendo cierto en Claude Code, pero no dice nada de pi.

**Qué cambiar:**
- Poner las 5 descriptions entre comillas simples, igual que las otras tres. No cambia el texto que ve el enrutador. Vale la pena hacer lo mismo con las de agentes y comandos que también tienen dos puntos (`verificador`, `lector-fresco`, `sintetizador`, `cierre`, `proyecto-init`, `revisar-antes-de-subir`): Claude Code las tolera, pero cualquier otro consumidor estricto falla igual.
- Agregar a `verificar.sh` una línea que marque `FALLA` cuando una description sin comillas contenga dos puntos y espacio. No necesita dependencias.

Aclaración: no lo ejecuté en pi. La conclusión sale del código del parser y del antecedente documentado.

### 2. (Menor) Quedan rayas y prefijos que el script no detecta, uno de ellos en el núcleo

**Qué pasa.** La cifra «F9 55 → 1, F12 19 → 0» es cierta según el script. Pero el script no ve dos casos, y por eso la limpieza quedó incompleta justo en los archivos con más uso.

**Evidencia:**
- La regla F9 (`muletillas.sh:48`, `\S \u2014 \S`) se aplica línea por línea. Una raya al inicio de línea no la detecta: `nucleo/CLAUDE.md:48` dice «Cargar de más no es gratis / — degrada el acierto». En pantalla se lee como raya espaciada, y está en el archivo que se carga en todas las sesiones.
- `muletillas.sh:100` borra el código en línea antes de buscar. Eso deja un espacio antes de la raya y la regla ya no la detecta:
  - `agents/sintetizador.md:26` («`rechazada` — o, si»): justo el agente que redacta las actas.
  - `commands/proyecto-init.md:130` («`CLAUDE.md` — algunos»).
- Fuera del conjunto que se midió:
  - `skills/kit-codigo/estandar-proyectos.md:3` todavía dice «re-deduzca», aunque la propuesta da `rededucir` por corregido.
  - Ese mismo archivo tiene 7 rayas espaciadas (líneas 14 y 38-47).
  - `commands/proyecto-init.md:79` («multi-sesión») está dentro de la plantilla de la ficha.

**Qué cambiar:** hay dos opciones.
- Corregir esas líneas. Como una de ellas está en el núcleo, el gate tiene que volver a correrse sobre el árbol final.
- O bien dejarlas y reescribir la cifra como «según el script, que no ve rayas al inicio de línea ni junto a código», con la lista de las que quedan.

### 3. (Trámite) El resultado del gate no está donde lo pide el RUNBOOK

`docs/pruebas/RUNBOOK.md:60` pide pegar el resultado en `disparo-descriptions.md` con fecha. El 21/21 sobre `e480497` solo aparece en el acta del council. Además, si se arregla el hallazgo 2 en el núcleo, el hash cambia.

## El mejor argumento en contra, y por qué no basta

El congelamiento dice que nada entra sin evidencia, y aquí la evidencia del beneficio es casi nula. La comparación que importa para este PR es «con kit» contra «kit sin rayas»: 2 de 10 contra 1 de 10. Eso es ruido, peor todavía que el p ≈ 0.47 que se cita, que compara con kit contra sin kit.

Aun así, no lo considero un motivo para rechazar:
1. La propuesta no agrega ninguna regla ni capacidad. Corrige la ortografía contra la norma de la RAE y quita una contradicción interna: el kit recomienda `muletillas.sh` en el checklist de `kit-redaccion` y su propio texto fallaba esa revisión 74 veces.
2. Se revierte con un solo `git revert`.
3. La v1.27 ya abrió el precedente al quitar la raya de `kit-redaccion` «mientras tanto».

Exigir un A/B con poder estadístico para una corrección ortográfica sería sobreingeniería. El riesgo real no estaba en la falta de evidencia del beneficio, sino en lo que se rompe al aplicarlo: el hallazgo 1.

## Qué está bien

- El alcance es honesto. La propuesta reconoce que el beneficio no está medido y que el kit no es la fuente principal de rayas.
- Ninguna frase gatillo cambia, y las descriptions que ya iban entre comillas siguen bien formadas.
- El mandato del evaluador solo cambia en una palabra (`sobreingeniería`). Ninguna copia literal fuera de `docs/` queda desalineada: solo `skills/kit-propuestas/SKILL.md:81` contiene «exigir controles de nivel corporativo».
- Tratar `anti-secretos` como código y no como prefijo es lo correcto, porque es el nombre de un hook.
- La rama sale limpia de main: el reflog muestra que se reinició desde `654a009` y no arrastra el PR #82.
