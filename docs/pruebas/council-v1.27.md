# Council v1.27 — el revisor de señales de IA vuelve al checklist y uso automático de /crear-verificacion (2026-09-30)

Rama `pstack/ronda-2` (`git diff main...pstack/ronda-2`). Viene del acta de v1.26 (`docs/pruebas/council-v1.26.md`),
que dejó la línea del revisor fuera de `kit-redaccion` con una condición: un A/B que separara kit de modelo en la
raya espaciada. No toca el núcleo ni ninguna description: el gate de disparo no aplica.

## Qué entra

1. **Una línea en el checklist de `kit-redaccion`**: antes de entregar a dirección o a un cliente, correr
   `bash "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude}/scripts/muletillas.sh" revisar <archivo>` y corregir las señales F.
2. **Regla F12 en `scripts/muletillas.sh`**: prefijo con guion ante minúscula (`multi-agente`), que la Ortografía de
   la RAE (2010) escribe junto; el guion solo va ante sigla, número o mayúscula («anti-OTAN», «sub-21»).
3. **Uso automático de `/crear-verificacion`**: una frase en el paso 4 del proceso de `kit-codigo` (si la ficha trae
   «Probar de verdad», córrelo antes de decir que quedó, con permiso si toca el entorno o gasta; si no, propón el
   comando) y una en el reporte de `/proyecto-init` (ofrecerlo una vez). Tabla «cuándo entra cada pieza» en el README.

Adiciones por skill en esta ronda: `kit-redaccion` 1, `kit-codigo` 1 (tope 2).

## Evidencia

**A/B de la raya** (la condición de v1.26). Opus 5.5 (el modelo de las sesiones), 5 encargos de negocio × 2
repeticiones × 3 brazos. «Con kit» = núcleo + contexto + lista de descriptions + cuerpo de `kit-redaccion`, como en
una sesión real. «Kit sin rayas» = lo mismo con cada raya espaciada cambiada por coma.

| Brazo | Textos con raya espaciada | Rayas espaciadas / 1,000 palabras | Viñetas «**Tema:**» / 1,000 |
|---|---|---|---|
| Sin kit | 0 de 10 | 0.0 | 9.8 |
| Con kit | 2 de 10 | 1.9 | 4.3 |
| Kit sin rayas | 1 de 10 | 0.9 | 4.7 |

Dosis en el contexto de trabajo real (rayas espaciadas por 1,000 palabras): texto del kit 2.9, notas del vault 10.9;
entregables reales 7.1; texto humano de 2021 0.0. Lectura: el modelo solo no produce la raya; la contagia el
contexto, y el kit es una fuente entre varias y no la mayor. Limpiar el kit la reduce pero no la elimina; la única
defensa que cubre todas las fuentes es el chequeo a la salida. n=10 por brazo y diferencias chicas: provisional.

**F12.** 0 en 5 artículos humanos de 2021; 16 en 11 entregables reales; 15 en el propio texto del kit; 0 en los 30
textos del A/B; 2 en 5 textos de Sonnet sin kit. Autotest: detecta `multi-agente` y `re-ejecutar`, y respeta
«anti-OTAN», «sub-21», `código` y rutas de archivo.

## Riesgos que el autor ya ve

- El beneficio para la audiencia sigue sin medirse: se sabe que las señales separan texto humano de texto de IA y
  que aparecen en los entregables, no que corregirlas cambie cómo lee dirección.
- La regla de `kit-codigo` pide correr un recorrido que ya existe; proponer `/crear-verificacion` donde falta quedaría
  sin evidencia (ver acta).
- El texto del kit conserva 39 rayas espaciadas y 15 prefijos con guion; limpiarlos toca descriptions (gate de
  disparo) y queda para otra ronda.

## Postura inicial del autor (antes de leer al panel)

Aprobada: la condición de v1.26 se cumplió y la evidencia apunta al chequeo a la salida como la defensa correcta.

## Acta (2026-09-30)

Panel: council-codex (GPT-6 Astra, viabilidad técnica), council-kimi (K3, riesgos), council-anthropic (Opus 5.5,
abogado del diablo); los tres: **aprobada con cambios**. Hallazgos verificados por el autor contra los archivos;
ninguno se descartó.

**Veredicto: aprobada con cambios.** Aplicados en la misma rama:
1. **Confidencialidad (Kimi).** El autotest de F12 usaba como ruta de ejemplo el nombre de un proyecto interno del
   grupo; se cambió por una carpeta genérica antes de cualquier push. Segundo caso de esta clase en dos rondas, y
   esta vez lo metió el autor en un ejemplo de prueba. Lección para quien escriba pruebas del kit: los ejemplos se
   inventan; nunca se toman de las carpetas de trabajo.
2. **Script ausente (Codex).** La línea del checklist admite que el script falte (claude.ai, instalación sin
   scripts): se revisa a mano y no se dice que pasó. La instalación manual del README ahora copia `scripts/`.
3. **Uso automático sin evidencia (Anthropic).** Se quitó «propón `/crear-verificacion`» de `kit-codigo` y la
   oferta de `/proyecto-init`: el comando sigue sin su primera corrida real. Queda «córrelo si la ficha lo trae».
   La tabla del README marca esas dos filas «en espera».
4. **Lectura del A/B (Anthropic).** 0/10 contra 2/10 no es concluyente (Fisher p ≈ 0.47), y la dosis del vault no
   estaba en ningún brazo. La línea entra por su bajo costo y porque el chequeo a la salida cubre cualquier fuente,
   no porque se haya probado la causa. El CHANGELOG lo dice así.

**Pendiente con condición:** primera corrida real de `/crear-verificacion` (sesión nueva, clon limpio, defecto
sembrado). Si pasa, entran las dos filas «en espera»; el umbral de retiro de v1.26 sigue vigente.

**¿El panel movió la postura del autor?** Sí. El autor proponía «aprobada» sin cambios. El panel encontró una fuga
que el autor mismo introdujo, un requisito que no funciona en dos vías de instalación y una regla sin evidencia.
