-- Case Study #2 - Pizza Runner

-- Create Tables
CREATE SCHEMA pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id,registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
  
  
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');



DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');
  
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  
  -- 2. Clean Data
SELECT * FROM runner_orders; -- We need to replace empty/'null' with null values and remove letters from numerical columns
SELECT * FROM customer_orders; -- We need to replace empty/'null' with null values 

SELECT runner_id, 
REPLACE(distance, 'km', '') as distance,
REPLACE(
	REPLACE(
		REPLACE(duration, 'minutes', ''),
        'mins', ''),
	'minute', '')
AS duration
FROM runner_orders;
-- this works well to remove the text
  
ALTER TABLE runner_orders ADD clean_duration INT;
ALTER TABLE runner_orders ADD clean_distance INT;
-- add columns for the clean data

DROP TABLE IF EXISTS runner_orders_clean;
CREATE TABLE runner_orders_clean (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23),
  duration_km VARCHAR(6),
  distance_km VARCHAR(6)
);
-- create new table for the clean data 


INSERT INTO runner_orders_clean
(
  order_id,
  runner_id,
  pickup_time,
  distance,
  duration,
  cancellation,
  duration_km,
  distance_km
)
SELECT
  order_id,
  runner_id,
  pickup_time,
  distance,
  duration,
  cancellation,
  REPLACE(
	REPLACE(
		REPLACE(duration, 'minutes', ''),
		'mins', ''),
	'minute', '')
 AS duration,
 REPLACE(distance, 'km', '') as distance
FROM runner_orders;
-- add cleaned data to the new table 

ALTER TABLE runner_orders_clean DROP distance, DROP duration; 
-- drop uncleaned columns

UPDATE runner_orders_clean
SET pickup_time = NULL 
WHERE pickup_time = 'null';

UPDATE runner_orders_clean
SET cancellation = NULL 
WHERE cancellation = 'null';

UPDATE runner_orders_clean
SET cancellation = NULL 
WHERE cancellation = '';

UPDATE runner_orders_clean
SET duration_km = NULL 
WHERE duration_km = 'null';

UPDATE runner_orders_clean 
SET distance_km = NULL
WHERE distance_km = 'null';

-- all 'null' and empty values changed to null 

SELECT * FROM customer_orders;

UPDATE customer_orders 
SET exclusions = NULL 
WHERE exclusions = '';

UPDATE customer_orders 
SET extras = NULL
WHERE extras = "";

UPDATE customer_orders 
SET exclusions = NULL
WHERE exclusions = 'null';

UPDATE customer_orders 
SET extras = NULL
WHERE extras = 'null';
 -- all 'null' and empty values replaced with NULL
 

-- 3. Answer Questions

-- Pizza Metrics 

-- How many pizzas were ordered?
SELECT COUNT(order_id) AS pizza_qty FROM customer_orders;

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS order_qty FROM customer_orders;

-- How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) 
FROM runner_orders_clean
WHERE cancellation	IS NULL 
GROUP BY runner_id;

-- How many of each type of pizza was delivered?

SELECT * FROM runner_orders_clean;
SELECT * FROM customer_orders;

SELECT pizza_id, COUNT(pizza_id)
FROM customer_orders
INNER JOIN runner_orders_clean ON customer_orders.order_id = runner_orders_clean.order_id
WHERE runner_orders_clean.cancellation IS NULL
GROUP BY pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, pizza_name
FROM customer_orders
INNER JOIN pizza_names ON customer_orders.pizza_id = pizza_names.pizza_id;

WITH CTE_1 AS(
	SELECT customer_id,
    CASE 
		WHEN pizza_name = 'Meatlovers' THEN 'TRUE'
        ELSE NULL
	END as 'Meatlovers',
    CASE 
		WHEN pizza_name = 'Vegetarian' THEN 'TRUE'
        ELSE NULL
	END AS 'Vegetarian'
    FROM customer_orders
	INNER JOIN pizza_names ON customer_orders.pizza_id = pizza_names.pizza_id
    )
    SELECT customer_id, COUNT(Meatlovers) as Meatlovers_Ordered, COUNT(Vegetarian) AS Vegetarian_Ordered
    FROM CTE_1
    GROUP BY customer_id;

-- What was the maximum number of pizzas delivered in a single order?
SELECT order_id, count(order_id) as count
FROM customer_orders
GROUP BY order_id
order by count desc
LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH CTE_1 AS(
	SELECT customer_id, count(customer_id) AS Pizzas_with_no_change
	FROM customer_orders
	WHERE exclusions IS NULL AND extras IS NULL
	GROUP BY customer_id
),
CTE_2 AS (
	SELECT customer_id, count(customer_id) AS Pizzas_with_changes
	FROM customer_orders
	WHERE exclusions IS NOT NULL OR extras IS NOT NULL
	GROUP BY customer_id
   ) 
   SELECT DISTINCT(customer_orders.customer_id), Pizzas_with_no_change, Pizzas_with_changes FROM customer_orders
