# Fixed DSC Configuration with correct feature names
Write-Host "Creating Fixed DSC Configuration" -ForegroundColor Cyan

Configuration ServerConfig {
    Node "localhost" {
        # Install Windows Backup (this should be available)
        WindowsFeature BackupFeature {
            Ensure = "Present"
            Name = "Windows-Server-Backup"
        }
        
        # Install RSAT tools (useful for management)
        WindowsFeature RSATTools {
            Ensure = "Present" 
            Name = "RSAT-AD-PowerShell"
        }
        
        # Create enterprise directory structure
        File EnterpriseRoot {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\Enterprise"
        }
        
        File LogsDirectory {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\Enterprise\Logs"
            DependsOn = "[File]EnterpriseRoot"
        }
        
        # Create configuration file
        File ConfigFile {
            Ensure = "Present"
            DestinationPath = "C:\Enterprise\server-config.txt"
            Contents = "Enterprise Server Configuration`nConfigured: $(Get-Date)`nDSC Applied Successfully!"
        }
        
        # Configure registry setting
        Registry DisableServerManagerStartup {
            Ensure = "Present"
            Key = "HKLM:\SOFTWARE\Microsoft\ServerManager"
            ValueName = "DoNotOpenInitialConfigurationTasksAtLogon"
            ValueData = "1"
            ValueType = "DWord"
        }
    }
}

# Generate and apply configuration
ServerConfig -OutputPath "C:\Scripts\DSC\Fixed"
Start-DscConfiguration -Path "C:\Scripts\DSC\Fixed" -Wait -Verbose

Write-Host "Fixed DSC configuration applied!" -ForegroundColor Green