import sys
import os
import re

if (sys.argv[1] == '-ping'):  # Если -ping
    result = os.popen("ping -c 1 " + sys.argv[2]).read()  # Делаем пинг
    result = re.findall(r"time=(.*) ms", result)  # Выдёргиваем из результата время
    print(result[0])  # Выводим результат в консоль

elif (sys.argv[1] == '-simple_print'):  # Если simple_print
    print(sys.argv[2])  # Выводим в консоль содержимое sys.argv[2]

else:  # Во всех остальных случаях
    print("Запрос в консоль.")
