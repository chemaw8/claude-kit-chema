$ErrorActionPreference = "SilentlyContinue"

$wavPath = Join-Path $PSScriptRoot "..\sounds\claude-done.wav"
$wavPath = (Resolve-Path $wavPath).Path

$player = New-Object System.Media.SoundPlayer $wavPath
$player.PlaySync()
