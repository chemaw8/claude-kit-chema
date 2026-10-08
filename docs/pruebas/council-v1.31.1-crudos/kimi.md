<!-- Reporte crudo, sin editar. revisor-kimi (kimi-coding/k3), lente riesgos, 2026-10-08. Reemplaza a council-kimi, que agotó su tiempo en la corrida en paralelo («Request timed out»); mismo modelo y mismo mandato, lanzado aparte porque el harness no admite un evaluador council suelto. Se archiva para poder rehacer la síntesis. -->

# Evaluación council v1.31.1 — Lente: RIESGOS

## 1) Veredicto

**Aprobada.** Cambio puramente de forma (comprobado mecánicamente, no solo declarado), barato, trivialmente reversible, con los conteos de la propuesta reproducidos al dígito y sin conflicto real con el PR #82.

## 2) Hallazgos

**Sin hallazgos que cambien la corrección o la decisión.** Evalué los cuatro focos de riesgo del encargo y todos salieron limpios o con riesgo residual despreciable frente al tamaño del cambio (108 líneas tocadas, un commit de texto, revert = un comando):

- **[menor] El gate de disparo no lo reejecuté yo** (cuesta llamadas a API; el autor reporta 21/21, rc=0 sobre e480497). Lo mitigo con una comprobación propia más barata y suficiente para este caso: extraje las cadenas entre comillas de las 16 descriptions en `main` y en HEAD y son **byte-idénticas** (`fin comparación gatillos` sin ningún «DIFIERE»). Los únicos cambios léxicos fuera de puntuación son dos prefijos fuera de las frases gatillo (`anticontaminación` en kit-codigo, `multiagente` en sintetizador). Riesgo de disparo residual: bajo; no es condición.
- **[menor, ya declarado por el autor] La F9 restante** (`commands/cierre.md:34`) la inspeccioné: es «…el `CONTINUAR` de `main`— y entre ramas…», inciso pegado conforme a RAE; el script lo marca por el `—` pegado al código inline. Falso positivo real. Enseñar al script a ignorar código inline sería otra mejora; exigirla aquí sería justo lo que el mandato del evaluador prohíbe (sobreingeniería sobre una propuesta pequeña).

Declaración de alcance: no leí `docs/pruebas/council-v1.31.1.md` ni `council-v1.31.1-crudos/` (instrucción explícita), así que la confidencialidad del **acta** queda fuera de mi revisión; la del código del kit sí la revisé (abajo).

## 3) Qué está bien (verificado, no opinado)

- **El diff es solo forma.** Normalicé ambos lados del diff completo de `nucleo skills agents commands` (quitando `—`, `:`, `;`, `,`, `()`, guiones de prefijos, «el hook» y backticks) y cada línea vieja colapsa con su nueva: `uniq -c` no deja **ninguna** línea sin par. Cero cambios de fondo ocultos.
- **Conteos reproducidos.** Extraje `main` a /tmp y corrí `muletillas.sh` en ambos lados: F9 **55→1**, F12 **19→0**; palabras **18,564→18,512**. Todo coincide con la propuesta al dígito.
- **`bash verificar.sh` → RC=0**, todas las líneas OK, ninguna FALLA (incluye límite del núcleo: 139 < 150, y coherencia `.claude-plugin`/CHANGELOG).
- **Conflicto con PR #82: descartado de verdad.** El diff del #82 toca la sección «Terminado significa verificado» (líneas ~55-64 del núcleo); este PR toca líneas 1, 21 y 109. Además `git merge-tree --write-tree` en **ambos órdenes** de merge: `MERGE LIMPIO`. No hay riesgo de choque ni de orden de fusión.
- **Mandato literal del evaluador.** El cambio es `sobre-ingeniería` → `sobreingeniería` (ortografía, no significado) en el texto que «se pasa literal» (kit-propuestas/SKILL.md:82). Las actas viejas conservan la cita histórica con guion y no se reescriben: correcto, son registro de su época. El mandato que recibí yo ya venía en la forma nueva y funcionó.
- **Confidencialidad del kit: limpia.** Grep sobre todas las líneas añadidas del diff del kit (nombres del grupo, clientes, correos, rutas `/home/`, cifras con formato de dinero): cero coincidencias. `anti-secretos` pasó a código como nombre de hook, con la aclaración «el hook»: bien.
- **Máquinas ya instaladas: sin riesgo.** El PR no toca `hooks/`, `scripts/`, `instalar.sh` ni settings; lo instalado sigue funcionando idéntico y la actualización es el flujo normal de reinstalar copias. Nada que migrar, nada que rompa a medio camino.
- **Riesgo-beneficio bien ponderado por el autor**: declara de entrada que el beneficio no está medido en audiencia y que el A/B es provisional (n=10, p≈0.47). Esa honestidad calibra el cambio como lo que es: higiene barata con evidencia débil pero costo ~0 — perfil correcto para aprobar sin condiciones.
