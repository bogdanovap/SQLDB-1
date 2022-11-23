# Домашнее задание к занятию "`Работа с данными (DDL/DML)`" - `Богданов Александр`

### Задание 1
- 1.3 Выполните запрос на получение списка пользователей в Базе Данных. (скриншот)
![список пользователей](\images\1-3.svg)

- 1.5 Выполните запрос на получение списка прав для пользователя sys_temp. (скриншот)
![права пользователя](\images\1-5.svg)

- 1.8 При работе в IDE сформируйте ER-диаграмму получившейся базы данных.(скриншот)
![er-диаграмма](\images\1-8.svg)

Список запросов к БД в [файле](hw_01.sql)


### Задание 2
Составьте таблицу, используя любой текстовый редактор или Excel, в которой должно быть два столбца, в первом должны быть названия таблиц восстановленной базы, во втором названия первичных ключей этих таблиц. Пример: (скриншот / текст)
```
Название таблицы 	| Название первичного ключа
actor			 	| actor_id
address			 	| address_id
category		 	| category_id
city			 	| city_id
country			 	| country_id
customer         	| customer_id
film	        	| film_id
film_actor       	| actor_id, film_id
film_category    	| film_id, category_id
film_text        	| film_id
inventory        	| inventory_id
language	     	| language_id
payment			 	| payment_id
rental				| rental_id
staff				| staff_id
store				| store_id

```