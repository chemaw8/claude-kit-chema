# Council v1.31. Ronda pstack 3: arena y cegado (2026-10-06)

Rama `pstack/ronda-5` (`git diff main...pstack/ronda-5`). La propuesta salió de una arena de tres soluciones
(corrida ultracode uc-202610061430-aogq; nota en `docs/pruebas/ARENA-uc-202610061430-aogq.md`). La evidencia está en
el acta `docs/pruebas/pstack-ronda-3.md`. No toca el núcleo ni ninguna description de skill, así que el gate de
disparo no aplica.

## Postura inicial del integrador (antes de leer al panel)

Aprobada con cambios. El cegado tiene aporte medido. La arena es la parte más débil: su evidencia es de otro proyecto,
con 2 tareas que discriminan, y su párrafo puede afirmar de más.

## Acta

**Panel, ciego entre sí, con el mandato literal de `kit-propuestas`:**
- council-codex (GPT-6 Astra, viabilidad técnica): **aprobada con cambios**.
- council-kimi (K3, riesgos): **aprobada**.
- council-anthropic (Opus 5.5, abogado del diablo): **aprobada con cambios**. Declaró conflicto de interés: es de la
  misma familia que la solución base y que el integrador. Sus hallazgos van contra la base.

**Síntesis:** `sintetizador` (Fable 5.1), que verificó cada hallazgo contra los archivos. Veredicto: **aprobada con
cambios**.

**Reportes del panel, resumidos** (se archivan para poder rehacer la síntesis):
- **codex:** con candidatos que son archivos, `etiquetar` les conservaba el nombre (`con-kit.md` llegaba al juez bajo
  la letra). Con el destino `salida/.`, el mapa caía dentro de la carpeta del juez. En los dos casos el script salía
  con 0.
- **kimi:** sin bloqueos. El párrafo de la arena no dice que se midió en otro harness con familias mezcladas. La
  elección de la base contra el juez está declarada y mitigada. Confidencialidad: 0 coincidencias.
- **anthropic:** sobre una carpeta, `revisar` leía el contenido de cada archivo. En un clon de este repo saldrían más
  de 200 coincidencias legítimas, y los 0 falsos positivos solo se midieron en encargos de una línea. Además, «tres
  autores» y «más de tres no suma» afirman más que los datos: en la medición, dos y tres empatan 1 a 1.

**Hallazgos clasificados:**

| # | Hallazgo | Clase | Quién | Qué se hizo |
|---|---|---|---|---|
| H1 | Candidato archivo conserva su nombre | actuar | codex | Se copia como `<letra>/entrega<ext>`; regresión en el autotest |
| H2 | Destino `x/.` deja el mapa dentro | actuar | codex | Destino normalizado; regresión |
| H3 | `revisar` sobre carpeta lee el contenido | actuar | anthropic | En carpetas solo revisa rutas; `--contenido` es opcional; regresión. Un clon de este repo pasa de >260 coincidencias a 9, y las 9 son rutas de material de evaluación real (`docs/pruebas/plugin-eval/…`) |
| H4 | El párrafo de la arena afirma de más | actuar | anthropic y kimi | Ahora dice «dos o tres», que se midió en pi-harness con familias mezcladas, que el juez no decide por mayoría y que con una sola familia los intentos tienden a equivocarse igual. El CHANGELOG quedó alineado |
| H5 | Avisar a pi-harness de las carpetas `arena-<n>` | considerar | los tres | Se arregló en pi-harness en la misma sesión (ver su DECISIONES) |
| H6 | Conflicto al elegir la base contra el juez | anotado | kimi | Declarado en la nota de la arena |
| H7 | Instalación, autotest en `verificar.sh` y versión, correctos | anotado | kimi | sin acción |
| H8 | (6) y (7) se cierran como ya cubiertos | anotado | los tres | sin acción |

