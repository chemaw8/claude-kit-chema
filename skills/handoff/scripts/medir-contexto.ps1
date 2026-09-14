# medir-contexto.ps1 - Kit Chema / skill handoff
# Uso manual: cuanto contexto lleva consumido la sesion.
#   powershell -NoProfile -File "$env:USERPROFILE\.claude\skills\handoff\scripts\medir-contexto.ps1"
# Sin -TranscriptPath toma el transcript principal mas reciente (ignora subagentes).

param(
    [string]$TranscriptPath = '',
    [switch]$Json
)

[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
. (Join-Path $PSScriptRoot 'lib-contexto.ps1')

$uso = Get-UsoContexto -TranscriptPath $TranscriptPath

if ($Json) {
    ($uso | ConvertTo-Json -Compress)
    exit 0
}

if (-not $uso.ok) {
    Write-Output "No se pudo medir: no encontre un transcript con datos de uso."
    Write-Output "Buscado en: $($uso.transcript)"
    exit 1
}

$semaforo = 'verde: holgado'
if ($uso.pct -ge 60) { $semaforo = 'amarillo: buen momento para el traspaso' }
if ($uso.pct -ge 85) { $semaforo = 'ROJO: escribe el traspaso y reinicia' }

$kTok = [math]::Round($uso.tokens / 1000.0, 1)
$kPre = [math]::Round($uso.presupuesto / 1000.0, 0)
$kVen = [math]::Round($uso.ventana / 1000.0, 0)

Write-Output ("Contexto vivo : {0}K tokens" -f $kTok)
Write-Output ("Presupuesto   : {0}K utiles (ventana del modelo: {1}K)" -f $kPre, $kVen)
Write-Output ("Utilizacion   : {0}%  [{1}]" -f $uso.pct, $semaforo)
Write-Output ("Transcript    : {0}" -f $uso.transcript)
