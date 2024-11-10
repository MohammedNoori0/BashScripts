#!/bin/bash

LOG_DIR="/var/log"
ARCHIVE_DIR="/var/log/archive"
DAYS=30

mkdir -p $ARCHIVE_DIR
find $LOG_DIR -type f -name "*.log" -mtime +$DAYS -exec mv {} $ARCHIVE_DIR \;

echo "Logs older than $DAYS days have been moved to $ARCHIVE_DIR."

