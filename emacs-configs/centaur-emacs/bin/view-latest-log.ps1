#Requires -Version 5.1
<#
.SYNOPSIS
    Display the most recent Centaur Emacs startup log.

.DESCRIPTION
    Usage:
        ./view-latest-log.ps1 [-Tail N] [-Raw]

    Arguments:
        -Tail N : Show last N lines (default: 50)
        -Raw    : Show raw log without filtering

.EXAMPLE
    ./view-latest-log.ps1 -Tail 100
    ./view-latest-log.ps1 -Raw
#>

[CmdletBinding()]
param(
    [int]$Tail = 50,
    [switch]$Raw
)

$LogDir = "$HOME\emacs-configs\centaur-emacs\logs"
$FallbackDir = "$HOME\.emacs.d\logs"

# Prefer main log dir
$Logs = @()
if (Test-Path $LogDir) {
    $Logs += Get-ChildItem "$LogDir\centaur-*.log" -ErrorAction SilentlyContinue
}
if (Test-Path $FallbackDir) {
    $Logs += Get-ChildItem "$FallbackDir\centaur-*.log" -ErrorAction SilentlyContinue
}

if ($Logs.Count -eq 0) {
    Write-Host "No log files found. Run centaur first with:" -ForegroundColor Yellow
    Write-Host "  ./launch-centaur-debug.ps1" -ForegroundColor Cyan
    exit
}

$Latest = $Logs | Sort-Object LastWriteTime | Select-Object -Last 1
Write-Host "Log file: $($Latest.FullName)" -ForegroundColor Cyan
Write-Host "Size: $($Latest.Length) bytes | Modified: $($Latest.LastWriteTime)" -ForegroundColor Gray
Write-Host ""

$content = Get-Content $Latest.FullName -Tail ($Tail * 5) -Encoding UTF8

if (-not $Raw) {
    $content = $content | Where-Object {
        # Filter out common noise
        ($_ -notmatch 'Scraping.*for loaddefs') -and
        ($_ -notmatch 'Compiling.*autoloads') -and
        ($_ -notmatch 'Checking.*elpa') -and
        ($_ -notmatch 'Package.*installed') -and
        ($_ -notmatch 'Extracting')
    }
}

$content | Select-Object -Last $Tail | ForEach-Object {
    if ($_ -match 'ERROR|Error|error:|!!!') {
        Write-Host $_ -ForegroundColor Red
    } elseif ($_ -match 'Warning|warning:') {
        Write-Host $_ -ForegroundColor Yellow
    } elseif ($_ -match 'SYNTAX OK|PASS') {
        Write-Host $_ -ForegroundColor Green
    } elseif ($_ -match 'T\+') {
        Write-Host $_ -ForegroundColor Cyan
    } elseif ($_ -match 'SECTION') {
        Write-Host $_ -ForegroundColor Magenta
    } else {
        Write-Host $_ -ForegroundColor White
    }
}

Write-Host ""
Write-Host "To follow log live: Get-Content `"$($Latest.FullName)`" -Wait" -ForegroundColor Gray
