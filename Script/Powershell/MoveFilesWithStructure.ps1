# Define source and destination directories
#$sourceDir = "D:\Upload\Cas_NewZoom\2024" # Change source drive and path
$sourceDir = "E:\Upload\CAS_NewZoom\2024"
#$destinationDir = "D:\New_Location\Cas_NewZoom\2024"  # Change this to your destination drive and path
$destinationDir = "\\macf-dbstg\e$\Backup_macf-file2\Upload\Cas_NewZoom\2024"  # Change this to your destination drive and path

# Get all files with extensions ideb and pdf in the source directory
Get-ChildItem -Path $sourceDir -Recurse -Include *.ideb, *.pdf, *.docx | ForEach-Object {
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
