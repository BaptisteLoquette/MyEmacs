#Requires -Version 5.1
<#
.SYNOPSIS
    Launch Centaur Emacs with comprehensive startup logging.

.DESCRIPTION
    This script launches Emacs in Centaur profile while capturing
    ALL stdout and stderr to timestamped log files for offline analysis.
    It also ensures the *Messages* buffer content is preserved.

    Usage:
        ./launch-centaur-debug.ps1 [-DebugInit] [-NoWait]

    Arguments:
        -DebugInit : Pass --debug-init to Emacs to enable init debugging
        -NoWait    : Don't keep the PowerShell window open after launch

    Outputs:
        1. Console output (stdout+stderr) : centaur-TERM-*.log
        2. Emacs *Messages* buffer       : centaur-messages-*.log
        3. Diagnostic state dump        : centaur-startup-*.log

    Log locations:
        ~/emacs-configs/centaur-emacs/logs/   (Centaur side)
        ~/.emacs.d/logs/                      (Chemacs fallback)

.NOTES
    File: launch-centaur-debug.ps1
    Author: Auto-generated for Centaur Emacs diagnostic setup
    Requires: Emacs 28+, PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [switch]$DebugInit,
    [switch]$NoWait
)

# ── Determine Emacs binary path ──────────────────────────────────────
$EmacsBinary = $null
$SearchPaths = @(
    "C:\Program Files\Emacs\emacs-30.2\bin\emacs.exe",
    "C:\Program Files\Emacs\emacs-29.4\bin\emacs.exe",
    "C:\Program Files\Emacs\emacs-29.3\bin\emacs.exe",
    "C:\Program Files\Emacs\emacs-28.2\bin\emacs.exe",
    "$env:LOCALAPPDATA\Programs\Emacs\bin\emacs.exe",
    "$env:ProgramFiles\Emacs\bin\emacs.exe"
)

foreach ($Path in $SearchPaths) {
    if (Test-Path $Path -PathType Leaf) {
        $EmacsBinary = $Path
        break
    }
}

# Fallback: search in PATH
if (-not $EmacsBinary) {
    $InPath = Get-Command "emacs.exe" -ErrorAction SilentlyContinue
    if ($InPath) {
        $EmacsBinary = $InPath.Source
    }
}

if (-not $EmacsBinary) {
    Write-Error "Cannot find emacs.exe. Searched:`n$($SearchPaths -join "`n")`n`nPlease install Emacs or update the search path in this script."
    exit 1
}

Write-Host "Using Emacs binary: $EmacsBinary" -ForegroundColor Cyan

# ── Set up log directories ──────────────────────────────────────────
$LogDir = "$HOME\emacs-configs\centaur-emacs\logs"
$FallbackLogDir = "$HOME\.emacs.d\logs"

foreach ($Dir in @($LogDir, $FallbackLogDir)) {
    if (-not (Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    }
}

# ── Generate timestamped log file names ──────────────────────────────
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss-fff"
$ConsoleLog  = Join-Path $LogDir "centaur-console-${Timestamp}.log"
$MessagesLog = Join-Path $LogDir "centaur-messages-${Timestamp}.log"
$RawLog      = Join-Path $LogDir "centaur-raw-${Timestamp}.log"

Write-Host "Console log : $ConsoleLog"  -ForegroundColor Green
Write-Host "Messages log: $MessagesLog" -ForegroundColor Green
Write-Host "Raw log     : $RawLog"      -ForegroundColor Green

# ── Build Emacs arguments ────────────────────────────────────────────
$EmacsArgs = @("--with-profile", "centaur")

if ($DebugInit) {
    $EmacsArgs += "--debug-init"
    Write-Host "Debug init ENABLED (--debug-init)" -ForegroundColor Yellow
}

# ── Pre-launch environment dump ──────────────────────────────────────
function Write-PrelaunchInfo {
    param($Path)
    $Header = @"
═══════════════════════════════════════════════════════════════
CENTAUR EMACS LAUNCH - Pre-Flight Report
═══════════════════════════════════════════════════════════════
Timestamp : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")
Emacs     : $EmacsBinary
Args      : $($EmacsArgs -join ' ')
User      : $env:USERNAME
Computer  : $env:COMPUTERNAME
Shell     : $PSVersionTable.PSVersion
PWD       : $(Get-Location)
═══════════════════════════════════════════════════════════════
Environment variables:
  HOME          = $env:HOME
  USERPROFILE   = $env:USERPROFILE
  APPDATA       = $env:APPDATA
  LOCALAPPDATA  = $env:LOCALAPPDATA
  PATH (first 3 entries):
    - $((($env:PATH -split ';')[0..2]) -join "`n    - ")
═══════════════════════════════════════════════════════════════
"@
    $Header | Out-File -FilePath $Path -Encoding UTF8
}

