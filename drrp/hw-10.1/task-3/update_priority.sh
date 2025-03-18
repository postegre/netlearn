#!/bin/bash

# Файл приоритета
PRIORITY_FILE="/etc/keepalived/priority.conf"

# Получаем Load Average за 1 минуту
LOAD=$(awk '{print $1}' /proc/loadavg)

# Логируем для проверки
echo "$(date) - Load: $LOAD" >> /var/log/priority.log

# Базовый приоритет
BASE_PRIORITY=150

# Определяем новый приоритет
if (( $(echo "$LOAD > 3.0" | bc -l) )); then
    PRIORITY=$((BASE_PRIORITY - 80))  # Высокая нагрузка → 70
elif (( $(echo "$LOAD > 2.0" | bc -l) )); then
    PRIORITY=$((BASE_PRIORITY - 50))  # Средняя нагрузка → 100
elif (( $(echo "$LOAD > 1.0" | bc -l) )); then
    PRIORITY=$((BASE_PRIORITY - 20))  # Лёгкая нагрузка → 130
else
    PRIORITY=$BASE_PRIORITY  # Без нагрузки → 150
fi

# Логируем приоритет
echo "$(date) - New Priority: $PRIORITY" >> /var/log/priority.log

# Записываем новый приоритет
echo $PRIORITY | sudo tee $PRIORITY_FILE > /dev/null
