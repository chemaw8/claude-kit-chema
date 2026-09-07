---
description: Revisa el cambio antes de subirlo al remoto y produce el sello que exige el gate de push — corre las pruebas del proyecto en una copia limpia, manda el diff a un revisor adversario con otro modelo, corrige o discute cada hallazgo bloqueante y solo entonces hace git push. Úsalo cuando el hook sello-push bloquee un push, o antes de subir cualquier rama en un repo con el gate activo.
---

Vas a subir un cambio a un repo con el gate de push activo (`git config kit-chema.gate true`).
El hook `sello-push` no deja pasar un `git push` sin sello de revisión para ese commit; este
comando produce el sello sin atajos.

El helper `sello-push.sh` hace lo mecánico. Está en `${CLAUDE_PLUGIN_ROOT}/scripts/sello-push.sh`
o, si el kit se instaló sin plugin, en `~/.claude/scripts/sello-push.sh`. Invócalo siempre con el
literal visible (así el hook puede exigir el timeout):

```bash
SELLO="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude}/scripts/sello-push.sh"
bash "${SELLO:-$HOME/.claude/scripts/sello-push.sh}" revisar     # Bash con run_in_background: true (o timeout: 600000)
```

## Pasos

1. **Revisar.** Corre `revisar` en un Bash con `run_in_background: true` y espera el aviso de
   Claude Code (las pruebas del proyecto corren en un worktree desechable y luego el revisor;
   una revisión real ha tardado hasta 11 minutos, más que el tope de 10 del Bash en primer
   plano). Si esperas una revisión corta puedes usar `timeout: 600000`; sin ninguno de los
   dos, el hook lo devuelve con la instrucción.
2. **Pruebas rojas (salida 1 con el hallazgo `P1`).** Arregla, commitea y vuelve al paso 1.
   El revisor no se invoca con pruebas rojas: no gastas cuota hasta que pasen.
3. **Hallazgos `bloquea`.** Por cada uno: si es real, corrígelo y commitea; el sha nuevo
   invalida el sello, así que vuelves al paso 1 (el revisor recibe los hallazgos previos y
   dice cuál quedó resuelto). Si crees que es un falso positivo, muéstraselo al usuario con
   la evidencia y espera su respuesta: **solo con la palabra del usuario** corres
   `bash "$SELLO" saltar <n> "<razón>"`. Nunca saltes un hallazgo por juicio propio.
4. **Avisos y hallazgos sin evidencia.** Repórtalos al usuario en una línea cada uno; no
   obligan a nada.
5. **Revisor no disponible (salida 3).** No hay sello y el push sigue bloqueado. Díselo al
   usuario tal cual: `KIT_SELLO=omitir git push …` es una decisión suya, no tuya, y queda
   anotada en el ledger. No la ejecutes sin que la pida expresamente.
6. **Subir.** Con 0 pendientes, `git push` solo, en su propio **comando aparte** (nunca
   `git commit … && git push`: el hook rechaza comandos que mueven HEAD y empujan en la
   misma línea).
7. **Reportar.** Di qué hallazgos se corrigieron, cuáles se saltaron y con qué razón, y los
   tokens del gate (los imprime `revisar`). Nunca declares subido algo que el hook bloqueó.
8. **Vigilar el CI.** Tras abrir o actualizar el PR, `gh pr checks <rama> --watch`. Si falla,
   el arreglo es un commit nuevo: vuelve al paso 1. La reparación nunca sube sobre una
   cabeza sin sello.

## Lo que no hace este comando

No revisa pushes hechos desde la terminal ni desde scripts (eso lo mide `estado
--contra-remoto`), no sustituye la branch protection ni el council del PR, y no escanea
secretos (anti-secretos y gitleaks ya lo hacen).
