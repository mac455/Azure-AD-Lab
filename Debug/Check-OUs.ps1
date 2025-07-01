# Let's see all existing OUs
Write-Host "All existing OUs in your domain:" -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName | Sort-Object Name

# Check specifically for Corporate and related OUs
Write-Host "`nChecking for Corporate-related OUs:" -ForegroundColor Yellow
Get-ADOrganizationalUnit -Filter "Name -like '*Corp*' -or Name -eq 'IT' -or Name -eq 'HR' -or Name -eq 'Users'" | Select-Object Name, DistinguishedName