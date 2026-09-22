Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
strPath = fso.GetParentFolderName(WScript.ScriptFullName) & "\cleanup_automation.ps1"
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -NoProfile -File """ & strPath & """", 0, False
