# Mecánica: banco de logros, estructura, ATS y verificación

Complemento operativo de `kit-cv/SKILL.md`. Aquí está el cómo; las reglas y los
criterios están en el SKILL.

## 1. Lectura de la vacante (paso previo a cualquier pregunta)

Con el texto de la vacante delante, llena esto y **muéstralo a la persona** antes
de entrevistarla:

| Campo | Qué anotar |
|---|---|
| Puesto y seniority | El título literal y el nivel real que se lee entre líneas |
| Requisitos excluyentes | Los que aparecen como "indispensable", "must", o repetidos |
| Deseables | Lo que suma pero no descarta |
| Problema real del puesto | Qué se rompió o qué van a escalar para abrir esta plaza |
| Vocabulario propio | Términos exactos que hay que espejear si son verdad |
| Empresa | Giro, tamaño, producto, algo publicado y verificable |
| Señales de cultura | Estructura, ritmo, si es primer puesto del área |

Dos lecturas que casi siempre pagan: un requisito repetido dos veces en el texto es
el que de verdad filtra; y una lista larguísima de tecnologías suele significar que
el equipo es chico y buscan alguien que haga de todo.

Si la vacante no existe todavía, se define el puesto objetivo con la persona y se
llena la misma tabla con lo que se espera de ese mercado, declarándolo como
supuesto.

## 2. Protocolo del CV anterior

Cuando llega un CV previo, se lee entero y se clasifica cada línea en tres montones
antes de escribir nada nuevo:

- **Rescatar** — fechas, puestos, instituciones y nombres propios: son los datos
  duros que ya no hay que volver a preguntar.
- **Auditar** — toda afirmación sin cifra, todo verbo grande ("lideré", "diseñé"),
  toda habilidad listada. Cada una se confirma con la persona: qué hiciste
  exactamente, cuánto fue, con qué evidencia. Un CV anterior es un borrador de
  alguien más, no una fuente de verdad; hereda las inflaciones de quien lo escribió.
- **Tirar** — objetivos genéricos ("busco un reto profesional"), datos personales
  innecesarios, barras de nivel de habilidad, formato de dos columnas, y todo lo
  que no responda a la vacante de hoy.

Además, del CV anterior se extraen tres cosas que no son texto: los **huecos de
fechas** (a preguntar sin rodeos), los **saltos de giro o de nivel** (a explicar en
el resumen o la carta) y el **techo de página** (si ya venía en tres páginas, hay
que decidir qué se corta, no encoger la tipografía).

Si el CV anterior está en PDF y no se puede extraer texto, avísalo: es señal de que
la persona lleva tiempo enviando un CV que ningún ATS puede leer.

## 3. Entrevista por bloques (banco de preguntas)

Se pregunta por bloques de 3 a 5, saltando todo lo que ya contestaron el CV
anterior, LinkedIn o la conversación. La meta es extraer al máximo, no ahorrar
preguntas.

**Bloque A — destino y encuadre**
1. ¿A qué vacante concreta va esto, y para cuándo cierra?
2. ¿En qué idioma, y se sube a un portal o va directo a una persona?
3. ¿Es tu CV, de alguien de tu equipo, o vas a evaluar a un candidato?
4. ¿Estás cambiando de puesto, de empresa o de giro? ¿Por qué ahora?

**Bloque B — dónde está hoy**
1. ¿Qué haces un día normal, y qué parte te toma más tiempo?
2. ¿Qué te piden a ti porque nadie más en el equipo sabe hacerlo?
3. ¿A quién le reportas y quién te reporta? ¿Presupuesto a tu cargo?
4. ¿Qué te dijeron en tu última evaluación de desempeño, bueno y malo?

**Bloque C — logros, con cifra (el bloque largo, uno por puesto)**
1. ¿Qué existía antes de ti en ese puesto y qué existe ahora?
2. ¿Qué estaba roto y arreglaste? ¿Qué pasaba si no se arreglaba?
3. ¿Qué haces hoy en menos tiempo, con menos gente o con menos dinero que antes?
4. ¿Qué número movió tu trabajo, aunque no fuera tu meta oficial?
5. Por cada respuesta anterior, la repregunta obligatoria: **¿cuánto, de cuánto a
   cuánto, en cuánto tiempo, cuántas personas, y cómo lo sabes?**
