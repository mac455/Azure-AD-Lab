Import-Module ActiveDirectory

$DomainDN = (Get-ADDomain).DistinguishedName
Write-Host "Creating OU structure in: $DomainDN" -ForegroundColor Cyan

Write-Host "Creating Corporate OU..." -ForegroundColor Yellow
try {
    New-ADOrganizationalUnit -Name "Corporate" -Path $DomainDN
    Write-Host "Success: Created Corporate OU" -ForegroundColor Green
} catch {
    Write-Host "Corporate OU already exists" -ForegroundColor Yellow
}

Write-Host "Creating main OUs..." -ForegroundColor Yellow
$MainOUs = @("IT", "HR", "Finance", "Users", "Computers", "Groups")

foreach ($OU in $MainOUs) {
    try {
        New-ADOrganizationalUnit -Name $OU -Path "OU=Corporate,$DomainDN"
        Write-Host "Success: Created $OU OU" -ForegroundColor Green
    } catch {
        Write-Host "$OU OU already exists" -ForegroundColor Yellow
    }
}

Write-Host "Creating sub-OUs..." -ForegroundColor Yellow
try {
    New-ADOrganizationalUnit -Name "Employees" -Path "OU=Users,OU=Corporate,$DomainDN"
    Write-Host "Success: Created Employees OU" -ForegroundColor Green
} catch {
    Write-Host "Employees OU already exists" -ForegroundColor Yellow
}

try {
    New-ADOrganizationalUnit -Name "Admins" -Path "OU=Users,OU=Corporate,$DomainDN"
    Write-Host "Success: Created Admins OU" -ForegroundColor Green
} catch {
    Write-Host "Admins OU already exists" -ForegroundColor Yellow
}

Write-Host "OU creation complete!" -ForegroundColor Green
Get-ADOrganizationalUnit -Filter * | Sort-Object DistinguishedName | Select-Object Name