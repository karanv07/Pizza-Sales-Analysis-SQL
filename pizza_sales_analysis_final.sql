-----------------------------------------Pizza Sales Analysis------------------------------------------
-------------------------------------------------------------------------------------------------------



---- For Droping exisiting Table

DROP TABLE IF EXISTS pizzas;
DROP TABLE IF EXISTS pizza_types;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_details;

======================================================================================================


---- For Creating New table

CREATE TABLE pizzas (
                     pizza_id	TEXT NOT NULL,
					 pizza_type_id TEXT NOT NULL,
					 size VARCHAR(5),
					 price FLOAT
);


CREATE TABLE pizza_types (
                          pizza_type_id TEXT NOT NULL,
						  name VARCHAR(50) NOT NULL,
						  category VARCHAR(20) NOT NULL,
						  ingredients TEXT
);


CREATE TABLE orders (
                     order_id INT PRIMARY KEY,
					 date DATE NOT NULL,
					 time TIME NOT NULL
);


CREATE TABLE order_details (
                            order_details_id INT PRIMARY KEY,
							order_id INT NOT NULL,
							pizza_id TEXT NOT NULL,
							quantity INT NOT NULL
);

======================================================================================================


---- For Adding Data into tables (2 added direct adn 2 added with query)


COPY pizzas
FROM '/Users/shubham/Downloads/pizza-sales---SQL-main/pizza_sales/pizzas.csv'
DELIMITER ','
CSV HEADER;


COPY pizza_types
FROM '/Users/shubham/Downloads/pizza-sales---SQL-main/pizza_sales/pizza_types.csv'
DELIMITER ','
CSV HEADER;

======================================================================================================


---- For Checking all data

SELECT * FROM pizzas;
SELECT * FROM pizza_types;
SELECT * FROM orders;
SELECT * FROM order_details;


======================================================================================================

-- Basic: 

-- 1) Retrieve the total number of orders placed.

CREATE VIEW Total_orders AS
SELECT COUNT(order_id) AS total_orders FROM orders;


-- 2) Calculate the total revenue generated from pizza sales.

CREATE VIEW Total_revenue AS
SELECT ROUND(SUM(od.quantity * p.price)::decimal,2) AS revenue 
FROM pizzas p
JOIN order_details od
ON od.pizza_id = p.pizza_id;


-- 3) Identify the highest-priced pizza.

CREATE VIEW Highest_price_pizza AS
SELECT pt.name, p.price as highest_price
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY highest_price DESC
LIMIT 1;


-- 4) Identify the most common pizza size ordered.

CREATE VIEW most_pizza_size_ordered AS
SELECT p.size, COUNT(od.order_id) as total_orders
FROM pizzas p
JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_orders DESC
LIMIT 1;


-- 5) List the top 5 most ordered pizza types along with their quantities.

CREATE VIEW top_5_pizzas_with_quantity AS
SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;



-- Intermediate:

-- 6) Join the necessary tables to find the total quantity of each pizza category ordered.

CREATE VIEW category_wise_total_quantity AS
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC;


-- 7) Determine the distribution of orders by hour of the day.

CREATE VIEW hourly_orders AS
SELECT EXTRACT (HOUR from time) as HOUR, COUNT(order_id) as total_orders
FROM orders
GROUP BY HOUR
ORDER BY HOUR;


-- 8) Join relevant tables to find the category-wise distribution of pizzas.

CREATE VIEW category_wise_total_pizzas AS
SELECT category, COUNT(name) as total_pizzas
FROM pizza_types
GROUP BY category;


-- 9) Group the orders by date and calculate the average number of pizzas ordered per day.

CREATE VIEW per_day_orders AS
SELECT ROUND(AVG(total_quantity)::decimal,0) AS per_day_orders
FROM
(SELECT o.date, SUM(od.quantity) AS total_quantity
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
GROUP BY o.date) AS total_orders;


-- 10) Determine the top 3 most ordered pizza types based on revenue.

CREATE VIEW top_3_by_revenue AS
SELECT pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM pizza_types pt
JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;



-- Advanced:

-- 11) Calculate the percentage contribution of each pizza category to total revenue.

CREATE VIEW category_wise_revenue_percentage AS
SELECT pt.category, ROUND(SUM(od.quantity * p.price)::decimal / (SELECT ROUND(SUM(od.quantity * p.price)::decimal,2)
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id) * 100,2) AS percentage
FROM pizza_types pt
JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY percentage DESC;


-- 12) Analyze the cumulative revenue generated over time.

CREATE VIEW cumulative_revenue AS
SELECT date, SUM(total_revenue) OVER (ORDER BY date) as revenue
FROM   
(SELECT o.date, ROUND(SUM( od.quantity * p.price)::decimal,2) as total_revenue
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
JOIN pizzas p
ON p.pizza_id = od.pizza_id
GROUP BY o.date) as revenue;


-- 13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

CREATE VIEW top_3_from_each_category AS
SELECT category, name, total_revenue, rank
FROM
(SELECT category, name, total_revenue,
      RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) as rank
FROM
(SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM pizza_types pt
JOIN pizzas p
ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY pt.category, pt.name) AS a) AS b
WHERE rank <= 3;


=====================================================================================================



-- 1) Retrieve the total number of orders placed.
SELECT * FROM Total_orders;


-- 2) Calculate the total revenue generated from pizza sales.
SELECT * FROM Total_revenue;


-- 3) Identify the highest-priced pizza.
SELECT * FROM Highest_price_pizza;


-- 4) Identify the most common pizza size ordered.
SELECT * FROM most_pizza_size_ordered;


-- 5) List the top 5 most ordered pizza types along with their quantities.
SELECT * FROM top_5_pizzas_with_quantity;


-- 6) Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT * FROM category_wise_total_quantity;


-- 7) Determine the distribution of orders by hour of the day.
SELECT * FROM hourly_orders;


-- 8) Join relevant tables to find the category-wise distribution of pizzas.
SELECT * FROM category_wise_total_pizzas;


-- 9) Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT * FROM per_day_orders;


-- 10) Determine the top 3 most ordered pizza types based on revenue.
SELECT * FROM top_3_by_revenue;


-- 11) Calculate the percentage contribution of each pizza type to total revenue.
SELECT * FROM category_wise_revenue_percentage;


-- 12) Analyze the cumulative revenue generated over time.
SELECT * FROM cumulative_revenue;


-- 13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT * FROM top_3_from_each_category;



============================================== END =================================================