LEFT JOIN CTE_1 ON customer_orders.customer_id = CTE_1.customer_id
LEFT JOIN CTE_2 ON customer_orders.customer_id = CTE_2.customer_id;

-- How many pizzas were delivered that had both exclusions and extras?
SELECT count(order_id)
FROM customer_orders
WHERE exclusions IS NOT NULL AND extras IS NOT NULL;

-- What was the total volume of pizzas ordered for each hour of the day?


WITH RECURSIVE CTE_1 AS (
	SELECT 0 AS `Hour`
    UNION ALL
    SELECT `Hour` + 1 
    FROM CTE_1
    WHERE `Hour` < 23
),
CTE_2 AS (
SELECT HOUR(order_time) AS `Hour`, count(order_id) AS Pizzas_Ordered
FROM customer_orders
GROUP BY `Hour`
)
SELECT HOUR(str_to_date(CTE_1.`Hour`, '%k')) as `Hour`, CTE_2.Pizzas_Ordered
FROM CTE_1
LEFT JOIN CTE_2 ON CTE_1.`Hour` = CTE_2.`Hour`;

-- What was the volume of orders for each day of the week?

WITH RECURSIVE CTE_1 AS (
	SELECT 0 AS `Weekday`
    UNION ALL
    SELECT `Weekday` + 1 
    FROM CTE_1
    WHERE `Weekday` < 6
),
CTE_2 AS (
SELECT WEEKDAY(order_time) AS `Weekday`, count(order_id) AS Pizzas_Ordered
FROM customer_orders
GROUP BY `Weekday`
)
SELECT CTE_1.`Weekday`, CTE_2.Pizzas_Ordered
FROM CTE_1
LEFT JOIN CTE_2 ON CTE_1.`Weekday` = CTE_2.`Weekday`;

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT YEAR(registration_date) AS `Year`, WEEK(registration_date,1) AS `Week`, COUNT(runner_id)
FROM runners
GROUP BY `Year`, `Week`;

SELECT WEEK(registration_date,4), registration_date, WEEKDAY(registration_date)
FROM runners;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH CTE_1 AS (
	SELECT DISTINCT(order_id), order_time
    FROM customer_orders
    )
SELECT runner_id, AVG(timestampdiff(MINUTE, order_time, pickup_time)) AS Avg_mins_to_pickup
FROM runner_orders_clean
JOIN CTE_1 ON runner_orders_clean.order_id = CTE_1.order_id
WHERE cancellation IS NULL
GROUP BY runner_id;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
	-- Yes, the more pizzas ordered then the longer it takes to prepare
WITH CTE_1 AS (
	SELECT customer_orders.order_id, COUNT(customer_orders.order_id) AS pizza_qty, AVG(timestampdiff(minute, order_time, pickup_time)) AS Time_to_prepare
	FROM customer_orders
	INNER JOIN runner_orders_clean ON customer_orders.order_id = runner_orders_clean.order_id
	WHERE cancellation IS NULL
	GROUP BY order_id
    )
SELECT pizza_qty, ROUND(AVG(time_to_prepare),0) AS Avg_time_to_prepare
FROM CTE_1
GROUP BY pizza_qty;

-- What was the average distance travelled for each customer?
WITH CTE_1 AS (
	SELECT DISTINCT(customer_orders.order_id), customer_id, distance_km
	FROM runner_orders_clean
	INNER JOIN customer_orders ON runner_orders_clean.order_id = customer_orders.order_id
    )
SELECT customer_id, AVG(distance_km)
FROM CTE_1
GROUP BY customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
WITH CTE_1 AS (
	SELECT MAX((TIMESTAMPDIFF(MINUTE, order_time, pickup_time) + duration_min)) AS `Longest_Delivery_Time`
	FROM customer_orders
	INNER JOIN runner_orders_clean ON customer_orders.order_id = runner_orders_clean.order_id
	),
CTE_2 AS (
	SELECT MIN((TIMESTAMPDIFF(MINUTE, order_time, pickup_time) + duration_min)) AS `Shortest_Delivery_Time`
	FROM customer_orders
	INNER JOIN runner_orders_clean ON customer_orders.order_id = runner_orders_clean.order_id
    )
SELECT Longest_Delivery_Time AS Longest_and_Shortest_Delivery_Time_Mins
FROM CTE_1
UNION
SELECT Shortest_Delivery_Time
FROM CTE_2;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- I can't see a trend 

SELECT runner_id, COUNT(customer_orders.order_id) AS Num_of_Pizza, (distance_km/(duration_min/60)) AS Speed
FROM runner_orders_clean
INNER JOIN customer_orders ON runner_orders_clean.order_id = customer_orders.order_id
GROUP BY runner_id, speed
ORDER BY runner_id, Num_of_Pizza;

