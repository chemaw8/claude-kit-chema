# hook-stop-aviso.ps1 - Kit Chema / skill handoff
# Hook Stop. Mide el contexto vivo al cerrar cada turno y actua en dos escalones:
#   AMARILLO -> systemMessage al usuario. No interrumpe nada.
#   ROJO     -> additionalContext: Claude sigue el turno y escribe el traspaso
#               sin que el usuario pida nada. Se usa additionalContext y no
#               decision "block" porque la doc lo reserva justo para esto:
#               el hook funciona como fue disenado y esta guiando, no fallando,
#               asi que no aparece como error de hook en el transcript.
# El modelo NO puede teclear /clear: los comandos slash solo se reconocen al
# inicio de un mensaje del usuario y no hay herramienta que los invoque.
# Avisa una sola vez por escalon y por sesion. Ante cualquier fallo sale en
# silencio con codigo 0: este hook jamas debe romper un turno.
# Sin acentos a proposito (PowerShell 5.1 los rompe si se pierde el BOM).

$ErrorActionPreference = 'Stop'
try {
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false

    $raw = [Console]::In.ReadToEnd()
    if (-not $raw) { exit 0 }
    $ev = $raw | ConvertFrom-Json

    # Proteccion nativa contra bucles: si el turno ya viene de un hook Stop, salir.
    if ($ev.stop_hook_active -eq $true) { exit 0 }

    . (Join-Path $PSScriptRoot 'lib-contexto.ps1')
    Remove-EstadoViejo -Dias 7

    $uso = Get-UsoContexto -TranscriptPath $ev.transcript_path
    if (-not $uso.ok) { exit 0 }

    # Escalones sobre el PRESUPUESTO UTIL, no sobre la ventana del modelo.
    $amarillo = 60
    $rojo     = 85
    if ($env:CLAUDE_HANDOFF_AMARILLO) { $v=0; if ([int]::TryParse($env:CLAUDE_HANDOFF_AMARILLO,[ref]$v)) { if ($v -gt 0) { $amarillo = $v } } }
    if ($env:CLAUDE_HANDOFF_ROJO)     { $v=0; if ([int]::TryParse($env:CLAUDE_HANDOFF_ROJO,[ref]$v))     { if ($v -gt 0) { $rojo = $v } } }

    $alcanzado = 0
    if ($uso.pct -ge $amarillo) { $alcanzado = $amarillo }
    if ($uso.pct -ge $rojo)     { $alcanzado = $rojo }
    if ($alcanzado -eq 0) { exit 0 }

    # Una vez por escalon y por sesion.
    $sid = [string]$ev.session_id
    if (-not $sid) { $sid = 'sin-id' }
    $sid = ($sid -replace '[^A-Za-z0-9_-]', '')
    $marca = Join-Path (Get-DirEstado) ($sid + '.txt')

    $yaAvisado = 0
    if (Test-Path -LiteralPath $marca) {
        $prev = 0
        $txt = (Get-Content -LiteralPath $marca -Raw -ErrorAction SilentlyContinue)
        if ($txt) { if ([int]::TryParse($txt.Trim(), [ref]$prev)) { $yaAvisado = $prev } }
    }
    if ($alcanzado -le $yaAvisado) { exit 0 }
    Set-Content -LiteralPath $marca -Value ([string]$alcanzado) -Encoding ascii

    $cwd = [string]$ev.cwd
    if (-not $cwd) { $cwd = (Get-Location).Path }
    $kTok = [math]::Round($uso.tokens / 1000.0, 0)
    $kPre = [math]::Round($uso.presupuesto / 1000.0, 0)

    $bel = [string][char]7
    $esc = [string][char]27

    if ($alcanzado -lt $rojo) {
        # AMARILLO: avisar al usuario y no interrumpir.
        $salida = [ordered]@{
            systemMessage    = "[handoff] Contexto: ${kTok}K de ${kPre}K utiles ($($uso.pct)%). Buen momento para cerrar con /handoff y reiniciar limpio."
            terminalSequence = "$esc]0;Claude - contexto $($uso.pct)%$bel"
        }
        [Console]::Out.Write(($salida | ConvertTo-Json -Depth 4 -Compress))
        exit 0
    }

    # ROJO: que el modelo escriba el traspaso antes de cerrar el turno.
    $guia = @"
[hook handoff] La sesion va en ${kTok}K de ${kPre}K tokens utiles ($($uso.pct)% del presupuesto). De aqui en adelante el razonamiento se degrada, y un /compact arrastraria los supuestos equivocados de esta conversacion en vez de limpiarlos.

Haz esto AHORA, antes que cualquier otra cosa, y nada mas que esto:
1. Invoca la skill handoff (Skill tool, skill: "handoff").
2. Escribe el traspaso siguiendo esa skill. Carpeta del trabajo en curso: $cwd
3. Comprueba que no queden tareas en segundo plano corriendo, y termina el turno diciendole al usuario, en una linea, que teclee /clear.

No sigas con la tarea anterior. Si no hay trabajo abierto que traspasar, dilo en una linea y termina. Este aviso no se repite en esta sesion.
"@

    $salida = [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName     = 'Stop'
            additionalContext = $guia
        }
        systemMessage    = "[handoff] ${kTok}K de ${kPre}K tokens utiles ($($uso.pct)%). Escribiendo el traspaso; despues teclea /clear."
        terminalSequence = "$bel$esc]0;HANDOFF pendiente - teclea /clear$bel"
    }
    [Console]::Out.Write(($salida | ConvertTo-Json -Depth 4 -Compress))
    exit 0
}
catch {
    if ($env:CLAUDE_HANDOFF_DEBUG) { [Console]::Error.WriteLine("[handoff] " + $_.Exception.Message + " | " + $_.ScriptStackTrace) }
    exit 0
}
