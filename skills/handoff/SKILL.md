---
name: handoff
license: MIT
description: Traspaso de sesión antes de reiniciar en limpio. Úsala cuando la conversación se degrade — el contexto llegó al 60% del presupuesto, el mismo problema ya se corrigió dos veces, el auto-compact está por entrar, las herramientas fallan en bucle — o cuando el usuario diga "handoff", "traspaso", "reinicia limpio", "me voy a dormir", "ya te perdiste", "empecemos de nuevo". Escribe HANDOFF.md con objetivo, estado, archivos, cambios, intentos fallidos y siguiente paso, y deja la sesión lista para /clear. Úsala también al retomar, para cerrar el traspaso cuando el trabajo termine.
---

# Traspaso de sesión (handoff)

Reiniciar en limpio, no compactar. `/compact` resume la conversación y arrastra
los supuestos malos con ella: conserva el "qué sigue" y pierde el "por qué". El
traspaso reescribe el estado desde cero — hechos verificados, intentos fallidos y
siguiente paso — y la sesión nueva arranca sin herencia.

Reiniciar es barato y reversible: `/clear` no cuesta tokens y la conversación
anterior se recupera con `/resume`. `/compact`, en cambio, es una petición cara
sobre todo el historial.

## Cuándo escribir el traspaso

Escríbelo sin que te lo pidan cuando pase cualquiera de estas cosas:

- El hook de contexto avisó (60% amarillo, 85% rojo del presupuesto útil).
- **El mismo problema ya se corrigió dos veces sin quedar resuelto.** Es el
  criterio de Anthropic para contexto contaminado, no una impresión.
- El auto-compact entró o está por entrar.
- Una herramienta falla en bucle sin diagnóstico nuevo.
- El usuario dice que se va, que retoma mañana, o que reinicies.

Trabajo trivial y ya cerrado: no escribas nada, dilo en una línea.

## Cómo escribirlo

1. **Lee el traspaso anterior si existe.** Un traspaso escrito sobre otro sin
   leerlo pierde el hilo en cadena.
2. **Decide dónde va.** En orden:
   - Carpeta del trabajo en curso → `HANDOFF.md` ahí mismo.
   - Sin carpeta clara → créala o usa la del proyecto; nunca la raíz del home.
   - Nunca cruces ámbitos: Innovattia en `Documents\`, lo personal y del ITAM en
     `~\Personal\`. El traspaso no se sube a ningún lado.
3. **Usa la plantilla.** Lee `${CLAUDE_SKILL_DIR}/PLANTILLA-HANDOFF.md` y respétala.
4. **Marca cada afirmación.** `[verificado]` solo lo que comprobaste ejecutando,
   abriendo o midiendo; `[supuesto]` todo lo demás. Es la razón de ser del
   documento: la sesión nueva no debe heredar corazonadas como si fueran datos.
5. **Entrega el artefacto y el criterio, no tu razonamiento.** Di qué hay que
   lograr y cómo se sabrá que está bien. El razonamiento de esta sesión es
   justamente lo que conviene no heredar.
6. **Los intentos fallidos van como datos, no como acusación.** Qué se probó, qué
   pasó textualmente, y si hay diagnóstico o no. Sin ellos la sesión nueva repite
   el callejón; pero un documento redactado como lista de fallas empuja al que
   llega a buscar problemas donde no los hay y a sobre-ingenierizar. Registra
   también **qué no se probó**.
7. **Sé breve.** Menos de 8,000 caracteres: por encima, el hook lo recorta al
   inyectarlo. Lo largo va en archivo aparte, enlazado.
8. **Verifica antes de cerrar.** Reabre el archivo y comprueba que alguien que no
   vivió la sesión podría continuar solo con eso.

## Cómo cerrar el turno

1. Comprueba que no queden tareas en segundo plano ni subagentes corriendo: un
   `/clear` no los detiene y siguen gastando tokens.
2. **Ponle nombre a ESTE chat, no al que sigue.** Analiza el tema real del
   traspaso — no la palabra "handoff" ni el nombre del archivo — y arma un
   nombre corto (3-6 palabras, el tema del trabajo, no la actividad genérica:
   "Verne Móvil — redes sociales", no "sesión de traspaso"). Con varios chats
   abiertos a la vez, un nombre genérico o repetido ("Handoff.md") es
   exactamente lo que hace perder cuál es cuál; este paso existe para eso.
3. Termina con este bloque, tal cual, con el nombre ya puesto en el `/rename`:

```
Traspaso escrito en <ruta>.
Para nombrar este chat: teclea /rename <nombre corto del tema>
Para continuar limpio: teclea /clear — la sesión nueva lo lee sola.
```

No hay forma de que yo teclee `/clear` ni `/rename`: los comandos slash solo
se reconocen al inicio de un mensaje del usuario y ninguna herramienta los
invoca. Lo único que hago es dejar el nombre ya armado, listo para pegar tal
cual. Todo lo demás del ciclo sí es automático.

## Al retomar

La sesión nueva recibe el traspaso por hook, sin pedirlo. Entonces:

1. Confirma en una línea qué vas a retomar.
2. Comprueba en disco lo marcado `[supuesto]` antes de construir encima.
3. No repitas lo listado como fallido sin una razón nueva, y no heredes la teoría
   de por qué falló.
4. Cíñete al objetivo declarado. No abras frentes que el traspaso no pide.
5. Al terminar: vuelca lo duradero a `CONTINUAR.md` y `DECISIONES.md` según el
   manual, y borra el `HANDOFF.md`. Si el trabajo sigue abierto pero cambia de
   tema, marca `estado: cerrado` en su frontmatter.

## Relación con CONTINUAR.md

No se sustituyen:

| | HANDOFF.md | CONTINUAR.md |
|---|---|---|
| Vida | Horas; se borra al retomar | Permanente, del proyecto |
| Contenido | Estado de la sesión, con su ruido | Estado del trabajo, ya limpio |
| Intentos fallidos | Sí, con detalle | Solo si cambian el rumbo |
| Lector | La sesión siguiente, hoy | Cualquiera, en semanas |

## Checklist antes de darlo por hecho

- [ ] El archivo existe y lo releíste.
- [ ] Cada afirmación dice `[verificado]` o `[supuesto]`.
- [ ] Los intentos fallidos traen el error textual, y está lo que no se probó.
- [ ] El siguiente paso es una acción concreta, no "seguir investigando".
- [ ] El ámbito está declarado y la ruta le corresponde.
- [ ] Fechas absolutas AAAA-MM-DD.
- [ ] No quedan tareas en segundo plano corriendo.
- [ ] Le diste el nombre corto para `/rename` (el tema, no "handoff").
- [ ] Le dijiste al usuario la ruta y que teclee `/clear`.

## Herramientas

- Medir el contexto ahora:
  `powershell -NoProfile -File "$env:USERPROFILE\.claude\skills\handoff\scripts\medir-contexto.ps1"`
- Los tres hooks, sus umbrales y cómo desactivarlos: `INSTALAR.md` de esta skill.

## Nota de gobernanza

Skill personal, fuera del repo gobernado `claude-kit-chema`. No modifica ninguna
skill del kit. Si se decide incorporarla al kit, entra como PR en borrador
revisado por council, según GOBERNANZA.md.
