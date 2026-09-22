@echo off
chcp 65001 >nul
echo Checking administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ================================================================
    echo [!] NOTE: Please right-click this file and select:
    echo     "Run as administrator"
    echo ================================================================
    pause
    exit /b 1
)

echo Registering AutoSystemCleanup with HIGHEST privileges...
schtasks /create /tn "AutoSystemCleanup" /tr "wscript.exe \"%USERPROFILE%\Scripts\run_hidden.vbs\"" /sc MINUTE /mo 30 /rl HIGHEST /f

if %errorlevel% equ 0 (
    echo.
    echo [OK] Task successfully updated with elevated privileges!
    echo RAMMap and Standby List flush will now run with full privileges every 30 minutes.
) else (
    echo.
    echo [!] An error occurred while upgrading the task.
)
pause
