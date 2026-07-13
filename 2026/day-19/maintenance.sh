#!/bin/bash

set -e

LOGFILE="$HOME/90DaysOfDevOps/2026/day-19/maintenance.log"

echo "==========================================" >> "$LOGFILE"
echo "$(date): Starting Maintenance" >> "$LOGFILE"

echo "$(date): Running Log Rotation..." >> "$LOGFILE"
./log_rotate.sh logs >> "$LOGFILE" 2>&1

echo "$(date): Running Backup..." >> "$LOGFILE"
./backup.sh logs backups >> "$LOGFILE" 2>&1

echo "$(date): Maintenance Completed Successfully." >> "$LOGFILE"
echo "==========================================" >> "$LOGFILE"
