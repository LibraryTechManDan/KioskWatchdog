# Elevate if not admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Restore default Windows shell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
                 -Name "Shell" `
                 -Value "explorer.exe"

# Disable and remove watchdog task
if (Get-ScheduledTask -TaskName "Kiosk Watchdog" -ErrorAction SilentlyContinue) {
    Disable-ScheduledTask -TaskName "Kiosk Watchdog" -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName "Kiosk Watchdog" -Confirm:$false -ErrorAction SilentlyContinue
    Write-Output "Kiosk Watchdog task disabled and removed."
}

# Log and reboot
Write-Output "[{0}] Kiosk shell unlocked. Explorer shell enabled. Watchdog removed." -f (Get-Date)
Start-Sleep -Seconds 3
Restart-Computer -Force
