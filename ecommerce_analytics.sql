-- Part 1 : Know your Data
-- question 1
-- how many users we have
SELECT COUNT(*) AS total_users
FROM users;

-- question 2
-- how many orders we have
SELECT sum(id)
FROM orders;

-- question 3
-- how many products we have
SELECT sum(id)
FROM products;

-- question 4
-- see when the order date started and how long it continues
SELECT 
	MIN(order_date),
    MAX(order_date)
FROM
	orders;
    
-- question 5 
-- Find countries that have very small share of users   
SELECT c.country,
       c.cnt,
       (c.cnt * 1.0 / t.total) AS pers
FROM (
    SELECT
       country,
       COUNT(*) AS cnt
       FROM users
       GROUP BY country
 ) AS c
 CROSS JOIN (
     SELECT COUNT(*) AS total
	 FROM users
) AS t
WHERE  (c.cnt * 1.0 / t.total) < 0/01
ORDER BY pers ASC ;

 -- second solution 
SELECT country,COUNT(*) AS usre_count
FROM users
GROUP BY country
HAVING (count(*) *1.0/(SELECT count(*)
FROM users)) < 0.01;

-- question 7
-- Find orders whose total amount does not add up to the sum of their items
SELECT 
	order_id
FROM
	order_items
INNER JOIN orders ON  order_items.order_id = orders.id
WHERE
	quantity * price != total_amount; 
-- second solution
SELECT 
	order_id
FROM
	order_items
LEFT JOIN orders ON  
       order_items.order_id = orders.id
WHERE order_id IS NULL;

-- question 6
-- List users who registered but did not make a single purchase
SELECT 
	users.id
FROM
	users
LEFT JOIN orders ON  users.id = orders.user_id
WHERE
	orders.id IS NULL;

-- part 2 : Key Sales Metrics
-- questin 1
-- What is the store's total revenue?
SELECT 
	SUM(total_amount)
FROM orders;

-- question 2
-- What is the month to month revenue?
SELECT 
	SUM(total_amount),
    order_date
FROM orders
group by order_date
ORDER BY order_date;

-- question 3
-- What is average order amount?
SELECT id AS orders,AVG(total_amount) AS average
FROM orders
GROUP BY id;

-- question 4
-- How much revenue does each user generate on average?
SELECT user_id AS customers,AVG(total_amount) AS average
FROM orders
GROUP BY user_id;
 
-- question 5
-- What percentage of total revenue does each country generate?
SELECT 
     country,
     SUM(total_amount),
     ROUND(SUM(total_amount) * 1.0 /(
     SELECT SUM(total_amount)
     FROM orders),2) AS pers
FROM users
JOIN orders ON users.id=orders.user_id
GROUP BY country;

-- Part 3 ; coustomer behavior
-- question 1
-- How many orders has each user placed?
SELECT user_id , COUNT(order_date)
FROM orders
GROUP BY user_id;

-- question 2
-- Divid the users into two catagories:
--            * THOSE who have only purchased once
--            * THOSE who have only purchased more than once
SELECT user_id , COUNT(order_date)
FROM orders
GROUP BY user_id
HAVING COUNT(order_date) = 1 ;
-- نمیشه با هم اجرا کرد ؟
SELECT user_id , COUNT(order_date)
FROM orders
GROUP BY user_id
HAVING COUNT(order_date) > 1;

-- question 3
-- what is the time interval between each user's purchases?
SELECT user_id ,
	order_date,
    perv_order_date,
    datediff(order_date,perv_order_date) AS distance
FROM (
    SELECT 
         user_id,
         order_date,
         LAG(order_date) OVER (PARTITION BY user_id ORDER BY order_date) AS perv_order_date
	FROM orders
) AS shop
WHERE perv IS NOT NULL;

-- question 4
-- who are the 10 users who spent the most money?
SELECT 
      user_id,
      SUM(total_amount) AS total
FROM orders
GROUP BY user_id
ORDER BY total DESC
LIMIT 10;

-- question 5
-- See how times most users purchase
SELECT 
      cnt_order,
      COUNT(*) AS number_of_users
FROM (
     SELECT user_id,COUNT(*) AS cnt_order
	 FROM orders
	 GROUP BY user_id
) AS count_orders
GROUP BY cnt_order
ORDER BY cnt_order;

-- PART 4 : product analyze
-- question 1 star
-- How much revenue did each product generate?
SELECT
    product_id,
    SUM(quantity * price) AS product_revenue
FROM order_items
GROUP BY product_id;

