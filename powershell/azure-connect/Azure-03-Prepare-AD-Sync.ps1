# Prepare Active Directory for Azure Sync
Import-Module ActiveDirectory

Write-Host "Preparing AD for Azure Synchronization" -ForegroundColor Cyan

# Create Azure AD Connect service account
$ServiceAccountName = "AAD_Connect_Svc"
$ServiceAccountPath = "OU=Service Accounts,OU=Users,OU=Corporate,DC=enterprise,DC=local"

try {
    New-ADUser -Name "Azure AD Connect Service" `
               -SamAccountName $ServiceAccountName `
               -UserPrincipalName "$ServiceAccountName@enterprise.local" `
               -Path $ServiceAccountPath `
               -AccountPassword (ConvertTo-SecureString "ServicePass123!" -AsPlainText -Force) `
               -Enabled $true `
               -PasswordNeverExpires $true
               
    Write-Host "✓ Created Azure AD Connect service account" -ForegroundColor Green
} catch {
    Write-Host "Service account may already exist" -ForegroundColor Yellow
}

# Add service account to required groups
Add-ADGroupMember -Identity "Enterprise Admins" -Members $ServiceAccountName
Add-ADGroupMember -Identity "Domain Admins" -Members $ServiceAccountName

# Set UPN suffix for cloud sync
Set-ADForest -UPNSuffixes @{Add="enterpriselab123.onmicrosoft.com"}

# Prepare users for sync by setting UPN
$Users = Get-ADUser -Filter * -SearchBase "OU=Users,OU=Corporate,DC=enterprise,DC=local"
foreach ($User in $Users) {
    $NewUPN = "$($User.SamAccountName)@enterpriselab123.onmicrosoft.com"
    Set-ADUser -Identity $User.SamAccountName -UserPrincipalName $NewUPN
    Write-Host "✓ Updated UPN for: $($User.Name)" -ForegroundColor Green
}

Write-Host "AD preparation for sync complete!" -ForegroundColor Green