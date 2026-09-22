# 🧹 Silent Win Cleanup

Automatic background cleanup for Windows 10/11 that runs every 30 minutes — completely silent, no windows, no popups, no slowdown.

## What it cleans (every 30 minutes):
- ✅ User Temp folder (`%TEMP%`)
- ✅ Windows Temp folder
- ✅ Crash Dumps
- ✅ DirectX Shader Cache
- ✅ Windows Update Download Cache
- ✅ DNS Cache (flushed for faster browsing)
- ✅ RAMMap Standby List flush (optional, if RAMMap.exe is installed)

## What it does NOT touch:
- ❌ Prefetch folder (preserved for fast app startup)
- ❌ Active/locked files (automatically skipped)
- ❌ Recycle Bin (permanent delete, no overhead)
- ❌ Any user documents or projects

## Weekly Report
Every 7 days, a summary report automatically opens in Notepad showing:
- Current disk free space
- Cleanup status
- Recent operation logs

## Quick Install

1. Clone or download this repo
2. Copy `cleanup_automation.ps1` and `run_hidden.vbs` to `C:\Users\[YourName]\Scripts\`
3. Run `Install_Elevated_Task.bat` as Administrator
4. Done! Cleanup starts immediately and repeats every 30 minutes

## Manual Install (if you prefer)

```batch
schtasks /create /tn "AutoSystemCleanup" /tr "wscript.exe C:\Users\[YourName]\Scripts\run_hidden.vbs" /sc minute /mo 30 /f
```

## Uninstall

Run `Uninstall_Task.bat` as Administrator, then delete the `Scripts` folder.

## Files

| File | Purpose |
|---|---|
| `cleanup_automation.ps1` | Main PowerShell cleanup script |
| `run_hidden.vbs` | Launches PowerShell silently (no window) |
| `AutoSystemCleanup.xml` | Task Scheduler XML (for import) |
| `Install_Elevated_Task.bat` | One-click installer (Admin required) |
| `Uninstall_Task.bat` | One-click uninstaller |
| `Deep_System_Cleanup.bat` | Manual deep cleanup (run when needed) |

## Requirements
- Windows 10 or 11
- PowerShell (built-in)
- Admin rights for installation only

## License
MIT — do whatever you want, no warranty.

---
Made with ❤️ by [FahadPrimeX](https://huggingface.co/FahadPrimeX)
