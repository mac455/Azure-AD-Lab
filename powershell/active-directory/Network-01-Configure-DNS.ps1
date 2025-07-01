Import-Module DnsServer

Write-Host "Configruing DNS services" -ForegroundColor Cyan

# Add DNS forwarders for internet resolution
Add-DnsServerForwarder -IPAddress "8.8.8.8", "1.1.1.1"

# Create internet lab zone 
Add-DnsServerPrimaryZone -Name "lab.enterprise.local" -ZoneFile "lab.enterprise.local.dns" 

# Add common server records
Add-DnsServerResourceRecordA -ZoneName "lab.enterprise.local" -Name "dc01" -IPv4Address "192.168.1.10"
Add-DnsServerResourceRecordA -ZoneName "lab.enterprise.local" -Name "fileserver" -IPv4Address "192.168.1.20"

# Create reverse lookup zone
Add-DnsServerPrimaryZone -NetworkID "192.168.1.0/24" -ZoneFile "1.168.192.in-addr.arpa.dns"

Write-Host "DNS configuration complete!" -ForegroundColor Green