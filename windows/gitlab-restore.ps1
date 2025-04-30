# Prompt for user input
$BackupDir = Read-Host "Enter the full path of the backup directory"
$GitLabConfig = Read-Host "Enter the full path for GitLab config (e.g., C:\GitLab\config)"
$GitLabData = Read-Host "Enter the full path for GitLab data (e.g., C:\GitLab\data)"
$GitLabLogs = Read-Host "Enter the full path for GitLab logs (e.g., C:\GitLab\logs)"
$ContainerName = Read-Host "Enter the name of the GitLab container"
$HostIP = Read-Host "Enter the IP address of the host (e.g., 203.192.158.123)"

# Find the latest backup file
$LatestBackup = Get-ChildItem -Path "$BackupDir\gitlab_backup_*.tar" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (!$LatestBackup) {
    Write-Host "No backup file found!"
    exit
}

Write-Host "Stopping existing GitLab container..."
docker stop $ContainerName

Write-Host "Restoring GitLab backup from $LatestBackup..."

# Load the saved image (disaster recovery)
docker load -i "$LatestBackup"

# Start a new GitLab container using the provided bind mounts
Write-Host "Starting GitLab container..."
docker run --detach --hostname $HostIP `
  --publish 443:443 --publish 80:80 --publish 22:22 `
  --name $ContainerName --restart always `
  --volume "$GitLabConfig :/etc/gitlab" `
  --volume "$GitLabData :/var/opt/gitlab" `
  --volume "$GitLabLogs :/var/log/gitlab" `
  gitlab/gitlab-ce:latest

# Restore GitLab configuration files (gitlab.rb, gitlab-secrets.json)
Write-Host "Restoring GitLab configuration files..."
$GitLabConfigFiles = @(
    "gitlab.rb",
    "gitlab-secrets.json"
)

foreach ($ConfigFile in $GitLabConfigFiles) {
    $SourcePath = "$BackupDir\$ConfigFile"
    $DestinationPath = "/etc/gitlab/$ConfigFile"
    
    # Copy configuration files back to the container
    docker cp "$SourcePath" "$ContainerName : $DestinationPath"
    Write-Host "Restored: $DestinationPath"
}

# Find the latest GitLab database backup file
$BackupFile = Get-ChildItem -Path "$BackupDir" -Filter "gitlab_backup_*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($BackupFile) {
    Write-Host "Restoring GitLab database..."
    docker exec -t $ContainerName gitlab-backup restore BACKUP=$BackupFile.Name
} else {
    Write-Host "No GitLab database backup found!"
}

Write-Host "GitLab restored successfully!"
