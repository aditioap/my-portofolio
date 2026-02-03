$inputFile = "D:\Aditio\Script\Powershell\list-server.txt"
$outputFile = "D:\Aditio\Script\Powershell\output-server.txt"

# Clear previous output file
if (Test-Path $outputFile) { Remove-Item $outputFile }

# Read each line from the file
Get-Content $inputFile | ForEach-Object {
    # Extract hostname and IP
    $parts = $_ -split '\s+'
    $hostname = $parts[0]
    $ip = $parts[1]

    # Check if port 3389 (RDP) is open
    $rdpResult = Test-NetConnection -ComputerName $ip -Port 3389 -InformationLevel Quiet

    # Check if port 22 (SSH) is open
    $sshResult = Test-NetConnection -ComputerName $ip -Port 22 -InformationLevel Quiet

    # Determine system type based on port availability
    if ($rdpResult) {
        "$hostname $ip windows" | Out-File -Append -FilePath $outputFile
    } elseif ($sshResult) {
        "$hostname $ip linux" | Out-File -Append -FilePath $outputFile
    } else {
        "$hostname $ip unreachable" | Out-File -Append -FilePath $outputFile
    }
}

Write-Output "Check completed. Results saved to $outputFile"
