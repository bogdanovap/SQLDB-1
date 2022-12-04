explain analyze
select distinct
    concat(c.last_name, ' ', c.first_name),
    sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where
    date(p.payment_date) = '2005-07-30'
    and p.payment_date = r.rental_date
    and r.customer_id = c.customer_id
    and i.inventory_id = r.inventory_id
;

/*
РЕЗУЛЬТАТ ЗАПРОСА
 -> Table scan on <temporary>  (cost=2.50..2.50 rows=0) (actual time=10229.161..10229.214 rows=391 loops=1)
    -> Temporary table with deduplication  (cost=0.00..0.00 rows=0) (actual time=10229.159..10229.159 rows=391 loops=1)
        -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY c.customer_id,f.title )   (actual time=4048.075..9799.878 rows=642000 loops=1)
            -> Sort: c.customer_id, f.title  (actual time=4048.016..4175.378 rows=642000 loops=1)
                -> Stream results  (cost=21648276.28 rows=15587935) (actual time=16.579..3056.066 rows=642000 loops=1)
                    -> Nested loop inner join  (cost=21648276.28 rows=15587935) (actual time=16.571..2567.232 rows=642000 loops=1)
                        -> Nested loop inner join  (cost=20073894.84 rows=15587935) (actual time=13.162..2346.519 rows=642000 loops=1)
                            -> Nested loop inner join  (cost=18499513.41 rows=15587935) (actual time=9.543..2063.789 rows=642000 loops=1)
                                -> Inner hash join (no condition)  (cost=1540399.19 rows=15400000) (actual time=7.396..132.817 rows=634000 loops=1)
                                    -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1.83 rows=15400) (actual time=2.534..21.691 rows=634 loops=1)
                                        -> Table scan on p  (cost=1.83 rows=15400) (actual time=2.519..18.943 rows=16044 loops=1)
                                    -> Hash
                                        -> Covering index scan on f using idx_title  (cost=112.00 rows=1000) (actual time=4.328..4.765 rows=1000 loops=1)
                                -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=1.00 rows=1) (actual time=0.002..0.003 rows=1 loops=634000)
                            -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.00 rows=1) (actual time=0.000..0.000 rows=1 loops=642000)
                        -> Single-row covering index lookup on i using PRIMARY (inventory_id=r.inventory_id)  (cost=0.00 rows=1) (actual time=0.000..0.000 rows=1 loops=642000)
 */

/*
АНАЛИЗ 1
Данная операция имеет максимальную стоимость и время выполнения
Причина - отсутствуют связи таблицы f  с другими таблицы.
-> Inner hash join (no condition)  (cost=1540399.19 rows=15400000) (actual time=7.396..132.817 rows=634000 loops=1)
    -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1.83 rows=15400) (actual time=2.534..21.691 rows=634 loops=1)
        -> Table scan on p  (cost=1.83 rows=15400) (actual time=2.519..18.943 rows=16044 loops=1)
    -> Hash
        -> Covering index scan on f using idx_title  (cost=112.00 rows=1000) (actual time=4.328..4.765 rows=1000 loops=1)

Попробуем оптимизировать запрос и исключить лишние таблицы
В оконной функции используются поля двух таблиц - invetory и film
Однако, мы можем заменить эти поля на поля из таблицы rental:
- customer.customer_id -> rental.customer_id
- film.film_id -> rental.inventory_id
*/
explain analyze
select distinct
    concat(c.last_name, ' ', c.first_name),
    sum(p.amount) over (partition by r.customer_id, r.inventory_id)
from rental r
    inner join payment p on r.rental_id = p.rental_id
    inner join customer c on r.customer_id = c.customer_id
where
    date(r.rental_date) = '2005-07-30'
