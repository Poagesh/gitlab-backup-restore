#!/bin/bash

# Prompt for user input
read -p "Enter the full path of the backup directory: " BackupDir
read -p "Enter the full path for GitLab config (e.g., /var/opt/gitlab/config): " GitLabConfig
read -p "Enter the full path for GitLab data (e.g., /var/opt/gitlab/data): " GitLabData
read -p "Enter the full path for GitLab logs (e.g., /var/opt/gitlab/logs): " GitLabLogs
read -p "Enter the name of the GitLab container: " ContainerName
read -p "Enter the IP address of the host (e.g., 203.192.158.123): " HostIP

# Find the latest backup file
LatestBackup=$(ls -t $BackupDir/gitlab_backup_*.tar | head -n 1)

if [ -z "$LatestBackup" ]; then
    echo "No backup file found!"
    exit 1
fi

echo "Stopping existing GitLab container..."
docker stop $ContainerName

echo "Restoring GitLab backup from $LatestBackup..."

# Load the saved image (disaster recovery)
docker load -i "$LatestBackup"

# Start a new GitLab container using the provided bind mounts
echo "Starting GitLab container..."
docker run --detach --hostname $HostIP \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name $ContainerName --restart always \
  --volume "$GitLabConfig:/etc/gitlab" \
  --volume "$GitLabData:/var/opt/gitlab" \
  --volume "$GitLabLogs:/var/log/gitlab" \
  gitlab/gitlab-ce:latest

# Restore GitLab configuration files (gitlab.rb, gitlab-secrets.json)
echo "Restoring GitLab configuration files..."
GitLabConfigFiles=("gitlab.rb" "gitlab-secrets.json")

for ConfigFile in "${GitLabConfigFiles[@]}"; do
    SourcePath="$BackupDir/$ConfigFile"
    DestinationPath="/etc/gitlab/$ConfigFile"
    
    # Copy configuration files back to the container
    docker cp "$SourcePath" "$ContainerName:$DestinationPath"
    echo "Restored: $DestinationPath"
done

# Find the latest GitLab database backup file
BackupFile=$(ls $BackupDir/gitlab_backup_* | sort -t_ -k3,3 -n | tail -n 1)

if [ -n "$BackupFile" ]; then
    echo "Restoring GitLab database..."
    docker exec -t $ContainerName gitlab-backup restore BACKUP=$(basename $BackupFile)
else
    echo "No GitLab database backup found!"
fi

echo "GitLab restored successfully!"
