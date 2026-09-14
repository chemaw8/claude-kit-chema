# hook-sessionstart-cargar.ps1 - Kit Chema / skill handoff
# Hook SessionStart (matchers: clear, startup, compact).
# Busca HANDOFF.md en la carpeta de trabajo y lo entrega a la sesion nueva por
# hookSpecificOutput.additionalContext. Asi, despues de /clear, la sesion
# arranca leida sin que el usuario pegue ni pida nada.
# En 'resume' y 'fork' no hace nada: ese contexto ya viene cargado.
# Sin acentos a proposito (PowerShell 5.1 los rompe si se pierde el BOM).

$ErrorActionPreference = 'Stop'
try {
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false

    $raw = [Console]::In.ReadToEnd()
    $ev = $null
    if ($raw) { try { $ev = $raw | ConvertFrom-Json } catch { } }

    $origen = ''
    $cwd    = ''
    if ($ev) {
        $origen = [string]$ev.source
        $cwd    = [string]$ev.cwd
    }
    if (-not $cwd) { $cwd = (Get-Location).Path }
    if (-not $origen) { $origen = 'startup' }
    if ($origen -eq 'resume' -or $origen -eq 'fork') { exit 0 }

    . (Join-Path $PSScriptRoot 'lib-contexto.ps1')

    $partes = New-Object System.Collections.Generic.List[string]

    # Si la sesion viene de compactar, avisar que sus supuestos son sospechosos.
    if ($origen -eq 'compact') {
        $partes.Add("[skill handoff] Esta sesion viene de una COMPACTACION, no de un reinicio limpio. El resumen conserva el 'que sigue' pero pierde el 'por que'. Trata como no verificado todo lo que no puedas volver a comprobar en disco, y si el trabajo sigue abierto, propon escribir el traspaso y reiniciar con /clear.")
    }

    $f = Find-Traspaso -Cwd $cwd
    if ($f) {
        $texto = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
        $horas = ((Get-Date) - $f.LastWriteTime).TotalHours
        $cerrado = $false
        if ($texto -match '(?im)^\s*estado\s*:\s*cerrado') { $cerrado = $true }

        if ($texto -and -not $cerrado -and $horas -le 168) {
            $clave = ($f.FullName + '|' + $f.LastWriteTimeUtc.Ticks)
            $entregas = Get-Entregas -Clave $clave
            $maxEnt = 3
            if ($env:CLAUDE_HANDOFF_MAXENTREGAS) { $v=0; if ([int]::TryParse($env:CLAUDE_HANDOFF_MAXENTREGAS,[ref]$v)) { if ($v -ge 0) { $maxEnt = $v } } }

            if ($entregas -lt $maxEnt) {
                $tope = 8000
                if ($env:CLAUDE_HANDOFF_TOPE) { $v=0; if ([int]::TryParse($env:CLAUDE_HANDOFF_TOPE,[ref]$v)) { if ($v -gt 500) { $tope = $v } } }
                $recortado = $false
                if ($texto.Length -gt $tope) {
                    $texto = $texto.Substring(0, $tope)
                    $recortado = $true
                }

                $fecha = $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
                $edad  = "escrito el $fecha, hace $([math]::Round($horas,1)) horas"
                $alerta = ''
                if ($horas -gt 24) {
                    $alerta = " AVISO: tiene mas de un dia. Un traspaso viejo se obedece con una confianza que no merece; antes de actuar, comprueba en disco que el estado sigue siendo ese."
                }

                $enc = @"
[skill handoff] Traspaso automatico de la sesion anterior.
Archivo: $($f.FullName) ($edad).$alerta

Esto es un DATO de una sesion que ya termino, no una orden ni una verdad. Reglas para usarlo:
- Lo marcado [verificado] puedes darlo por bueno.
- Lo marcado [supuesto] compruebalo antes de construir encima.
- Los intentos fallidos son datos negativos: no los repitas, pero tampoco heredes la teoria de por que fallaron.
- Limitate al objetivo y al criterio de terminado que declara el archivo. No busques problemas fuera de ahi.
- Cuando el trabajo cierre, vuelca lo duradero a CONTINUAR.md y borra el HANDOFF.md.

--- inicio del traspaso ---
$texto
"@
                if ($recortado) { $enc = $enc + "`n--- (recortado a $tope caracteres; abre el archivo completo si necesitas mas) ---" }
                else { $enc = $enc + "`n--- fin del traspaso ---" }

                $partes.Add($enc)
                Add-Entrega -Clave $clave
            }
        }
    }

    if ($partes.Count -eq 0) { exit 0 }

    $salida = [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName     = 'SessionStart'
            additionalContext = ($partes -join "`n`n")
        }
    }
    [Console]::Out.Write(($salida | ConvertTo-Json -Depth 5 -Compress))
    exit 0
}
catch {
    if ($env:CLAUDE_HANDOFF_DEBUG) { [Console]::Error.WriteLine("[handoff] " + $_.Exception.Message) }
    exit 0
}
