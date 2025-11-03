# -------------------------------
# Define Local Folder and OBS Bucket
# -------------------------------

# Local directory containing .rar backup files
$localFolder = "D:\SQL_BACKUP"            # Replace with your actual backup folder path

# Target OBS bucket name
$bucket = "your-obs-bucket-name"          # Example: "my-backup-bucket"


# -------------------------------
# Retrieve .rar Files
# -------------------------------

# Get all .rar files in the specified folder
$rarFiles = Get-ChildItem -Path $localFolder -Filter *.rar -File


# -------------------------------
# Validate obsutil Availability
# -------------------------------

# Check whether obsutil is installed and available in the system path
if (-not (Get-Command obsutil -ErrorAction SilentlyContinue)) {
    Write-Host "obsutil is not found in system path. Please check the installation." -ForegroundColor Red
    return
}


# -------------------------------
# Upload Each File to OBS
# -------------------------------

foreach ($file in $rarFiles) {
    $localFilePath = $file.FullName
    $obsPath = "obs://$bucket/$($file.Name)"   # Construct the OBS path for each file

    Write-Host "`nUploading $localFilePath to $obsPath ..."

    # Perform upload using obsutil command
    $uploadOutput = & obsutil cp "$localFilePath" "$obsPath"

    # Check upload result based on obsutil output
    if ($uploadOutput -match "upload.*successfully" -or $uploadOutput -match "succeed") {
        Write-Host "Upload successful. Deleting local file: $localFilePath"
        Remove-Item -Path $localFilePath -Force
    } else {
        Write-Host "Upload failed for $localFilePath. File not deleted." -ForegroundColor Red
    }
}


###############################################################################
# End of Script
###############################################################################
