# Linux Health Check & Backup Automation

A lightweight Bash script that monitors system health, creates timestamped configuration backups, and automatically prunes archives older than seven days.

---

## Repository Structure

```
linux-health-check-automation/
├── health_check.sh       # Main automation script
├── app-config/
│   └── app.conf          # Sample application configuration
├── logs/                 # Health-check log files (git-ignored)
├── backups/              # Compressed backup archives (git-ignored)
├── .gitignore
└── README.md
```

---

## What the Script Checks

| Check | Command used | Details |
|---|---|---|
| **Disk usage** | `df -h /` | Human-readable usage for the root filesystem |
| **Memory usage** | `free -h` | Total, used, free RAM and swap |
| **System uptime** | `uptime` | How long the system has been running + load averages |
| **CPU load average** | `/proc/loadavg` | 1, 5, 15-minute averages |
| **Top 5 processes** | `ps aux --sort=-%mem` | Highest memory-consuming processes |

---

## How Backups Work

1. The script compresses the entire `app-config/` directory into a `.tar.gz` archive inside `backups/`.
2. Archives are named `app-config-YYYYMMDD-HHMMSS.tar.gz` for easy chronological sorting.
3. On every run, archives **older than 7 days** are automatically deleted using `find … -mtime +7 -delete`.

---

## Prerequisites

- A Linux system (or WSL 2 on Windows with Ubuntu installed)
- Bash 4+
- Standard GNU coreutils (`df`, `free`, `uptime`, `tar`, `find`, `ps`)

---

## How to Run

### 1 — Clone the repository

```bash
git clone https://github.com/<your-username>/linux-health-check-automation.git
cd linux-health-check-automation
```

### 2 — Make the script executable

```bash
chmod +x health_check.sh
```

### 3 — Run it manually

```bash
./health_check.sh
```

### 4 — Inspect the output

```bash
# View today's log
cat logs/health-$(date +%F).log

# List backup archives
ls -lh backups/
```

---

## Sample Output

```
[2025-10-21 18:30:01] Starting Linux health check
────────────────────────────────────────────────────────────
[2025-10-21 18:30:01] DISK USAGE (root filesystem):
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G  8.3G   39G  18% /
────────────────────────────────────────────────────────────
[2025-10-21 18:30:01] MEMORY USAGE:
               total        used        free      shared  buff/cache   available
Mem:           7.7Gi       1.2Gi       5.1Gi        12Mi       1.4Gi       6.3Gi
Swap:          2.0Gi          0B       2.0Gi
────────────────────────────────────────────────────────────
[2025-10-21 18:30:01] SYSTEM UPTIME:
 18:30:01 up 2 days,  4:13,  1 user,  load average: 0.08, 0.04, 0.01
────────────────────────────────────────────────────────────
[2025-10-21 18:30:01] Creating backup: /home/user/linux-health-check-automation/backups/app-config-20251021-183001.tar.gz
[2025-10-21 18:30:01] Backup created successfully (size: 4.0K)
────────────────────────────────────────────────────────────
[2025-10-21 18:30:01] Pruning backups older than 7 days…
[2025-10-21 18:30:01] Pruning complete – 0 old backup(s) removed
────────────────────────────────────────────────────────────
[2025-10-21 18:30:01] Health check completed successfully
[2025-10-21 18:30:01] Log file: /home/user/linux-health-check-automation/logs/health-2025-10-21.log
```

---

## Step 5 — Automated Scheduling with Cron

Schedule the script to run **every day at 06:00** so health checks happen automatically:

```bash
# Open your crontab
crontab -e
```

Add this line at the bottom (adjust the path if needed):

```cron
0 6 * * * /home/$USER/linux-health-check-automation/health_check.sh >> /home/$USER/linux-health-check-automation/logs/cron.log 2>&1
```

| Field | Value | Meaning |
|---|---|---|
| `0` | minute | At minute 0 |
| `6` | hour | At 06:00 AM |
| `* * *` | day/month/weekday | Every day |

Verify the cron job was saved:

```bash
crontab -l
```

---

## License

MIT — free to use and modify.
