# Instructivo del Kit Chema

Esta guía explica qué es cada pieza del kit, dónde queda instalada y cómo darte
cuenta de que está funcionando. No es la guía de cómo escribir peticiones —eso
está en `COMO-PEDIR.md`—; aquí el objetivo es otro: reconocer las piezas y
tener señales claras para saber si el kit está activo o si algo no cargó.

El kit tiene tres tipos de pieza. El **núcleo** son las reglas universales que
Claude aplica en toda conversación. Las **skills** son playbooks de dominio que
se activan solos cuando la tarea los necesita. El **hook** es una regla que se
cumple siempre porque la ejecuta la máquina, no depende de que Claude la
recuerde. A eso se suman el **contexto** (empresa y personal, tus datos) y `COMO-PEDIR.md`
(para ti, no para Claude).

## 1. Mapa del kit

Todo se instala bajo `~/.claude/` cuando corres `./instalar.sh`. Esta es cada
pieza, dónde queda y cómo notas que actúa.

| Pieza | Dónde queda instalada | Cuándo actúa | Cómo saber que funciona |
|---|---|---|---|
| **Núcleo** (`nucleo/CLAUDE.md`) | `~/.claude/CLAUDE.md`, dentro de una sección marcada | Siempre, en toda conversación | Pides un deck y Claude pregunta audiencia y objetivo antes de empezar; propones una idea y te dice qué le preocupa antes de ejecutarla |
| **kit-presentaciones** | `~/.claude/skills/kit-presentaciones/` | Deck, láminas, pptx o informe con audiencia | Claude define audiencia, objetivo y narrativa antes de tocar el diseño |
| **kit-analisis-datos** | `~/.claude/skills/kit-analisis-datos/` | Analizar o explorar datos: CSV, Excel, ventas, métricas, dashboards | Claude comenta la calidad del dato (huecos, periodo) antes de sacar conclusiones y separa el hecho de la interpretación |
| **kit-research** | `~/.claude/skills/kit-research/` | Investigar con fuentes: comparativas, mercado, normativa | Cita con URL y fecha, cruza dos fuentes independientes y marca lo que viene de una sola |
| **kit-codigo** | `~/.claude/skills/kit-codigo/` | Escribir, modificar o revisar código y scripts | Lee el código existente antes de escribir, corre lo que hizo con datos reales y no deja archivos de prueba sueltos |
| **kit-propuestas** | `~/.claude/skills/kit-propuestas/` | Redactar o evaluar una propuesta o decisión; palabra `council` | Estructura problema / opciones / costos / recomendación / reversión; con `council` corre un panel con veredicto |
| **kit-finanzas** | `~/.claude/skills/kit-finanzas/` | Cotización, presupuesto, proyección, margen, costos | Lista los supuestos aparte, recalcula cada cifra y entrega las proyecciones con escenarios, no con un número único |
| **kit-automatizacion** | `~/.claude/skills/kit-automatizacion/` | Automatizar un proceso: cron, integración, bot, flujo que corre solo | Define disparador, entradas y salidas antes de construir y deja escrito cómo apagarlo |
| **Contexto** (`contexto/*.md`: empresa y personal) | `~/.claude/contexto/` (cada plantilla solo se instala si no existe) | Antes de cualquier trabajo sustantivo | Claude usa tu tono, glosario y marca sin que se lo repitas cada vez |
| **Hook anti-secretos** (`hooks/anti-secretos.sh`) | `~/.claude/hooks/` más una entrada en `settings.json` (opt-in) | Justo antes de un `git commit` que Claude ejecuta (solo dentro de Claude Code) | Intenta commitear un archivo con una clave y el commit se bloquea con un aviso del kit |
| **COMO-PEDIR.md** | Se queda en el repo; no se instala en `~/.claude/` | Cuando tú redactas una petición | No cambia el comportamiento de Claude: te ayuda a ti a pedir mejor (anatomía de la petición, plantillas, palabras clave) |

Las siete skills viven en `~/.claude/skills/` y Claude elige cuál usar por su
`description`: no tienes que nombrarlas, basta con describir la tarea.

## 2. Señales de que está funcionando

La prueba más rápida es pedir un trabajo normal y ver si Claude cambia su forma
de trabajar. Cada fila es una señal de que sí, y su señal de alarma cuando no.

- **Deck.** Pides una presentación y Claude pregunta para quién es y qué debe
  lograr antes de escribir la primera lámina. Si arranca a diseñar sin preguntar
  la audiencia, el núcleo no está cargado en este `~/.claude/`.
- **Cotización o números.** Pides una cotización y Claude lista los supuestos
  aparte y recalcula las cifras. Si te devuelve un número solo, sin supuestos ni
  escenarios, `kit-finanzas` no disparó.
- **Tu propia idea.** Propones una decisión y Claude te responde qué está bien,
  qué le preocupa y qué haría él, antes de ejecutar. Si dice "perfecto" y la hace
  tal cual —sin que tú dijeras `hazlo directo`—, la evaluación crítica del núcleo
  no está activa.
