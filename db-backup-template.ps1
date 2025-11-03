


# -------------------------------
# Define Parameters
# -------------------------------

$server = "SERVER_NAME_OR_INSTANCE"     # Example: "localhost" or "SQLSERVER01"
# Define database names
$database1 = "DB_NAME_1"
$database2 = "DB_NAME_2"
$database3 = "DB_NAME_3"
# ... add more databases as needed

# Create timestamp for filenames
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$date = Get-Date -Format yyyy-MM-dd

# Define backup directory path (change as required)
$folderPath = "D:\SQL_BACKUP\$date"
New-Item -ItemType Directory -Path $folderPath -Force | Out-Null


# -------------------------------
# Define Backup File Paths
# -------------------------------

$backupPath1 = "$folderPath\${database1}_backup_$timestamp.bak"
$backupPath2 = "$folderPath\${database2}_backup_$timestamp.bak"
$backupPath3 = "$folderPath\${database3}_backup_$timestamp.bak"
# ... continue for each database


# -------------------------------
# Define SQL Backup Commands
# -------------------------------

$sql1 = @"
BACKUP DATABASE [$database1]
TO DISK = N'$backupPath1'
WITH INIT, FORMAT;
"@

$sql2 = @"
BACKUP DATABASE [$database2]
TO DISK = N'$backupPath2'
WITH INIT, FORMAT;
"@

$sql3 = @"
BACKUP DATABASE [$database3]
TO DISK = N'$backupPath3'
WITH INIT, FORMAT;
"@
# ... continue for each database


# -------------------------------
# Execute SQL Backups
# -------------------------------
# Use appropriate authentication method (SQL login or Windows authentication)

# Example using SQL authentication (replace placeholders accordingly)
Invoke-Sqlcmd -ServerInstance $server -Username "<SQL_USERNAME>" -Password "<SQL_PASSWORD>" -Query $sql1 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "<SQL_USERNAME>" -Password "<SQL_PASSWORD>" -Query $sql2 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "<SQL_USERNAME>" -Password "<SQL_PASSWORD>" -Query $sql3 -QueryTimeout 1000
# ... continue for all databases


# -------------------------------
# Compress Backup Folder to RAR
# -------------------------------

# Path to WinRAR executable (update based on installation location)
$rarPath = "C:\Program Files\WinRAR\rar.exe"

# Output archive path
$rarFilePath = "D:\SQL_BACKUP\$date.rar"

# Verify WinRAR exists and run compression
if (Test-Path $rarPath) {
    Start-Process -FilePath $rarPath -ArgumentList "a -r `"$rarFilePath`" `"$folderPath\*.*`"" -Wait -NoNewWindow

    # Small delay to ensure file is written completely
    Start-Sleep -Seconds 2

    if (Test-Path $rarFilePath) {
        # Delete the original uncompressed folder
        Remove-Item -Path $folderPath -Recurse -Force
        Write-Host "Backup completed successfully. Archive created at: $rarFilePath"
    } else {
        Write-Host "Error: RAR file not found. Backup folder retained: $folderPath"
    }
} else {
    Write-Host "Error: WinRAR not found at path $rarPath. Please verify installation path."
}


