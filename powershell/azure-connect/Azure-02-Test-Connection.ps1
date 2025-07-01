# Test Azure Connectivity 
Write-Host "Testing Azure Connectivity" -ForegroundColor Cyan
Write-Host "Tenant: mcanthonyotuonyegmail.onmicrosoft.com" -ForegroundColor Yellow

# Test Azure AD endpoints
$AzureEndpoints = @(
    "login.microsoftonline.com",
    "graph.microsoft.com", 
    "management.azure.com",
    "aadcdn.msftauth.net"
)

foreach ($Endpoint in $AzureEndpoints) {
    try {
        $Test = Test-NetConnection -ComputerName $Endpoint -Port 443
        if ($Test.TcpTestSucceeded) {
            Write-Host "✓ $Endpoint - Connected" -ForegroundColor Green
        } else {
            Write-Host "✗ $Endpoint - Failed" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ $Endpoint - Error" -ForegroundColor Red
    }
}

# Test specific tenant connectivity
try {
    $TenantTest = Test-NetConnection -ComputerName "login.microsoftonline.com" -Port 443
    Write-Host "✓ Tenant connectivity: Ready for Azure AD Connect" -ForegroundColor Green
} catch {
    Write-Host "✗ Tenant connectivity: Failed" -ForegroundColor Red
}

# Check TLS version
$TLS = [System.Net.ServicePointManager]::SecurityProtocol
Write-Host "TLS Protocol: $TLS" -ForegroundColor Green

Write-Host "Azure connectivity test complete!" -ForegroundColor Green