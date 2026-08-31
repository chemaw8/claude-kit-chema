---
description: Crea la ficha de este proyecto — un CLAUDE.md corto y estable (qué es, stack, cómo correr, trampas, confidencialidad) más .claude/settings.json con permisos, y deja CONTINUAR.md en formato de reanudación. Úsalo una vez por proyecto, al entrar a uno que todavía no tiene ficha.
---

Le das a este proyecto su ficha: lo que Claude necesita saber siempre, para no
volver a deducirlo cada sesión. Se corre **una vez por proyecto**; después lo
mantiene `/cierre`.

El helper `rotar-continuar.sh` está en
`${CLAUDE_PLUGIN_ROOT}/scripts/rotar-continuar.sh` o, sin plugin, en
`~/.claude/scripts/rotar-continuar.sh`. Llámalo `ROTAR`.

Antes de arrancar, dimensiona: si el proyecto es muy chico (un script de un
uso, una exploración puntual), **pregunta al usuario** si quiere la estructura
completa o la mínima (ficha + CONTINUAR) — nunca lo decidas en silencio. La
estructura completa y la capa `specs/NNN-nombre/` por feature están en
`estandar-proyectos.md` de la skill kit-codigo, con sus plantillas al lado.

Si ya existe `CLAUDE.md` en la raíz del proyecto, no lo pises: dilo y ofrece
revisarlo en vez de regenerarlo.

## 1. Lee lo que ya existe

`README.md`, `CONTINUAR.md`, `DECISIONES.md`, `docs/`, los manifiestos de
dependencias (`package.json`, `pyproject.toml`, `requirements.txt`, `go.mod`…),
`scripts/`, y el estado de git (`git remote -v`, `git log --oneline -5`,
`git status --short --ignored`).

Revisa también si hay una nota de memoria o del vault sobre este proyecto: suele
tener destiladas las trampas y lo confidencial, que es lo más caro de re-deducir.

## 2. Evalúa si el proyecto es sensible — antes de ejecutar nada

Un proyecto es sensible si aparece cualquiera de estas señales:

- `.claude/settings.json` con reglas `deny`, o material declarado NDA;
- credenciales en `.env*`, o cadenas de conexión en la configuración;
- conexión a una base de datos de **producción**, o a infraestructura de un cliente;
- el trabajo es de seguridad ofensiva, auditoría o cumplimiento (pentest, PCI).

**En un proyecto sensible no ejecutes nada a ciegas.** Lista los comandos que
correrías y pide confirmación explícita antes de cada uno. Correr un script de
migración, un seed o una conexión "solo para verificar" puede tocar producción o
mover datos reales.

En un proyecto normal, **sí ejecuta** los comandos de instalar, probar y correr:
la ficha solo debe contener comandos verificados. Si uno falla, repórtalo en vez de
escribirlo — un comando inventado en la ficha es peor que ninguno.

## 3. Redacta la ficha propuesta

`CLAUDE.md` en la raíz, **tope 40 líneas**, con esta estructura:

```markdown
# <proyecto>
<una o dos frases: qué es y para quién>

## Estado
Estado actual en CONTINUAR.md · decisiones cerradas en DECISIONES.md ·
historia larga en docs/bitacora.md. **Al retomar, corre primero
`bash ~/.claude/scripts/rotar-continuar.sh reconciliar .`**: si sale rancio,
reconstruye del git diff antes de creerle. Luego léelos antes de proponer cambios.

## Stack y cómo correr
<solo comandos verificados en el paso 2>

## Datos
<de dónde salen, dónde viven, qué NO se versiona>

## Trampas conocidas
<lo que rompe si no se sabe — cada una costó una sesión aprenderla>

## Confidencialidad
<qué no sale de aquí; verificado contra git, no contra lo que se recuerde>

## Convenciones
<lo propio de este proyecto que no se deduce del código; si tendrá features
multi-sesión, recuerda aquí la capa specs/NNN del estándar de kit-codigo>
```

Dos reglas de contenido:

- **Cero estado.** "Vamos en la fase 2" no es ficha, es `CONTINUAR.md`. La ficha
  es lo que sigue siendo cierto dentro de seis meses.
- **La confidencialidad se verifica contra git**, nunca contra la memoria. Corre
  `git remote -v` y `git status --ignored`: una ficha que hereda un "sin remoto"
  viejo es justo el error que este diseño existe para evitar.

Si algo no cabe en 40 líneas, es porque es estado (→ `CONTINUAR.md`) o historia
(→ `docs/bitacora.md`).

## 4. Propón los permisos, no los apliques

Deriva `.claude/settings.json` de los comandos que verificaste y del uso real del
proyecto. En proyectos con material que no puede salir, incluye `deny` para las
herramientas que mandan contenido afuera (`WebFetch`, `WebSearch`, MCP de scraping
o navegador) y para los archivos con secretos.

**Nunca escribas `settings.json` sin aprobación.** Los permisos son sensibles:
muéstralos y espera el visto bueno.

## 5. Muestra todo junto antes de escribir

Presenta en un solo bloque: la ficha propuesta, los permisos propuestos, y —si
`CONTINUAR.md` pasa de 60 líneas— la rotación propuesta a `docs/bitacora.md`. Nada
se escribe sin aprobación.

*Por qué 60 y no 40:* 60 dispara la rotación única de migración, para no rotar
CONTINUARs que ya están sanos. 40 es el tope blando de régimen que `/cierre`
sostiene después.

## 6. Escribe, deja el estado en contrato y commitea

Tras la aprobación:

1. Escribe `CLAUDE.md` y `.claude/settings.json`.
2. Deja `CONTINUAR.md` en formato de reanudación. Genera el encabezado del
   borrador con `bash "$ROTAR" anclar <proyecto>`. Si **ya existía** un
   `CONTINUAR.md`, **siempre** aplícalo con `bash "$ROTAR" rotar <proyecto>
   <borrador>` — nunca lo reescribas directo, sin importar su tamaño: el helper
   archiva lo desplazado y verifica cero pérdida, y si nada se desplaza no-opea
   limpio. (El umbral de 60 líneas del paso 5 decide cuánto resumir, no si se usa
   el helper.)
3. Comprueba con `bash "$ROTAR" contrato <proyecto>`.
4. Revisa que `.gitignore` no excluya `CLAUDE.md` — algunos frameworks lo generan
   y lo ignoran, y entonces la ficha no se versiona ni viaja.
5. Commitea. Si el proyecto no tiene remoto y debería tenerlo, dilo.

## 7. Reporta

Qué quedó en la ficha, qué comandos verificaste (y cuáles fallaron), qué permisos
propusiste, y qué se rotó. Si el proyecto era sensible y hubo comandos que no
corriste, dilo explícitamente.