-- question 2
-- How much revenue did each product caegory generate ?
SELECT category,SUM(total_amount)
FROM order_items
LEFT JOIN products ON products.id = order_items.product_id
LEFT JOIN orders ON orders.id = order_items.order_id
GROUP BY category
ORDER BY SUM(total_amount) DESC;

-- question 3
-- Find products that had no sales
SELECT p.*
FROM products p
LEFT JOIN order_items oi ON oi.product_id= p.id
WHERE oi.product_id IS NULL;

-- question 4 
-- What are the top 5 products that had the most sales?
SELECT product_id,SUM(quantity)
FROM order_items
GROUP BY product_id
ORDER BY SUM(quantity) DESC
LIMIT 5;

-- question 5
-- Identity products that were recently added but have no sales yet
SELECT p.*
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
WHERE oi.product_id IS NULL 
   AND created_at >= (CURDATE()- INTERVAL 30 DAY);

-- Second solution
SELECT p.*
FROM products p
WHERE created_at >= (CURDATE()- INTERVAL 30 DAY)
  AND NOT EXISTS(
     SELECT 1 
     FROM order_items oi
     WHERE oi.product_id=p.id
);

-- PART 5 : time analyze
-- question 1
-- Calculate your monthly income and see the trend
SELECT MONTH(order_date) month,SUM(total_amount)
FROM orders
GROUP BY MONTH(order_date)
ORDER BY SUM(total_amount);
-- need more info

-- question 2
-- What is your average daily income?
SELECT  
        (SUM(total_amount)/DATEDIFF(MAX(order_date), MIN(order_date))+1)
        AS avg_daily_revenue
FROM orders;
-- OR 
SELECT  
        (SUM(price * quantity)/DATEDIFF(MAX(order_date), MIN(order_date))+1)
        AS avg_daily_revenue
FROM orders o
JOIN order_items oi ON oi.order_id=o.id ;

-- question 3
-- When was your best and wrost day?
(SELECT  o.order_date AS the_best_day
        ,SUM(price * quantity) AS daily_revenue
FROM orders o
JOIN order_items oi ON oi.order_id=o.id 
GROUP BY o.order_date
ORDER BY daily_revenue DESC
limit 1)
UNION 
(SELECT  o.order_date AS the_worst_day
        ,SUM(price * quantity)  AS daily_revenue
FROM orders o
JOIN order_items oi ON oi.order_id=o.id 
GROUP BY o.order_date
ORDER BY daily_revenue ASC
limit 1);

-- question 4
-- Are sales better on weekens or weekdays?
SELECT 
    day_type, AVG(daily_revenue) Aavg_daily_revnue
FROM
    (SELECT 
        DATE(order_date) day,
            CASE
                WHEN DAYOFWEEK(order_date) IN (6 , 7) THEN 'weekend'
                ELSE 'weekday'
            END AS day_type,
            SUM(total_amount) AS daily_revenue
    FROM
        orders
    GROUP BY DATE(order_date) , day_type) AS daily
GROUP BY day_type;

-- question 5
-- Has your monthly income increased or decreased compared to the previous month?
SELECT 
     month,
     current_revenue,
     perv_revenue,
     CASE 
         WHEN current_revenue > perv_revenue THEN 'positive'
         WHEN current_revenue < perv_revenue THEN 'Negetive'
         ELSE 'not change'
	 END AS trend
FROM(
     SELECT 
         DATE_FORMAT(order_date,'%Y_%m') AS month,
         SUM(total_amount) AS current_revenue,
         LAG(SUM(total_amount))OVER(ORDER BY  DATE_FORMAT(order_date,'%Y_%m'))  AS perv_revenue
	FROM orders
    GROUP BY month
)AS m
WHERE perv_revenue IS NOT NULL;

-- PART 6 : Advance SQL 
-- question 1
-- Calculate revenue cumulatively over time
WITH daily_sales AS (
    SELECT 
         DATE(order_date) AS days,
         SUM(total_amount) AS daily_revenue
	FROM orders
    GROUP BY days
)
SELECT 
      days,
      daily_revenue,
      SUM(daily_revenue) OVER (ORDER BY days) AS cumulative_revenue
FROM daily_sales
ORDER BY days;

-- question 2
-- Rank users based on the revenue they generate 
SELECT 
	user,
    total_rev,
    DENSE_RANK()OVER(ORDER BY total_rev DESC)
FROM(
    SELECT
         user_id  AS user,
         SUM(total_amount) AS total_rev
	FROM orders
    GROUP BY user
) AS t;

