# Advanced DSC Configuration for Enterprise Environment
Write-Host "Creating Advanced DSC Configuration" -ForegroundColor Cyan

Configuration EnterpriseServerConfig {
    param(
        [string]$ServerName = "localhost"
    )
    
    Node $ServerName {
        # Ensure specific Windows features
        WindowsFeature BackupFeature {
            Ensure = "Present"
            Name = "Windows-Server-Backup"
        }
        
        WindowsFeature PowerShellWebAccess {
            Ensure = "Present" 
            Name = "WindowsPowerShellWebAccess"
        }
        
        # Configure registry settings
        Registry DisableServerManager {
            Ensure = "Present"
            Key = "HKLM:\SOFTWARE\Microsoft\ServerManager"
            ValueName = "DoNotOpenInitialConfigurationTasksAtLogon"
            ValueData = "1"
            ValueType = "DWord"
        }
        
        # Ensure log directories exist
        File LogDirectory {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\Enterprise\Logs"
        }
        
        File ScriptDirectory {
            Ensure = "Present"
            Type = "Directory" 
            DestinationPath = "C:\Enterprise\Scripts"
        }
        
        # Create scheduled task configuration file
        File ScheduledTaskConfig {
            Ensure = "Present"
            DestinationPath = "C:\Enterprise\Scripts\MaintenanceTask.ps1"
            Contents = "# Enterprise maintenance task`nWrite-Host 'Running maintenance...' -ForegroundColor Green"
        }
    }
}

# Create directory first
New-Item -ItemType Directory -Path "C:\Scripts\DSC\Advanced" -Force

# Generate configuration
EnterpriseServerConfig -OutputPath "C:\Scripts\DSC\Advanced"

# Apply configuration
Start-DscConfiguration -Path "C:\Scripts\DSC\Advanced" -Wait -Verbose

Write-Host "Advanced DSC configuration complete!" -ForegroundColor Green