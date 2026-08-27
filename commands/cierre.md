---
description: Cierra la sesión de trabajo en este proyecto — deja CONTINUAR.md con el estado mínimo para reanudar (dónde vamos, siguiente paso, cómo retomar, bloqueadores), archiva el detalle viejo en docs/bitacora.md sin perder nada, actualiza la ficha si cambió algo, anota decisiones caras y borra los temporales. Úsalo al terminar o pausar el trabajo en un proyecto.
---

Cierras el trabajo en este proyecto dejándolo listo para reanudar en frío: dentro
de tres semanas, en otra máquina, o después de que la sesión se muera sin avisar.

El helper `rotar-continuar.sh` hace lo mecánico. Está en
`${CLAUDE_PLUGIN_ROOT}/scripts/rotar-continuar.sh` o, si el kit se instaló sin
plugin, en `~/.claude/scripts/rotar-continuar.sh`. Llámalo `ROTAR` de aquí en
adelante.

## 1. Reconstruye el estado desde artefactos durables

No lo redactes de memoria: si la sesión fue larga, tu contexto pudo compactarse y
el estado saldría incompleto **en silencio**. Reconstrúyelo de lo que quedó en
disco:

```bash
git -C <proyecto> status --short
git -C <proyecto> log --oneline -10
bash "$ROTAR" reconciliar <proyecto>
```

Al abrir `/cierre`, `reconciliar` casi siempre dirá "hubo trabajo después del
cierre": es **normal y esperado** — ese trabajo es el de esta sesión, que es justo
lo que vas a capturar. **No lo leas como que el estado anterior mentía.** Solo es
alarma en dos casos: si el encabezado dice `cierre limpio: no` (una sesión murió
sin cerrar), o si los archivos que lista son cambios que nadie de esta sesión hizo.
En esos dos casos sí: reconstruye del `git diff` antes de creerle al estado viejo.

## 2. Decide qué cambió de verdad — y no preguntes por lo demás

Este comando es **silencioso en lo que no cambió**. Recorre esta lista y actúa
solo donde haya algo:

| Si en la sesión… | Entonces |
|---|---|
| cambió el stack, un comando o apareció una trampa nueva | actualiza `CLAUDE.md` (la ficha) |
| hubo una decisión cara o difícil de revertir | añade entrada a `DECISIONES.md` con fecha absoluta, razones y alternativas descartadas |
| se produjo algo notable para el conocimiento | deja nota enlazada en el vault con `basic-memory` |
| no cambió ninguna de las anteriores | no toques esos archivos ni preguntes por ellos |

## 3. Escribe el estado nuevo en un borrador

Redáctalo completo en un archivo temporal (no edites `CONTINUAR.md` directo; el
helper lo reemplaza de forma segura en el paso 4). Usa exactamente esta forma —
arriba de la línea `---` va lo blindado, abajo lo recortable:

```markdown
# CONTINUAR — <proyecto>  ·  cierre <YYYY-MM-DD>  ·  commit <hash>  ·  cierre limpio: sí
> Estado vivo de sesión. Los hechos estables (repo, remoto, stack) viven en
> CLAUDE.md, no aquí.

## Dónde vamos
<una frase: en qué punto está el trabajo>

## Siguiente paso
- [ ] <verbo + objeto + criterio de terminado>

## Cómo retomar
- Abrir:    <archivo / carpeta>
- Correr:   <comando>
- Verificar arranque: <comando o qué debe verse>

## Bloqueadores / esperas
- <qué + de quién o de qué depende + desde qué fecha>      (o "Ninguno")

## Frentes abiertos          ← solo si hay más de uno
| Frente | Estado | Siguiente | Bloqueo |
|---|---|---|---|

## Última decisión relevante
- <YYYY-MM-DD>  <qué>  → DECISIONES.md

---
## Detalle vivo
<lo que sigue haciendo falta para el siguiente paso, y nada más>
```

Genera el encabezado con `bash "$ROTAR" anclar <proyecto>` para que la fecha y el
ancla de git sean reales, no inventadas.

**Orden de commit (importante para que la próxima reanudación salga limpia).** El
ancla que estampa `anclar` es el `HEAD` de este momento, así que:

1. **Commitea primero el trabajo real de la sesión** (código, datos, scripts) —
   así el ancla lo captura. Si no lo commiteas, no pasa nada grave: al reanudar,
   `reconciliar` marcará esos archivos como "trabajo sin cerrar", que es honesto.
2. Luego genera el encabezado con `anclar` y rota (paso 4).
3. Al final, commitea el **papeleo** (CONTINUAR.md, docs/bitacora.md, y la ficha o
   DECISIONES si los tocaste) en un commit aparte.

Con ese orden, la sesión que retome verá "solo se movió el papeleo del cierre" =
estado fresco. Si mezclas trabajo y papeleo en un mismo commit tras `anclar`, la
próxima reanudación marcará un falso rancio (inofensivo, pero ruido).

Tres reglas al redactar:

- **No repitas hechos estables.** Repo, remoto, stack y "qué es el proyecto" van en
  `CLAUDE.md`. Si los copias aquí, envejecerán aquí — es exactamente cómo una ficha
  terminó diciendo "sin remoto" cuando ya tenía remoto.
- **El siguiente paso tiene que ser ejecutable.** Prueba: ¿alguien que llega en
  frío sabría exactamente qué abrir o qué teclear? "Continuar el análisis" no pasa;
  "correr `scripts/03-modelo.py` y comparar el R² contra el corte de junio" sí.
- **Sobrescribe, no acumules.** El estado es una foto fresca de hoy, no un
  sedimento de todas las sesiones.

## 4. Rota con garantía de cero pérdida

```bash
bash "$ROTAR" rotar <proyecto> <borrador>        # añade --dry-run para ver antes
```

El helper mueve a `docs/bitacora.md` todo lo que estaba en el `CONTINUAR.md` viejo
y no está en el nuevo, y **verifica línea por línea** que nada se perdió. Si algo
se perdería, aborta sin tocar nada — no lo fuerces: revisa qué quedó fuera.

Criterio de qué se archiva: **¿hace falta para el siguiente paso?** Lo que sigue
pendiente se arrastra hacia adelante; solo se archiva lo ya cerrado. Nunca archives
un bloqueador vivo ni una pregunta abierta.

## 5. Comprueba el contrato

```bash
bash "$ROTAR" contrato <proyecto>
```

Debe pasar. El tope de ~40 líneas es **blando**: si el estado genuino no cabe,
**dilo** en vez de recortar el contrato. Y si el contrato *solo* ya pasa de 40
líneas, el diagnóstico es otro: son demasiados frentes y conviene proponer partir
el proyecto.

## 6. Cero residuos

Lista los archivos temporales que creaste en la sesión y bórralos. Di cuáles
borraste. Si algo temporal debe sobrevivir, no es temporal: dale lugar y nómbralo.

## 7. Cierra reportando

En tres o cuatro líneas: qué quedó hecho, qué sigue, qué se archivó y qué quedó
fuera. Si algo falló o no pudiste verificar, dilo — un "listo" falso cuesta más
que un "me faltó esto".
