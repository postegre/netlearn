Домашнее задание к занятию «Репликация и масштабирование. Часть 1»

**Задание 1**
На лекции рассматривались режимы репликации master-slave, master-master, опишите их различия.

Ответить в свободной форме.


**Master-Slave репликация**
В этой схеме есть один главный сервер — master, и один или несколько подчинённых — slaves.

Все изменения данных (записи, обновления, удаления) выполняются только на master.

Slaves получают копии изменений от master и обновляют свои данные, но не могут вносить изменения самостоятельно.

Slaves обычно используются для чтения данных, чтобы разгрузить мастер или обеспечить отказоустойчивость для чтения.

Если мастер выходит из строя, необходимо вручную или с помощью автоматических механизмов переключать роль на одного из слейвов.

Это простая и стабильная схема, хорошо подходит для масштабирования чтения и создания резервных копий.

**Master-Master репликация**
Здесь оба сервера равноправны: каждый является и master, и slave одновременно.

Оба сервера могут принимать изменения данных.

Все, что записывается на одном сервере, автоматически реплицируется на другой.

Это удобно для ситуаций, где нужно обеспечить высокую доступность: если один сервер выходит из строя, второй продолжает работать без потерь.

Но такая схема требует очень аккуратной настройки: если два пользователя одновременно внесут изменения в одну и ту же строку на разных серверах, может произойти конфликт. 
Поэтому чаще всего на практике используется разделение зон ответственности: например, один мастер обслуживает одни данные, второй — другие.


**Задание 2**
Выполните конфигурацию master-slave репликации, примером можно пользоваться из лекции.

Приложите скриншоты конфигурации, выполнения работы: состояния и режимы работы серверов.

Ссылка но docker-compose.yml: https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-2/docker-compose.yml


Docker ps![Docker ps](https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-2/Task-2.1.png)
Master Status![Master Status](https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-2/Task-2.2.png)
Replica status![Replica status](https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-2/Task-2.3.png)
Master Insert![Master Insert](https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-2/Task-2.4.png)
Slave Check![Slave Check](https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-2/Task-2.5.png)



**Задание 3***
Выполните конфигурацию master-master репликации. Произведите проверку.

Приложите скриншоты конфигурации, выполнения работы: состояния и режимы работы серверов.


Ссылка но docker-compose.yml: 


Config files![Config files](https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-3/Task-3.1.png)
Master 1 Status![Master 1 Status](https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-3/Task-3.2.png)
Master 1 Status![Master 2 Status](https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-3/Task-3.3.png)
Master Insert![Master 1 Insert](https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-3/Task-3.4.png)
Master 2 Select![Master 2 Select](https://github.com/postegre/netlearn/blob/main/db/hw-12.6/task-3/Task-3.5.png)