6. ¿Lo hiciste solo, lo lideraste, o contribuiste? ¿Cuánta gente más?

**Bloque D — lo incómodo (no se esquiva)**
1. ¿Hay huecos entre empleos? ¿Qué pasó y cómo lo quieres contar?
2. ¿Alguna salida que preferirías no detallar? ¿Hay contrato de no competencia?
3. ¿Qué cifras de tu trabajo **no** puedes publicar por confidencialidad o NDA?
   (Se sustituyen por magnitudes relativas: "reduje 40%" en vez del monto real.)
4. ¿Hay algo en tu historial que un reclutador vaya a preguntar y convenga tener
   preparado?

**Bloque E — logística y cierre**
1. Disponibilidad de inicio; ubicación, híbrido o remoto.
2. Expectativa salarial y si ya la pidieron en el proceso.
3. Permiso de trabajo o visa, si aplica al país de la vacante.
4. ¿Quieres carta de presentación y actualización de LinkedIn en el mismo paquete?

Regla de cierre: antes de pasar al banco de logros, devuelve a la persona un
resumen de lo que entendiste y pregunta qué falta. Casi siempre aparece ahí el
mejor logro, el que no creía que contaba.

## 4. Banco de logros

Se construye una vez por persona y se reutiliza en cada postulación. Vive en la
carpeta del interesado como `BANCO-LOGROS.md`, nunca solo en el chat.

| Logro (verbo + qué) | Magnitud | Periodo | Rol real | Evidencia | Palabras clave |
|---|---|---|---|---|---|
| Automaticé la reportería semanal de tiendas | 40 tiendas, 6 h → 20 min | 2025-03 a 2025-08 | ejecuté solo | script en repo X, correo de Y | Python, ETL, automatización |

Reglas de llenado:

- **Magnitud** siempre en unidades duras: pesos, %, horas, personas, volumen,
  plazo. Si no hay número, el logro entra al banco marcado `[SIN CIFRA]` y solo
  se usa si no hay nada mejor.
- **Rol real** con una de tres etiquetas: *ejecuté solo*, *lideré a N personas*,
  *contribuí en equipo de N*. Esa etiqueta decide el verbo del CV.
- **Evidencia** es de dónde sale la cifra (reporte, repo, correo, tablero). Si la
  evidencia es "lo recuerdo", se anota así y se confirma con el usuario.
- **Palabras clave** son los términos con los que una vacante buscaría ese logro.
  Sirven para el mapa vacante → evidencia del SKILL (paso 5).

Cuando la persona dice que "no tiene nada que poner", el problema es la pregunta,
no la trayectoria: usa el bloque C del §3 y repregunta por la cifra hasta que
aparezca. Siempre aparece.

## 5. Estructura del CV

Orden por defecto, con experiencia profesional:

1. **Encabezado** — nombre, oficio en una línea, ciudad/país, teléfono, correo,
   LinkedIn. Sin foto ni datos de identificación (ver SKILL, sección de datos
   personales).
2. **Resumen** — 2 o 3 líneas: qué es, cuántos años, especialidad, y el gancho
   que conecta con la vacante. Se reescribe en cada postulación.
3. **Experiencia** — de lo más reciente a lo más antiguo. Por puesto: empresa,
   puesto, ciudad, mes-año inicio – mes-año fin, y de 2 a 4 viñetas de resultado.
4. **Educación** — institución, grado, año (o "en curso, titulación prevista AAAA").
5. **Habilidades** — agrupadas y honestas: solo lo que aguanta una pregunta
   técnica. Máximo 8 a 10 elementos.
6. **Extras solo si suman a esta vacante** — certificaciones, idiomas con nivel
   real, publicaciones, proyectos propios, voluntariado.

Si la persona tiene poca o ninguna experiencia laboral, sube **Educación** y
**Proyectos** por encima de Experiencia, y las viñetas de proyecto se escriben con
la misma exigencia de magnitud y resultado.

