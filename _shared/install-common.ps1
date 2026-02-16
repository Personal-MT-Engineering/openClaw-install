# ============================================================================
# OpenClaw - PowerShell Bootstrap Installer
# Detects WSL2 or Git Bash and delegates to the bash install.sh
# ============================================================================

param(
    [string]$EnvFile = "",
    [switch]$Docker,
    [switch]$Local
)

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "=== $Text ===" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Log {
    param([string]$Text)
    Write-Host "[OpenClaw] $Text" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Text)
    Write-Host "[OpenClaw] $Text" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Text)
    Write-Host "[OpenClaw] $Text" -ForegroundColor Red
}

# Get the directory where this script lives
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallSh = Join-Path $ScriptDir "install.sh"

if (-not (Test-Path $InstallSh)) {
    Write-Err "install.sh not found in $ScriptDir"
    exit 1
}

Write-Header "OpenClaw - Windows Installer"

# Build arguments for the bash script
$BashArgs = @()
if ($EnvFile) {
    $BashArgs += "--env-file"
    $BashArgs += $EnvFile
}
if ($Docker) {
    $BashArgs += "--docker"
}
if ($Local) {
    $BashArgs += "--local"
}

$ArgsString = $BashArgs -join " "

# ---- Try WSL2 first ----
function Test-WSL {
    try {
        $result = wsl --status 2>&1
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

function Install-WSL {
    Write-Header "Installing WSL2"
    Write-Log "WSL2 is required. Installing..."

    try {
        wsl --install -d Ubuntu --no-launch
        Write-Log "WSL2 installed. A restart may be required."
        Write-Warn "After restart, run this script again."
        Read-Host "Press Enter to restart, or Ctrl+C to cancel"
        Restart-Computer -Force
    } catch {
        Write-Err "Failed to install WSL2 automatically."
        Write-Err "Please install WSL2 manually: https://docs.microsoft.com/en-us/windows/wsl/install"
        exit 1
    }
}

# ---- Try Git Bash ----
function Find-GitBash {
    $paths = @(
        "C:\Program Files\Git\bin\bash.exe",
        "C:\Program Files (x86)\Git\bin\bash.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }

    # Check PATH
    $gitBash = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($gitBash) { return $gitBash.Source }

    return $null
}

# ---- Run via WSL2 ----
if (Test-WSL) {
    Write-Log "Using WSL2 to run installer..."

    # Convert Windows path to WSL path
    $WslScriptDir = wsl wslpath -a "$ScriptDir" 2>&1
    if ($LASTEXITCODE -ne 0) {
        $WslScriptDir = $ScriptDir -replace '\\', '/' -replace '^([A-Z]):', '/mnt/$1'.ToLower()
    }

    $WslInstallSh = "$WslScriptDir/install.sh"
    Write-Log "Running: wsl bash $WslInstallSh $ArgsString"

    wsl bash -c "chmod +x '$WslInstallSh' && '$WslInstallSh' $ArgsString"
    exit $LASTEXITCODE
}

# ---- Run via Git Bash ----
$GitBash = Find-GitBash
if ($GitBash) {
    Write-Log "Using Git Bash to run installer..."
    Write-Log "Running: $GitBash $InstallSh $ArgsString"

    & $GitBash --login -c "cd '$(($ScriptDir -replace '\\', '/'))' && chmod +x install.sh && ./install.sh $ArgsString"
    exit $LASTEXITCODE
}

# ---- Neither available - offer to install WSL ----
Write-Warn "Neither WSL2 nor Git Bash found."
$choice = Read-Host "Would you like to install WSL2? (Y/n)"
if ($choice -eq "" -or $choice -match "^[Yy]") {
    Install-WSL
} else {
    Write-Err "Please install WSL2 or Git Bash, then run this script again."
    Write-Log "WSL2: https://docs.microsoft.com/en-us/windows/wsl/install"
    Write-Log "Git:  https://git-scm.com/download/win"
    exit 1
}
