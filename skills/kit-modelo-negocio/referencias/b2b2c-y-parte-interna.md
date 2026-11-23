# B2B2C (varios actores) y parte interna del canvas

Aprendido de un caso real terminado; los ejemplos están generalizados.

## 1. Mapa de empatía: uno por actor, no uno por segmento

En B2B2C quien decide, quien opera y quien usa suelen ser personas distintas; cuando lo son, un mapa para cada uno
(si dos coinciden, se fusionan y se dice):

| Actor | Qué responde su mapa |
|---|---|
| Decisor del socio (dirección general) | Qué le preocupa de su negocio: cartera, fondeo, competencia, regulación |
| Operador del socio (área o producto que lo administra) | Qué promete hoy su programa, qué le falta y qué le cuesta operarlo |
| Beneficiario final | Qué vive con el producto del socio y con el nuestro (con microdatos si existen) |

Estructura fija de cada mapa: **Fuentes** (tabla con id, alcance y verificación) → **Retrato** → **Qué vive o le
preocupa** → **Mapa de empatía** → **Dónde podría entrar el negocio** → **Validación pendiente** → **Pendiente**. Cada
rasgo cita el id de su fuente; una nota de prensa sin respaldo se marca «fuente única».

## 2. Propuesta de valor con escenarios de quién paga

No se escoge pagador de antemano: se modelan los escenarios y se comparan.

1. **Oferta de trabajo**: tabla Elemento | Supuesto | Tipo (paquete, costo, condición, elegibilidad, cobro).
2. **Propuesta por actor y escenario**: filas = dolores del mapa; columnas = escenario 1 (paga el socio) y escenario 2
   (paga el usuario y el socio cobra una participación de ingresos). Señalar dónde el escenario 2 deja de ser
   beneficio y se vuelve venta, y qué incentivo cambia.
3. **Economía por actor y escenario**, para el negocio y para el socio, con un bloque de verificación reproducible.
4. **Al terminar la relación con el socio**: ¿el usuario se queda y cómo paga?
5. **Operación, riesgos, piloto y lo que valida el usuario.**

Restricción legal típica: el beneficio no puede condicionar el producto principal del socio. Va como restricción en el
JSON de la hipótesis (regla C5) y se marca «revisar con abogado».

## 3. Parte interna: misma plantilla para actividades, recursos, alianzas y costos

| Sección | Contenido |
|---|---|
| Marco | Quién es el negocio frente a su grupo (por ejemplo, unidad que paga servicios internos a costo más margen) |
| Común / propio de cada segmento | Lo compartido primero; luego solo lo distinto (digital frente a asistido) |
| Motivo (alianzas) | Por qué cada socio: optimización, reducción de riesgo o adquisición de recursos |
| Respuestas del responsable, con fecha | Convierten supuestos del agente en supuestos con dueño |
| Riesgos | Lo que puede volverse costo |

Costos: primero el tipo de estructura (orientada a costos o a valor, economías de escala y de alcance); luego
**variables por unidad**, **por alta**, **fijos** y **riesgos que pueden volverse costo**, cada partida con «qué la
mueve» y su estado (conocido / supuesto / por cotizar). Alimenta directamente las hojas de supuestos del P&L.
