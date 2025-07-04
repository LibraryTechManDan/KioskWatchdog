# Auto-elevate if needed
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define script and task parameters
$watchdogScriptPath = "C:\ProgramData\KioskWatchdog.ps1"
$exePath = "C:\Users\Library\AppData\Local\Programs\kiosk-browser\KioskBrowser.exe"
$taskName = "Kiosk Watchdog"

# Write the watchdog script to disk
$watchdogScript = @"
\$exePath = "$exePath"
while (\$true) {
    if (-not (Get-Process -Name "KioskBrowser" -ErrorAction SilentlyContinue)) {
        Start-Process \$exePath
    }
    Start-Sleep -Seconds 5
}
"@
Set-Content -Path $watchdogScriptPath -Value $watchdogScript -Encoding UTF8 -Force

# Create scheduled task that runs at logon
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$watchdogScriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force

Write-Output "[{0}] Kiosk Watchdog task created and script written." -f (Get-Date)
Start-Sleep -Seconds 1
exit
