# Automated User Management Functions
Import-Module ActiveDirectory

Write-Host "Creating User Automation Functions" -ForegroundColor Cyan

# Function for bulk user creation
function New-BulkUsers {
    param([array]$UserList)
    
    foreach ($User in $UserList) {
        try {
            $Username = "$($User.FirstName.Substring(0,1).ToLower()).$($User.LastName.ToLower())"
            $UPN = "$Username@enterprise.local"
            $Path = "OU=Employees,OU=Users,OU=Corporate,DC=enterprise,DC=local"
            
            New-ADUser -Name "$($User.FirstName) $($User.LastName)" `
                       -GivenName $User.FirstName `
                       -Surname $User.LastName `
                       -SamAccountName $Username `
                       -UserPrincipalName $UPN `
                       -Department $User.Department `
                       -Path $Path `
                       -AccountPassword (ConvertTo-SecureString "TempPass123!" -AsPlainText -Force) `
                       -Enabled $true
                       
            Write-Host "✓ Created user: $Username" -ForegroundColor Green
        } catch {
            Write-Host "✗ Failed to create: $($User.FirstName) $($User.LastName)" -ForegroundColor Red
        }
    }
}

# Function to disable departing users
function Disable-DepartingUser {
    param([string]$Username, [string]$Reason)
    
    try {
        # Disable account
        Disable-ADAccount -Identity $Username
        
        # Move to disabled OU
        $DisabledOU = "OU=Disabled,OU=Users,OU=Corporate,DC=enterprise,DC=local"
        Move-ADObject -Identity (Get-ADUser $Username).DistinguishedName -TargetPath $DisabledOU
        
        # Add description
        Set-ADUser -Identity $Username -Description "Disabled: $(Get-Date -Format 'yyyy-MM-dd') - $Reason"
        
        Write-Host "✓ Disabled user: $Username" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to disable: $Username" -ForegroundColor Red
    }
}

# Example usage
$NewUsers = @(
    @{FirstName="Alice"; LastName="Cooper"; Department="Marketing"},
    @{FirstName="Bob"; LastName="Miller"; Department="Operations"}
)

New-BulkUsers -UserList $NewUsers

Write-Host "User automation functions ready!" -ForegroundColor Green