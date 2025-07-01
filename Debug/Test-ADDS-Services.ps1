Write-Host "Testing Active Directory Domain Services (AD DS) installation..." -ForegroundColor Cyan

# Test 1: Check if Ad is installed 

Write-Host "`n1. Checking if Active Directory Domain Services (AD DS) is installed..." -ForegroundColor Yellow
$Domain = Get-ADDomain
if ($Domain) {
    Write-Host "Domain $(Domain.DNSRoot) is installed." -ForegroundColor Green
}
else {
    Write-Host "Domain is not installed." -ForegroundColor Red
}

# Test 2: Testing server
Write-Host "`n2. Testing services" -ForegroundColor Yellow
$DNS = Resolve-DnsName -Name "enterprise.local" -ErrorAction SilentlyContinue
if ($DNS) {
    Write-Host "   ✅ DNS Resolution: Working" -ForegroundColor Green
} else {
    Write-Host "   ❌ DNS Resolution: Failed" -ForegroundColor Red
}

Write-Host "`n3. Testing AD DS services" -ForegroundColor Yellow
$Services = @("NTDS", "DNS", "KDC")
foreach ($Service in $Services) {
     $ServiceObj = Get-Service -Name $Service -ErrorAction SilentlyContinue
    if ($ServiceObj -and $ServiceObj.Status -eq "Running") {
        Write-Host "   ✅ ${Service}: Running" -ForegroundColor Green
    } else {
        Write-Host "   ❌ ${Service}: Not Running" -ForegroundColor Red
    }
}

Write-Host "`nTest Completed!" -ForegroundColor Green