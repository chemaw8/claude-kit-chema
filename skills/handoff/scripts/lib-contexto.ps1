# lib-contexto.ps1 - Kit Chema / skill handoff
# Funciones compartidas por los tres hooks. No ejecuta nada por si mismo.
# Sin acentos a proposito: PowerShell 5.1 los rompe si el archivo pierde el BOM.

# --- Ventana real del modelo -------------------------------------------------
function Get-VentanaContexto {
    if ($env:CLAUDE_HANDOFF_VENTANA) {
        $v = 0
        if ([int]::TryParse($env:CLAUDE_HANDOFF_VENTANA, [ref]$v)) { if ($v -gt 0) { return $v } }
    }
    $modelo = ''
    $cfg = Join-Path $env:USERPROFILE '.claude\settings.json'
    if (Test-Path -LiteralPath $cfg) {
        try {
            $j = Get-Content -LiteralPath $cfg -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($j.model) { $modelo = [string]$j.model }
        } catch { }
    }
    if ($modelo -match '\[1m\]') { return 1000000 }
    return 200000
}

# --- Presupuesto util --------------------------------------------------------
# La ventana NO es el umbral. Chroma ("context rot", 2025) midio degradacion muy
# por debajo del limite en 18 modelos frontera, y Liu et al. (TACL 2024) mostro
# que lo de en medio del contexto se pierde. HumanLayer recomienda operar entre
# 40% y 60% de utilizacion. Con ventana de 1M, avisar al 70% seria avisar a los
# 700K: inservible. Por eso el presupuesto util se topa en 250K.
function Get-PresupuestoUtil {
    if ($env:CLAUDE_HANDOFF_PRESUPUESTO) {
        $v = 0
        if ([int]::TryParse($env:CLAUDE_HANDOFF_PRESUPUESTO, [ref]$v)) { if ($v -gt 0) { return $v } }
    }
    $ventana = Get-VentanaContexto
    if ($ventana -gt 250000) { return 250000 }
    return $ventana
}

# --- Medicion del contexto vivo ---------------------------------------------
# Verificado a mano el 2026-08-18 contra un transcript real: cada respuesta del
# modelo registra "usage" y el contexto vivo es
#   input_tokens + cache_creation_input_tokens + cache_read_input_tokens
# (lo cacheado SI ocupa ventana). Se lee la ultima linea con "usage".
function Get-UsoContexto {
    param([string]$TranscriptPath = '')

    if (-not $TranscriptPath -or -not (Test-Path -LiteralPath $TranscriptPath)) {
        # Sin ruta explicita, tomar el transcript mas reciente del hilo PRINCIPAL.
        # Los de subagentes viven en .\<sesion>\subagents\... y falsean la medida.
        $dir = Join-Path $env:USERPROFILE '.claude\projects'
        if (Test-Path -LiteralPath $dir) {
            $f = Get-ChildItem -LiteralPath $dir -Filter *.jsonl -File -Recurse -ErrorAction SilentlyContinue |
                 Where-Object { $_.FullName -notlike '*subagents*' } |
                 Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($f) { $TranscriptPath = $f.FullName }
        }
    }

    $res = [ordered]@{
        tokens      = 0
        ventana     = Get-VentanaContexto
        presupuesto = Get-PresupuestoUtil
        pct         = 0
        transcript  = $TranscriptPath
        ok          = $false
    }
    if (-not $TranscriptPath -or -not (Test-Path -LiteralPath $TranscriptPath)) { return $res }

    $lineas = @(Get-Content -LiteralPath $TranscriptPath -Tail 200 -ErrorAction SilentlyContinue)
    for ($i = $lineas.Count - 1; $i -ge 0; $i--) {
        $l = $lineas[$i]
        if ($l -notmatch '"usage"') { continue }
        $mIn    = [regex]::Matches($l, '"input_tokens":\s*(\d+)')
        $mCread = [regex]::Matches($l, '"cache_read_input_tokens":\s*(\d+)')
        $mCcrea = [regex]::Matches($l, '"cache_creation_input_tokens":\s*(\d+)')
        if ($mIn.Count -eq 0 -and $mCread.Count -eq 0) { continue }
        $t = 0
        if ($mIn.Count    -gt 0) { $t += [int]$mIn[$mIn.Count - 1].Groups[1].Value }
        if ($mCread.Count -gt 0) { $t += [int]$mCread[$mCread.Count - 1].Groups[1].Value }
        if ($mCcrea.Count -gt 0) { $t += [int]$mCcrea[$mCcrea.Count - 1].Groups[1].Value }
        if ($t -le 0) { continue }
        $res.tokens = $t
        $res.pct    = [math]::Round(100.0 * $t / $res.presupuesto, 1)
        $res.ok     = $true
        break
    }
    return $res
}

