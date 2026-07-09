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

## Mejora del kit por corrección (no es una excepción)

El núcleo dice que si el usuario corrige dos veces lo mismo, se propone volver
esa corrección regla del kit. Esa propuesta **no** se convierte en un commit
directo a `main`: genera **siempre un PR en borrador** que revisa un council
(protocolo de la skill `kit-propuestas`: panel de evaluadores con veredicto
aprobada / con cambios / rechazada). Solo si el council aprueba, el PR se saca de
borrador y sigue el flujo normal (CI + CODEOWNERS). Así el mecanismo que hace
"aprender" al kit no es también la vía por la que se degrada sin control.

## Rollback

Si un cambio ya fusionado resulta dañino, el rollback es **revertir el PR**
(`git revert` del merge o el botón "Revert" de GitHub) con su propio PR. No se
reescribe la historia de `main`.

## Pendiente del dueño del repo

Activar **branch protection** en `main` (requiere permisos de administrador y no
se hace desde este repo): exigir PR antes de fusionar, exigir que el CI pase y
exigir la revisión de CODEOWNERS. Sin branch protection, estas reglas son un
acuerdo; con ella, son un mecanismo que GitHub hace cumplir.

## Diferido a v1.3 (no bloqueante)

- Plugin "lean": hoy el paquete se distribuye con `source "./"` (viaja el repo
  entero — docs, CI, deck). Claude Code solo activa skills/commands/hooks, así
  que es inofensivo, pero conviene empaquetar solo lo necesario cuando haya un
  mecanismo de exclusión claro.
- Reemplazar el hook anti-secretos por una vía sin dependencia de python3.
- Equipo de 2+ revisores en CODEOWNERS (hoy un único dueño es punto único de
  fallo).
