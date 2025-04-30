# Prompt for user input
$Date = Get-Date -Format "yyyyMMdd"
$BackupRoot = Read-Host "Enter the full path where you want the backup to be stored (e.g., C:\Backup)"
$BackupDir = Join-Path -Path $BackupRoot -ChildPath $Date

#$GitLabConfig = Read-Host "Enter the full path for the GitLab config directory (e.g., C:\path\to\config)"
$GitLabData = Read-Host "Enter the full path for the GitLab data directory (e.g., C:\path\to\data)"
$ContainerName = "gitlab"
$BackupFileName = "gitlab_image_$Date.tar"

# Ensure backup directory exists
if (!(Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

Write-Host "`n=== Starting GitLab Backup ===`n"

# Run GitLab backup inside the container
docker exec -t $ContainerName gitlab-backup create

# Get the latest backup filename from container
$BackupFile = docker exec $ContainerName bash -c "ls -t /var/opt/gitlab/backups | grep gitlab_backup | head -1"

if (-not $BackupFile) {
    Write-Host "No backup file found in container." -ForegroundColor Red
    exit 1
}

# Copy the backup file to local directory
$SourceBackupFile = Join-Path $GitLabData\backups $BackupFile
$DestinationBackupFile = Join-Path $BackupDir $BackupFile

Write-Host "Copying backup file: $BackupFile"
Copy-Item -Path $SourceBackupFile -Destination $DestinationBackupFile -Force

# Backing up GitLab configuration files
Write-Host "`nBacking up GitLab configuration files..."
$GitLabConfigFiles = @("gitlab.rb", "gitlab-secrets.json")

foreach ($file in $GitLabConfigFiles) {
    $ContainerPath = "/etc/gitlab/$file"
    $LocalPath = Join-Path $BackupDir $file

    docker cp "$ContainerName : $ContainerPath" "$LocalPath"
    Write-Host "✓ Backed up: $file"
}

# Save GitLab Docker image (optional disaster recovery)
Write-Host "`nSaving GitLab Docker image (optional)..."
$DockerImagePath = Join-Path $BackupDir $BackupFileName
docker commit $ContainerName gitlab_backup_temp
docker save -o $DockerImagePath gitlab_backup_temp
docker image rm gitlab_backup_temp

Write-Host "`n✅ Backup completed successfully!"
Write-Host "All files are stored in: $BackupDir"