# --- Estado operativo en el home (contadores, nunca contenido) ---------------
function Get-DirEstado {
    $d = Join-Path $env:USERPROFILE '.claude\handoffs'
    if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
    return $d
}

function Remove-EstadoViejo {
    param([int]$Dias = 7)
    try {
        $d = Get-DirEstado
        Get-ChildItem -LiteralPath $d -Filter '*.txt' -File -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$Dias) } |
            Remove-Item -Force -ErrorAction SilentlyContinue
    } catch { }
}

# --- Localizar el traspaso vigente ------------------------------------------
# El traspaso vive en la carpeta del trabajo. Se busca en el cwd y hasta 3
# carpetas arriba; nunca se acepta el propio home (seria un traspaso huerfano).
function Find-Traspaso {
    param(
        [string]$Cwd = '',
        [string]$Nombre = 'HANDOFF.md'
    )
    if ($env:CLAUDE_HANDOFF_ARCHIVO) { $Nombre = $env:CLAUDE_HANDOFF_ARCHIVO }
    if (-not $Cwd) { $Cwd = (Get-Location).Path }
    if (-not (Test-Path -LiteralPath $Cwd)) { return $null }

    $carpetaHome = [System.IO.Path]::GetFullPath($env:USERPROFILE)
    $act = [System.IO.Path]::GetFullPath($Cwd)
    for ($n = 0; $n -lt 4; $n++) {
        if (-not $act) { break }
        if ($act.TrimEnd('\') -ieq $carpetaHome.TrimEnd('\')) { break }
        $p = Join-Path $act $Nombre
        if (Test-Path -LiteralPath $p) { return (Get-Item -LiteralPath $p) }
        $padre = Split-Path -Parent $act
        if (-not $padre -or $padre -eq $act) { break }
        $act = $padre
    }
    return $null
}

# --- Contador de entregas (evita re-inyectar el mismo traspaso sin fin) ------
function Get-Entregas {
    param([string]$Clave)
    $f = Join-Path (Get-DirEstado) 'entregas.json'
    if (-not (Test-Path -LiteralPath $f)) { return 0 }
    try {
        $j = Get-Content -LiteralPath $f -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($j.PSObject.Properties.Name -contains $Clave) { return [int]$j.$Clave }
    } catch { }
    return 0
}

function Add-Entrega {
    param([string]$Clave)
    $f = Join-Path (Get-DirEstado) 'entregas.json'
    $mapa = @{}
    if (Test-Path -LiteralPath $f) {
        try {
            $j = Get-Content -LiteralPath $f -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($p in $j.PSObject.Properties) { $mapa[$p.Name] = [int]$p.Value }
        } catch { }
    }
    if ($mapa.ContainsKey($Clave)) { $mapa[$Clave] = $mapa[$Clave] + 1 } else { $mapa[$Clave] = 1 }
    if ($mapa.Count -gt 60) {
        $sobran = $mapa.Keys | Select-Object -First ($mapa.Count - 40)
        foreach ($k in @($sobran)) { $mapa.Remove($k) }
    }
    try {
        ($mapa | ConvertTo-Json -Depth 3) | Set-Content -LiteralPath $f -Encoding utf8
    } catch { }
}
