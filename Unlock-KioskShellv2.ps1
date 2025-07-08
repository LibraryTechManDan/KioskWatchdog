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

# Log and reboot
Write-Output "[{0}] Kiosk shell unlocked. Explorer shell enabled." -f (Get-Date)
Start-Sleep -Seconds 3
Restart-Computer -Force
