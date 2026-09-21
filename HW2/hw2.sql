-- All tables for this assignment were created using CSV files mentioned on Canvas, which were
-- imported into their respective relations using MySQL Workbench's Import Wizard.

create database hw2;

use hw2;

-- 1) Find the average price of pastries for each category from the pastries table.
select * from pastries;

select
	category,
    avg(price) as avg_price
from pastries
group by category
order by avg_price desc;

-- 2) Find the total number of baristas at each experience level from the baristas table.
select * from baristas;

select 
	experience_level, 
    count(*) as baristas_count
from baristas
group by experience_level
order by baristas_count desc;

-- 3) Count the total number of shops located in each city from the shops table.
select * from shops;

select
	city,
    count(*) as shops_count
from shops
group by city
order by shops_count desc;

-- 4) Find the maximum price among pastries for each category from the pastries table.
select * from pastries;

select 
	category,
    max(price) as max_price
from pastries
group by category
order by max_price desc;

-- 5) Count how many pastries have been added by each shop using the shopID column from the offers table.
select * from offers;

select 
	shopID,
    count(pastryID) as pastry_count
from offers
group by shopID
order by pastry_count desc;

-- 6) Find the name, category, and price of any pastry whose price matches the maximum price within its category.
select
	name,
    category,
    price
from pastries p1
where price = (
	select 
		max(price) 
	from pastries p2 
    where p1.category = p2.category
    )
order by price desc;

-- 7) Find the unique shop IDs from the offers table that have offered at least one pastry 
-- whose price is strictly greater than the overall average price of all pastries.
select * from offers;
select * from pastries;

select
	distinct shopID
from offers
where pastryID in (
	select
		pastryID 
	from pastries
    where price > (select avg(price) from pastries)
    )

-- 8) Find the shop ID and pastry ID for the records in the offers table that have 
-- the earliest date_added (minimum date).
select * from offers;

select 
	shopID,
    pastryID,
    date_added
from offers
where date_added = (
	select 
		min(date_added) 
	from offers
	)

-- 9) Find the shop ID(s) that offer the highest number of pastries, utilizing 
-- a subquery to evaluate the maximum count per shop.
select * from offers;
   
select
	shopID,
    count(pastryID) as pastry_count
from offers
group by shopID
having count(pastryID) >= all (
	select
		count(pastryID)
	from offers
	group by shopID
    );

-- 10) Find the names of baristas who work at shops located in 'Seattle' using nested subqueries.
select * from baristas;
select * from shops;
select * from employs;

select
	name
from baristas
where baristaID in (
	select 
		baristaID 
	from employs
    where shopID in (
		select
			shopID
		from shops
        where city = 'Seattle')
    )
