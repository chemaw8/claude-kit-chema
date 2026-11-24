# Protocolo — caso dorado modelo-negocio-01

Objetivo: medir si `kit-modelo-negocio` mejora un encargo de modelo de negocio frente al kit actual, como pidió el
council del PR #113 (2026-11-22). Caso ficticio («Habla», clases de inglés en línea), no relacionado con el caso que
originó la skill, para medir si la skill generaliza.

## Encargo (idéntico para los dos brazos)
> Vamos a lanzar Habla. Te dejo en esta carpeta lo que tenemos (junta, costos, memo de la aseguradora y una
> encuesta). Ármame el modelo de negocio y dime con qué segmento y con qué socio arrancamos, y si da. Es para
> dirección.

## Ejecución
- `claude plugin eval` sobre dos copias del repo sin `docs/pruebas/casos-dorados/` (para que el brazo no vea la
  clave): A desde `origin/main`, B desde la rama del PR. `--ablation none --runs 3 --model opus`, núcleo en
  `append_system_prompt`, insumo copiado al directorio de trabajo con `scaffold_script`.
- Se guarda la respuesta final de cada corrida, se cega (`scripts/cegar.sh etiquetar`) y la califican dos jueces
  (codex y kimi) con `rubrica.md` y `clave.md`.
- Resultados en `resultados.md` con fecha, costo y el mapa de letras al final.