-- question 3
-- See what percentage of total revenue the top 20 %  of users generate
WITH user_revenue as(
     SELECT 
          user_id,
          SUM(total_amount) AS revenue
	FROM orders
    GROUP BY user_id
),
ranked_user AS(
    SELECT
          revenue,
          ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn,
          COUNT(*) OVER() AS total_users
	FROM user_revenue
),
top_20_percent AS (
	SELECT 
         revenue,
         rn,
         total_users,
         total_users * 0.2 AS top_20_count 
	FROM ranked_user
    WHERE rn <= GREATEST(CEILING(total_users * 0.2),1)
),
total_stats AS (
    SELECT
         (SELECT SUM(revenue) FROM user_revenue) AS total_revenue,
         (SELECT SUM(revenue) FROM top_20_percent) AS top_20_revenue
)
SELECT 
     top_20_revenue,
     total_revenue,
     ROUND(top_20_revenue / total_revenue * 100 ,2) AS percent_by_top_20
FROM total_stats;

-- question 4
-- Identity each user's first and last purchase
SELECT
      user_id,
	  MIN(order_date) AS fist_order,
      MAX(order_date) as last_order
FROM orders
GROUP BY user_id;

-- question 5
-- Do  a simple calculate of each user's lifetime value (LTV)
SELECT 
     u.id,
     COALESCE(SUM(total_amount),0) AS LTV
FROM users AS u
LEFT JOIN orders o ON u.id=o.user_id
GROUP BY u.id
ORDER BY LTV DESC;
          
-- Part 7 : SEGMENT
-- question 1
-- Segment usres into low,medium,and high value
WITH user_ltv AS (
        SELECT 
             u.id user,
             COALESCE(SUM(total_amount),0) AS LTV
        FROM users AS u
        LEFT JOIN orders o ON u.id=o.user_id
        GROUP BY u.id
),
ranked_user AS (
        SELECT 
             user,
             LTV,
             NTILE(4)OVER(ORDER BY LTV) AS quart
		FROM user_ltv
)
SELECT
      user,
      LTV,
      CASE
          WHEN  quart = 1 THEN 'low'
          WHEN  quart IN (2,3) THEN 'medium'
          WHEN  quart = 4 THEN 'high'
		END AS customr_value
FROM ranked_user;
          
-- question 2
-- Segment products based on sales
WITH product_sales AS (
        SELECT
           product_id AS product,
           SUM(quantity * price) AS total_sales
        FROM order_items
        GROUP BY product
        ORDER BY total_sales DESC
),
cumulativ AS (
        SELECT
           *,
           SUM(total_sales) OVER (ORDER BY total_sales DESC) AS cumulative_sales,
           SUM(total_sales)OVER() AS total_sales_all_products
		FROM product_sales
),
total_percent AS(
        SELECT
            *,
            ROUND((cumulative_sales / total_sales_all_products *100),2) AS percent_cumulative
		FROM cumulativ
)
SELECT
   *,
   CASE
      WHEN percent_cumulative <=70 THEN 'group A'
      WHEN percent_cumulative <=90 THEN 'group B'
      ELSE 'group C'
   END AS ABC_product_type
   FROM total_percent
   ORDER BY total_sales DESC;
   
   -- question 3
   -- How much of the total revenue does each segment generate?
WITH product_sales AS (
        SELECT
           product_id AS product,
           SUM(quantity * price) AS total_sales
        FROM order_items
        GROUP BY product
        ORDER BY total_sales DESC
),
cumulativ AS (
        SELECT
           *,
           SUM(total_sales) OVER (ORDER BY total_sales DESC) AS cumulative_sales,
           SUM(total_sales)OVER() AS total_sales_all_products
		FROM product_sales
),
final_percent AS(
        SELECT
            *,
            ROUND((cumulative_sales / total_sales_all_products *100),2) AS percent_cumulative
		FROM cumulativ
),
ABC_catagory AS (
       SELECT
           *,
		    CASE
                WHEN percent_cumulative <=70 THEN 'group A'
                WHEN percent_cumulative <=90 THEN 'group B'
                ELSE 'group C'
            END AS ABC_product_type
      FROM final_percent
)
SELECT 
     ABC_product_type,
     ROUND(SUM(total_sales),2) AS total_sales,
     ROUND(SUM(total_sales)/(SELECT SUM(total_sales) FROM ABC_catagory)*100,2)AS
     percentage_of_total,
     SUM(ROUND(SUM(total_sales)/(SELECT SUM(total_sales) FROM ABC_catagory)*100,2))OVER(ORDER BY ABC_product_type ) as total_percent
     FROM ABC_catagory
     GROUP BY ABC_product_type
     ORDER BY ABC_product_type;