Write-PrelaunchInfo -Path $RawLog

# ── Launch Emacs with capture ────────────────────────────────────────
# We redirect BOTH stdout and stderr to the same file.
# PowerShell's Start-Process handles process creation but Tee-Object
# gives us live console output while also writing to file.

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "LAUNCHING CENTAUR EMACS" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

# Build the full command line string
$EmacsArgsString = ($EmacsArgs | ForEach-Object { '"$_"' }) -join ' '
$FullCommand = "`"$EmacsBinary`" $EmacsArgsString"

# Redirect *all* output to the raw log using cmd.exe call-through.
# This captures everything Emacs prints, including errors.
$Process = Start-Process -FilePath "cmd.exe" `
    -ArgumentList "/c", "`"$EmacsBinary`"", ($EmacsArgs -join ' '), ">`"$RawLog`" 2>&1" `
    -PassThru `
    -WindowStyle Normal

Write-Host "Emacs PID: $($Process.Id)" -ForegroundColor Cyan
Write-Host ""

# ── Wait for Emacs to fully start (gives time to load packages) ───
Write-Host "Waiting for Emacs to initialize..."
Start-Sleep -Seconds 3

# ── Try to capture *Messages* buffer after startup ──────────────────
# We create an elisp script that dumps *Messages* to a file.
$MessagesScript = @"
(with-temp-file "$($MessagesLog -replace '\\', '/')")
  (if (get-buffer "*Messages*")
      (insert (with-current-buffer "*Messages*" (buffer-string)))
    (insert ";;; *Messages* buffer not yet available at capture time.\n"))
  (insert "\n;;; Capture time: " (current-time-string) "\n"))
"@

$MessagesEl = Join-Path $env:TEMP "centaur-capture-messages.el"
$MessagesScript | Out-File -FilePath $MessagesEl -Encoding UTF8 -NoNewline

# Run it via emacsclient (non-interactive) if server is ready
# We use the same profile to ensure correct environment.
$EmacsClientBinary = Join-Path (Split-Path $EmacsBinary) "emacsclient.exe"
if (Test-Path $EmacsClientBinary) {
    # Wait a bit more for the server to start
    Start-Sleep -Seconds 5

    $ClientArgs = @("-s", "centaur", "-e", "(load-file `"$MessagesEl`")")
    $null = Start-Process -FilePath $EmacsClientBinary `
        -ArgumentList $ClientArgs `
        -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
}

# ── Post-launch summary ──────────────────────────────────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "LAUNCH COMPLETE" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "Log files:" -ForegroundColor Cyan
Write-Host "  Console (raw) : $RawLog" -ForegroundColor Green
Write-Host "  Messages      : $MessagesLog" -ForegroundColor Green
Write-Host "  Start time    : $Timestamp" -ForegroundColor Cyan
Write-Host ""
Write-Host "To inspect the log from PowerShell:" -ForegroundColor Yellow
Write-Host "  Get-Content `"$RawLog`" | Select-Object -Last 50" -ForegroundColor Yellow
Write-Host ""
Write-Host "To follow the log live:" -ForegroundColor Yellow
Write-Host "  Get-Content `"$RawLog`" -Wait" -ForegroundColor Yellow
Write-Host ""

if (-not $NoWait) {
    Write-Host "Press any key to close this window..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
