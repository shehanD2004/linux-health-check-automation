#!/usr/bin/env bash
# =============================================================
#  Linux Health Check & Backup Automation
#  Author : Admin
#  Purpose: Check disk, memory, uptime; back up app-config;
#           prune backups older than 7 days.
# =============================================================

set -euo pipefail

BASE_DIR="$HOME/linux-health-check-automation"
LOG_DIR="$BASE_DIR/logs"
CONFIG_DIR="$BASE_DIR/app-config"
BACKUP_DIR="$BASE_DIR/backups"
RETENTION_DAYS=7

# ── Ensure required directories exist ──────────────────────────
mkdir -p "$LOG_DIR" "$BACKUP_DIR"

LOG_FILE="$LOG_DIR/health-$(date +%F).log"

# ── Logging helper ─────────────────────────────────────────────
log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

# ── Section divider ────────────────────────────────────────────
divider() {
    printf '%s\n' "$(printf '─%.0s' {1..60})" | tee -a "$LOG_FILE"
}

# ==============================================================
log "Starting Linux health check"
divider

# ── 1. Disk Usage ──────────────────────────────────────────────
log "DISK USAGE (root filesystem):"
df -h / | tee -a "$LOG_FILE"
divider

# ── 2. Memory Usage ────────────────────────────────────────────
log "MEMORY USAGE:"
free -h | tee -a "$LOG_FILE"
divider

# ── 3. System Uptime ───────────────────────────────────────────
log "SYSTEM UPTIME:"
uptime | tee -a "$LOG_FILE"
divider

# ── 4. CPU Load Average ────────────────────────────────────────
log "CPU LOAD AVERAGE:"
cat /proc/loadavg | tee -a "$LOG_FILE"
divider

# ── 5. Top 5 Memory-Consuming Processes ────────────────────────
log "TOP 5 PROCESSES BY MEMORY:"
ps aux --sort=-%mem | awk 'NR==1 || NR<=6' | tee -a "$LOG_FILE"
divider

# ── 6. Backup app-config ───────────────────────────────────────
BACKUP_FILE="$BACKUP_DIR/app-config-$(date +%Y%m%d-%H%M%S).tar.gz"

log "Creating backup: $BACKUP_FILE"

if tar -czf "$BACKUP_FILE" -C "$BASE_DIR" app-config/; then
    BACKUP_SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
    log "Backup created successfully (size: ${BACKUP_SIZE})"
else
    log "ERROR: Backup failed – check permissions for $CONFIG_DIR"
    exit 1
fi
divider

# ── 7. Prune old backups ───────────────────────────────────────
log "Pruning backups older than ${RETENTION_DAYS} days…"

REMOVED=0
while IFS= read -r -d '' old_file; do
    rm -f "$old_file"
    log "  Removed: $old_file"
    (( REMOVED++ )) || true
done < <(find "$BACKUP_DIR" -type f -name 'app-config-*.tar.gz' -mtime +"$RETENTION_DAYS" -print0)

log "Pruning complete – ${REMOVED} old backup(s) removed"
divider

log "Health check completed successfully"
log "Log file: $LOG_FILE"
