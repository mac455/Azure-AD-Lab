# Check available Windows features
Write-Host "Checking Available Windows Features" -ForegroundColor Cyan

# Find web server features
Write-Host "`nWeb Server Features:" -ForegroundColor Yellow
Get-WindowsFeature | Where-Object {$_.Name -like "*Web*" -or $_.Name -like "*IIS*"} | Select-Object Name, InstallState

# Find PowerShell features  
Write-Host "`nPowerShell Features:" -ForegroundColor Yellow
Get-WindowsFeature | Where-Object {$_.Name -like "*PowerShell*"} | Select-Object Name, InstallState

# Find other useful features
Write-Host "`nOther Useful Features:" -ForegroundColor Yellow
Get-WindowsFeature | Where-Object {$_.Name -like "*Backup*" -or $_.Name -like "*RSAT*"} | Select-Object Name, InstallState

Write-Host "`nFeature check complete!" -ForegroundColor Green