$Source      = "\\172.16.100.195\E$\SFTP Fincore"
$Destination = "D:\backup-macf-dbstg\E\Backup\macf-file2\E\SFTP Fincore"

# Ensure destination exists
if (!(Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
}

# Incremental copy (skip existing unchanged files)
robocopy `
    "$Source" `
    "$Destination" `
    /E `
    /COPY:DAT `
    /XO `
    /R:3 `
    /W:5 `
    /MT:8 `
    /LOG+:D:\logs\robocopy_sftp_fincore_incremental.log