Fórmula de viñeta: `verbo de acción + qué + magnitud + efecto`.
Verbos que cargan resultado: automaticé, reduje, aumenté, diseñé, implementé,
negocié, migré, coordiné, detecté, estandaricé, recuperé.
Verbos que no dicen nada y se evitan: apoyé, participé, colaboré, fui responsable
de, me encargué de, ayudé con.

## 6. Reglas ATS (lo que rompe la lectura automática)

Nada de esto entra en un CV que pasa por portal:

- Dos o más columnas, cuadros de texto, tablas para maquetar.
- Encabezados y pies de página con datos que solo están ahí (el ATS los ignora).
- Iconos, emojis, barras o estrellas de "nivel de habilidad" (un gráfico no se lee).
- Imágenes con texto dentro, incluido el CV exportado como imagen o escaneado.
- Tipografías decorativas o no incrustadas; fuentes por debajo de 10 pt.
- Fechas ambiguas ("2 años", "verano pasado"): siempre `mm/aaaa – mm/aaaa`.
- Nombres de sección creativos ("Mi trayectoria"): usar Experiencia, Educación,
  Habilidades, que es lo que el parser busca.
- Nombre de archivo genérico: usar `Apellido-Nombre-CV-Puesto.pdf`.

## 7. Cadena de generación y verificación (esta máquina, verificada 2026-08-25)

Disponible: `pdftotext`, Chrome, Python con `pypdf` y `pymupdf`. No hay pandoc,
LibreOffice ni wkhtmltopdf: no los propongas sin instalarlos.

CV en HTML de una columna → PDF con Chrome headless:

```bash
"/c/Program Files/Google/Chrome/Application/chrome.exe" --headless --disable-gpu \
  --no-pdf-header-footer --print-to-pdf="CV.pdf" "file:///ruta/cv.html"
```

`--no-pdf-header-footer` es obligatorio: sin él Chrome estampa URL y fecha en cada
página. En el CSS, `@page { size: Letter; margin: 14mm; }` y tipografía de 10.5 a
11 pt para cuerpo.

Verificación mínima, siempre antes de entregar:

```bash
pdftotext -layout CV.pdf - | head -60          # ¿sale el texto, en orden?
python -c "import pypdf,sys; print(len(pypdf.PdfReader(sys.argv[1]).pages))" CV.pdf   # páginas
pdftotext CV.pdf - | wc -w                      # 350-550 palabras en una página
```

Si `pdftotext` devuelve vacío o texto desordenado, el CV está roto para el ATS,
aunque en pantalla se vea perfecto. Se corrige antes de entregar, no se avisa
después.

Trampa de consola: en Git Bash los acentos salen como `?` porque la terminal es
cp1252, no porque el PDF esté mal. Antes de "arreglar" una codificación, confírmalo
leyendo en UTF-8 — probado en esta máquina el 2026-08-25, el PDF conserva acentos
y `·` aunque la consola los muestre roto:

```bash
python -c "import fitz,io; t=fitz.open('CV.pdf')[0].get_text(); print('acentos ok:', 'ó' in t)"
```

## 8. Carta de presentación

Media página, tres párrafos, misma tipografía que el CV:

1. **Por qué esta vacante y esta empresa** — una razón concreta y verificable de
   la empresa (producto, mercado, algo publicado), no adulación genérica.
2. **Las dos pruebas más fuertes** — dos logros del banco, con cifra, que atacan
   los dos requisitos principales. No repite el CV completo.
3. **Qué pido y cómo sigo** — disponibilidad y siguiente paso, en una línea.

Sin "espero que este correo te encuentre bien", sin "apasionado por", sin repetir
el nombre de la empresa en cada párrafo.

## 9. Perfil de LinkedIn derivado

- **Titular**: oficio + especialidad + dominio. "Analista de datos | automatización
  de reportería en retail", no "Apasionado por la tecnología".
- **Acerca de**: 3 a 5 líneas en primera persona, con dos cifras del banco.
- **Experiencia**: mismas fechas y puestos que el CV, viñetas más cortas.
- Contradicciones entre CV y LinkedIn (fechas, títulos, empresas) se leen como
  mentira: se revisan las dos versiones a la vez, siempre.
