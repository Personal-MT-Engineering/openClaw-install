# OpenClaw - Employee Onboarding Automation
# PowerShell installer - delegates to install.sh via WSL2 or Git Bash

param(
    [string]$EnvFile = "",
    [switch]$Docker,
    [switch]$Local
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SharedPS1 = Join-Path (Join-Path $ScriptDir ".." ) "_shared\install-common.ps1"

if (Test-Path $SharedPS1) {
    & $SharedPS1 -EnvFile $EnvFile -Docker:$Docker -Local:$Local
} else {
    Write-Host "[OpenClaw] Shared installer not found. Please run from the repository root." -ForegroundColor Red
    exit 1
}
