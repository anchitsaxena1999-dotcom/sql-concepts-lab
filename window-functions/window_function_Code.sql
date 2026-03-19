/* 
 Write a query to return only the most recent order per customer (by order_date). If two orders share the same date,
 keep the one with the higher order_id.
*/
select customer_id, order_id, order_date, total_amount from
	(select *,
		row_number() over(partition by customer_id order by order_date DESC) rn
	from orders)x
where x.rn =1;

/*
 find the top 3 products by total revenue (quantity × unit_price) within each product category.
 Include ties — if two products are tied for 3rd, both should appear.
*/
With revenue as(
select  p.category,
		p.product_name, 
		sum(oi.quantity * oi.unit_price) as total_revenue
from products p
join order_items oi
on p.product_id = oi.product_id
group by 1,2
)
select * from(
	select *,
	dense_rank() over(partition by category order by total_revenue DESC) dr
	from revenue)x
where x.dr <=3;

/*
 Write a query that shows each order for every customer alongside a running cumulative total of total_amount ordered by order_date. 
 The running total should reset for each customer.
*/
select customer_id, order_date, total_amount,
	sum(total_amount)over(partition by customer_id order by order_date)
from orders;

/*
 calculate the total revenue per month. Then for each month, show the revenue from the previous month and the absolute change.
 Your output should have: month, revenue, prev_month_revenue,
*/
with monthly_revenue as(
select 
	extract(month from order_date) as month,
	sum(total_amount) as revenue
from orders
group by month
order by month
)
select month, revenue,
	lag(revenue) over (order by month) as previous_month_revenue,
	revenue - LAG(revenue) OVER (ORDER BY month) AS mom_change
from monthly_revenue;

/*
 Flag customers whose next order came within 30 days
*/
select customer_id, order_id,order_date,
	lead(order_date)over(partition by customer_id order by order_date) as next_month_date,
	case
		when lead(order_date) over(partition by customer_id order by order_date) - order_date <= 30 
		then 'YES' else 'NO'
	end as is_repeted_within_30_days
from orders;

/*
 Compare each order to the customer's average order value
*/
select customer_id, total_amount,
	round(avg(total_amount) over(partition by customer_id) ,2) as average_value,
	total_amount - round(avg(total_amount) over(partition by customer_id) ,2) as difernence_in_amount
from orders
ORDER BY customer_id, order_date;

/*
 Calculate each customer's total lifetime spend from the orders table. Then use NTILE(4) to assign every customer a 
 spending quartile (1 = lowest 25%, 4 = highest 25%). Label them: Q1, Q2, Q3, Q4.
*/
with spend as (
select customer_id, sum(total_amount) as total_spend
from orders
group by 1
)
select customer_id, total_spend,
	NTILE(4) over(order by total_spend) as quartile_num,
	CASE NTILE(4) OVER (ORDER BY total_spend)
		 WHEN 1 THEN 'Q1 - Low'
	     WHEN 2 THEN 'Q2 - Mid-Low'
	     WHEN 3 THEN 'Q3 - Mid-High'
	     WHEN 4 THEN 'Q4 - High'
  	END AS segment
from spend;

/*
 7-day rolling average of daily revenue
*/
with daily as(
select order_date, sum(total_amount) as daily_revenue
from orders
group by order_date
)
select 	order_date, 
		daily_revenue,
		round(
				avg(daily_revenue) over(order by order_date 
				ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) 
				as rolling_7_avg
from daily;

/*
Detect revenue drop of more than 20% versus previous month (per sales rep)
*/

WITH rep_revenue as(
select  o.rep_id, 
		s.rep_name,
		extract(month from o.order_date) as month,
		sum(o.total_amount) as revenue
from orders o
left join sales_reps s
on o.rep_id = s.rep_id
group by o.rep_id, s.rep_name, month
),
lagged as(
select *,
	lag(revenue) over( partition by rep_name order by month) as previous_revenue
from rep_revenue	
)
select rep_name, month, revenue, previous_revenue,
case 
	when previous_revenue is not null
	and (revenue-previous_revenue)*1.0/previous_revenue < -.20
	then 'drop>20%' ELSE 'OK'
end as flag
from lagged;

/*
 Show each order with the customer's very first and last order amount
*/

with cte as (
select customer_id,order_date, total_amount,
	first_value(total_amount) over(partition by customer_id order by order_date) as first_purchase,
	last_value(total_amount) over(partition by customer_id order by order_date
	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_purchase
from orders
)
SELECT DISTINCT 
    customer_id,
    first_purchase,
    last_purchase

--if want to both dates and amount 

SELECT 
    customer_id,

    MIN(first_order_date) AS first_order_date,
    MIN(first_order_amount) AS first_order_amount,

    MIN(last_order_date) AS last_order_date,
    MIN(last_order_amount) AS last_order_amount

FROM (
    SELECT 
        customer_id,

        FIRST_VALUE(order_date) OVER(
            PARTITION BY customer_id ORDER BY order_date
        ) AS first_order_date,

        FIRST_VALUE(total_amount) OVER(
            PARTITION BY customer_id ORDER BY order_date
        ) AS first_order_amount,

        LAST_VALUE(order_date) OVER(
            PARTITION BY customer_id 
            ORDER BY order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_order_date,

        LAST_VALUE(total_amount) OVER(
            PARTITION BY customer_id 
            ORDER BY order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_order_amount

    FROM orders
) t

GROUP BY customer_id;
/*
 Find the 2nd highest order value per customer
*/
select customer_id,order_id,order_date, total_amount from
	(select *,
	row_number()over (partition by customer_id order by total_amount) rn
	from orders) x
where x.rn =2;

/*
 Identify customers who placed orders in 3 consecutive months
*/

with order_month as(
select  customer_id,
		extract(month from order_date) as month,
		row_number() over(partition by customer_id order by extract(month from order_date)) row_num
from orders
),
consecutive_month as(
select  customer_id,
		(month - row_num) as diff
		from order_month
)
select customer_id
from consecutive_month
group by customer_id,diff
having count(*)>=3;


/*
 Calculate what % of total revenue each product contributes (revenue share)
*/

with product_revenue as (
		select  p.product_name,
				(oi.quantity * oi.unit_price) as total_revenue
		from products p
		join order_items oi
		on p.product_id = oi.product_id
		group by p.product_name, total_revenue
)
select  product_revenue,
		total_revenue,
		(total_revenue*100)/sum(total_revenue) over()
from product_revenue
group by 1,2;

/*
 Find customers whose last order is their highest order
*/

with ranked as (
	Select customer_id,
			total_amount,
			row_number() over (partition by customer_id order by order_date DESC) as last_date,
			max(total_amount) over(partition by customer_id ) as max_revenue
	from orders		
)
select  customer_id from ranked
where last_date = 1
	and total_amount = max_revenue;

/*
Calculate 3-order moving average revenue for each sales_rep.
*/

select  rep_id,
		total_amount,
		order_date,
		round (avg(total_amount) over(partition by rep_id order by order_date 
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) as moving_avg
from orders;

