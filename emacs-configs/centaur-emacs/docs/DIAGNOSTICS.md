# Centaur Emacs Diagnostic Logging Setup

## Overview

This setup provides comprehensive startup logging for Centaur Emacs, enabling you (and the Droid/AI agent) to capture and analyze every aspect of the initialization process — even when Emacs fails to start fully.

---

## Architecture

```
User launches Emacs
     |
     v
+----------------------------------+
|  launch-centaur-debug.ps1        |  <-- PowerShell wrapper
|  - Captures stdout + stderr      |
|  - Generates timestamped logs    |
+----------------------------------+
     |
     v
+----------------------------------+
|  Chemacs2 (~/.emacs.d)           |
|  - Reads ~/.emacs-profiles.el    |
|  - Selects "centaur" profile     |
+----------------------------------+
     |
     v
+----------------------------------+
|  Centaur Emacs init.el           |
|  - Loads core modules            |
+----------------------------------+
     |
     v
+----------------------------------+
|  custom.el                       |
|  - Loads init-diagnostics.el     |  <-- hooks into everything
|  - Loads custom-post-data.el     |
|  - Loads custom-post-ai.el       |
+----------------------------------+
     |
     v
+----------------------------------+
|  init-diagnostics.el             |
|  - Logs all (require) calls      |
|  - Catches uncaught errors       |
|  - Dumps system state            |
|  - Writes to logs/               |
+----------------------------------+
```

---

## File Locations

| File | Purpose | Modified |
|------|---------|----------|
| `~/emacs-configs/centaur-emacs/custom.el` | Added diagnostics loading | **Yes** |
| `~/emacs-configs/centaur-emacs/lisp/init-diagnostics.el` | Core logging engine | **New** |
| `~/emacs-configs/centaur-emacs/bin/launch-centaur-debug.ps1` | PowerShell launcher | **New** |
| `~/.emacs-profiles.el` | Profile definitions | No |
| `~/.emacs.d/` (Chemacs2) | Profile switcher | No |

### Log Output Locations

All logs are written to:
```
~/emacs-configs/centaur-emacs/logs/
```

With fallback to:
```
~/.emacs.d/logs/
```

---

## How to Launch

### Method 1: PowerShell Script (Recommended for Debugging)

```powershell
# From any PowerShell prompt:
& "~/emacs-configs/centaur-emacs/bin/launch-centaur-debug.ps1"

# With --debug-init flag (catches ALL errors):
& "~/emacs-configs/centaur-emacs/bin/launch-centaur-debug.ps1" -DebugInit

# Don't keep window open after launch:
& "~/emacs-configs/centaur-emacs/bin/launch-centaur-debug.ps1" -NoWait
```

### Method 2: Direct Launch (Faster, but less logging)

```powershell
& "C:\Program Files\Emacs\emacs-30.2\bin\emacs.exe" --with-profile centaur

# With debug init:
& "C:\Program Files\Emacs\emacs-30.2\bin\emacs.exe" --with-profile centaur --debug-init
```

### Method 3: Droid/AI Agent Remote Capture

The AI can read logs post-hoc:

```powershell
# List all logs
Get-ChildItem ~/emacs-configs/centaur-emacs/logs/ | Select-Object Name, Length, LastWriteTime

# Read the latest console log
Get-ChildItem ~/emacs-configs/centaur-emacs/logs/centaur-raw-*.log | Sort-Object LastWriteTime | Select-Object -Last 1 | Get-Content

# Read the latest diagnostic log
Get-ChildItem ~/emacs-configs/centaur-emacs/logs/centaur-startup-*.log | Sort-Object LastWriteTime | Select-Object -Last 1 | Get-Content
```

---

## What Gets Logged

### 1. Console Output (`centaur-raw-*.log`)
Everything Emacs prints to stdout/stderr, including:
- Package installation messages
- Byte compilation warnings
- Error backtraces
- use-package: messages

Example:
```
Loading c:/Users/Bapti/emacs-configs/centaur-emacs/early-init.el (source)...
Contacting host: melpa.org:443
Package refresh done
Compiling c:/Users/Bapti/.emacs.d/elpa/gptel-0.9.9.4/gptel.el...
Done (Total of 1 file compiled, 2 skipped)
Package 'gptel' installed.
```

### 2. Diagnostic State Dump (`centaur-startup-*.log`)
Structured timing and state data:
- `[T+0000.1234ms]` style timestamps
- Every `(require ...)` call logged
- System variables (user-emacs-directory, load-path, package-archives)
- Active processes list
- Open buffers list
- Loaded features list

