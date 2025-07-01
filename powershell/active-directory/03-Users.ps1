# Essential User Creation - Learn user provisioning patterns
Import-Module ActiveDirectory

$DomainDN = (Get-ADDomain).DistinguishedName
$DomainName = (Get-ADDomain).DNSRoot

Write-Host "Creating essential user accounts..." -ForegroundColor Cyan

# Learn the user creation pattern - this is crucial for AD admin
function New-DomainUser {
    param(
        [string]$FirstName,
        [string]$LastName, 
        [string]$Department,
        [string]$JobTitle,
        [string[]]$Groups = @()
    )
    
    $Username = "$($FirstName.Substring(0,1).ToLower()).$($LastName.ToLower())"
    $UserPath = "OU=Employees,OU=Users,OU=Corporate,$DomainDN"
    
    try {
        # Core user creation - learn these parameters
        New-ADUser -Name "$FirstName $LastName" `
                   -GivenName $FirstName `
                   -Surname $LastName `
                   -SamAccountName $Username `
                   -UserPrincipalName "$Username@$DomainName" `
                   -Department $Department `
                   -Title $JobTitle `
                   -Path $UserPath `
                   -AccountPassword (ConvertTo-SecureString "Welcome123!" -AsPlainText -Force) `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true
                   
        Write-Host "✓ Created user: $Username ($FirstName $LastName)" -ForegroundColor Green
        
        # Add to groups - learn group membership
        foreach ($Group in $Groups) {
            Add-ADGroupMember -Identity $Group -Members $Username
            Write-Host "  └─ Added to: $Group" -ForegroundColor Cyan
        }
        
    } catch {
        Write-Host "Failed to create: $Username" -ForegroundColor Red
    }
}

# Create key users - practice the function calls
New-DomainUser -FirstName "John" -LastName "Smith" -Department "IT" -JobTitle "IT Director" -Groups @("IT Department", "IT Administrators", "Management Team")

New-DomainUser -FirstName "Sarah" -LastName "Johnson" -Department "IT" -JobTitle "Systems Admin" -Groups @("IT Department", "Server Admins")

New-DomainUser -FirstName "Lisa" -LastName "Anderson" -Department "HR" -JobTitle "HR Director" -Groups @("HR Department", "Management Team")

New-DomainUser -FirstName "Mike" -LastName "Brown" -Department "Finance" -JobTitle "Finance Manager" -Groups @("Finance Department")

# Admin account - different pattern to learn
$AdminPath = "OU=Admins,OU=Users,OU=Corporate,$DomainDN"
New-ADUser -Name "IT Admin" -SamAccountName "admin.it" -Path $AdminPath -AccountPassword (ConvertTo-SecureString "AdminPass123!" -AsPlainText -Force) -Enabled $true

Write-Host "Essential users created! Default password: Welcome123!" -ForegroundColor Green