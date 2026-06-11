# Executa a suíte Maestro em um simulador iOS.
# Pré-requisito: macOS com Xcode e um simulador iOS em execução.
# (Maestro em iOS só roda em macOS; este script é referência para a pipeline.)
param(
    [string]$IncludeTags = "",
    [string]$ExcludeTags = "wip",
    [string]$Flow = ".maestro"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot | Split-Path -Parent
$env:MAESTRO_CLI_NO_ANALYTICS = "1"

$envArgs = @()
Get-Content "$repoRoot/.maestro/env/ios.env" |
    Where-Object { $_ -match '=' -and $_ -notmatch '^\s*#' } |
    ForEach-Object { $envArgs += '--env'; $envArgs += $_.Trim() }

$cliArgs = @("test") + $envArgs
if ($IncludeTags -ne "") { $cliArgs += @("--include-tags", $IncludeTags) }
if ($ExcludeTags -ne "") { $cliArgs += @("--exclude-tags", $ExcludeTags) }
$cliArgs += "$repoRoot/$Flow"

Write-Host "Executando: maestro $($cliArgs -join ' ')" -ForegroundColor Cyan
& maestro @cliArgs
