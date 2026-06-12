# Executa a suíte Maestro em um simulador iOS.
# Pré-requisito: macOS com Xcode e um simulador iOS em execução.
# (Maestro em iOS só roda em macOS; este script é referência para a pipeline.)
param(
    [string]$IncludeTags = "",
    [string]$ExcludeTags = "wip",
    [string]$Flow = ".maestro",
    [switch]$KeepArtifacts                 # por padrão RESETA a pasta de artefatos a cada run
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot | Split-Path -Parent
$env:MAESTRO_CLI_NO_ANALYTICS = "1"

# Pasta única de artefatos, resetada a cada execução.
$artifacts = Join-Path $repoRoot "artifacts"
if (-not $KeepArtifacts -and (Test-Path $artifacts)) {
    Remove-Item $artifacts -Recurse -Force
    Write-Host "Artefatos anteriores removidos: $artifacts" -ForegroundColor DarkGray
}
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

$envArgs = @()
foreach ($envFile in @("$repoRoot/.maestro/env/ios.env", "$repoRoot/.maestro/env/ios.local.env")) {
    if (Test-Path $envFile) {
        Get-Content $envFile |
            Where-Object { $_ -match '=' -and $_ -notmatch '^\s*#' } |
            ForEach-Object { $envArgs += '--env'; $envArgs += $_.Trim() }
    }
}

$cliArgs = @("test") + $envArgs
if ($IncludeTags -ne "") { $cliArgs += @("--include-tags", $IncludeTags) }
if ($ExcludeTags -ne "") { $cliArgs += @("--exclude-tags", $ExcludeTags) }
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
