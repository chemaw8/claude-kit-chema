<!-- Reporte crudo, sin editar. council-codex (openai-codex/gpt-6-astra, esfuerzo max), lente viabilidad técnica, 2026-10-08. Se archiva para poder rehacer la síntesis (pedido de la resíntesis v1.11 y del acta v1.30). -->

## 1. Veredicto: **aprobada con cambios**

La limpieza es viable, pero introduce YAML inválido que impediría cargar varias skills y comandos en pi. La corrección es pequeña.

## 2. Hallazgos

### 1. Los nuevos dos puntos necesitan comillas en las `description`

**Qué falla.** Reemplazar ` — ` por `: ` dentro de un valor YAML sin entrecomillar cambia su sintaxis, aunque conserve el sentido en español.

Ejemplo en `skills/kit-codigo/SKILL.md:4`:

```yaml
description: Estándar […] Úsala siempre antes de tocar código: al crear […]
```

**Archivos afectados:**
- Línea 4 de `skills/kit-analisis-datos/SKILL.md`, `skills/kit-automatizacion/SKILL.md`, `skills/kit-codigo/SKILL.md`, `skills/kit-finanzas/SKILL.md` y `skills/kit-research/SKILL.md`.
- `commands/cierre.md:2`, `commands/proyecto-init.md:2` y `commands/revisar-antes-de-subir.md:2`.
- El mismo defecto sintáctico aparece en `agents/verificador.md:3` y `agents/lector-fresco.md:3`, aunque el traductor de agentes de pi sí entrecomilla su salida.

**Consecuencia concreta, comprobada por lectura del código consumidor:**
- El paquete instalado de pi usa `yaml.parse()` en `dist/utils/frontmatter.js:23`.
- Ante un error, `dist/core/skills.js:222–229` devuelve `skill: null`; `dist/core/prompt-templates.js:95–100` devuelve `template: null`.
- `../pi-harness/configurar-pi.sh:104` configura las skills por ruta, sin sanearlas.
- `../pi-harness/traducir-comandos.py:241–249` conserva el frontmatter original: tampoco corrige esos valores.

Por tanto, **al instalar y regenerar los prompts, cinco skills y tres comandos quedarían fuera de la carga de pi**. No atribuyo esa caída a los agentes: su traductor los protege.

**Por qué los controles citados no lo detectan.** `verificar.sh:21,68,82` extrae descripciones mediante `awk`; `docs/pruebas/disparo.py:15–16` mediante regex. Ninguno valida YAML. El gate puede comprobar correctamente las frases gatillo mientras el cargador real rechaza sus archivos.

**Qué cambiar.** Entrecomillar, en una sola línea, las `description` afectadas que contienen `: `, o elegir otra puntuación válida. Después comprobar su carga con el parser real. Basta esa verificación local; no requiere otra campaña de evaluación.

## 3. Qué está bien

- En las sustituciones cotejadas no encontré cambios de obligación, negación o alcance. Las frases gatillo se conservan textualmente.
- Se preservan identificadores operativos: `anti-secretos` mantiene su nombre y la plantilla de `CONTINUAR` conserva su formato.
- Los instaladores y traductores revisados no dependen de las rayas o prefijos modificados en la prosa. El problema encontrado es de sintaxis del frontmatter, no de esas reglas.

**Límite de verificación:** esta sesión no dispone de ejecución. No corrí `git diff`, `verificar.sh` ni `muletillas.sh`; contrasté archivos actuales con la copia instalada v1.31 y seguí los consumidores por lectura. No leí el acta prohibida ni modifiqué archivos.
