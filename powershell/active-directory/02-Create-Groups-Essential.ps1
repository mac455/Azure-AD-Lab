Import-Module ActiveDirectory
$DomainDN = (Get-ADDomain).DistinguishedName
$GroupsOU = "OU=Groups,OU=Corporate,$DomainDN"

Write-Host "Creating essential security groups..." -ForegroundColor Cyan

function New-SecurityGroup {
    param(
        [string]$GroupName,
        [string]$Description
    )

    try {
        New-ADGroup -Name $GroupName -Path $GroupsOU -GroupScope Global -GroupCategory Security -Description $Description
        Write-Host "✓ Created group: $GroupName" -ForegroundColor Green
    } catch {
        if ($_.Exception.Message -like "*already exists*") {
            Write-Host "○ Group already exists: $GroupName" -ForegroundColor Yellow
        } else {
            Write-Host "✗ Failed to create $GroupName`: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Admin Groups
New-SecurityGroup -GroupName "IT Admins" -Description "IT Administrators with full access to all systems"
New-SecurityGroup -GroupName "Server Admins" -Description "Administrators with full access to servers"
New-SecurityGroup -GroupName "Helpdesk" -Description "Helpdesk staff with limited access to user accounts"

# Department Groups
$Departments = @("IT Department", "HR Department", "Finance Department")
foreach ($Department in $Departments) {
    New-SecurityGroup -GroupName $Department -Description "All staff in $Department"
}

# Management Group
New-SecurityGroup -GroupName "Management" -Description "Management team with access to sensitive data"

Write-Host "Essential security groups created successfully!" -ForegroundColor Green

# Verify groups were created
Write-Host "`nVerifying groups..." -ForegroundColor Cyan
$Groups = Get-ADGroup -Filter * -SearchBase $GroupsOU -ErrorAction SilentlyContinue

if ($Groups) {
    Write-Host "✓ Found $($Groups.Count) groups:" -ForegroundColor Green
    $Groups | Select-Object Name, Description | Sort-Object Name | Format-Table -AutoSize
} else {
    Write-Host "No groups found in $GroupsOU" -ForegroundColor Red
    Write-Host "Check if the Groups OU exists!" -ForegroundColor Yellow
}