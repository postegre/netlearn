#!/bin/bash

REMOTE_USER="postegre"
REMOTE_HOST="192.168.10.159"
REMOTE_BACKUP_DIR="/home/postegre/backup"
SRC_DIR="$HOME/"
NOW=$(date +"%Y-%m-%d_%H-%M-%S")
DEST_DIR="daily.$NOW"
LOGFILE="$HOME/rsync_backup.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "$TIMESTAMP - Starting backup: $DEST_DIR" >> "$LOGFILE"

# Убедиться, что папка существует на сервере
ssh -i "$HOME/.ssh/id_rsa" -o IdentitiesOnly=yes "$REMOTE_USER@$REMOTE_HOST" \
"mkdir -p $REMOTE_BACKUP_DIR"

# Проверим, существует ли latest
ssh -i "$HOME/.ssh/id_rsa" -o IdentitiesOnly=yes "$REMOTE_USER@$REMOTE_HOST" \
"test -e $REMOTE_BACKUP_DIR/latest"
LINK_EXISTS=$?

# Выполняем rsync (с или без --link-dest)
if [ $LINK_EXISTS -eq 0 ]; then
  rsync -a --delete \
    -e "ssh -i $HOME/.ssh/id_rsa -o IdentitiesOnly=yes" \
    --link-dest="$REMOTE_BACKUP_DIR/latest" \
    "$SRC_DIR" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_BACKUP_DIR/$DEST_DIR" >> "$LOGFILE" 2>&1
else
  echo "$TIMESTAMP - No previous backup found. Creating full copy." >> "$LOGFILE"
  rsync -a --delete \
    -e "ssh -i $HOME/.ssh/id_rsa -o IdentitiesOnly=yes" \
    "$SRC_DIR" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_BACKUP_DIR/$DEST_DIR" >> "$LOGFILE" 2>&1
fi

if [ $? -eq 0 ]; then
    echo "$TIMESTAMP - Backup $DEST_DIR completed successfully" >> "$LOGFILE"
else
    echo "$TIMESTAMP - ERROR: Backup $DEST_DIR failed" >> "$LOGFILE"
    exit 1
fi

# Обновим latest
ssh -i "$HOME/.ssh/id_rsa" -o IdentitiesOnly=yes "$REMOTE_USER@$REMOTE_HOST" \
"ln -sfn $REMOTE_BACKUP_DIR/$DEST_DIR $REMOTE_BACKUP_DIR/latest"

# Удалим только старые директории, latest не трогаем
ssh -i "$HOME/.ssh/id_rsa" -o IdentitiesOnly=yes "$REMOTE_USER@$REMOTE_HOST" \
"cd $REMOTE_BACKUP_DIR && \
find . -maxdepth 1 -type d -name 'daily.*' | sort -r | tail -n +6 | xargs -r rm -rf --" >> "$LOGFILE" 2>&1

echo "$TIMESTAMP - Backup complete" >> "$LOGFILE"
