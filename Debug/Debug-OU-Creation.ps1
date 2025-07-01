# Command 1: Basic AD connectivity
Write-Host "=== AD Connectivity Test ===" -ForegroundColor Cyan
Get-ADDomain | Select-Object Name, DNSRoot, DistinguishedName

# Command 2: Current user context
Write-Host "`n=== User Context ===" -ForegroundColor Cyan
whoami
(whoami /groups) -match "Domain.*Admin"

# Command 3: Existing OUs
Write-Host "`n=== Existing OUs ===" -ForegroundColor Cyan
Get-ADOrganizationalUnit -Filter * | Select-Object Name

# Command 4: Test OU creation with detailed output
Write-Host "`n=== Manual OU Creation Test ===" -ForegroundColor Cyan
$DomainDN = (Get-ADDomain).DistinguishedName
Write-Host "Domain DN: $DomainDN"

try {
    New-ADOrganizationalUnit -Name "TestOU" -Path $DomainDN -Verbose
    Write-Host "Test OU creation: SUCCESS" -ForegroundColor Green
    
    # Clean up
    Remove-ADOrganizationalUnit -Identity "OU=TestOU,$DomainDN" -Confirm:$false
    Write-Host "Test OU removed" -ForegroundColor Yellow
} catch {
    Write-Host "Test OU creation: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}