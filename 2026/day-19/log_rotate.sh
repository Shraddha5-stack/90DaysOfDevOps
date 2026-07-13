#!/bin/bash

# Exit if any command fails
set -e

# Check if the user has provided a directory
if [ $# -ne 1 ]; then
    echo "Usage: $0 <log_directory>"
    exit 1
fi

# Store the directory name
LOG_DIR=$1

# Check whether the directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory '$LOG_DIR' does not exist."
    exit 1
fi

echo "Log Directory: $LOG_DIR"

# Count old .log files
COMPRESS_COUNT=$(find "$LOG_DIR" -type f -name "*.log" -mtime +7 | wc -l)

# Compress old log files
find "$LOG_DIR" -type f -name "*.log" -mtime +7 -exec gzip {} \;

# Count old .gz files
DELETE_COUNT=$(find "$LOG_DIR" -type f -name "*.gz" -mtime +30 | wc -l)

# Delete old compressed files
find "$LOG_DIR" -type f -name "*.gz" -mtime +30 -delete

echo "------------------------------------"
echo "Compressed files : $COMPRESS_COUNT"
echo "Deleted files    : $DELETE_COUNT"
echo "Log Rotation Completed Successfully!"
