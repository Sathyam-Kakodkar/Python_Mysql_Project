select * from df_orders;

drop table df_orders;

create table df_orders (
order_id int primary key,
order_date date,
ship_mode varchar (20),
segment varchar (20),
country varchar (20),
city varchar (20),
state varchar (20),
postal_code varchar (20),
region varchar (20),
category varchar (20),
sub_category varchar (20),
product_id varchar (20),
quantity int,
discount decimal (7,2),
sale_price decimal (7,2),
profit decimal (7,2)
);

-- find top 10 highest reveue generating products 
select product_id, sum(sale_price) as  sales
from df_orders
group by product_id
order by `sales` desc
limit 10;

-- find top 5 highest selling products in each region
with hig_sl_prdt as (
select region , product_id, sum(sale_price) as  sales
from df_orders
group by region ,product_id)
select * from (select * ,
row_number() over (partition by region order by sales desc) as rn
from hig_sl_prdt) A 
where A.rn <= 5;

-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with mon_yr_sal as (
select monthname(order_date) as order_month, month(order_date) as order_monthno , year(order_date) as order_year, sum(sale_price) as sales
from df_orders
group by 1,2,3 )
select order_month, order_monthno,
	   sum(case when order_year = 2022 then sales else 0 end) as sales_2022 ,
	   sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from mon_yr_sal
group by order_month, order_monthno
order by order_monthno;

-- for each category which month had highest sales 

with cte as (
select category, DATE_FORMAT(order_date, '%Y-%m') as order_year_month, 
sum(sale_price) as sale
from df_orders
group by category, DATE_FORMAT(order_date, '%Y-%m')
order by category, DATE_FORMAT(order_date, '%Y-%m')
)
select * 
from  (select *,
row_number() over (partition by category order by sale desc ) as rn
from
cte) A
where A.rn = 1;

-- which sub category had highest growth% by profit in 2023 compare to 2022
with cte as (
select sub_category, year(order_date) as order_year, sum(sale_price) as sales
from df_orders
group by 1,2 )
,cte2 as (
select sub_category,
	   sum(case when order_year = 2022 then sales else 0 end) as sales_2022 ,
	   sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category)
select *,
(sales_2023 - sales_2022)/sales_2022*100 as growth
from cte2
order by growth desc
limit 1