**Mapa de acuerdos.** Las tres familias coinciden en que entran la arena y el cegado, en que (6) y (7) quedan
cerrados y en avisar a pi-harness. H4 lo vieron dos familias desde lentes distintos. H1, H2 y H3 los trajo un solo
evaluador cada uno, con un camino de falla concreto que el sintetizador confirmó. La única contradicción es que kimi
dio `aprobada` y trató H4 como «considerar»; se resolvió hacia actuar, porque los datos de dos contra tres son mixtos.

**Verificación tras aplicar:** `bash scripts/cegar.sh autotest` sale en verde. Tres mutaciones lo ponen en rojo:
quitar la normalización del destino, conservar el nombre del archivo y leer el contenido en carpetas. La calibración
real se repitió: 6 de 6 y 0 de 4 en los encargos de la medición de pi-harness, y 0 de 30 en el banco de disparo.

**¿El panel movió la postura del integrador?** El veredicto no cambió, y el panel confirmó que el párrafo de la arena
afirmaba de más. Lo que sí cambió fue el cegado: la postura lo daba por firme, y el panel mostró tres usos reales que
la medición no había cubierto (candidatos como archivo, destino sin normalizar, contenido de carpetas).

## Costo de la ronda (2026-10-06)

Fuentes: el recibo de la corrida (`uc-202610061430-aogq.jsonl`) para la arena y el juez; la transcripción de la
sesión para el council y el sintetizador, que corrieron después de cerrarse el recibo; el registro del gate
(`gate.jsonl`) para los sellos. Dinero real = lo que corre en Anthropic por extra usage; Codex y Kimi entran en sus
planes.

| Etapa | Agentes | USD nominales | Dinero real |
|---|---|---|---|
| Arena | autor-anthropic 3.42, autor-codex 8.79, autor-kimi 2.59 | 14.80 | 3.42 |
| Juez | revisor-codex | 4.20 | 0 |
| Council | codex 1.08, kimi 0.45, anthropic 0.71 | 2.24 | 0.71 |
| Síntesis | sintetizador (Fable 5.1) | 1.35 | 1.35 |
| Sellos del gate | 7 revisiones (kit y pi-harness) | 1.15 | sin comprobar |
| **Total** | | **23.74** | **5.48 más los sellos** |

Los sellos corren con `claude -p` y su cobro depende de la cuenta de esa sesión: no se comprobó si fue plan o extra
usage. No incluye el sello de este cambio ni el hilo del orquestador.

## Criterio de retiro y lo que falta medir (José, 2026-10-06)

**Retiro de `cegar.sh`.** Se anotan aquí sus usos reales (fecha, corrida, qué marcó y si era fuga). Si en los
próximos 3 usos (arena, A/B o sonda) no atrapa ninguna fuga real, o todo lo que marca son falsos positivos, la viñeta
de cegado y el script vuelven a revisión. Una fuga real basta para que se queden.

**Lo que la evidencia no cubre, y cuándo medirlo.**
- *Arena desde Claude Code, con una sola familia.* Lo medido es de pi-harness con familias mezcladas. Se mide en la
  primera arena real que se corra desde Claude Code: anotar si la base con sus injertos superó al mejor intento y si
  los intentos se equivocaron igual. Si en 2 corridas no supera al mejor intento, el párrafo dice que en Claude Code no
  rinde.
- *Si el cegado cambia resultados.* Hoy está medido que el chequeo detecta fugas, no que una fuga mueva las
  calificaciones. Medirlo exige un A/B con y sin fuga sobre las mismas tareas (del orden de 10 USD de extra usage,
  como la corrida RF-11). No se corre mientras no haya una decisión que dependa de esa cifra.

### Usos reales de `cegar.sh`

| Fecha | Corrida | Qué marcó | ¿Fuga real? |
|---|---|---|---|
| 2026-10-06 | Arena de la Cabina de claude-entorno (spec 006 B, uc-202610062330-cab) | Encargo limpio; en la carpeta `trabajo-1`, la ruta `memory/proyecto-evals-entregables.md` («evals») | No: nombre legítimo del repo (falso positivo). Cuenta como uso 1 de 3 sin fuga real |
