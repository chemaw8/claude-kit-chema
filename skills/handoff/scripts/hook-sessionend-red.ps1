# hook-sessionend-red.ps1 — Kit Chema / skill handoff
# Hook SessionEnd (matcher: clear). Red de seguridad: si la sesion se limpia
# SIN traspaso reciente, deja un puntero al transcript para poder recuperarla.
# No copia el transcript: /clear no lo borra y la conversacion se recupera con
# /resume. Debe ser instantaneo (presupuesto por defecto: 1.5 s).

$ErrorActionPreference = 'Stop'
try {
    $raw = [Console]::In.ReadToEnd()
    if (-not $raw) { exit 0 }
    $ev = $raw | ConvertFrom-Json

    # Solo interesa el caso /clear: es el unico en que el usuario cree que
    # dejo todo listo. Al salir normalmente no hace falta ensuciar la bandeja.
    if ([string]$ev.reason -ne 'clear') { exit 0 }

    $cwd = [string]$ev.cwd
    if (-not $cwd) { $cwd = (Get-Location).Path }

    $frescos = @()
    $enCwd = Join-Path $cwd 'HANDOFF.md'
    if (Test-Path -LiteralPath $enCwd) { $frescos += (Get-Item -LiteralPath $enCwd) }
    $bandeja = Join-Path $env:USERPROFILE '.claude\handoffs'
    if (Test-Path -LiteralPath $bandeja) {
        $frescos += @(Get-ChildItem -LiteralPath $bandeja -Filter *.md -File -ErrorAction SilentlyContinue)
    }
    $hayTraspaso = $false
    foreach ($f in $frescos) {
        if (((Get-Date) - $f.LastWriteTime).TotalMinutes -le 30) { $hayTraspaso = $true }
    }
    if ($hayTraspaso) { exit 0 }

    if (-not (Test-Path -LiteralPath $bandeja)) { New-Item -ItemType Directory -Path $bandeja -Force | Out-Null }
    $sello = Get-Date -Format 'yyyy-MM-dd HH:mm'
    $nota = @"
# Aviso: se limpio la sesion sin traspaso

- Fecha: $sello
- Carpeta de trabajo: $cwd
- Motivo del cierre: $($ev.reason)
- Sesion: $($ev.session_id)
- Transcript recuperable: $($ev.transcript_path)

La conversacion anterior NO se borro del disco: se recupera con /resume, o desde
el menu de rewind en el mismo proceso de Claude Code.

Este archivo lo escribe el hook SessionEnd de la skill handoff. Borralo cuando ya
no haga falta.
"@
    Set-Content -LiteralPath (Join-Path $bandeja '_ultimo-clear-sin-traspaso.txt') -Value $nota -Encoding utf8
    exit 0
}
catch {
    exit 0
}
