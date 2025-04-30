# GitLab Backup & Restore Scripts (Bash)

This repository contains two Bash scripts to **backup** and **restore** a self-hosted GitLab instance running in a Docker container on Linux.

## 📁 Scripts

- `gitlab-backup.bash`: Backs up GitLab data, config, and Docker image.
- `gitlab-restore.bash`: Restores GitLab from a previously created backup.

---

## ⚙️ Prerequisites

- Linux system with Bash
- Docker installed and running
- GitLab running inside a Docker container
- Sudo/root privileges for file system access

---

## 📦 Backup Script

### 🔄 Script: `gitlab-backup.bash`

This script:
- Executes GitLab's internal backup (`gitlab-backup create`)
- Copies the backup archive from inside the container to your host
- Copies essential GitLab config files (`gitlab.rb`, `gitlab-secrets.json`)
- Saves the GitLab Docker image for disaster recovery

### ▶️ Usage

```bash
chmod +x gitlab-backup.bash
./gitlab-backup.bash
```

### 📥 Inputs Prompted

- Backup destination root directory (e.g., `/home/user/backup`)
- GitLab config directory path (e.g., `/var/opt/gitlab/config`)
- GitLab data directory path (e.g., `/var/opt/gitlab`)
- GitLab logs directory path (e.g., `/var/log/gitlab`)

### 🗂 Output

A dated backup folder is created with:
- GitLab backup archive (`gitlab_backup_*.tar`)
- `gitlab.rb`, `gitlab-secrets.json`
- Docker image of GitLab container

---

## ♻️ Restore Script

### 🔁 Script: `gitlab-restore.bash`

This script:
- Stops any running GitLab container
- Loads the GitLab Docker image backup (`docker load`)
- Starts a new GitLab container with correct volume mounts
- Restores configuration files and GitLab database

### ▶️ Usage

```bash
chmod +x gitlab-restore.bash
./gitlab-restore.bash
```

### 📥 Inputs Prompted

- Path to the backup directory (from previous backup)
- GitLab config, data, and logs volume paths
- Name for the GitLab Docker container
- Host IP address for GitLab container

---

## 📝 Notes

- Ensure Docker is installed and the daemon is running.
- Backup files follow the format: `gitlab_backup_<YYYYMMDD>`.
- Config files are backed up from `/etc/gitlab/` inside the container.
- During restoration, ensure the volume paths match your previous setup.
- The restore script uses the most recent `.tar` backup found in the backup directory.

---

## ✅ Example Workflow

1. Run `gitlab-backup.bash` and save backups in `/home/user/backup`.
2. In case of failure, run `gitlab-restore.bash` and provide the backup path and mount volumes as used earlier.

---

## 🛡️ Disclaimer

These scripts are designed for self-hosted GitLab Docker setups on **Linux**. Use them responsibly and always validate restore procedures in a test environment before applying them in production.
