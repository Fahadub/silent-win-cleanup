@echo off
chcp 65001 >nul
echo Stopping and removing automatic cleanup task...
schtasks /delete /tn "AutoSystemCleanup" /f >nul 2>&1
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\AutoSystemCleanup.vbs" (
    del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\AutoSystemCleanup.vbs"
)
echo.
echo [OK] Scheduled task and startup entry successfully removed.
pause
