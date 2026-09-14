# Skill handoff — instalación, ajuste y desinstalación

Instalada y verificada el 2026-08-18 en Windows 11, Claude Code con
`model: opus[1m]`.

## Qué hace, en tres piezas

| Pieza | Cuándo corre | Qué hace |
|---|---|---|
| `hook-stop-aviso.ps1` | Al cerrar cada turno (`Stop`) | Mide el contexto real. Al 60% avisa al usuario; al 85% le indica a Claude que escriba el traspaso ahí mismo. |
| `hook-sessionstart-cargar.ps1` | Al arrancar sesión (`SessionStart`) | Si hay `HANDOFF.md` vigente, lo inyecta en la sesión nueva. Tras `/clear` retoma sola. |
| `hook-sessionend-red.ps1` | Al hacer `/clear` (`SessionEnd`) | Si se limpió sin traspaso, deja un puntero al transcript recuperable. |

La skill `SKILL.md` es la que escribe el documento; los hooks solo detectan,
avisan y reinyectan.

## Lo único que no es automático

Teclear `/clear`. Los comandos slash solo se reconocen al inicio de un mensaje
del usuario y ninguna herramienta del modelo los invoca — verificado contra la
documentación oficial, no es una limitación de esta skill. Todo lo demás
—detectar, medir, avisar, escribir el traspaso, recargarlo al arrancar— corre solo.

## Cómo mide el contexto

Lee el transcript JSONL de la sesión y toma el último registro `usage`:

```
contexto vivo = input_tokens + cache_creation_input_tokens + cache_read_input_tokens
```

Verificado a mano contra un transcript real el 2026-08-18. Los tokens cacheados
sí ocupan ventana, por eso se suman.

El porcentaje **no** se calcula sobre la ventana del modelo sino sobre un
*presupuesto útil* topado en 250K tokens. Razón: con ventana de 1M, avisar al 70%
sería avisar a los 700K, cuando la degradación empieza mucho antes (Chroma,
"context rot", 2025; Liu et al., TACL 2024). El consejo publicado es operar entre
40% y 60% de utilización.

## Ajustes por variable de entorno

| Variable | Efecto | Por defecto |
|---|---|---|
| `CLAUDE_HANDOFF_PRESUPUESTO` | Tokens útiles antes del 100% | 250000 |
| `CLAUDE_HANDOFF_VENTANA` | Ventana del modelo, si se detecta mal | 1M si el modelo trae `[1m]`, si no 200K |
| `CLAUDE_HANDOFF_AMARILLO` | % del aviso suave | 60 |
| `CLAUDE_HANDOFF_ROJO` | % del aviso que dispara el traspaso | 85 |
| `CLAUDE_HANDOFF_ARCHIVO` | Nombre del archivo de traspaso | `HANDOFF.md` |
| `CLAUDE_HANDOFF_TOPE` | Caracteres máximos que se reinyectan | 8000 |
| `CLAUDE_HANDOFF_MAXENTREGAS` | Veces que el mismo traspaso se reinyecta | 3 |
| `CLAUDE_HANDOFF_DEBUG` | Escribe los errores del hook a stderr | apagado |

Palanca complementaria del propio Claude Code: `/autocompact 300k` mueve el punto
en que entra la compactación automática.

## Probar sin esperar a que se llene el contexto

```powershell
# Medición actual
powershell -NoProfile -File "$env:USERPROFILE\.claude\skills\handoff\scripts\medir-contexto.ps1"

# Forzar el escalón rojo en la próxima respuesta
$env:CLAUDE_HANDOFF_ROJO = 1
```

Para ver los hooks en vivo: `claude --debug`.

## Desinstalar

1. Quitar de `~/.claude/settings.json` las entradas de `hooks` cuyo `command`
   apunte a `skills\handoff\scripts`. El respaldo previo está en
   `settings.json.bak-antes-handoff-2026-08-18`.
2. Borrar `~/.claude/skills/handoff/`.
3. Borrar `~/.claude/handoffs/` (solo contadores y avisos, ningún contenido de
   trabajo).

## Dónde vive el estado

- `~/.claude/handoffs/<session_id>.txt` — escalón ya avisado por sesión. Se purga solo a los 7 días.
- `~/.claude/handoffs/entregas.json` — cuántas veces se reinyectó cada traspaso.
- `~/.claude/handoffs/_ultimo-clear-sin-traspaso.txt` — puntero de emergencia.

Ninguno guarda contenido del trabajo: los traspasos viven en la carpeta de su
proyecto, cada uno en su ámbito.
