# Path to the configuration file
$configFile = "ftp_sites.txt"

# Read each line from the configuration file
Get-Content $configFile | ForEach-Object {
    # Split line by semicolon and trim spaces
    $fields = $_ -split ";"

    # Assign values based on expected positions
    $siteName = $fields[0].Trim()
    $port = $fields[1].Trim()
    $ftpPath = $fields[2].Trim().Trim('"')  # Remove quotes around the path
    $user = ($fields[3].Trim() -split " ")[0]  # Extract username before 'ReadOnly'

    # Create the FTP directory if it doesn't exist
    if (!(Test-Path -Path $ftpPath)) {
        New-Item -ItemType Directory -Path $ftpPath
    }

    # Create the FTP site
    Write-Output "Creating FTP site: $siteName on port $port with directory $ftpPath for user $user"
    New-WebFtpSite -Name $siteName -Port $port -PhysicalPath $ftpPath -AllowRead $true

    # Set read and write permissions for the domain user group
    icacls $ftpPath /grant "macf.co.id\Domain Users:(OI)(CI)M"

    # Set authorization rule in IIS for the user with read-only access
    Set-WebConfiguration "/system.ftpServer/security/authorization" -PSPath "IIS:\" `
        -Location $siteName -Value @{accessType="Allow"; users="$user"; permissions="Read"}

    # Start the FTP site
    Start-WebFtpSite -Name $siteName
}
