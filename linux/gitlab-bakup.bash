#!/bin/bash

# Prompt for user input
read -p "Enter the full path where you want the backup to be stored (e.g., /home/user/backup): " BackupDir
Date=$(date +%Y%m%d)
BackupDir="$BackupDir/$Date"

read -p "Enter the full path for the GitLab config directory (e.g., /path/to/config): " GitLabConfig
read -p "Enter the full path for the GitLab data directory (e.g., /path/to/data): " GitLabData
read -p "Enter the full path for the GitLab logs directory (e.g., /path/to/logs): " GitLabLogs
BackupFileName="gitlab_backup_$Date.tar"
ContainerName="gitlab"

# Ensure backup directory exists
mkdir -p "$BackupDir"

echo "Starting GitLab Backup..."

# Run GitLab backup inside the container
docker exec -t $ContainerName gitlab-backup create

# Copy the backup file from /var/opt/gitlab/backups to local backup directory
BackupFile=$(docker exec $ContainerName ls /var/opt/gitlab/backups | grep "gitlab_backup")

echo "Copying GitLab backup files..."
cp "$GitLabData/backups/$BackupFile" "$BackupDir/$BackupFile"

# Backing up the configuration files (gitlab.rb, gitlab-secrets.json)
echo "Backing up GitLab configuration files..."
GitLabConfigFiles=(
    "/etc/gitlab/gitlab.rb"
    "/etc/gitlab/gitlab-secrets.json"
)

for ConfigFile in "${GitLabConfigFiles[@]}"; do
    SourcePath="/etc/gitlab/$ConfigFile"
    DestinationPath="$BackupDir/$ConfigFile"

    # Copy configuration files to backup directory
    docker cp "$ContainerName:$SourcePath" "$DestinationPath"
    echo "Backed up: $SourcePath"
done

# Save GitLab container image (optional disaster recovery)
echo "Saving GitLab Docker image..."
docker commit $ContainerName gitlab_backup
docker save -o "$BackupDir/$BackupFileName" gitlab_backup

echo "Backup completed successfully! Files stored in $BackupDir"
