---
description: Genera para este proyecto una forma escrita y ejecutable de probar la app como la usa una persona —un mapa en docs/verificacion/ y un script que la arranca, la recorre, guarda evidencia y limpia— y la prueba una vez antes de entregarla. Úsalo en apps con interfaz o servicio (web, API, CLI) cuya ficha solo dice «corre las pruebas» y «levántala». No hace falta en proyectos que generan entregables (reportes, PDF, Excel) cuya ficha ya dice cómo revisar la salida.
---

Vas a dejarle a este proyecto una forma de probar que la app sirve, no solo que compila o que la
suite pasa. La leerá en frío, a media tarea, un agente que nunca vio la app: escribe para él.
(Adaptado de `create-verification-skill` y `maintain-verification-skill` de pstack, Lauren Tan, MIT.)

**Antes de correr nada en el entorno del usuario, pide permiso**: el recorrido crea y borra datos en
su BD de desarrollo, y si la app llama a una API de pago (un LLM, SMS, correo), recorrerla cuesta y
manda datos fuera. Di cuál de las dos cosas pasará y cómo evitarla.

## Pasos

1. **Entrevista al repo, no al usuario.** Del código y la ficha saca: qué toca el usuario (web, API,
   CLI, varias; elige la principal), cómo arranca (el comando documentado del repo, puertos, variables,
   datos de siembra), cómo se maneja desde un script (primero lo que el repo ya tenga: pruebas e2e,
   endpoints; luego curl, navegador sin ventana o una terminal), qué evidencia se puede guardar
   (respuestas, capturas, archivos exportados, filas en la BD) y si dos instancias pueden convivir.
   Pregunta solo lo que no se puede observar.
2. **Si no arranca tal cual, arréglalo o repórtalo antes.** Un mapa escrito sobre una base rota enseña
   pasos falsos. Lo que cueste arrancar va a la ficha como trampa (ejemplo real: con npm 11, `npm ci`
   ya no genera el cliente de Prisma).
3. **Escribe el mapa** en `docs/verificacion/README.md` con estas secciones, todas con comandos reales
   del repo: Arrancar (y cómo saber que está lista) · Chequeo previo (solo lectura: ¿vale la pena
   probar esta instancia?) · Recorrer · Evidencia · Limpieza · Mapa de funciones. Luego un archivo por
   función de usuario en `docs/verificacion/funciones/` (3 a 5 para empezar): cómo se llega, qué
   resultado visible prueba que sirve, trampas.
4. **Construye la herramienta**: `scripts/verificar-app.sh` con `doctor | recorrer | limpiar`. Reglas:
   - Recorre por la ruta del usuario (sus endpoints o su interfaz). La BD solo se lee para decidir qué
     elegir o para cotejar, nunca para escribir el resultado que se quiere probar.
   - Coteja la salida contra la fuente: un export contra la BD, un total contra sus renglones.
   - La evidencia va fuera del repo (`~/.cache/<proyecto>-verificacion/<fecha-hora>/`) y sobrevive a la
     limpieza. Puede traer datos de cliente: no se sube a ningún lado.
   - Se niega a correr contra una BD o un servicio que no sea local.
   - Falla cerrado: un error al consultar es salida 2, nunca «no encontré nada».
   - Crea con un prefijo (`verificacion-…`) y limpia solo eso; mata solo lo que arrancó, nunca por
     nombre de proceso.
   - Si la app va a gastar (una API de pago), el chequeo previo lo avisa y el mapa dice cómo evitarlo.
5. **Pruébala antes de entregarla.** Corre `recorrer` de punta a punta y abre la evidencia (la captura
   se mira, no solo se confirma que existe). Después de `limpiar`, la evidencia debe seguir ahí. Luego
   mete a propósito un defecto en una parte sin pruebas (una ruta, una transición de estado) y confirma
   que el script lo detecta. Siembra el defecto en un worktree o clon desechable, nunca en el árbol de
   trabajo del usuario. Si no puedes crear uno, no siembres: pide permiso o sáltalo y dilo en el
   reporte. Al terminar, borra esa copia. Si el script no lo detecta, no prueba nada:
   corrígelo. Una herramienta que nunca se corrió es un borrador.
6. **Una línea en la ficha**, en «Stack y cómo correr»: `Probar de verdad: docs/verificacion/README.md
   y scripts/verificar-app.sh recorrer → sale 0 y deja evidencia en …`. Y en el mapa, arriba: el
   recorrido **no sustituye** la prueba de regresión; quien arregla un bug deja también la prueba que
   lo reproduce.

## Mantenerla viva

Quien cambia una función actualiza su archivo en `funciones/` y el script en el mismo cambio. Si
`recorrer` falla sin que tu cambio lo explique, primero decide qué falló. Si la app se porta mal, es un
defecto: el fallo se queda, se reporta y el recorrido no se ajusta para aceptarlo. Si la app cambió a
propósito y el mapa quedó viejo (otra ruta, otro paso), corrige el mapa en su propio commit, con la
corrida que lo prueba, sin mezclarlo con el trabajo.

## Reporte final

Qué superficie cubre y cuál no, la salida del `recorrer` y dónde quedó la evidencia, qué defecto
sembrado detectó, qué trampas de arranque encontraste y qué costó o qué datos salieron al probar
(o «nada»). Lo que quede en manos del usuario (fusionar, rotar una clave), como decisión concreta.
