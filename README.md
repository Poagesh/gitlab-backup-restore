# GitLab Backup and Restore Scripts

This repository contains platform-specific scripts for backing up and restoring GitLab instances on **Windows** and **Linux** systems.

---

## 🖥️ Platforms Supported

- ✅ **Linux (Ubuntu, CentOS, RHEL, etc.)**
- ✅ **Windows (PowerShell)**

---

## 📁 Directory Structure

```bash
/
├── linux/
│   ├── gitlab-backup.bash
│   └── gitlab-restore.bash
├── windows/
│   ├── gitlab-backup.ps1
│   └── gitlab-restore.ps1
└── README.md
```

---

## 📦 Backup Instructions

### 🔧 Linux

1. Navigate to the `linux` directory.
2. Run the backup script:
   ```bash
   sudo bash gitlab-backup.sh
   ```

3. Backup files will be stored in `/var/opt/gitlab/backups` by default.

### 🪟 Windows

1. Open PowerShell as Administrator.
2. Navigate to the `windows` directory.
3. Run the script:
   ```powershell
   .\gitlab-backup.ps1
   ```

4. Backup files will be stored in `C:\GitLab\backups` (or the path specified in the script).

---

## 🔁 Restore Instructions

### 🔧 Linux

1. Place your backup `.tar` file in `/var/opt/gitlab/backups`.
2. Run:
   ```bash
   sudo bash gitlab-restore.sh
   ```

3. The script will restore GitLab to the specified backup version and reconfigure services.

### 🪟 Windows

1. Copy the `.tar` backup file to `C:\GitLab\backups`.
2. Run:
   ```powershell
   .\gitlab-restore.ps1
   ```

3. The script will restore the GitLab instance from the backup.

---

## ⚠️ Important Notes

- Ensure GitLab services are **stopped before restoring** and restarted after.
- Ensure the backup file version matches the GitLab version you are restoring.
- These scripts may require admin/root privileges.
- Always test backups and restores in a staging environment before production use.

---

## 🧑‍💻 Author

Created by [Poagesh N.](https://github.com/poagesh)  
If you find this useful, give it a ⭐️ or contribute!