Example:
```elisp
[T+0123.4560ms] require: init-base
[T+0456.7890ms] require: init-ui
[T+0789.0120ms] require: init-org
---
user-emacs-directory: c:/Users/Bapti/emacs-configs/centaur-emacs/
load-path entries: 87
package-user-dir: c:/Users/Bapti/.emacs.d/elpa/
package-archives: (("gnu" . "https://elpa.gnu.org/packages/")
                   ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                   ("melpa" . "https://melpa.org/packages/"))
```

### 3. Messages Buffer (`centaur-messages-*.log`)
Contents of the `*Messages*` buffer captured after startup.

### 4. Error Capture
Any uncaught errors are logged with full backtraces:
```elisp
!!! UNCAUGHT ERROR !!!
  Signal: invalid-read-syntax
  Data: (")" 89 50)
  Backtrace:
    - load-with-code-conversion
    - load
    - ...
```

---

## How the AI Can Help

### Scenario 1: "Emacs crashes on startup"

User runs:
```powershell
./launch-centaur-debug.ps1 -DebugInit
```

User shares: "It shows an error about init-diagnostics.el"

AI response: "Let me check the latest log"
```
# PowerShell command the AI can run:
Get-ChildItem ~/emacs-configs/centaur-emacs/logs/centaur-raw-*.log |
    Sort-Object LastWriteTime |
    Select-Object -Last 1 |
    Get-Content -Tail 100
```

AI reads the log, identifies the error, and fixes it.

### Scenario 2: "Package installation fails"

From the log:
```
Error (use-package): Failed to install gptel: Package `gptel' is unavailable
```

AI checks package archives configuration from the state dump and suggests fixes.

### Scenario 3: "Everything loads but Org mode is slow"

AI reads the timing data:
```
[T+0123.4560ms] require: init-org
[T+5678.9010ms] ...  <-- 4.5 seconds for org!
```

AI suggests optimizations.

---

## Troubleshooting the Logging Itself

### "Log files are empty"
- Check that `~/emacs-configs/centaur-emacs/logs/` directory exists and is writable
- Check Windows permissions: `icacls "$HOME\emacs-configs\centaur-emacs\logs"`

### "init-diagnostics.el errors prevent Emacs from starting"
- The file is loaded with `(condition-case)` in `custom.el` — it should never prevent startup
- If it does, comment out the `(load "lisp/init-diagnostics.el")` line in `custom.el`

### "Messages buffer log is empty"
- The `*Messages*` buffer capture runs 5 seconds after launch
- If Emacs crashes before then, only the raw log is available
- Increase the delay in `launch-centaur-debug.ps1` if needed

---

## Maintenance

### Cleaning Old Logs
```powershell
# Delete logs older than 7 days
Get-ChildItem ~/emacs-configs/centaur-emacs/logs/*.log |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
    Remove-Item -Force
```

### Disabling Diagnostics for "Production" Use
Simply comment out this line in `custom.el`:
```elisp
;; (load (expand-file-name "lisp/init-diagnostics.el" user-emacs-directory) nil t)
```

### Re-enabling Diagnostics
Uncomment the same line.

---

## Advanced: Manual Emacs Batch Debugging

For the AI agent to test without interactive display:

```powershell
$testScript = @'
(message "=== Manual Batch Test ===")
(setq user-emacs-directory "c:/Users/Bapti/emacs-configs/centaur-emacs/")
(load-file "c:/Users/Bapti/emacs-configs/centaur-emacs/early-init.el")
(condition-case err
    (load-file "c:/Users/Bapti/emacs-configs/centaur-emacs/init.el")
  (error (message "Init error: %s" (error-message-string err))))
(message "=== Test Complete ===")
'@
$testScript | Set-Content -Path "$env:TEMP\manual-test.el"

& "C:\Program Files\Emacs\emacs-30.2\bin\emacs.exe" -q --batch -l "$env:TEMP\manual-test.el" 2>&1 | Tee-Object -FilePath "$HOME\emacs-configs\centaur-emacs\logs\manual-test.log"
```

---

## Summary

With this setup:
1. **Every startup is logged** with timestamps and full state
2. **Errors are captured** with backtraces, even if Emacs crashes
3. **The AI can read logs** after the fact to diagnose issues
4. **No manual copy/paste** of error messages is needed

Run `./launch-centaur-debug.ps1` and share the log file path when reporting issues.
