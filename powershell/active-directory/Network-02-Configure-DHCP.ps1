# Get your actual server IP address
$ServerIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"}).IPAddress
Write-Host "Your server IP is: $ServerIP" -ForegroundColor Cyan

# Get domain controller name
$DCName = $env:COMPUTERNAME
Write-Host "Your DC name is: $DCName" -ForegroundColor Cyan

# DHCP Setup - Fixed Version
Write-Host "Setting up DHCP with correct settings..." -ForegroundColor Cyan

# Get actual server IP
$ServerIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"}).IPAddress
$DCName = $env:COMPUTERNAME

Write-Host "Using Server IP: $ServerIP" -ForegroundColor Yellow
Write-Host "Using DC Name: $DCName" -ForegroundColor Yellow

# Install DHCP
try {
    Install-WindowsFeature DHCP -IncludeManagementTools -ErrorAction Stop
    Write-Host "✓ DHCP installed" -ForegroundColor Green
} catch {
    Write-Host "✗ DHCP install failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Import module
try {
    Import-Module DhcpServer -ErrorAction Stop
    Write-Host "✓ Module imported" -ForegroundColor Green
} catch {
    Write-Host "✗ Module import failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Create scope with correct network
$Network = $ServerIP.Substring(0, $ServerIP.LastIndexOf('.'))
$ScopeStart = "$Network.100"
$ScopeEnd = "$Network.200"
$ScopeID = "$Network.0"

try {
    Add-DhcpServerv4Scope -Name "Lab Network" -StartRange $ScopeStart -EndRange $ScopeEnd -SubnetMask "255.255.255.0" -ErrorAction Stop
    Write-Host "✓ Scope created: $ScopeStart - $ScopeEnd" -ForegroundColor Green
} catch {
    Write-Host "✗ Scope creation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Set options with correct DNS server
try {
    Set-DhcpServerv4OptionValue -ScopeId $ScopeID -DnsServer $ServerIP -ErrorAction Stop
    Write-Host "✓ DNS server set to: $ServerIP" -ForegroundColor Green
} catch {
    Write-Host "✗ DNS option failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "DHCP setup complete!" -ForegroundColor Green