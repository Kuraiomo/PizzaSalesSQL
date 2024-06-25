use pizzacentre;
CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);
CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);
-- Questions



-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS totalOrders
FROM
    orders;
    

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(price * quantity),2) AS totalRevenue
FROM
    order_details
        JOIN
    pizzas
WHERE
    order_details.pizza_id = pizzas.pizza_id;
    
    
    
-- Identify the highest-priced pizza.
SELECT 
    name, category, price
FROM
    pizza_types
        JOIN
    pizzas
WHERE
    pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY 3 DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    size AS mostCommonSize, COUNT(order_details_id) as quantity
FROM
    pizzas
        JOIN
    order_details
WHERE
    order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) as quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    category, COUNT(order_details_id) as totalQuantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id) as noOfOrders
FROM
    orders
GROUP BY 1;


-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(pizza_id) AS categoryWiseDisturbution
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY 1;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(new_quant))
FROM
    (SELECT 
        order_date, SUM(quantity) AS new_quant
    FROM
        orders
    JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY 1) AS order_quant;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    name, SUM(quantity * price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    name,
    ROUND(SUM(quantity * price) / (SELECT 
                    SUM(quantity * price)
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;



-- Analyze the cumulative revenue generated over time.
select order_date,round( sum(revenue) over (order by order_date),2) 
as cumulative
from
(SELECT 
    order_date, SUM(quantity * price) AS revenue
FROM
    orders
        JOIN
    order_details ON order_details.order_id = orders.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select 
category ,name, revenue,ran
 from(select category,name,revenue ,rank()
 over(partition by category order by revenue desc )as ran
from 
(SELECT 
    category,name, ROUND(SUM(price * quantity), 0) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
group by 1,2 ) as tab)as tab2
 where ran <=3;
