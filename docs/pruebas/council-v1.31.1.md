# Council v1.31.1. Limpieza del texto del kit: raya al estilo inglés y prefijos con guion (2026-10-08)

Rama `texto/rayas-y-prefijos` (`git diff main...texto/rayas-y-prefijos`). Pendiente desde el acta v1.27 («el texto del
kit conserva 39 rayas espaciadas y 15 prefijos con guion; limpiarlos toca descriptions y queda para otra ronda»).
Pedido por el dueño el 2026-10-07.

## Qué entra

Solo forma, sin cambiar reglas. En el núcleo, las 9 skills, los 4 agentes y los 3 comandos:
- **54 rayas con espacio a ambos lados** (estilo inglés, señal F9 de `scripts/muletillas.sh`) pasan a dos puntos,
  coma, punto y coma o paréntesis según la función, y una a inciso pegado («—su alcance—», norma RAE 2010).
- **19 prefijos con guion** (F12) se escriben juntos: `multiagente`, `reejecutar`, `anticontaminación`,
  `sobreingeniería`, `antianclaje`, `multisesión`, `multiángulo`, `rededucir`, `relanzamiento`. `anti-secretos`, que es
  el nombre de un hook, pasa a código.
- Tocan **16 descriptions** (9 skills, 4 agentes, 3 comandos): en todas, solo la raya. Ninguna palabra gatillo cambia.

Conteo con `scripts/muletillas.sh revisar` sobre `nucleo/*.md skills/*/SKILL.md skills/*/references/*.md agents/*.md
commands/*.md`: F9 55 → 1 y F12 19 → 0; 18,564 → 18,512 palabras. La F9 que queda es un falso positivo del script
(`commands/cierre.md:34`, inciso bien puesto que cierra tras un `código`). El conteo de v1.27 (39 y 15) era sobre un
conjunto más chico de archivos.

## Evidencia

- **Por qué vale la pena** (acta v1.27): en el A/B de la raya, «con kit» dio 2 de 10 textos con raya espaciada y «kit
  sin rayas» 1 de 10; sin kit, 0 de 10. Provisional (n=10, Fisher p ≈ 0.47) y el kit no es la mayor fuente (las notas
  del vault tienen más). Los prefijos con guion: 0 en texto humano, 15 en el kit, 16 en entregables reales.
- **Gate de disparo:** `python3 docs/pruebas/disparo.py --modelo sonnet --paralelo 6` sobre e480497 → núcleo 21/21,
  confusiones de frontera no benignas 0, rc=0.
- `bash verificar.sh`: rc=0, ninguna FALLA.

## Riesgos que el autor ya ve

- El beneficio no está medido en la audiencia: se limpia una dosis moderada de una fuente entre varias.
- El mandato del evaluador de `kit-propuestas` se «pasa literal»: cambia una palabra (`sobre-ingeniería` →
  `sobreingeniería`). Las actas viejas lo citan con guion; no se reescriben.
- Choca en el núcleo con el PR #82 (v1.32, en borrador) solo si tocan las mismas líneas: no las tocan.

## Postura inicial del autor (antes de leer al panel)

Aprobada: es forma, el gate pasa y es reversible con un revert. Mi única duda es si alguna sustitución cambió el
sentido de una frase.
