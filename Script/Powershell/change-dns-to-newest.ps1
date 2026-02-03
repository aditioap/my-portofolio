# Set the network adapter name
$adapterName = "Wi-Fi"

# Set primary and secondary DNS addresses
$primaryDNS = "172.16.100.103"
$secondaryDNS = "172.16.100.6"

# Set the DNS servers for the adapter
Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses ($primaryDNS, $secondaryDNS)

Write-Host "DNS for '$adapterName' has been set to $primaryDNS and $secondaryDNS"
