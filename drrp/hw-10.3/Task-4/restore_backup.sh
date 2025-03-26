#!/bin/bash

REMOTE_USER="postegre"
REMOTE_HOST="192.168.10.159"
REMOTE_BACKUP_DIR="/home/vagrant/backup"
RESTORE_TARGET="$HOME"
LOGFILE="/var/log/rsync_backup.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Получить список доступных копий
echo "Доступные резервные копии:"
ssh "$REMOTE_USER@$REMOTE_HOST" "ls -1 $REMOTE_BACKUP_DIR | grep '^daily\.'" | nl

read -p "Введите номер копии для восстановления: " CHOICE

SELECTED=$(ssh "$REMOTE_USER@$REMOTE_HOST" "ls -1 $REMOTE_BACKUP_DIR | grep '^daily\.'" | sed -n "${CHOICE}p")

if [ -z "$SELECTED" ]; then
    echo "Неверный выбор."
    echo "$TIMESTAMP - ERROR: Invalid restore choice" >> "$LOGFILE"
    exit 1
fi

echo "$TIMESTAMP - Starting restore from $SELECTED" >> "$LOGFILE"

rsync -a --delete "$REMOTE_USER@$REMOTE_HOST:$REMOTE_BACKUP_DIR/$SELECTED/" "$RESTORE_TARGET/" >> "$LOGFILE" 2>&1

if [ $? -eq 0 ]; then
    echo "$TIMESTAMP - Restore from $SELECTED completed successfully" >> "$LOGFILE"
else
    echo "$TIMESTAMP - ERROR: Restore from $SELECTED failed" >> "$LOGFILE"
    exit 1
fi