- **Council.** Escribes `council` y Claude corre un panel de evaluadores con un
  veredicto (aprobada / con cambios / rechazada). Si ignora la palabra y entrega
  sin panel, `kit-propuestas` o el núcleo no cargaron.
- **Datos.** Pides analizar un Excel y Claude comenta primero la calidad del dato
  (filas vacías, rango de fechas, unidades) y luego concluye. Si salta directo a
  conclusiones bonitas, `kit-analisis-datos` no disparó.
- **Research.** Pides investigar y las afirmaciones que importan traen URL y
  fecha, con lo dudoso marcado como de una sola fuente. Si te da afirmaciones
  sueltas sin de dónde salieron, `kit-research` no disparó.
- **Código.** Pides un script y Claude lo corre con datos reales y limpia lo
  temporal antes de decir que quedó. Si dice "listo" sin haberlo ejecutado o deja
  archivos de prueba tirados, revisa `kit-codigo`.
- **Contexto.** Mencionas un trabajo para la empresa y Claude usa tu tono y tu
  glosario sin que se lo repitas. Si pregunta cosas que ya están en
  `CONTEXTO-EMPRESA.md`, ese archivo está vacío o no lo está leyendo.
- **Terminado significa verificado.** Al cerrar, Claude te reporta lo que quedó
  fuera o lo que no pudo comprobar, no solo un "listo" a secas.
- **Hook.** Intentas commitear un archivo con una clave o token cuando Claude ejecuta el commit por ti y el commit se detiene con un mensaje del kit (no protege commits hechos a mano fuera de Claude Code). Si el commit pasa sin avisar, el hook no está instalado; actívalo con `KIT_HOOKS=s ./instalar.sh`.

Si no ves ninguna de estas señales en una conversación nueva, lo más probable es
que el kit no esté instalado en este `~/.claude/`, o que estés en claude.ai web
(ver la sección siguiente).

## 3. Uso en claude.ai web

claude.ai en el navegador no lee tu carpeta `~/.claude/`, así que ahí el kit no
se instala solo: se monta a mano dentro de cada proyecto y funciona en una
versión degradada, pero conserva el criterio y el vocabulario del kit.

- **Núcleo:** copia el contenido de `nucleo/CLAUDE.md` y pégalo como
  instrucciones del proyecto. Eso da a Claude las reglas universales. Como en la
  web no existe `~/.claude/contexto/`, pega también el contenido de
  tus archivos de `contexto/` (ya rellenados) al final de esas instrucciones.
- **Skills:** sube como archivos del proyecto los `SKILL.md` de las skills que
  vayas a usar en ese proyecto (por ejemplo el de presentaciones si es un deck).
  En la web no hay carga automática por descripción: subes tú lo que aplica.
- **Council:** corre en secuencial, no en paralelo. El panel funciona igual, solo
  que un evaluador después de otro; espera que tarde un poco más.
- **Hook:** no aplica en la web (no hay `git` local que interceptar). La regla de
  no filtrar credenciales sigue como consejo en el núcleo, pero sin el bloqueo
  automático que da el hook en tu equipo.

## 4. Actualizar el kit

Para traer la última versión, dentro de la carpeta del repo:

```bash
git pull && ./instalar.sh
```

El instalador es no destructivo. Solo reemplaza dos cosas: la sección del núcleo
marcada entre `<!-- kit-chema:inicio -->` y `<!-- kit-chema:fin -->` dentro de tu
`~/.claude/CLAUDE.md`, y las carpetas `skills/kit-*`. Lo que tú hayas escrito en
tu `CLAUDE.md` fuera de esos marcadores no se toca, y tu
las plantillas de `contexto/` se respetan si ya existen. Antes de reescribir la sección del
núcleo, guarda un respaldo de tu archivo anterior en `~/.claude/CLAUDE.md.pre-kit-chema.bak`,
por si necesitas volver atrás.

Después de actualizar puedes comprobar que el kit cumple sus límites con
`bash verificar.sh`: imprime una línea `OK` o `FALLA` por chequeo y sale con
código 0 si todo pasó.

## 5. Para IT (a futuro)

Cuando el kit se despliegue a toda la empresa, Claude Code trae una vía oficial
que no depende de que cada persona corra el instalador: un `CLAUDE.md` de
política gestionada —la clave `claudeMd` en `managed-settings.json`, o
`/etc/claude-code/CLAUDE.md` en Linux— se carga antes que los archivos de usuario
y de proyecto y no puede desactivarse por configuración individual. Es el camino
para imponer un estándar de uso de IA a toda la organización, complementado con
las skills (que se distribuyen igual) y los hooks para lo no negociable. El
detalle técnico, con fuentes oficiales, está en
`investigacion/reporte-mejores-practicas.md`.