;
/*
-> Table scan on <temporary>  (cost=2.50..2.50 rows=0) (actual time=18.767..18.921 rows=599 loops=1)
    -> Temporary table with deduplication  (cost=0.00..0.00 rows=0) (actual time=18.765..18.765 rows=599 loops=1)
        -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY r.customer_id,r.inventory_id )   (actual time=15.814..18.269 rows=634 loops=1)
            -> Sort: r.customer_id, r.inventory_id  (actual time=15.791..15.939 rows=634 loops=1)
                -> Stream results  (cost=12830.65 rows=16008) (actual time=4.270..15.388 rows=634 loops=1)
                    -> Nested loop inner join  (cost=12830.65 rows=16008) (actual time=4.262..14.818 rows=634 loops=1)
                        -> Nested loop inner join  (cost=7227.85 rows=16008) (actual time=4.246..11.349 rows=634 loops=1)
                            -> Filter: (cast(r.rental_date as date) = '2005-07-30')  (cost=1625.05 rows=16008) (actual time=4.228..9.540 rows=634 loops=1)
                                -> Covering index scan on r using rental_date  (cost=1625.05 rows=16008) (actual time=0.054..6.826 rows=16044 loops=1)
                            -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.25 rows=1) (actual time=0.003..0.003 rows=1 loops=634)
                        -> Index lookup on p using fk_payment_rental (rental_id=r.rental_id)  (cost=0.25 rows=1) (actual time=0.004..0.005 rows=1 loops=634)
*/
 /*
АНАЛИЗ 2
Мы видим что время выполнения запроса сократилось 10229.214 => 18.921
Самая "дорогая" часть запроса:
    - фильтрация данных по дате, т.к. выполняется преобразование типа, что приводит к отключению индекса.
В этой таблице уже есть кластерный индекс, включающий поле rental_date.
Однако, поскольку мы поменяли запрос, целесообразно добавить отдельный индекс только на rental_date
-> Nested loop inner join  (cost=7227.85 rows=16008) (actual time=4.246..11.349 rows=634 loops=1)
    -> Filter: (cast(r.rental_date as date) = '2005-07-30')  (cost=1625.05 rows=16008) (actual time=4.228..9.540 rows=634 loops=1)
        -> Covering index scan on r using rental_date  (cost=1625.05 rows=16008) (actual time=0.054..6.826 rows=16044 loops=1)
    -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.25 rows=1) (actual time=0.003..0.003 rows=1 loops=634)
*/
create index rental_date_only on rental (rental_date asc);
explain analyze
select distinct
    concat(c.last_name, ' ', c.first_name),
    sum(p.amount) over (partition by r.customer_id, r.inventory_id)
from rental r
    inner join payment p on r.rental_id = p.rental_id
    inner join customer c on r.customer_id = c.customer_id
where
    r.rental_date between '2005-07-30' and '2005-07-31'
;

/*
-> Table scan on <temporary>  (cost=2.50..2.50 rows=0) (actual time=11.105..11.202 rows=599 loops=1)
    -> Temporary table with deduplication  (cost=0.00..0.00 rows=0) (actual time=11.104..11.104 rows=599 loops=1)
        -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY r.customer_id,r.inventory_id )   (actual time=8.781..10.743 rows=634 loops=1)
            -> Sort: r.customer_id, r.inventory_id  (actual time=8.762..8.897 rows=634 loops=1)
                -> Stream results  (cost=572.61 rows=634) (actual time=0.087..8.274 rows=634 loops=1)
                    -> Nested loop inner join  (cost=572.61 rows=634) (actual time=0.080..7.622 rows=634 loops=1)
                        -> Nested loop inner join  (cost=350.71 rows=634) (actual time=0.056..3.520 rows=634 loops=1)
                            -> Filter: (r.rental_date between '2005-07-30' and '2005-07-31')  (cost=128.81 rows=634) (actual time=0.041..1.375 rows=634 loops=1)
                                -> Covering index range scan on r using rental_date over ('2005-07-30 00:00:00' <= rental_date <= '2005-07-31 00:00:00')  (cost=128.81 rows=634) (actual time=0.036..0.702 rows=634 loops=1)
                            -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.25 rows=1) (actual time=0.003..0.003 rows=1 loops=634)
                        -> Index lookup on p using fk_payment_rental (rental_id=r.rental_id)  (cost=0.25 rows=1) (actual time=0.005..0.006 rows=1 loops=634)

 */

 /*
  в результате
    скорость выполнения запроса вновь сократилая - до примерно 11мс
    цена операции фильтрации снизилась в несколько раз до примерно 128.81
*/