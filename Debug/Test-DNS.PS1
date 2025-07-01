# Test DNS functionality
Write-Host "Testing DNS Resolution" -ForegroundColor Cyan

# Test internal resolution
Resolve-DnsName "dc01.lab.enterprise.local"
Resolve-DnsName "enterprise.local"

# Test external resolution
Resolve-DnsName "google.com"

Write-Host "DNS tests complete!" -ForegroundColor Green