--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select
	concat_ws(' ',
	first_name,
	last_name) as "Customer name",
	a.address,
	c2.city ,
	c3.country
from
	customer c
join address a on
	c.address_id = a.address_id
join city c2 on
	a.city_id = c2.city_id
join country c3 on
	c2.country_id = c3.country_id 


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select
	store_id as "ID магазина",
	count(*) as "Количество покупателей"
from
	customer c
group by
	store_id 


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select
	store_id as ID,
	count(*) as CNT
from
	customer c
group by
	store_id
having
	count(*) > 300


-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select
	c.store_id as "ID магазина",
	c.cnt as "Количество покупателей",
	c2.city as "Город",
	concat_ws(' ',
	s2.first_name ,
	s2.last_name) as "Имя сотрудника"
from
	(
	select
		store_id,
		count(*) as cnt
	from
		customer c
	group by
		store_id
	having
		count(*) > 300) as c
join store s on
	c.store_id = s.store_id
join address a on
	s.address_id = a.address_id
join city c2 on
	a.city_id = c2.city_id
join staff s2 on
	c.store_id = s2.store_id 


--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select
	concat_ws(' ',
	c.first_name ,
	c.last_name),
	t.cnt
from
	(
	select
		customer_id ,
		count(*)as cnt
	from
		rental
	group by
		customer_id) as t
join customer c on
	t.customer_id = c.customer_id
order by
	t.cnt desc
limit 5


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select
	concat_ws(' ',
	c2.first_name,
	c2.last_name) as "Имя и Фамилия покупателя" ,
	t.cnt as "Количество фильмов",
	round(t.sum_pay) as "Общая стоимость платежей",
	t.min_pay as "Минимальная стоимость платежа",
	t.max_pay as "Максимальная стоимость платежа"
from
	customer c2
join 
	(
	select
		c.customer_id ,
		count(*) as cnt,
		sum(amount) sum_pay,
		min(amount) min_pay,
		max(amount) max_pay
	from
		customer c
	join rental r on
		c.customer_id = r.customer_id
	join payment p on
		r.rental_id = p.rental_id
	group by
		c.customer_id) as t
	on
	c2.customer_id = t.customer_id
	
	
--ЗАДАНИЕ №5
--Используя данные из таблицы городов, составьте все возможные пары городов так, чтобы 
--в результате не было пар с одинаковыми названиями городов. Решение должно быть через Декартово произведение.
 select
	c.city,
	c2.city
from
	city c,
	city c2
where
	c.city != c2.city 

 
--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и 
--дате возврата (поле return_date), вычислите для каждого покупателя среднее количество 
--дней, за которые он возвращает фильмы. В результате должны быть дробные значения, а не интервал.
 select
	customer_id,
	round(avg(((DATE_PART('day', return_date - rental_date) * 24 + 
	DATE_PART('hour', return_date - rental_date)) * 60 + 
	DATE_PART('minute', return_date - rental_date))/ 1440)::numeric,
	2)
from
	rental r
group by
	customer_id
order by
	customer_id 


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select
	f2.title,
	f2.rating,
	c."name",
	f2.release_year,
	l."name",
	case 
		when t.cnt is null then 0
		else t.cnt
	end,
	case 
		when t.sum_pay is null then 0
		else t.sum_pay
	end
from
	film f2
left join
(
	select
		i.film_id,
		count(*) as cnt ,
		sum(p.amount) as sum_pay
	from
		inventory i
	join rental r on
		i.inventory_id = r.inventory_id
	join payment p on
		r.rental_id = p.rental_id
	group by
		i.film_id) t on
	f2.film_id = t.film_id
join film_category fc on
	f2.film_id = fc.film_id
join category c on
	fc.category_id = c.category_id
join "language" l on
	f2.language_id = l.language_id 
	
	
	
--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd дисках.
select
	f2.title,
	f2.rating,
	c."name",
	f2.release_year,
	l."name",
	case 
		when t.cnt is null then 0
		else t.cnt
	end,
	case 
		when t.sum_pay is null then 0
		else t.sum_pay
	end
from
	film f2
left join
(
	select
		i.film_id,
		count(*) as cnt ,
		sum(p.amount) as sum_pay
	from
		inventory i
	join rental r on
		i.inventory_id = r.inventory_id
	join payment p on
		r.rental_id = p.rental_id
	group by
		i.film_id) t on
	f2.film_id = t.film_id
join film_category fc on
	f2.film_id = fc.film_id
join category c on
	fc.category_id = c.category_id
join "language" l on
	f2.language_id = l.language_id
left join inventory i2 on
	f2.film_id = i2.film_id
where
	i2.inventory_id is null
	
	

--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select
	p.staff_id as "ID продавца",
	count(*) as "Количесвто продаж",
	case
		when count(*) > 7300 then 'Премия'
		else 'Нет премии'
	end
from
	payment p
group by
	p.staff_id




