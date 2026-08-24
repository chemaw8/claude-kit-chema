# Council — Kit v1.11 (mecanismo)

Fecha: 2026-08-23
Propuesta: tres subagentes en `agents/`, regla "Presupuesto de contexto" en el
núcleo, y reescritura de la sección de subagentes para decir cuándo delegar.
Panel: 4 evaluadores independientes, Opus 5, contexto fresco, sin ver los
reportes de los demás. Cada uno recibió solo la propuesta autocontenida y el
mandato acotado literal de `kit-propuestas`.

## Postura del hilo principal ANTES de leer ningún reporte

> Apruebo v1.11. Las dos adiciones al núcleo son heurísticas que evitan errores
> caros y están respaldadas por evidencia medida, y los tres subagentes dan
> mecanismo a una regla que llevaba diez versiones sin nada que la aplicara. Mi
> única duda es el +19% de palabras del núcleo.

## Veredicto del panel

| Lente | Veredicto |
|---|---|
| Viabilidad técnica | aprobada con cambios |
| Costo / beneficio | aprobada con cambios |
| Riesgos | aprobada con cambios |
| Abogado del diablo | aprobada con cambios |

**Unánime: aprobada con cambios.** Tres de los cuatro señalaron de forma
independiente el mismo bloqueante (H-1).

## ¿Cambió de opinión el hilo principal?

**Sí, en tres cosas concretas**, y por eso el council no fue teatral:

1. **Iba a mergear algo inerte.** Mi postura inicial daba por hecho que los tres
   agentes se instalaban. No se instalaban: `instalar.sh:10` creaba `skills`,
   `contexto` y `hooks`, y la palabra `agents` no aparecía en todo el archivo.
   Peor: el núcleo ya afirmaba "Agentes listos del kit: verificador,
   evaluador-council, lector-fresco". Habría publicado tres nombres que no
   resuelven, con el núcleo asegurando que existen — la misma "regla sin
   mecanismo" que la versión venía a arreglar, un nivel más arriba.
2. **Dos de mis cifras estaban mal.** El "15×" es una cita mal aplicada
   (Anthropic mide sistemas multi-agente frente a chat, no una delegación frente
   a hacerlo en línea, donde el orden es 2–4×), y el "+19%" comparaba el archivo
   instalado contra el crudo. Las dos las corregí.
3. **Cité como aval algo que no avalaba nada.** Reporté "verificar.sh exit 0"
   como respaldo de v1.11 cuando el linter solo iteraba `skills/*/SKILL.md` y del
   núcleo únicamente miraba el límite de 150 líneas. Era estructuralmente incapaz
   de ver la parte nueva.

## Hallazgos y qué se hizo con cada uno

