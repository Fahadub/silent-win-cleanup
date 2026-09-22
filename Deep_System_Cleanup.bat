@echo off
chcp 65001 >nul
title Deep System Cleanup and Windows Update Maintenance (DISM & SoftwareDistribution)
color 0A

echo ==============================================================================
echo              Deep Cleanup Tool for Cumulative Windows Leftovers
echo ==============================================================================
echo.

:: Check Admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] NOTE: This deep cleanup requires Administrator privileges.
    echo     Please right-click this file and select:
    echo     "Run as administrator".
    echo ==============================================================================
    pause
    exit /b 1
)

echo [1/5] جاري تفريغ كاش تنزيلات تحديثات ويندوز (SoftwareDistribution\Download)...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
for /d %%p in ("C:\Windows\SoftwareDistribution\Download\*") do rmdir /s /q "%%p" >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
echo       - اكتمل تنظيف كاش التحديثات بنجاح.
echo.

echo [2/5] جاري تنظيف مخزن مكونات وتحديثات ويندوز القديمة (DISM Component Cleanup)...
echo       (قد يستغرق هذا الأمر بضع دقائق لتنظيف نسخ التحديثات القديمة المستبدلة)
dism.exe /online /cleanup-image /startcomponentcleanup /quiet
echo       - اكتمل تنظيف مخزن مكونات ويندوز بنجاح.
echo.

echo [3/5] جاري تنظيف كاش معالج الرسوميات (DirectX Shader Cache)...
if exist "%LOCALAPPDATA%\D3DSCache" (
    del /f /s /q "%LOCALAPPDATA%\D3DSCache\*" >nul 2>&1
    for /d %%p in ("%LOCALAPPDATA%\D3DSCache\*") do rmdir /s /q "%%p" >nul 2>&1
)
echo       - اكتمل تنظيف كاش الرسوميات بنجاح.
echo.

echo [4/5] جاري مسح وتحديث كاش أسماء النطاقات (DNS Flush)...
ipconfig /flushdns >nul 2>&1
echo       - اكتمل تحديث كاش الـ DNS بنجاح.
echo.

echo [5/5] جاري تفريغ الذاكرة الاحتياطية (RAMMap Standby List) وتشغيل التنظيف الفوري...
if exist "%USERPROFILE%\RAMMap.exe" (
    "%USERPROFILE%\RAMMap.exe" -Es
) else if exist "%USERPROFILE%\RAMMap\RAMMap.exe" (
    "%USERPROFILE%\RAMMap\RAMMap.exe" -Es
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\Scripts\cleanup_automation.ps1"
echo       - اكتمل التنظيف الفوري وتفريغ الذاكرة بنجاح.
echo.

echo ==============================================================================
echo [OK] تمت عملية الصيانة والتنظيف العميق للنظام بنجاح تام!
echo ==============================================================================
pause
