
#!/bin/bash

LOGFILE="/var/log/rsync/rsync.log"
LOG_TAG="daily-home-backup"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Выполняем резервное копирование
rsync -a --delete --checksum \
  --exclude='.*' \
  --exclude='*/.*' \
  /home/$USER/ /tmp/backup/ >> "$LOGFILE" 2>&1

# Проверка результата и логирование
if [ $? -eq 0 ]; then
    echo "$TIMESTAMP - Backup completed successfully" >> "$LOGFILE"
    logger -t "$LOG_TAG" "Backup completed successfully"
else
    echo "$TIMESTAMP - Backup failed" >> "$LOGFILE"
    logger -t "$LOG_TAG" "Backup failed"
fi
