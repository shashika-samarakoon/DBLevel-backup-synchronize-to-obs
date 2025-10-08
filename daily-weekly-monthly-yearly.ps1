# ==============================
# SQL Backup Script with OBS Upload
# ==============================

# Parameters
$server = "localhost"                     # Adjust if needed
$databases = "dba.stackexchange.com"
$rarPath = "C:\Program Files\WinRAR\rar.exe"
$obsutilPath = "C:\Users\Administrator\Downloads\obsutil_windows_amd64_5.7.3\obsutil.exe"   # Adjust if obsutil installed elsewhere

# Determine backup type
$today = Get-Date
$backupType = "Daily"   # Default
if ($today.DayOfWeek -eq "Sunday") { $backupType = "Weekly" }
if ($today.Day -eq 28) { $backupType = "Monthly" }
if ($today.Day -eq 31 -and $today.Month -eq 12) { $backupType = "Yearly" }

# Create folder paths
$date = Get-Date -Format yyyy-MM-dd
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$folderPath = "C:\SQL_Backup\$backupType\$date"
New-Item -ItemType Directory -Path $folderPath -Force | Out-Null

# Backup each database
foreach ($db in $databases) {
    $backupPath = "$folderPath\${db}_${backupType}_$timestamp.bak"
    $sql = @"
    BACKUP DATABASE [$db]
    TO DISK = N'$backupPath'
    WITH INIT, FORMAT;
"@
    Invoke-Sqlcmd -ServerInstance $server -Username "sa" -Password "user@1234" -Query $sql -QueryTimeout 300
}

# Compress to RAR file
$rarFilePath = "C:\SQL_Backup\$backupType\${date}_${backupType}.rar"

if (Test-Path $rarPath) {
    Start-Process -FilePath $rarPath -ArgumentList "a -r `"$rarFilePath`" `"$folderPath\*.*`"" -Wait -NoNewWindow
    Start-Sleep -Seconds 2

    if (Test-Path $rarFilePath) {
        # Remove the raw .bak folder after compression
        Remove-Item -Path $folderPath -Recurse -Force

        # Upload to OBS
        $obsFolderPath = "obs://shashika/sql-backups/$backupType/"
        Write-Host "Uploading $rarFilePath → $obsFolderPath ..."
        & "$obsutilPath" cp "$rarFilePath" "$obsFolderPath" -f -e obs.as-south-210.orel.cloud

        # Verify upload and cleanup
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Upload successful → Removing local RAR file."
            Remove-Item -Path $rarFilePath -Force
        } else {
            Write-Host "Upload failed → Keeping local copy: $rarFilePath"
        }
    } else {
        Write-Host "[$backupType] RAR creation failed, folder retained: $folderPath"
    }
} else {
    Write-Host "WinRAR not found at $rarPath. Please install or update the path."
}
