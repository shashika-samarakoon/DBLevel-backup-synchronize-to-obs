# Define parameters
$server = "localhost"   # Adjust if needed
$database1 = "Attendance"
$database2 = "AuditLogPH"
$database3 = "Callcenter_DM"
$database4 = "CashVouchers"
$database5 = "CentralAccessDBPH"
$database6 = "ContactCenterPH"
$database7 = "DiscountModulePH"
$database8 = "EWallet"
$database9 = "LS_Data"
$database10 = "RestaurantPH"
$database11 = "SMS"


# Create timestamp for filename
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$date = Get-Date -Format yyyy-MM-dd
$folderPath = "E:\SQL_BACKUP\$date"
New-Item -ItemType Directory -Path $folderPath -Force | Out-Null

# Set the backup file path with timestamp
$backupPath1 = "E:\SQL_BACKUP\$date\${database1}_backup_$timestamp.bak"
$backupPath2 = "E:\SQL_BACKUP\$date\${database2}_backup_$timestamp.bak"
$backupPath3 = "E:\SQL_BACKUP\$date\${database3}_backup_$timestamp.bak"
$backupPath4 = "E:\SQL_BACKUP\$date\${database4}_backup_$timestamp.bak"
$backupPath5 = "E:\SQL_BACKUP\$date\${database5}_backup_$timestamp.bak"
$backupPath6 = "E:\SQL_BACKUP\$date\${database6}_backup_$timestamp.bak"
$backupPath7 = "E:\SQL_BACKUP\$date\${database7}_backup_$timestamp.bak"
$backupPath8 = "E:\SQL_BACKUP\$date\${database8}_backup_$timestamp.bak"
$backupPath9 = "E:\SQL_BACKUP\$date\${database9}_backup_$timestamp.bak"
$backupPath10 = "E:\SQL_BACKUP\$date\${database10}_backup_$timestamp.bak"
$backupPath11 = "E:\SQL_BACKUP\$date\${database11}_backup_$timestamp.bak"

# SQL command
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

$sql4 = @"
BACKUP DATABASE [$database4]
TO DISK = N'$backupPath4'
WITH INIT, FORMAT;
"@

$sql5 = @"
BACKUP DATABASE [$database5]
TO DISK = N'$backupPath5'
WITH INIT, FORMAT;
"@

$sql6 = @"
BACKUP DATABASE [$database6]
TO DISK = N'$backupPath6'
WITH INIT, FORMAT;
"@

$sql7 = @"
BACKUP DATABASE [$database7]
TO DISK = N'$backupPath7'
WITH INIT, FORMAT;
"@

$sql8 = @"
BACKUP DATABASE [$database8]
TO DISK = N'$backupPath8'
WITH INIT, FORMAT;
"@

$sql9 = @"
BACKUP DATABASE [$database9]
TO DISK = N'$backupPath9'
WITH INIT, FORMAT;
"@

$sql10 = @"
BACKUP DATABASE [$database10]
TO DISK = N'$backupPath10'
WITH INIT, FORMAT;
"@

$sql11 = @"
BACKUP DATABASE [$database11]
TO DISK = N'$backupPath11'
WITH INIT, FORMAT;
"@

# Run SQL backup (use SQL login or Windows auth as needed)
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql1 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql2 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql3 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql4 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql5 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql6 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql7 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql8 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql9 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql10 -QueryTimeout 1000
Invoke-Sqlcmd -ServerInstance $server -Username "dbbackup" -Password "user@1234" -Query $sql11 -QueryTimeout 1000

# Create .rar file using WinRAR
$rarPath = "C:\Program Files\WinRAR\rar.exe"  # Adjust if needed
$rarFilePath = "E:\SQL_BACKUP\$date.rar"

if (Test-Path $rarPath) {
    Start-Process -FilePath $rarPath -ArgumentList "a -r `"$rarFilePath`" `"$folderPath\*.*`"" -Wait -NoNewWindow

    # Wait a moment to ensure the file is written
    Start-Sleep -Seconds 2

    if (Test-Path $rarFilePath) {
        # Delete the original backup folder
        Remove-Item -Path $folderPath -Recurse -Force
        Write-Host "Backup completed, archived to: $rarFilePath, and folder deleted."
    } else {
        Write-Host "RAR file not created. Folder not deleted: $folderPath"
    }
} else {
    Write-Host "WinRAR not found at $rarPath. Please install or check the path."
}
   
