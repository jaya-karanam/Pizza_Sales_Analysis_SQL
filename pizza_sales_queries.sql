create database wscube;
use wscube;
-- Basic:
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS num_of_orders
FROM
    orders;
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(price * quantity), 2) AS total_sales
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id;
    
-- Identify the highest-priced pizza.
SELECT 
    name, price
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    size, COUNT(order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY order_count DESC
LIMIT 1;
 
-- List thepizzase top 5 most ordered pizza types 
-- along with their quantities.
SELECT 
    name, SUM(quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY name
ORDER BY total_quantity DESC
LIMIT 5;

-- Intermediate:
-- Join the necessary tables to 
-- find the total quantity of each pizza category ordered.
SELECT 
    category, SUM(quantity) AS ordered_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY category;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time), COUNT(order_id) AS num_orders
FROM
    orders
GROUP BY HOUR(time)
ORDER BY num_orders DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and 
-- calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total), 0) AS average
FROM
    (SELECT 
        date, SUM(quantity) AS total
    FROM
        order_details od
    JOIN orders o ON od.order_id = o.order_id
    GROUP BY date) AS a;
    
-- Determine the top 3 most ordered pizza types based on revenue.
select name,sum(price*quantity) as revenue from order_details od join 
pizzas p on p.pizza_id=od.pizza_id join pizza_types pt 
on pt.pizza_type_id = p.pizza_type_id
group by name order by revenue desc limit 3;
-- Advanced:
-- Calculate the percentage contribution of each pizza type
-- to total revenue.
select category, 
round(sum(price*quantity)/(SELECT 
    ROUND(SUM(price * quantity), 2) AS total_sales
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id) * 100 ,2) as percentage
from pizza_types pt join pizzas p on p.pizza_type_id=pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by category;

-- Analyze the cumulative revenue generated over time.
select date,
sum(revenue) over(order by date) as cumulative
from (select date,sum(price * quantity) as revenue 
from pizza_types pt join pizzas p on p.pizza_type_id=pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id join orders o 
on o.order_id=od.order_id
group by date) as sales;

-- Determine the top 3 most ordered pizza types based on 
-- revenue for each pizza category.
select category,name,revenue,rn 
from 
(select category,name,revenue , 
rank() over(partition by category order by revenue desc) rn
from (select category,name,sum(price*quantity) as revenue 
from pizza_types pt join pizzas p on p.pizza_type_id=pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by category,name) as a) b  where rn<=3;