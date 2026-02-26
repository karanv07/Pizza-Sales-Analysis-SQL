-- Drop Table IF EXITS
DROP TABLE IF EXISTS pizzas;

-- For Create New Table
CREATE TABLE pizzas (
              pizza_id VARCHAR(50),
			  pizza_type_id	VARCHAR(50),
			  size VARCHAR(10),
			  price DECIMAL (10,2)
);

-- For Checking Results
SELECT * FROM pizzas;

-- Drop Table IF EXITS
DROP TABLE IF EXISTS pizza_type;


-- For Creating New Table
CREATE TABLE pizza_type (
              pizza_type_id VARCHAR(50),
			  name VARCHAR(100),
			  category VARCHAR(100),
			  ingredients VARCHAR (300)
);

-- For Checking Results
SELECT * FROM pizza_type;


-- For Changing Table type
ALTER TABLE pizza_type
ALTER COLUMN ingredients TYPE TEXT;


-- For Adding Data into Table
\copy pizza_type FROM 'data/pizza_types.csv' WITH (FORMAT csv, HEADER true);


-- For Checking Results
SELECT * FROM pizza_type;


-- Drop Table IF EXITS
DROP TABLE IF EXISTS orders;


-- For Creating New Table
CREATE TABLE orders (
             order_id INT,
			 date DATE,
			 time TIME
);


-- For Checking Results
SELECT * FROM orders;


-- For Changing Table type
ALTER TABLE orders
ALTER COLUMN time TYPE TIME;



-- For Adding Data into Table
\copy orders FROM 'data/orders.csv' WITH (FORMAT csv, HEADER true);


-- Drop Table IF EXITS
DROP TABLE IF EXISTS order_details;


-- For Creating New Table
CREATE TABLE order_details (
             order_details_id INT,	
			 order_id INT,	
			 pizza_id VARCHAR(50),	
			 quantity INT
);


-- For Checking Results
SELECT * FROM order_details;




-- For Checking Results
SELECT * FROM pizzas;
SELECT * FROM pizza_type;
SELECT * FROM orders;
SELECT * FROM order_details;


--Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_orders FROM orders;


--Calculate the total revenue generated from pizza sales.
SELECT SUM(p.price * od.quantity) AS total_revenue 
FROM pizzas p
JOIN order_details od
ON p.pizza_id = od.pizza_id;


--Identify the highest-priced pizza.
SELECT pt.name, MAX(p.price)
FROM pizzas p
JOIN pizza_type pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY MAX(p.price) DESC
LIMIT 1;



--Identify the most common pizza size ordered.
SELECT p.size, COUNT(od.quantity) AS total_order_quantity
FROM pizzas p
JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_order_quantity DESC
LIMIT 1;



-- For Checking Results
SELECT * FROM pizzas;
SELECT * FROM pizza_type;
SELECT * FROM orders;
SELECT * FROM order_details;

--List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM pizza_type pt
JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM pizza_type pt
JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC;


ALTER TABLE orders
RENAME COLUMN time TO order_time;

-- Determine the distribution of orders by hour of the day.
SELECT EXTRACT(HOUR from order_time) AS hour, COUNT(order_id) as total_orders
FROM orders
GROUP BY hour
ORDER BY hour;


--Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name)
FROM pizza_type
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(total_quantity),2) 
FROM 
 (SELECT o.date, SUM(od.quantity) as total_quantity
 FROM orders o
 JOIN order_details od
 ON o.order_id = od.order_id
 GROUP BY o.date) as order_quantity;



-- For Checking Results
SELECT * FROM pizzas;
SELECT * FROM pizza_type;
SELECT * FROM orders;
SELECT * FROM order_details;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pt.name, SUM(p.price * od.quantity) AS total_revenue
FROM pizza_type pt
JOIN pizzas p
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category, ROUND(SUM(od.quantity * p.price) / (SELECT round(SUM(p.price * od.quantity),2)
FROM pizzas p
JOIN order_details od
ON p.pizza_id = od.pizza_id) * 100,2) as percentage_revenue
FROM pizza_type pt
JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.category;



-- Analyze the cumulative revenue generated over time.
SELECT date, SUM(revenue)
OVER (ORDER BY date) as cum_revenue
FROM
(SELECT o.date, SUM(p.price * od.quantity) AS revenue
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
JOIN pizzas p
ON p.pizza_id = od.pizza_id
GROUP BY o.date) as Sale;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, revenue, rn
FROM
(SELECT category, name, revenue,
 RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
 FROM
(SELECT pt.category, pt.name, SUM(od.quantity * p.price) as revenue
FROM pizzas p
JOIN pizza_type pt
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.category, pt.name) AS a) AS b
WHERE rn <= 3;
