# Define local folder and OBS bucket
$localFolder = "E:\SQL_BACKUP"
$bucket = "db-primary-backup"

# Get all .rar files from the folder
$rarFiles = Get-ChildItem -Path $localFolder -Filter *.rar -File

# Check if obsutil is available
if (-not (Get-Command obsutil -ErrorAction SilentlyContinue)) {
    Write-Host "obsutil is not found in system path. Please check the installation." -ForegroundColor Red
    return
}

# Loop through each .rar file
foreach ($file in $rarFiles) {
    $localFilePath = $file.FullName
    $obsPath = "obs://$bucket/$($file.Name)"

    Write-Host "`nUploading $localFilePath to $obsPath ..."

    # Upload file using obsutil and capture output
    $uploadOutput = & obsutil cp "$localFilePath" "$obsPath"

    # Check if the upload succeeded
    if ($uploadOutput -match "upload.*successfully" -or $uploadOutput -match "succeed") {
        Write-Host "Upload successful. Deleting local file: $localFilePath"
        Remove-Item -Path $localFilePath -Force
    } else {
        Write-Host "Upload failed for $localFilePath. File not deleted." -ForegroundColor Red
    }
}
