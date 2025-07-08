# Elevate if not admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define kiosk app path
$kioskAppPath = "C:\Users\Library\AppData\Local\Programs\kiosk-browser\KioskBrowser.exe"

# Set kiosk shell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
                 -Name "Shell" `
                 -Value $kioskAppPath

# Log and reboot
Write-Output "[{0}] Kiosk shell locked. KioskBrowser shell set." -f (Get-Date)
Start-Sleep -Seconds 3
Restart-Computer -Force
