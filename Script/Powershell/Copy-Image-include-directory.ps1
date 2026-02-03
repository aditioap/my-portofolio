$source = "D:\Aditio\Document\MACF\Fincore\Dokumentasi\macf-file2\2024\01\01\Screenshot.png"
$destinationBase = "D:\Aditio\Document\MACF\Fincore\Dokumentasi\macf-file\2024"

# Normalize paths by replacing backslashes with forward slashes
$sourceNormalized = $source -replace '\\', '/'
$destinationBaseNormalized = $destinationBase -replace '\\', '/'

# Extract the relative path after "macf-file2\2024"
$relativePath = $sourceNormalized -replace [regex]::Escape("D:/Aditio/Document/MACF/Fincore/Dokumentasi/macf-file2/2024"), ""

# Construct the full destination path
$destination = Join-Path -Path $destinationBase -ChildPath $relativePath

# Ensure the destination directory exists
$destinationDir = Split-Path -Path $destination -Parent
if (!(Test-Path -Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force
}

# Copy the file
Copy-Item -Path $source -Destination $destination -Force
Write-Host "File copied successfully to: $destination"
