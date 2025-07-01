# Enterprise Backup Automation
Write-Host "Setting up Backup Automation" -ForegroundColor Cyan

# Function to backup AD database
function Backup-ActiveDirectory {
    param([string]$BackupPath = "C:\Backups\AD")
    
    # Create backup directory
    New-Item -ItemType Directory -Path $BackupPath -Force
    
    # Backup AD using ntdsutil
    $BackupScript = @"
ntdsutil "authoritative restore" "backup to $BackupPath" q q
"@
    
    $BackupScript | Out-File -FilePath "$BackupPath\ad-backup.cmd"
    
    Write-Host "✓ AD backup script created" -ForegroundColor Green
}

# Function to backup Group Policies
function Backup-GroupPolicies {
    param([string]$BackupPath = "C:\Backups\GPO")
    
    # Create backup directory
    New-Item -ItemType Directory -Path $BackupPath -Force
    
    # Backup all GPOs
    Import-Module GroupPolicy
    $GPOs = Get-GPO -All
    
    foreach ($GPO in $GPOs) {
        try {
            Backup-GPO -Name $GPO.DisplayName -Path $BackupPath
            Write-Host "✓ Backed up GPO: $($GPO.DisplayName)" -ForegroundColor Green
        } catch {
            Write-Host "✗ Failed to backup: $($GPO.DisplayName)" -ForegroundColor Red
        }
    }
}

# Function to backup scripts and configurations
function Backup-Scripts {
    param([string]$BackupPath = "C:\Backups\Scripts")
    
    # Create backup directory  
    New-Item -ItemType Directory -Path $BackupPath -Force
    
    # Copy scripts
    Copy-Item -Path "C:\Scripts\*" -Destination $BackupPath -Recurse -Force
    
    Write-Host "✓ Scripts backed up" -ForegroundColor Green
}

# Run backup functions
Backup-ActiveDirectory
Backup-GroupPolicies  
Backup-Scripts

# Create scheduled backup task
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Scripts\Automation-04-Backup-Scripts.ps1"
$Trigger = New-ScheduledTaskTrigger -Daily -At "2:00AM"
Register-ScheduledTask -TaskName "Enterprise Backup" -Action $Action -Trigger $Trigger

Write-Host "Backup automation complete!" -ForegroundColor Green