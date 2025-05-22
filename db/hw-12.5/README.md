Домашнее задание к занятию «Индексы»


**Задание 1**
Напишите запрос к учебной базе данных, который вернёт процентное отношение общего размера всех индексов к общему размеру всех таблиц.


![Задание 1.1](https://github.com/postegre/netlearn/blob/main/db/hw-12.5/Task-1.1.png)


**Задание 2**
Выполните explain analyze следующего запроса:

select distinct concat(c.last_name, ' ', c.first_name), sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id and i.inventory_id = r.inventory_id
перечислите узкие места;
оптимизируйте запрос: внесите корректировки по использованию операторов, при необходимости добавьте индексы.


![Задание 2.1](https://github.com/postegre/netlearn/blob/main/db/hw-12.5/task-2/Task-2.1.png)
Сыылка на вывод отформатированного но не оптимизированного запроса: https://github.com/postegre/netlearn/blob/main/db/hw-12.5/task-2/not_optimized_output


![Задание 1.1](https://github.com/postegre/netlearn/blob/main/db/hw-12.5/task-2/Task-2.2.png)
Ссылка на вывод запроса с EXPLAIN ANALYSE: https://github.com/postegre/netlearn/blob/main/db/hw-12.5/task-2/explain_analyze_output

![Задание 1.1](https://github.com/postegre/netlearn/blob/main/db/hw-12.5/task-2/Task-2.3.png)
Ссылка на вывод оптимизированного запроса: https://github.com/postegre/netlearn/blob/main/db/hw-12.5/task-2/optimized_output


Узкие места:
❌ Старый синтаксис JOIN: FROM a, b, c WHERE ... — это плохо читается и затрудняет оптимизацию. Лучше использовать JOIN ... ON.

❌ Функция DATE(p.payment_date) в WHERE:

Приводит к тому, что индексы по payment_date не используются, т.к. обернуты в колонку функцией. Это сильно замедляет фильтрацию.

❌ Нет условий соединения с film f:

film f участвует, но в WHERE нет никакой связи f.film_id = ....

Это приводит к декартовому произведению — все строки всех фильмов комбинируются со всем остальным.

❌ DISTINCT + оконная функция:

Использование DISTINCT с оконной функцией зачастую избыточно и приводит к двойной работе.


**Задание 3***
Самостоятельно изучите, какие типы индексов используются в PostgreSQL. Перечислите те индексы, которые используются в PostgreSQL, а в MySQL — нет.

Приведите ответ в свободной форме.


**Решение:**


В PostgreSQL, помимо стандартных B-Tree и Hash индексов, поддерживаются дополнительные мощные типы индексов, которые отсутствуют в MySQL:

GIN — используется для поиска внутри массивов, JSON, tsvector, особенно полезен при полнотекстовом поиске.

GiST — применяется для работы с геоданными, диапазонами и структурированными типами.

SP-GiST — оптимален для иерархий, расстояний, других нестандартных структур.

BRIN — индекс по диапазонам блоков, экономит память на больших таблицах.

Эти типы индексов делают PostgreSQL более гибким для сложных структур и запросов, в то время как MySQL ориентирован больше на классический реляционный подход и менее расширяем по части индексации.
