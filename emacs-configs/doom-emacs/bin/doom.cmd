@echo off
REM Doom CLI wrapper for Windows CMD
REM Delegates to the PowerShell launcher (doom.ps1)

setlocal enabledelayedexpansion

set "DOOMDIR=%~dp0"
set "DOOMPS1=%DOOMDIR%doom.ps1"

if not exist "%DOOMPS1%" (
    echo Error: doom.ps1 not found at %DOOMPS1%
    exit /b 1
)

REM Pass all arguments through to PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "%DOOMPS1%" %*

endlocal
