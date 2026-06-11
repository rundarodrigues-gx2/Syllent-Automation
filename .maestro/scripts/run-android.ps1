# Executa a suíte Maestro em um dispositivo/emulador Android.
# Pré-requisito: um emulador ou device Android conectado (adb devices) e Maestro no PATH.
param(
    [string]$IncludeTags = "",
    [string]$ExcludeTags = "wip,ios",
    [string]$Flow = ".maestro"            # diretório com config.yaml (flows/**)
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot | Split-Path -Parent
$env:MAESTRO_CLI_NO_ANALYTICS = "1"

# Converte o(s) .env em pares --env KEY=VALUE (esta versão do Maestro não tem --env-file).
# Carrega android.env e, se existir, android.local.env por cima (local sobrescreve — credenciais reais).
$envArgs = @()
foreach ($envFile in @("$repoRoot/.maestro/env/android.env", "$repoRoot/.maestro/env/android.local.env")) {
    if (Test-Path $envFile) {
        Get-Content $envFile |
            Where-Object { $_ -match '=' -and $_ -notmatch '^\s*#' } |
            ForEach-Object { $envArgs += '--env'; $envArgs += $_.Trim() }
    }
}

$cliArgs = @("test") + $envArgs
if ($IncludeTags -ne "") { $cliArgs += @("--include-tags", $IncludeTags) }
if ($ExcludeTags -ne "") { $cliArgs += @("--exclude-tags", $ExcludeTags) }
$cliArgs += "$repoRoot/$Flow"

Write-Host "Executando: maestro $($cliArgs -join ' ')" -ForegroundColor Cyan
& maestro @cliArgs