SELECT runner_id, WEEKDAY(pickup_time) AS Weekday, (distance_km/(duration_min/60)) AS Speed
FROM runner_orders_clean
INNER JOIN customer_orders ON runner_orders_clean.order_id = customer_orders.order_id
ORDER BY Speed ;

-- What is the successful delivery percentage for each runner?

WITH CTE_1 AS (
	SELECT runner_id, CASE 
		WHEN cancellation IS NULL THEN 1
		WHEN cancellation IS NOT NULL THEN 0
		END AS 'Failure/Success'
	FROM runner_orders_clean
	ORDER BY runner_id
    )
SELECT runner_id, ROUND(SUM(`Failure/Success`)/COUNT(`Failure/Success`),2) AS Order_Success_Rate
FROM CTE_1
GROUP BY runner_id;

-- C. Ingredient Optimisation
-- What are the standard ingredients for each pizza?
WITH CTE_1 AS (
	SELECT pizza_id, TRIM(RIGHT(substring_index(toppings, ',', n),2)) AS topping, n
	FROM pizza_recipes PR
	JOIN numbers ON char_length(toppings)- char_length(replace(toppings, ",", "")) >= n-1
    )
    SELECT pizza_id, topping_name 
    FROM CTE_1
	JOIN pizza_toppings PT ON CTE_1.topping = PT.topping_id
    ORDER BY pizza_id;
    
 SELECT * FROM pizza_recipes;   

-- What are the common ingredients that both pizza use?

create temporary table numbers as 
	(
    select 1 as n union 
    select 2 as n union 
    select 3 as n union 
    select 4 as n union 
    select 5 as n union 
    select 6 as n union 
    select 7 as n union 
    select 8 as n   
    );

WITH CTE_1 AS (
	SELECT pizza_id, TRIM(RIGHT(substring_index(toppings, ',', n),2)) AS topping, n
	FROM pizza_recipes PR
	JOIN numbers ON char_length(toppings)- char_length(replace(toppings, ",", "")) >= n-1
    ),
    CTE_2 AS (
    SELECT COUNT(topping_id) AS Topping_Count, topping_name 
    FROM CTE_1
	JOIN pizza_toppings PT ON CTE_1.topping = PT.topping_id
	GROUP BY topping_name
    )
    SELECT Topping_Count, topping_name FROM CTE_2
    WHERE Topping_Count = (
		SELECT COUNT(DISTINCT(pizza_id))
        FROM pizza_names
        );

-- What was the most commonly added extra?
-- Bacon
WITH CTE_1 AS (
	SELECT TRIM(RIGHT(SUBSTRING_INDEX(extras, ",", n),2)) AS extra, n
	FROM customer_orders
	JOIN numbers ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ",", ""))  >= n-1
),
CTE_2 AS (
	SELECT topping_name, COUNT(extra) AS Toppings_Count
	FROM CTE_1
	JOIN pizza_toppings ON topping_id = extra
	GROUP BY topping_name 
    )
SELECT topping_name, Toppings_Count
FROM CTE_2;

-- What was the most common exclusion?
-- Cheese
WITH CTE_1 AS (
	SELECT TRIM(RIGHT(SUBSTRING_INDEX(exclusions, ",", n),2)) AS exclusion, n
	FROM customer_orders
	JOIN numbers ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ",", ""))  >= n-1
),
CTE_2 AS (
	SELECT topping_name, COUNT(exclusion) AS Exclusion_Count
	FROM CTE_1
	JOIN pizza_toppings ON topping_id = exclusion
	GROUP BY topping_name 
    )
SELECT topping_name, Exclusion_Count
FROM CTE_2;

-- Generate an order item for each record in the customers_orders table in the format of one of the following:
    -- Meat Lovers
    -- Meat Lovers - Exclude Beef
    -- Meat Lovers - Extra Bacon
    -- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH CTE_1 AS (
	SELECT order_id, TRIM(RIGHT(SUBSTRING_INDEX(exclusions, ",", n),2)) AS exclusion, n
	FROM customer_orders
	JOIN numbers ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ",", ""))  >= n-1
),
CTE_2 AS (
	SELECT order_id, exclusion, topping_name
	FROM CTE_1
	JOIN pizza_toppings ON topping_id = exclusion
)
SELECT CO.order_id, exclusion, topping_name
FROM customer_orders CO
JOIN pizza_names PN ON CO.pizza_id = PN.pizza_id
JOIN CTE_2 ON CO.order_id = CTE_2.order_id;

WITH CTE_1 AS (
	SELECT order_id, TRIM(RIGHT(SUBSTRING_INDEX(exclusions, ",", n),2)) AS exclusion, n
	FROM customer_orders
	JOIN numbers ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ",", ""))  >= n-1
)
	SELECT order_id, exclusion, topping_name
	FROM CTE_1
	JOIN pizza_toppings ON topping_id = exclusion;


SELECT * FROM customer_orders;
SELECT * FROM pizza_toppings;



