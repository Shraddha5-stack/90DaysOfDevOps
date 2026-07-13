#!/bin/bash

# Exit immediately if any command fails
set -e

# Check if two arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_directory> <backup_directory>"
    exit 1
fi

SOURCE=$1
DESTINATION=$2

# Check if source directory exists
if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory '$SOURCE' does not exist."
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$DESTINATION"

# Create timestamp
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# Backup file name
BACKUP_FILE="$DESTINATION/backup-$DATE.tar.gz"

# Create archive
tar -czf "$BACKUP_FILE" "$SOURCE"

# Verify backup
if [ -f "$BACKUP_FILE" ]; then
    echo "Backup created successfully!"
    echo "Backup File : $(basename "$BACKUP_FILE")"
    echo "Backup Size : $(du -h "$BACKUP_FILE" | cut -f1)"
else
    echo "Backup failed!"
    exit 1
fi

# Delete backups older than 14 days
find "$DESTINATION" -name "*.tar.gz" -mtime +14 -delete

echo "Old backups older than 14 days removed."
echo "Backup completed successfully."
