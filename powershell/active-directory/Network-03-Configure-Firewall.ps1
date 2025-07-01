
function Write-Host-Error {
    # Helper function to write error messages  
    param(
        [string]$Message, 
        [string]$Status,
        [string]$Details
    )
    $Colour = switch ($Status) {
        "SUCCESS" {"Green"}
        "FAILURE" {"Red"}
        "WARNING" {"Yellow"}
        "INFO" {"Cyan"}
        Default {"White"}
    }

    $Timestamp = Get-Date -Format "HH:mm:ss"  # Fixed typo: Fornat -> Format
    $FormattedMessage = "[$Timestamp] $Message"
    
    if ($Details) {
        $FormattedMessage += " - $Details"
    }
    
    Write-Host $FormattedMessage -ForegroundColor $Colour
}

# Start firewall configuration
Write-Host-Error -Message "Starting Windows Firewall Configuration" -Status "INFO"

try {
    # Enable firewall profiles
    Write-Host-Error -Message "Enabling firewall profiles" -Status "INFO"
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    Write-Host-Error -Message "Firewall profiles enabled" -Status "SUCCESS"
}
catch {
    Write-Host-Error -Message "Failed to enable firewall profiles" -Status "FAILURE" -Details $_.Exception.Message
}

# Configure Active Directory rules
Write-Host-Error -Message "Configuring Active Directory firewall rules" -Status "INFO"
try {
    $ADRules = Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Active Directory*"}
    
    if ($ADRules) {
        $EnabledCount = 0
        foreach ($Rule in $ADRules) {
            try {
                Enable-NetFirewallRule -Name $Rule.Name
                $EnabledCount++
                Write-Host-Error -Message "AD Rule enabled" -Status "SUCCESS" -Details $Rule.DisplayName
            }
            catch {
                Write-Host-Error -Message "Failed to enable AD rule" -Status "WARNING" -Details $Rule.DisplayName
            }
        }
        Write-Host-Error -Message "Active Directory rules configuration complete" -Status "SUCCESS" -Details "$EnabledCount rules enabled"
    }
    else {
        Write-Host-Error -Message "No Active Directory firewall rules found" -Status "WARNING" -Details "This may be normal for some Windows versions"
    }
}
catch {
    Write-Host-Error -Message "Error processing Active Directory rules" -Status "FAILURE" -Details $_.Exception.Message
}

# Configure DNS rules
Write-Host-Error -Message "Configuring DNS firewall rules" -Status "INFO"
try {
    $DNSRules = Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*DNS*"}
    
    if ($DNSRules) {
        $EnabledCount = 0
        foreach ($Rule in $DNSRules) {
            try {
                Enable-NetFirewallRule -Name $Rule.Name
                $EnabledCount++
                Write-Host-Error -Message "DNS Rule enabled" -Status "SUCCESS" -Details $Rule.DisplayName
            }
            catch {
                Write-Host-Error -Message "Failed to enable DNS rule" -Status "WARNING" -Details $Rule.DisplayName
            }
        }
        Write-Host-Error -Message "DNS rules configuration complete" -Status "SUCCESS" -Details "$EnabledCount rules enabled"
    }
    else {
        Write-Host-Error -Message "No DNS firewall rules found" -Status "WARNING"
        # Create custom DNS rule
        New-NetFirewallRule -DisplayName "DNS Server Custom" -Direction Inbound -Protocol UDP -LocalPort 53 -Action Allow
        Write-Host-Error -Message "Created custom DNS rule" -Status "SUCCESS" -Details "UDP port 53"
    }
}
catch {
    Write-Host-Error -Message "Error processing DNS rules" -Status "FAILURE" -Details $_.Exception.Message
}

