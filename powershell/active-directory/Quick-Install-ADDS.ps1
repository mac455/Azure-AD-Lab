param(
    [string]$DomainName = "enterprise.local",
    [string]$SafeModePassword = "ModernFamily123!"
)
# Install ADDS on Windows Server
Write-Host "Installing Active Directory Domain Services (AD DS)..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Import the ADDS module
Import-Module ADDSDeployment

# Promte to Domain Controller
Write-Host "Promoting to Domain Controller.." -ForegroundColor Yellow
$SecurePassword = ConvertTo-SecureString $SafeModePassword -AsPlainText -Force


Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName "ENTERPRISE" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -SafeModeAdministratorPassword $SecurePassword `
    -InstallDns:$true `
    -CreateDnsDelegation:$false `
    -Force:$true

Write-Host "Installation completed! The server will restart." -ForegroundColor Green