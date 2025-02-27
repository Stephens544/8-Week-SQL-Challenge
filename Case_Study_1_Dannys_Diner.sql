-- Create tables

CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

/* Questions
	1. What is the total amount each customer spent at the restaurant?
    2. How many days has each customer visited the restaurant?
    3. What was the first item from the menu purchased by each customer?
    4. What is the most purchased item on the menu and how many times was it purchased by all customers?
    5. Which item was the most popular for each customer?
    6. Which item was purchased first by the customer after they became a member?
    7. Which item was purchased just before the customer became a member?
    8. What is the total items and amount spent for each member before they became a member?
    9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
    10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
*/ 

-- 1 What is the total amount each customer spent at the restaurant?
SELECT sales.customer_id, SUM(menu.price) FROM sales
INNER JOIN menu ON 
	sales.product_id = menu.product_id
GROUP BY customer_id;

-- 2 How many days has each customer visited the restaurant?
SELECT customer_id, count(order_date) AS days_visited FROM sales
GROUP BY customer_id;

-- 3 What was the first item from the menu purchased by each customer?
SELECT sales.customer_id, MIN(sales.order_date), menu.product_name FROM sales
INNER JOIN menu ON 
	sales.product_id = menu.product_id

GROUP BY menu.product_name, sales.customer_id
order by menu.product_nameev_demand_vs_renew_supply_ratioev_charging_pointsev_charging_pointsev_charging_points
;


WITH CTE_1 AS 
	(
    SELECT sales.customer_id, sales.order_date, menu.product_name, 
    ROW_NUMBER() OVER (PARTITION BY sales.customer_id, sales.order_date ORDER BY sales.order_date) AS RN
    FROM sales
    INNER JOIN menu ON
		sales.product_id = menu.product_id
	
	)
SELECT * FROM CTE_1
WHERE RN = 1 AND order_date IN (SELECT MIN(order_date) FROM CTE_1)
ORDER BY order_date
;


-- 4 What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    menu.product_name, COUNT(sales.product_id) AS count
FROM
    sales
        INNER JOIN
    menu ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY count DESC;

-- 5 Which item was the most popular for each customer?
WITH CTE_1 AS (
	SELECT 
		sales.customer_id,
		menu.product_name,
		COUNT(sales.product_id) AS count,
		RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(sales.product_id) DESC) `Rank`
	FROM
		sales
			INNER JOIN
		menu ON sales.product_id = menu.product_id
        GROUP BY menu.product_name , sales.customer_id
        )
	SELECT * 
    FROM CTE_1
	WHERE `Rank` = 1
;

-- 6. Which item was purchased first by the customer after they became a member?

WITH CTE_2 AS (
	SELECT members.customer_id, members.join_date, sales.order_date, menu.product_name,
    RANK() OVER(PARTITION BY members.customer_id ORDER BY sales.order_date) `Rank`
	FROM sales
	INNER JOIN members ON members.customer_id = sales.customer_id
	INNER JOIN menu ON menu.product_id = sales.product_id
	WHERE join_date < order_date
	ORDER BY order_date
    )
SELECT * 
FROM CTE_2
WHERE `Rank` = 1;

--  7. Which item was purchased just before the customer became a member?
WITH CTE_3 AS (
	SELECT members.customer_id, members.join_date, sales.order_date, menu.product_name,
    RANK() OVER(PARTITION BY members.customer_id ORDER BY sales.order_date DESC) `Rank`
	FROM sales
	INNER JOIN members ON members.customer_id = sales.customer_id
	INNER JOIN menu ON menu.product_id = sales.product_id
	WHERE join_date > order_date
	ORDER BY order_date
    )
SELECT * 
FROM CTE_3
WHERE `Rank` = 1;


-- 8. What is the total items and amount spent for each member before they became a member?

SELECT members.customer_id, SUM(menu.price) AS Value_of_Orders, COUNT(sales.product_id) AS Items_Ordered
FROM sales
INNER JOIN members ON members.customer_id = sales.customer_id
INNER JOIN menu ON menu.product_id = sales.product_id
WHERE join_date > order_date
GROUP BY members.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

-- Correct answer depends on the meaning of the question. If the meaning is to calculate points for all purchases, then answer A, if only points after becoming a member, then B.

-- A

WITH CTE_4 AS (
	SELECT sales.customer_id, sales.order_date, menu.product_name, menu.price, 
    CASE 
		WHEN product_name = 'sushi' THEN menu.price*20
		ELSE menu.price * 10 
	END as Points
	FROM sales
	INNER JOIN menu ON menu.product_id = sales.product_id
	ORDER BY order_date
    )
SELECT customer_id, sum(points) 
FROM CTE_4
GROUP BY customer_id;

-- B

WITH CTE_5 AS (
	SELECT members.customer_id, menu.price AS Value_of_Orders, sales.product_id AS Items_Ordered, menu.product_name,
	CASE 
			WHEN product_name = 'sushi' THEN menu.price*20
			ELSE menu.price * 10 
		END as Points
	FROM sales
	INNER JOIN members ON members.customer_id = sales.customer_id
	INNER JOIN menu ON menu.product_id = sales.product_id
	WHERE join_date < order_date
)
SELECT customer_id, sum(points) 
FROM CTE_5
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH CTE_6 AS (
	SELECT members.customer_id, menu.price AS Value_of_Orders, menu.product_name, sales.order_date, members.join_date,
	CASE 
			WHEN (order_date >= join_date AND order_date <= join_date+6) THEN menu.price*20
            WHEN product_name = 'sushi' THEN menu.price*20
			ELSE menu.price * 10 
		END as Points
	FROM sales
	INNER JOIN members ON members.customer_id = sales.customer_id
	INNER JOIN menu ON menu.product_id = sales.product_id
	WHERE order_date < '2021/02/01' AND order_date > join_date
)
SELECT customer_id, SUM(points)
FROM CTE_6
GROUP BY customer_id;




