# Auto-elevate if not running as admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Set paths
$watchdogScriptPath = "C:\ProgramData\KioskWatchdog.ps1"
$exePath = "C:\Users\Library\AppData\Local\Programs\kiosk-browser\KioskBrowser.exe"
$taskName = "Kiosk Watchdog"

# Create watchdog script content
$watchdogScript = @"
`$exePath = "$exePath"

while (`$true) {
    `$processes = Get-Process -Name "KioskBrowser" -ErrorAction SilentlyContinue
    `$hasWindow = `$false

    foreach (`$p in `$processes) {
        try {
            if (`$p.MainWindowHandle -ne 0) {
                `$hasWindow = `$true
                break
            }
        } catch {}
    }

    if (-not `$hasWindow) {
        Stop-Process -Name "KioskBrowser" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Start-Process -FilePath `$exePath
        Write-Output "[$(Get-Date)] KioskBrowser restarted."
    } else {
        Write-Output "[$(Get-Date)] KioskBrowser running with window."
    }

    Start-Sleep -Seconds 5
}
"@

# Save watchdog script to file
Set-Content -Path $watchdogScriptPath -Value $watchdogScript -Encoding UTF8 -Force

# Create scheduled task to run as Library user at logon
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$watchdogScriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "Library" -LogonType Interactive -RunLevel Highest

# Register the scheduled task
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force

Write-Output "[{0}] Watchdog script created and task '$taskName' registered under 'Library' user." -f (Get-Date)
