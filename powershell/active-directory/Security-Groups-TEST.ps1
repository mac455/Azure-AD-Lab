Import-Module ActiveDirectory

$DomainDN = (Get-ADDomain).DistinguishedName
$GroupsOU = "OU=Groups,OU=Corporate,$DomainDN"

Write-Host "Creating security groups..." -ForegroundColor Cyan

# Create groups directly (no function to avoid syntax issues)
try {
    New-ADGroup -Name "IT Admins" -Path $GroupsOU -GroupScope Global -GroupCategory Security
    Write-Host "✓ Created: IT Admins" -ForegroundColor Green
} catch {
    Write-Host "○ IT Admins already exists" -ForegroundColor Yellow
}

try {
    New-ADGroup -Name "Server Admins" -Path $GroupsOU -GroupScope Global -GroupCategory Security
    Write-Host "✓ Created: Server Admins" -ForegroundColor Green
} catch {
    Write-Host "○ Server Admins already exists" -ForegroundColor Yellow
}

try {
    New-ADGroup -Name "Helpdesk" -Path $GroupsOU -GroupScope Global -GroupCategory Security
    Write-Host "✓ Created: Helpdesk" -ForegroundColor Green
} catch {
    Write-Host "○ Helpdesk already exists" -ForegroundColor Yellow
}

try {
    New-ADGroup -Name "IT Department" -Path $GroupsOU -GroupScope Global -GroupCategory Security
    Write-Host "✓ Created: IT Department" -ForegroundColor Green
} catch {
    Write-Host "○ IT Department already exists" -ForegroundColor Yellow
}

try {
    New-ADGroup -Name "HR Department" -Path $GroupsOU -GroupScope Global -GroupCategory Security
    Write-Host "✓ Created: HR Department" -ForegroundColor Green
} catch {
    Write-Host "○ HR Department already exists" -ForegroundColor Yellow
}

try {
    New-ADGroup -Name "Finance Department" -Path $GroupsOU -GroupScope Global -GroupCategory Security
    Write-Host "✓ Created: Finance Department" -ForegroundColor Green
} catch {
    Write-Host "○ Finance Department already exists" -ForegroundColor Yellow
}

try {
    New-ADGroup -Name "Management" -Path $GroupsOU -GroupScope Global -GroupCategory Security
    Write-Host "✓ Created: Management" -ForegroundColor Green
} catch {
    Write-Host "○ Management already exists" -ForegroundColor Yellow
}

Write-Host "`nGroups creation complete!" -ForegroundColor Green

# Verify groups
Write-Host "`nVerifying groups..." -ForegroundColor Cyan
$Groups = Get-ADGroup -Filter * -SearchBase $GroupsOU

if ($Groups) {
    Write-Host "✓ Found $($Groups.Count) groups:" -ForegroundColor Green
    foreach ($Group in $Groups) {
        Write-Host "  • $($Group.Name)" -ForegroundColor White
    }
} else {
    Write-Host "No groups found!" -ForegroundColor Red
}