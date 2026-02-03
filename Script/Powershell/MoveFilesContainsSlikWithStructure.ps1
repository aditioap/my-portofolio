# Define source and destination directories
$sourceDir = "D:\Upload\CAS_NewZoom\2024"  # Change source drive and path
#$destinationDir = "\\macf-dbstg\e$\Backup_macf-file2\Upload\Cas_NewZoom\2024"  # Change this to your destination drive and path
$destinationDir = "D:\New_Location\Cas_NewZoom\2024"  # Change this to your destination drive and path

# Get all files in the source directory, and filter for file names containing "slik"
Get-ChildItem -Path $sourceDir -Recurse | Where-Object { $_.Name -like "*slik*" } | ForEach-Object {
    # Create the destination path, preserving the original folder structure
    $relativePath = $_.FullName.Substring($sourceDir.Length)
    $destinationPath = Join-Path $destinationDir $relativePath

    # Create the destination directory if it doesn't exist
    $destinationFolder = Split-Path $destinationPath
    if (-not (Test-Path $destinationFolder)) {
        New-Item -ItemType Directory -Path $destinationFolder -Force
    }

    # Move the file to the destination
    Move-Item -Path $_.FullName -Destination $destinationPath -Force
}
