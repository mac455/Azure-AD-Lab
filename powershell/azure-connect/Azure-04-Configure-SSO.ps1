
Write-Host "=== Azure AD Hybrid Sync Investigation ===" -ForegroundColor Cyan


Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Identity.DirectoryManagement

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All", "Organization.Read.All"

Write-Host "✓ Connected to Microsoft Graph" -ForegroundColor Green

# Get detailed user information
Write-Host "`n1. DETAILED USER ANALYSIS" -ForegroundColor Yellow
$AllUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,OnPremisesSyncEnabled,OnPremisesImmutableId,OnPremisesDomainName,OnPremisesSamAccountName,CreatedDateTime,UserType"

Write-Host "Total users found: $($AllUsers.Count)" -ForegroundColor Green

# Analyze each user in detail
foreach ($User in $AllUsers) {
    Write-Host "`n--- User: $($User.DisplayName) ---" -ForegroundColor Cyan
    Write-Host "  UPN: $($User.UserPrincipalName)" -ForegroundColor White
    Write-Host "  User Type: $($User.UserType)" -ForegroundColor White
    Write-Host "  Created: $($User.CreatedDateTime)" -ForegroundColor White
    Write-Host "  On-Premises Sync Enabled: $($User.OnPremisesSyncEnabled)" -ForegroundColor $(if ($User.OnPremisesSyncEnabled) {"Green"} else {"Red"})
    Write-Host "  On-Premises Immutable ID: $($User.OnPremisesImmutableId)" -ForegroundColor White
    Write-Host "  On-Premises Domain: $($User.OnPremisesDomainName)" -ForegroundColor White
    Write-Host "  On-Premises SAM Account: $($User.OnPremisesSamAccountName)" -ForegroundColor White
}

# Check directory synchronization status
Write-Host "`n2. DIRECTORY SYNCHRONIZATION STATUS" -ForegroundColor Yellow
try {
    $OrgInfo = Get-MgOrganization
    $DirSync = $OrgInfo | Select-Object -ExpandProperty OnPremisesSyncEnabled
    Write-Host "Directory Sync Enabled: $DirSync" -ForegroundColor $(if ($DirSync) {"Green"} else {"Red"})
    
    if ($OrgInfo.OnPremisesLastSyncDateTime) {
        Write-Host "Last Sync Time: $($OrgInfo.OnPremisesLastSyncDateTime)" -ForegroundColor Green
    } else {
        Write-Host "Last Sync Time: Never" -ForegroundColor Red
    }
} catch {
    Write-Host "Could not retrieve organization sync status: $($_.Exception.Message)" -ForegroundColor Red
}

# Check domains and their sync status
Write-Host "`n3. DOMAIN ANALYSIS" -ForegroundColor Yellow
$Domains = Get-MgDomain
foreach ($Domain in $Domains) {
    Write-Host "`nDomain: $($Domain.Id)" -ForegroundColor Cyan
    Write-Host "  Verified: $($Domain.IsVerified)" -ForegroundColor $(if ($Domain.IsVerified) {"Green"} else {"Red"})
    Write-Host "  Default: $($Domain.IsDefault)" -ForegroundColor White
    Write-Host "  Initial: $($Domain.IsInitial)" -ForegroundColor White
    Write-Host "  Authentication Type: $($Domain.AuthenticationType)" -ForegroundColor White
}

# Check for Azure AD Connect health (if available)
Write-Host "`n4. AZURE AD CONNECT STATUS CHECK" -ForegroundColor Yellow
try {
    # This requires additional permissions, so might fail
    $ConnectHealth = Get-MgDirectoryOnPremisesSynchronization -ErrorAction SilentlyContinue
    if ($ConnectHealth) {
        Write-Host "Azure AD Connect detected!" -ForegroundColor Green
        Write-Host "Configuration: $($ConnectHealth.Configuration)" -ForegroundColor White
    } else {
        Write-Host "No Azure AD Connect configuration found" -ForegroundColor Red
    }
} catch {
    Write-Host "Azure AD Connect status check failed (may require additional permissions)" -ForegroundColor Yellow
}

# Summary and recommendations
Write-Host "`n5. SUMMARY AND RECOMMENDATIONS" -ForegroundColor Yellow
$SyncedUsers = $AllUsers | Where-Object {$_.OnPremisesSyncEnabled -eq $true}
$CloudUsers = $AllUsers | Where-Object {$_.OnPremisesSyncEnabled -ne $true}

Write-Host "Synchronized Users: $($SyncedUsers.Count)" -ForegroundColor Green
Write-Host "Cloud-Only Users: $($CloudUsers.Count)" -ForegroundColor Yellow

if ($SyncedUsers.Count -eq 0) {
    Write-Host "`n⚠️  NO SYNCHRONIZED USERS DETECTED" -ForegroundColor Red
    Write-Host "This suggests:" -ForegroundColor Yellow
    Write-Host "  1. Azure AD Connect is not installed/configured" -ForegroundColor White
    Write-Host "  2. Synchronization is not working properly" -ForegroundColor White
    Write-Host "  3. All users were created directly in Azure AD" -ForegroundColor White
    
    Write-Host "`n📋 NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "  1. Verify Azure AD Connect is installed on domain controller" -ForegroundColor White
    Write-Host "  2. Check Azure AD Connect sync status" -ForegroundColor White
    Write-Host "  3. Review on-premises AD user configuration" -ForegroundColor White
    Write-Host "  4. Consider running initial sync if Connect is installed" -ForegroundColor White
}

Write-Host "`n=== Investigation Complete ===" -ForegroundColor Cyan