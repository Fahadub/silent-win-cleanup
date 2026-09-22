# ==============================================================================
# Auto Fast Cleanup Script (Windows 10 / 11)
# 100% Background & Silent Execution.
# Deletes permanently (no Recycle Bin overhead, no slow counting).
# Safely skips any locked or in-use files.
# Prefetch is preserved intentionally for fast program startup.
# Weekly summary report automatically opens once every 7 days.
# ==============================================================================

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile = Join-Path $scriptDir "cleanup.log"
$reportTracker = Join-Path $scriptDir "last_weekly_report.txt"
$weeklyReportFile = Join-Path $scriptDir "weekly_cleanup_report.txt"
$maxLogSizeBytes = 256KB

function Write-FastLog {
    param ([string]$Msg)
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -LiteralPath $logFile -Value "[$ts] $Msg" -Encoding UTF8 -Force -ErrorAction SilentlyContinue
}

# Fast cleanup function: direct removal without slow file enumeration loops
function Invoke-FastFolderClean {
    param ([string]$TargetFolder)

    if (-not (Test-Path -LiteralPath $TargetFolder)) {
        return
    }

    $items = Get-ChildItem -LiteralPath $TargetFolder -Force -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        # Safety: never delete from drive root
        if ($item.FullName.Length -le 3) { $script:skippedCount++; continue }
        try {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop
            $script:deletedCount++
        } catch {
            $script:skippedCount++
        }
    }
}

# Counters for logging
$script:deletedCount = 0
$script:skippedCount = 0

# 1. Clean User Temp (%TEMP%)
if ($env:TEMP) {
    Invoke-FastFolderClean -TargetFolder $env:TEMP
}

# 2. Clean Windows Temp
Invoke-FastFolderClean -TargetFolder "C:\Windows\Temp"

# 3. Clean Crash Dumps
$crashDumpsPath = "$env:LOCALAPPDATA\CrashDumps"
if (Test-Path -LiteralPath $crashDumpsPath) {
    Invoke-FastFolderClean -TargetFolder $crashDumpsPath
}

# 4. Clean DirectX Shader Cache
$shaderPath = "$env:LOCALAPPDATA\D3DSCache"
if (Test-Path -LiteralPath $shaderPath) {
    Invoke-FastFolderClean -TargetFolder $shaderPath
}

# 5. Clean Windows Update Download Cache (if elevated)
$swDownload = "C:\Windows\SoftwareDistribution\Download"
if (Test-Path -LiteralPath $swDownload) {
    Invoke-FastFolderClean -TargetFolder $swDownload
}

# 6. Flush DNS Cache
try {
    Clear-DnsClientCache -ErrorAction SilentlyContinue
} catch {}

# 7. Optional RAMMap Standby Flush (if elevated)
$rammapExe = (Join-Path $env:USERPROFILE "RAMMap.exe")
if (-not (Test-Path -LiteralPath $rammapExe)) {
    $rammapExe = (Join-Path $env:USERPROFILE "RAMMap\RAMMap.exe")
}
if (Test-Path -LiteralPath $rammapExe) {
    try {
        Start-Process -FilePath $rammapExe -ArgumentList "-Es" -NoNewWindow -Wait -ErrorAction Stop
    } catch {}
}

# Log one quick line
Write-FastLog "Cleanup: $($script:deletedCount) deleted, $($script:skippedCount) skipped."

# Trim log file if it exceeds size
if (Test-Path -LiteralPath $logFile) {
    $item = Get-Item -LiteralPath $logFile -ErrorAction SilentlyContinue
    if ($item -and $item.Length -gt $maxLogSizeBytes) {
        $recent = Get-Content -LiteralPath $logFile -Tail 100 -ErrorAction SilentlyContinue
        Set-Content -LiteralPath $logFile -Value $recent -Encoding UTF8 -Force -ErrorAction SilentlyContinue
    }
}

# 8. Check 7-Day Weekly Report
$shouldOpenReport = $false
$today = Get-Date

if (-not (Test-Path -LiteralPath $reportTracker)) {
    $today.ToString("yyyy-MM-dd") | Set-Content -Path $reportTracker -Encoding UTF8
} else {
    $lastDateStr = (Get-Content -Path $reportTracker -ErrorAction SilentlyContinue).Trim()
    try {
        $lastDate = [datetime]::ParseExact($lastDateStr, "yyyy-MM-dd", $null)
        if ($today.Date -ge $lastDate.AddDays(7).Date) {
            $shouldOpenReport = $true
        }
    } catch {
        $today.ToString("yyyy-MM-dd") | Set-Content -Path $reportTracker -Encoding UTF8
    }
}

if ($shouldOpenReport) {
    $recentLogs = Get-Content -LiteralPath $logFile -Tail 30 -ErrorAction SilentlyContinue
    $cDrive = Get-PSDrive -Name C -ErrorAction SilentlyContinue
    $freeSpaceGB = if ($cDrive) { [math]::Round($cDrive.Free / 1GB, 2) } else { "N/A" }

    $reportText = @"
================================================================================
                 Weekly System Maintenance Report (Every 7 Days)
================================================================================
Report Date: $($today.ToString("yyyy-MM-dd HH:mm"))
Current Free Space on Drive (C:): $freeSpaceGB GB

System Cleanup Status:
- %TEMP% and Windows Temp folders: Automatically cleaned every 30 minutes in background.
- DirectX Shader Cache: Cleaned periodically.
- DNS Cache: Flushed periodically for faster browsing.
- Storage Sense: Enabled and running weekly automatically in Windows.
- Deletion Type: Immediate, direct and permanent (bypasses Recycle Bin with no processing delay).
- Active Program Files: Automatically excluded to protect your work and program stability.
- Prefetch Folder: Excluded from deletion to maintain maximum app startup speed.
- RAMMap: Configured to flush Standby List memory only, without affecting open programs.

Recent Logged Operations:
--------------------------------------------------------------------------------
$($recentLogs -join "`r`n")
--------------------------------------------------------------------------------
(This report will automatically open again in 7 days to update you on maintenance status).
================================================================================
"@

    [System.IO.File]::WriteAllText($weeklyReportFile, $reportText, [System.Text.Encoding]::Unicode)
    $today.ToString("yyyy-MM-dd") | Set-Content -Path $reportTracker -Encoding UTF8
    Start-Process "notepad.exe" -ArgumentList $weeklyReportFile
}
