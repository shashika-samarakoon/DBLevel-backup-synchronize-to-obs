# ==============================
# SQL Backup Script with OBS Upload + SINGLE LOG FILE
# ==============================

# Parameters
$server = "localhost"
$databases = "test"
$rarPath = "C:\Program Files\WinRAR\rar.exe"
$obsutilPath = "C:\Program Files\obsutil\obsutil.exe"

# Logging Setup - Single File
$logFolder = "C:\Scripts"
$logFile = "C:\Scripts\logs.txt"

# Create log folder if not exists
if (!(Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

# Create log file if missing
if (!(Test-Path $logFile)) {
    New-Item -Path $logFile -ItemType File | Out-Null
}

function Write-Log {
    param([string]$message)
    $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

Write-Log "===================== Script Execution Started ====================="

# Determine backup type
$today = Get-Date
$backupType = "Daily"
if ($today.DayOfWeek -eq "Sunday") { $backupType = "Weekly" }
if ($today.Day -eq 1) { $backupType = "Monthly" }

Write-Log "Backup Type: $backupType"

# Create folder paths
$date = Get-Date -Format yyyy-MM-dd
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$folderPath = "C:\SQL_Backup\$backupType\$date"
New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
Write-Log "Backup folder created: $folderPath"

# Backup each database
foreach ($db in $databases) {

    # UPDATED: Backup name begins with backup type
    $backupName = "${backupType}_${db}_${timestamp}.bak"
    $backupPath = "$folderPath\$backupName"

    Write-Log "Starting backup for database: $db → $backupPath"

    $sql = @"
    BACKUP DATABASE [$db]
    TO DISK = N'$backupPath'
    WITH INIT, FORMAT;
"@

    try {
        Invoke-Sqlcmd -ServerInstance $server -Username "sa" -Password "user@1234" -Query $sql -QueryTimeout 300
        Write-Log "Backup completed successfully for $db"
    }
    catch {
        Write-Log "ERROR: Backup failed for $db → $_"
    }
}

# UPDATED: RAR file name starts with backup type
$rarFilePath = "C:\SQL_Backup\$backupType\${backupType}_${date}.rar"

if (Test-Path $rarPath) {

    Write-Log "Compressing backup folder to RAR: $rarFilePath"

    Start-Process -FilePath $rarPath -ArgumentList "a -r `"$rarFilePath`" `"$folderPath\*.*`"" -Wait -NoNewWindow
    Start-Sleep -Seconds 2

    if (Test-Path $rarFilePath) {
        Write-Log "RAR compression successful: $rarFilePath"

        Remove-Item -Path $folderPath -Recurse -Force
        Write-Log "Deleted temporary backup folder: $folderPath"

        # Upload to OBS
        $obsFolderPath = "obs://shashika/sql-backups/$backupType/"
        Write-Log "Uploading file to OBS: $obsFolderPath"

        & "$obsutilPath" cp "$rarFilePath" "$obsFolderPath" -f -e obs.as-south-210.orel.cloud

        if ($LASTEXITCODE -eq 0) {
            Write-Log "Upload successful. Removing local RAR file."
            Remove-Item -Path $rarFilePath -Force
        } else {
            Write-Log "ERROR: Upload failed. Local file retained: $rarFilePath"
        }

    } else {
        Write-Log "ERROR: RAR file creation failed. Folder retained: $folderPath"
    }

} else {
    Write-Log "ERROR: WinRAR not found at $rarPath"
}

Write-Log "===================== Script Execution Completed ====================="
Write-Log ""
