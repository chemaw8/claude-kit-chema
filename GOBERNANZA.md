# Gobernanza del Kit Chema

El kit es un estándar compartido: se instala en la máquina de mucha gente y se
propaga por git. Por eso un cambio malo no afecta solo a un archivo, se replica.
Estas reglas existen para que ninguna degradación llegue a `main` sin que un
humano la haya visto y el CI la haya validado.

## Cómo entra un cambio

1. **Siempre por pull request.** Nunca `git push` directo a `main`. Todo cambio
   —incluido el del dueño del repo— pasa por un PR contra una rama.
2. **El CI debe pasar en verde.** El workflow `.github/workflows/ci.yml` corre
   dos jobs y ambos tienen que pasar:
   - `límites`: `verificar.sh` (núcleo < 150 líneas, descriptions en rango, sin
     mayúsculas de énfasis).
   - `secretos`: gitleaks; si encuentra una credencial, el build falla.
3. **Revisión de CODEOWNERS.** Las rutas sensibles (`/nucleo/`, `/skills/`,
   `/hooks/`, `/.github/`) tienen dueño en `.github/CODEOWNERS` y su aprobación
   es obligatoria para fusionar. Lo ideal es que sea un equipo de 2+ revisores,
   no una sola persona.
4. **Gate de disparo cuando toca el disparo.** Todo PR que añada una skill nueva,
   edite la `description` de un SKILL.md, o cambie el núcleo debe pasar el gate de
   disparo (ver `docs/pruebas/RUNBOOK.md`) antes de salir de borrador/mergear. Los
   PR que solo tocan cuerpos de skill, docs o scripts no lo requieren.

## Mejora del kit por corrección (no es una excepción)

El núcleo dice que si el usuario corrige dos veces lo mismo, se propone volver
esa corrección regla del kit. Esa propuesta **no** se convierte en un commit
directo a `main`: genera **siempre un PR en borrador** que revisa un council
(protocolo de la skill `kit-propuestas`: panel de evaluadores con veredicto
aprobada / con cambios / rechazada). Solo si el council aprueba, el PR se saca de
borrador y sigue el flujo normal (CI + CODEOWNERS). Así el mecanismo que hace
"aprender" al kit no es también la vía por la que se degrada sin control.

## Crear una skill nueva

El oficio para que una skill dispare bien y no degrade el kit. Antes de
escribirla, confirma que el dominio no lo cubre ya una skill existente: si solo
falta un matiz, es una adición de 1-2 líneas a esa skill, no una skill nueva.

1. **La description primero.** Escríbela antes que el cuerpo: qué es, cuándo
   usarla con las frases gatillo típicas del usuario, y el "cuándo no usarla"
   cediendo explícitamente a la skill vecina. Las fronteras se cierran por
   ambos lados: la vecina también reclama lo suyo (ejemplo vivo: kit-redaccion
   cede los informes a kit-presentaciones y los mensajes que piden aprobación a
   kit-propuestas, y kit-propuestas los reclama).
2. **Cuerpo mínimo.** Sigue la anatomía de las skills existentes (bien hecho
   significa / proceso / checklist / errores típicos). Empieza corto: es más
   fácil añadir la línea que faltó que detectar la que sobra — primero prueba,
   luego engorda.
3. **Los límites los dicta `verificar.sh`.** Córrelo; él es la autoridad de
   líneas, caracteres y palabras (no se copian aquí: deben poder cambiar en un
   solo lugar).
4. **Gate de disparo.** Añade al banco (`docs/pruebas/banco/disparo.md`) 1-2
   casos de frontera con sus vecinas reales y corre el gate según
   `docs/pruebas/RUNBOOK.md`. El criterio del núcleo (≥ 19/21) no se mueve: las
   skills nuevas se cubren por fronteras, como se hizo con kit-redaccion.
5. **PR + council**, como todo cambio (sección "Cómo entra un cambio"). Una
   skill nueva toca el disparo, así que el gate es obligatorio antes de sacar
   el PR de borrador.

## Rollback

Si un cambio ya fusionado resulta dañino, el rollback es **revertir el PR**
(`git revert` del merge o el botón "Revert" de GitHub) con su propio PR. No se
reescribe la historia de `main`.

## Branch protection (activa desde 2026-07-10)

`main` está protegida en GitHub, así que las reglas de arriba dejan de ser un
acuerdo y son un mecanismo que GitHub hace cumplir. Configuración vigente:

- **PR obligatorio**: no se acepta `git push` directo a `main`; todo entra por PR.
- **Checks de CI requeridos** (deben salir en verde para poder fusionar):
  `límites del kit` y `escaneo de secretos (gitleaks)`.
- **Rama al día** (`strict`): el PR debe estar actualizado con `main` antes de
  fusionar.
- **Aplica también a administradores** (`enforce_admins`): el dueño del repo
  tampoco se la salta.
- **Sin force-push ni borrado** de `main`.
- **Aprobaciones requeridas: 0.** Hoy el repo tiene un único mantenedor, así que
  se auto-fusiona su propio PR una vez que el CI pasa; no se exige revisión de
  CODEOWNERS todavía. Cuando haya 2+ colaboradores, subir las aprobaciones a 1–2
  y activar `require_code_owner_reviews` (ver "Diferido").

Operación: crea una rama, abre el PR, espera a que los dos checks estén en verde
y fusiona. Emergencia: como el dueño sigue siendo admin, puede desactivar la
protección temporalmente en GitHub → Settings → Branches; es reversible y
deliberadamente incómodo (esa fricción es el punto).

## Diferido (no bloqueante)

- Plugin "lean": hoy el paquete se distribuye con `source "./"` (viaja el repo
  entero — docs, CI, deck). Claude Code solo activa skills/commands/hooks, así
  que es inofensivo, pero conviene empaquetar solo lo necesario cuando haya un
  mecanismo de exclusión claro.
- Reemplazar el hook anti-secretos por una vía sin dependencia de python3.
- Equipo de 2+ revisores en CODEOWNERS (hoy un único dueño es punto único de
  fallo); al lograrlo, subir aprobaciones requeridas a 1–2 y activar
  `require_code_owner_reviews` en la branch protection.
- Meta-skill `kit-crea-skills` (la sección "Crear una skill nueva" convertida
  en skill que dispara al pedir "crea una skill del kit"). Su detonante es que
  exista un segundo autor real del kit: hoy sería una skill siempre listada
  para una audiencia de un solo mantenedor, con una frontera de disparo nueva
  que mantener (council 2026-07-10).