| # | Lente | Hallazgo | Resolución |
|---|---|---|---|
| H-1 | técnica, riesgos, diablo | `instalar.sh` no copiaba `agents/`; la propuesta era inerte | **Aplicado.** `mkdir` incluye `agents` y hay paso 2b que copia archivo por archivo (nunca `rm -rf` del directorio, para no pisar agentes ajenos). Probado en sandbox, incluida la no-destrucción de un agente propio del usuario. |
| H-1b | técnica, diablo | el linter no veía `agents/` ni el crecimiento del núcleo | **Aplicado.** `verificar.sh` gana 15 comprobaciones: agente prometido existe, `name` coincide, `model` válido, `description` < 1024, y que el instalador siga instalándolos. |
| H-2 | riesgos | el hook imprimía su encabezado fuera del guard de existencia, así que la prueba de presencia del núcleo se satisfacía con una inyección vacía; y el recorte había borrado el caso "o está vacía" | **Aplicado.** El encabezado se movió dentro del bucle y solo se imprime con el primer archivo no vacío; sin archivos el hook sale 0 sin imprimir. El núcleo recupera el caso: "si lo que aparece son plantillas sin llenar, léelo tú… no des por cargadas las reglas de confidencialidad sin haberlas visto". Verificado en los tres casos (normal, sin contexto, archivo vacío). |
| H-3 | riesgos | "extrae lo que sirve" podía volverse muestreo y producir verificaciones falsas | **Aplicado.** Cláusula: el presupuesto aplica a lo que se lee para redactar, no a lo que se mide; conteos, nulos y rangos salen del archivo completo. |
| H-4 | riesgos | la puerta de delegación indexa en tamaño mientras el resto del kit indexa en riesgo | **Aplicado.** "El tamaño no manda sobre el riesgo: si el entregable va a dirección o a un cliente, o mueve dinero, se verifica aunque el cambio sea de una línea." |
| H-4t | técnica | los tres agentes heredaban todas las herramientas: un `verificador` con Write puede validar su propia corrección | **Aplicado.** `tools: Read, Grep, Glob, Bash` en `verificador`; `tools: Read, Grep, Glob` en `lector-fresco`; `evaluador-council` sigue heredando. |
| H-5 | riesgos | truncamiento silencioso si las discrepancias no caben en el tope | **Aplicado.** "Si las discrepancias no caben en el tope, di cuántas quedaron fuera." |
| C-a | costo | el argumento económico del `verificador` era falso: Sonnet es 1.67× más barato que Opus, no un orden de magnitud, y el subagente repaga su prompt base y relee material ya cacheado | **Aplicado en parte.** Se quitó el argumento de costo y la regla ahora dice delegar solo si el material aún no está en contexto. El valor real del agente es higiene de contexto e independencia, no precio. |
| C-b | costo, diablo | el "15×" mal citado suprimiría delegaciones que sí valen | **Aplicado.** La cifra sale del núcleo; queda el criterio. |
| C-c | costo, diablo | tasa base 0/9 en agentes de plugins; v1.11 entraba sin métrica ni criterio de retiro, mientras a otras propuestas se les exige gate | **Aplicado.** Condición de retiro en el CHANGELOG: a las 4 semanas se cuentan invocaciones; el agente en cero se borra y su regla se queda. |
| C-d | costo, diablo | hay retorno 3–14× mayor esperando, y `pr-review-toolkit` (~1,570 tok/sesión, 0 usos) no está bloqueado por las fichas | **Anotado, fuera de alcance de v1.11.** Queda como siguiente paso en el CONTINUAR. |
| C-e | costo | el +19% era en realidad +24% (y +44% tras las cláusulas del council) | **Aplicado.** Cifra real en el CHANGELOG, con la deuda del recorte declarada. |
| T-2 | técnica | por la vía plugin los agentes se invocan con prefijo (`kit-chema:verificador`), y `marketplace.json` seguía diciendo "8 skills + dos hooks" | **Aplicado.** Descripción actualizada y aviso de los dos nombres en el INSTRUCTIVO. |
| T-x | técnica | el núcleo dice "un solo agente iguala a varios" mientras `kit-propuestas` manda lanzar N evaluadores | **Aplicado.** Cláusula "(el council siempre califica)". |

## Hallazgos descartados tras verificación

Se verificaron antes de heredarlos, como pide el protocolo:

- **"Solución en busca de problema"** — el abogado del diablo intentó este ataque
  y él mismo lo descartó con evidencia: hay 84 delegaciones en los transcripts
  reales cuya descripción menciona council, y `lector-fresco` ya corrió a mano.
  Los casos de uso existen y hoy se ejecutan con prompts escritos cada vez.
- **"El 0/9 de agentes de plugins predice el destino de estos tres"** — descartado
  por el propio evaluador: esos nueve son de `pr-review-toolkit` y vercel,
  dominios que José casi no toca. No es tasa base comparable.
- **"Contradicción con el recorte del 80% de Anthropic"** — descartado por el
  evaluador de costo: ellos bajaron por sobre-restricción, y lo que aquí se
  agrega son heurísticas permisivas, no restricciones. El diagnóstico no aplica,
  aunque el argumento de tamaño sí quedó gastado (ver C-e).
- **"`lector-fresco` sobre material confidencial es exposición nueva"** —
  descartado por el evaluador de riesgos: "sin contexto previo" es instrucción de
  rol, no frontera de aislamiento; mismo proceso, misma cuenta, y lee un
  entregable que ya va camino a su destinatario.
- **"El repo es público, ¿los agentes exponen algo?"** — descartado tras leer los
  tres: son definiciones de rol genéricas, sin nombres de cliente, cifras,
  credenciales ni hosts.

## Nota de método

El council corrió con `general-purpose` y el prompt del rol pasado en el mensaje,
porque los agentes de v1.11 —incluido `evaluador-council`— todavía no estaban
instalados en `~/.claude/agents/`. Ese hecho es, en sí mismo, la evidencia de
H-1: la versión que introduce el `evaluador-council` no pudo usarlo para
evaluarse. A partir del merge, el council se corre con el agente del kit.
