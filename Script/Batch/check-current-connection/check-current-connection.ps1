$websiteName = "YourWebsiteName"
$portNumber = 8080

# Import the WebAdministration module
Import-Module WebAdministration

# Retrieve the website object
$website = Get-Website $websiteName

# Retrieve the current connections for the website using the custom port
$siteId = $website.Id
$bindings = (Get-WebBinding -Port $portNumber).bindingInformation
$currentConnections = (Get-Counter -Counter "\Web Service($siteId($bindings))\Current Connections").CounterSamples[0].CookedValue

# Display the current connections
Write-Host "Current connections for $websiteName on port $portNumber: $currentConnections"
