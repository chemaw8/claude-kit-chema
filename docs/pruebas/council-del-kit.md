# Council del propio kit (dogfooding) — 2026-07-09

Criterio de aceptación 8 del spec: el kit completo pasa por su propio
protocolo council antes de declararse v1.0. Se ejecutó con 4 evaluadores
Opus 4.8 de contexto fresco leyendo el repo real (lentes: usuario no técnico
que instala desde cero, fidelidad al spec P1-P10/R1-R12, riesgos de adopción,
abogado del diablo), mandato acotado con proporcionalidad, y veredicto
sintetizado con Fable 5.

## Veredicto: aprobada con cambios

Ningún lente encontró un defecto que bloquee la v1.0 (dos lentes cerraron
"sin hallazgos relevantes"; los hallazgos con evidencia venían marcados como
no condicionantes de la decisión de fondo). El veredicto bajó un nivel solo
porque el *acto de declarar* traía 4 condiciones mecánicas, todas aplicadas
en el commit `44187b6`:

1. **CHANGELOG a v1.0** — el instalador deriva la versión del CHANGELOG y
   estampaba "v0.9" en el marcador instalado.
2. **CONTINUAR.md desactualizado dentro del repo distribuible** — decía que
   el proyecto estaba sin construir; reescrito al estado real.
3. **Hook anti-secretos sobre-declaraba `git push`** — con `git diff
   --cached` el escaneo en push era un no-op (protección ilusoria). Se quitó
   push del hook y de la documentación; probado de nuevo (commit con secreto
   → bloquea; push → ya no promete nada que no haga).
4. **Sellos v0.9 en el deck** — actualizados a v1.0.

## Sugerencias aplicadas (sin condicionar)

Puntero "¿no usas terminal?" en el README; la ruta claude.ai web ahora indica
pegar también el CONTEXTO-EMPRESA; `instalar.sh` avisa y omite hooks si falta
python3 en vez de abortar; encabezado honesto en la tabla de palabras clave de
COMO-PEDIR (3 interruptores del núcleo + 2 convenciones); kit-propuestas fija
Fable 5 para la síntesis del veredicto (alineación con la escalera de
modelos); fecha de ejemplo genérica en el núcleo; rastro completo de los 8
criterios en `docs/pruebas/aceptacion.md`.

## Sugerencias diferidas a v1.1 (registradas en CHANGELOG)

Desinstalador, aviso de drift de versión instalada vs. repo, vía Windows
nativo (PowerShell), prueba end-to-end de la ruta claude.ai web, y marca
oficial en el deck cuando existan activos en `~/Trabajo/recursos/marca/`.

## Notas que José ratifica al usar la v1.0

- C.A.2 quedó en 20/21 disparos: el caso frontera ("haz un script que
  renombre fotos" → kit-automatizacion) es benigno porque ese playbook aplica
  kit-codigo al construir; no se engordaron las descriptions por un caso
  límite (principio anti-bloat).
- C.A.7 (deck "con marca") se cumple en forma condicional: paleta tomada del
  deck del grupo 2026-07 porque la carpeta de marca está vacía.

Evidencia íntegra: journal del workflow `wf_21c2505a-8ed` y la bitácora de la
sesión de construcción 2026-07-09.
