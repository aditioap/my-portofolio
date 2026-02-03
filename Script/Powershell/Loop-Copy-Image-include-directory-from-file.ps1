# Define CSV file and destination base path
$csvFile = "D:\Aditio\files.csv"  # Change this to your actual CSV file path
$destinationBase = "\\172.16.100.194\Upload"  # Destination base folder

# Read CSV file and ensure it exists
if (!(Test-Path -Path $csvFile)) {
    Write-Host "Error: CSV file not found at $csvFile"
    exit
}

$files = Import-Csv -Path $csvFile

foreach ($file in $files) {
    # Read 'PATHFULL' column from CSV
    $source = $file.PATHFULL.Trim()  

    # Validate if $source is empty
    if ([string]::IsNullOrEmpty($source)) {
        Write-Host "Skipping: Empty source path found in CSV"
        continue
    }

    # Validate source file existence
    if (!(Test-Path -Path $source)) {
        Write-Host "Skipping: File not found -> $source"
        continue
    }

    # Extract relative path after "E:\Upload\"
    $relativePath = $source -replace [regex]::Escape("E:\Upload\"), ""

    # Construct the full destination path
    $destination = Join-Path -Path $destinationBase -ChildPath $relativePath

    # Ensure the destination directory exists
    $destinationDir = Split-Path -Path $destination -Parent
    if (!(Test-Path -Path $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    }

    # Copy the file
    Copy-Item -Path $source -Destination $destination -Force
    Write-Host "Copied: $source -> $destination"
}

Write-Host "File copy process completed."