# Configure DHCP rules
Write-Host-Error -Message "Configuring DHCP firewall rules" -Status "INFO"
try {
    $DHCPRules = Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*DHCP*"}
    
    if ($DHCPRules) {
        $EnabledCount = 0
        foreach ($Rule in $DHCPRules) {
            try {
                Enable-NetFirewallRule -Name $Rule.Name
                $EnabledCount++
                Write-Host-Error -Message "DHCP Rule enabled" -Status "SUCCESS" -Details $Rule.DisplayName
            }
            catch {
                Write-Host-Error -Message "Failed to enable DHCP rule" -Status "WARNING" -Details $Rule.DisplayName
            }
        }
        Write-Host-Error -Message "DHCP rules configuration complete" -Status "SUCCESS" -Details "$EnabledCount rules enabled"
    }
    else {
        Write-Host-Error -Message "No DHCP firewall rules found" -Status "WARNING" -Details "Creating custom DHCP rule"
        New-NetFirewallRule -DisplayName "DHCP Server Custom" -Direction Inbound -Protocol UDP -LocalPort 67 -Action Allow
        Write-Host-Error -Message "Created custom DHCP rule" -Status "SUCCESS" -Details "UDP port 67"
    }
}
catch {
    Write-Host-Error -Message "Error processing DHCP rules" -Status "FAILURE" -Details $_.Exception.Message
}

# Configure Remote Desktop
Write-Host-Error -Message "Configuring Remote Desktop access" -Status "INFO"
try {
    $RDPRules = Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Remote Desktop*"}
    
    if ($RDPRules) {
        $EnabledCount = 0
        foreach ($Rule in $RDPRules) {
            try {
                Enable-NetFirewallRule -Name $Rule.Name
                $EnabledCount++
            }
            catch {
                Write-Host-Error -Message "Failed to enable RDP rule" -Status "WARNING" -Details $Rule.DisplayName
            }
        }
        Write-Host-Error -Message "Remote Desktop rules configured" -Status "SUCCESS" -Details "$EnabledCount rules enabled"
    }
    else {
        Write-Host-Error -Message "No Remote Desktop rules found" -Status "WARNING"
    }
}
catch {
    Write-Host-Error -Message "Error configuring Remote Desktop" -Status "FAILURE" -Details $_.Exception.Message
}

# Configure Windows Remote Management
Write-Host-Error -Message "Configuring Windows Remote Management" -Status "INFO"
try {
    $WinRMRules = Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Windows Remote Management*"}
    
    if ($WinRMRules) {
        $EnabledCount = 0
        foreach ($Rule in $WinRMRules) {
            try {
                Enable-NetFirewallRule -Name $Rule.Name
                $EnabledCount++
            }
            catch {
                Write-Host-Error -Message "Failed to enable WinRM rule" -Status "WARNING" -Details $Rule.DisplayName
            }
        }
        Write-Host-Error -Message "WinRM rules configured" -Status "SUCCESS" -Details "$EnabledCount rules enabled"
    }
    else {
        Write-Host-Error -Message "No WinRM rules found" -Status "WARNING"
    }
}
catch {
    Write-Host-Error -Message "Error configuring WinRM" -Status "FAILURE" -Details $_.Exception.Message
}

# Create custom lab rule
Write-Host-Error -Message "Creating custom lab traffic rule" -Status "INFO"
try {
    $ExistingRule = Get-NetFirewallRule -DisplayName "Lab Internal Traffic" -ErrorAction SilentlyContinue
    
    if ($ExistingRule) {
        Write-Host-Error -Message "Lab traffic rule already exists" -Status "WARNING" -Details "Skipping creation"
    }
    else {
        New-NetFirewallRule -DisplayName "Lab Internal Traffic" -Direction Inbound -Protocol TCP -LocalPort 1024-5000 -Action Allow
        Write-Host-Error -Message "Lab traffic rule created" -Status "SUCCESS" -Details "TCP ports 1024-5000"
    }
}
catch {
    Write-Host-Error -Message "Failed to create lab traffic rule" -Status "FAILURE" -Details $_.Exception.Message
}

# Final summary
Write-Host-Error -Message "Windows Firewall configuration completed" -Status "SUCCESS"
Write-Host-Error -Message "Configuration summary available in event logs" -Status "INFO"