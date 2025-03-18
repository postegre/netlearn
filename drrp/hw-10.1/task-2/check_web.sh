#!/bin/bash

WEB_IP="192.168.56.15"
PORT="80"
WEB_ROOT="/var/www/html/index.nginx-debian.html"

# Проверка доступности порта
nc -zv $WEB_IP $PORT > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Порт $PORT недоступен!"
    exit 1
fi

# Проверка существования index.html
if [ ! -f "$WEB_ROOT" ]; then
    echo "Файл index.html отсутствует!"
    exit 1
fi

# Если всё ок
exit 0
