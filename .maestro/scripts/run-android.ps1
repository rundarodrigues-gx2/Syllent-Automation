# Executa a suíte Maestro em um dispositivo/emulador Android.
# Pré-requisito: um emulador ou device Android conectado (adb devices) e Maestro no PATH.
param(
    [string]$IncludeTags = "",
    [string]$ExcludeTags = "wip,ios",
    [string]$Flow = ".maestro",           # diretório com config.yaml (flows/**)
    [switch]$KeepArtifacts                 # por padrão RESETA a pasta de artefatos a cada run
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot | Split-Path -Parent
$env:MAESTRO_CLI_NO_ANALYTICS = "1"

# Pasta única de artefatos (logs + screenshots + relatório), resetada a cada execução.
$artifacts = Join-Path $repoRoot "artifacts"
if (-not $KeepArtifacts -and (Test-Path $artifacts)) {
    Remove-Item $artifacts -Recurse -Force
    Write-Host "Artefatos anteriores removidos: $artifacts" -ForegroundColor DarkGray
}
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

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
# Artefatos numa pasta fixa, sem subpastas/timestamps (flatten) + relatório HTML
$cliArgs += @(
    "--debug-output", $artifacts,
    "--flatten-debug-output",
    "--test-output-dir", $artifacts,        # screenshots (takeScreenshot) também vão para artifacts/
    "--format", "HTML",
    "--output", (Join-Path $artifacts "report.html")
)
$cliArgs += "$repoRoot/$Flow"

Write-Host "Executando: maestro $($cliArgs -join ' ')" -ForegroundColor Cyan
& maestro @cliArgs
$code = $LASTEXITCODE
Write-Host "Artefatos desta execução: $artifacts (report.html, maestro.log, screenshots)" -ForegroundColor Cyan
exit $code
