-- 1.2 Создайте учетную запись sys_temp.
-- drop user 'sys_temp'
CREATE USER 'sys_temp'@'%' IDENTIFIED WITH mysql_native_password BY 'password';

-- 1.3 Выполните запрос на получение списка пользователей в Базе Данных. (скриншот)
select * from mysql.user;

-- 1.4 Дайте все права для пользователя sys_temp.
grant all privileges on *.* to 'sys_temp'@'%';

-- 1.5 Выполните запрос на получение списка прав для пользователя sys_temp. (скриншот)
show grants for sys_temp;