-- question 4
-- Who are the VIP users in each country
WITH user_ltv AS (
        SELECT 
             u.id user,
             country,
             COALESCE(SUM(total_amount),0) AS LTV
        FROM users AS u
        LEFT JOIN orders o ON u.id=o.user_id
        GROUP BY u.id
),
ranked_user AS (
        SELECT 
             *,
             COUNT(*)OVER(PARTITION BY country) AS total_users_of_country,
             ROW_NUMBER()OVER(PARTITION BY country ORDER BY LTV DESC) AS rank_LTV
		FROM user_ltv
)
SELECT
     user,
     country,
     total_users_of_country,
     rank_LTV,
     total_users_of_country * 0.1  AS ten_top_percent
FROM ranked_user
WHERE rank_LTV <= GREATEST(CEILING(total_users_of_country * 0.1),1);
   
-- PART 8 : Hnaling NULL Values
 -- question 1
 -- Find orders that have no items
 SELECT 
      o.*
FROM orders o
LEFT JOIN order_items oi ON  o.id = oi.order_id
WHERE oi.order_id IS NULL;

-- question 2
-- Find items that have zero price or quantity
SELECT
     id
     FROM order_items
     WHERE quantity = 0
			OR price = 0;

-- question 3
-- Check for users who have a lot of strange orders in a very short time
WITH user_canceles AS (
    select
        user_id,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN stats IN ('cancelled','returned') THEN 1 ELSE 0 END) -- i know we do not have stats table
        AS problemtic_orders
	FROM orders
    GROUP BY user_id
)
SELECT 
     user_id,
     total_orders,
     problemtic_orders,
     ROUND(problemtic_orders/total_orders  * 100,2) AS canelled_return_orders
FROM user_canceles
WHERE total_orders >= 5
   AND problemtic_orders >= 3
   AND problemtic_orders * 1.0 / total_orders > 0.5
ORDER BY canelled_return_orders DESC;
     
    
-- question 4.1
-- Report any incomplete or suspicious data you see
SELECT 
    o.id AS order_id,
    o.user_id,
    o.order_date,
    o.total_amount
FROM orders o
LEFT JOIN users u
    ON o.user_id = u.id
WHERE u.id IS NULL;

-- 4.2 Invalid Order Items
-- Find order items with zero or negative quantity or price

SELECT 
    o.id AS order_id,
    o.order_date,
    o.total_amount
FROM orders o
LEFT JOIN order_items oi
    ON o.id = oi.order_id
WHERE oi.id IS NULL;
    
-- 4.3 Unusual Order Frequency
-- Find customers who placed at least 3 orders within 10 minutes

SELECT
    o1.customer_id,
    o1.order_id AS first_order_id,
    o2.order_id AS second_order_id,
    o1.order_date AS first_order_date,
    o2.order_date AS second_order_date,
    TIMESTAMPDIFF(
        MINUTE,
        o1.order_date,
        o2.order_date
    ) AS time_difference_minutes
FROM orders o1
JOIN orders o2
    ON o1.customer_id = o2.customer_id
    AND o1.order_id < o2.order_id
    AND o2.order_date >= o1.order_date
    AND o2.order_date <= DATE_ADD(
        o1.order_date,
        INTERVAL 10 MINUTE
    )
ORDER BY
    o1.customer_id,
    o1.order_date;
    
-- 4.4.A Orders Without Valid Customers

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.total_amount
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 4.4.B Order Items Without Valid Products

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 4.4.C Orders With Invalid Total Amount

SELECT 
    id AS order_item_id,
    order_id,
    product_id,
    quantity,
    price
FROM order_items
WHERE quantity <= 0
   OR price <= 0;
   
-- 4.4.D Customers With Missing Signup Date

SELECT 
    u.id AS user_id,
    u.signup_date,
    MIN(o.order_date) AS first_order_date
FROM users u
JOIN orders o
    ON u.id = o.user_id
WHERE u.signup_date IS NULL
   OR u.signup_date > o.order_date
GROUP BY 
    u.id,
    u.signup_date;

-- 4.4.E Products With Missing Category

SELECT 
    o.id AS order_id,
    o.user_id,
    u.signup_date,
    o.order_date
FROM orders o
JOIN users u
    ON o.user_id = u.id
WHERE o.order_date < u.signup_date;
-- 4.5  Uncategorized Products   
SELECT 
    id AS product_id,
    category,
    created_at
FROM products
WHERE category IS NULL
   OR TRIM(category) = '';

--4.
SELECT 
    oi.id AS order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.price
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.id
WHERE p.id IS NULL;