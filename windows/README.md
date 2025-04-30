# GitLab Backup & Restore Scripts (PowerShell)

This repository contains two PowerShell scripts to **backup** and **restore** a self-hosted GitLab instance running in a Docker container on Windows.

## 📁 Scripts

- `gitlab-backup.ps1`: Backs up GitLab data, config, and Docker image.
- `gitlab-restore.ps1`: Restores GitLab from a previously created backup.

---

## ⚙️ Prerequisites

- Windows OS with PowerShell
- Docker installed and running
- GitLab running inside a Docker container
- Administrator/privileged PowerShell session

---

## 📦 Backup Script

### 🔄 Script: `gitlab-backup.ps1`

This script:
- Executes GitLab's internal backup
- Copies the backup archive from the container to your host
- Copies essential GitLab config files
- Optionally saves the GitLab Docker image for disaster recovery

### ▶️ Usage

```powershell
.\gitlab-backup.ps1
```

### 📥 Inputs Prompted

- Backup destination folder (e.g., `C:\Backup`)
- GitLab data directory (e.g., `C:\GitLab\data`)

### 🗂 Output

A backup folder is created with:
- GitLab backup archive (`gitlab_backup_*.tar`)
- `gitlab.rb`, `gitlab-secrets.json`
- Docker image of GitLab container (optional, for DR)

---

## ♻️ Restore Script

### 🔁 Script: `gitlab-restore.ps1`

This script:
- Stops any existing GitLab container
- Loads the GitLab Docker image
- Starts a new GitLab container with previous volumes
- Restores configuration and database

### ▶️ Usage

```powershell
.\gitlab-restore.ps1
```

### 📥 Inputs Prompted

- Path to the backup folder (from the backup script)
- GitLab config, data, and log volume paths
- Name for the GitLab Docker container
- Host machine's IP address

---

## 📝 Notes

- Ensure Docker is running before executing these scripts.
- Backup files are stored under the format: `gitlab_backup_<YYYYMMDD>`.
- Config files (`gitlab.rb`, `gitlab-secrets.json`) are backed up from `/etc/gitlab/` inside the container.
- Make sure volume paths used during restore match the original setup.

---

## ✅ Example Workflow

1. Run `gitlab-backup.ps1` and store backups in `C:\Backup`.
2. If disaster strikes, run `gitlab-restore.ps1` and provide the backup directory and relevant paths.

---

## 🛡️ Disclaimer

These scripts are intended for self-hosted GitLab Docker setups on **Windows**. Use them at your own risk and always test restore procedures in non-production environments.
