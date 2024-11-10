#!/bin/bash

BACKUP_DIR="/path/to/backup"
TIMESTAMP=$(date +%F-%H%M%S)
FILES_TO_BACKUP=("/etc/fstab" "/etc/hosts" "/etc/passwd")

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/backup-$TIMESTAMP.tar.gz ${FILES_TO_BACKUP[@]}

echo "Backup completed: $BACKUP_DIR/backup-$TIMESTAMP.tar.gz"

