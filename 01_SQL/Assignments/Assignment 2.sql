use ds13;
select * from customers;
select * from items;
select * from orders;

-- --------------------------------------------------------------------------------------------------------------
-- [Question 1]: You wish to call up regular customers and give them a discount code
-- Find out first_name, last_name, and phone_number for customers that have placed more than 4 orders
-- Sort results by first_name
-- [5 marks]
-- --------------------------------------------------------------------------------------------------------------

SELECT 
    c.first_name,
    c.last_name,
    c.phone_number
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.phone_number
HAVING COUNT(o.order_id) > 4
ORDER BY c.first_name;

-- --------------------------------------------------------------------------------------------------------------
-- [Question 2]: Even though marked as shipped, there was an issue with shipment for orders between the dates of 2022-07-15 and 2022-07-20
-- Find out customer_id, full name, city, phone_number, order_id, order_date, item_name, item_type and item_price for all such orders 
-- so that you can contact customers and let them know their order has not been shipped due to an issue
-- Results should be sorted by order date in ascending order
-- [5 marks]
-- --------------------------------------------------------------------------------------------------------------


SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    c.city,
    c.phone_number,
    o.order_id,
    o.order_date,
    i.item_name,
    i.item_type,
    i.item_price
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN items i ON o.item_id = i.item_id
WHERE o.order_date BETWEEN '2022-07-15' AND '2022-07-20'
ORDER BY o.order_date ASC;

-- --------------------------------------------------------------------------------------------------------------
-- [Question 3]: You wish to see which categories of items are doing well on Fridays. 
-- [5 + 5 marks]
-- --------------------------------------------------------------------------------------------------------------
-- Find out how much of each item_type is ordered on Fridays

SELECT 
    i.item_type,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN items i ON o.item_id = i.item_id
WHERE DAYNAME(o.order_date) = 'Friday'
GROUP BY i.item_type
ORDER BY total_orders DESC;


-- What is the most ordered item_type(s) on Fridays? 
-- Show both item_type and order_count for all such item_types
-- (do not do this with LIMIT. Use subqueries or CTEs) 

WITH friday_orders AS (
    SELECT 
        i.item_type,
        COUNT(o.order_id) AS order_count
    FROM orders o
    JOIN items i ON o.item_id = i.item_id
    WHERE DAYNAME(o.order_date) = 'Friday'
    GROUP BY i.item_type
)
SELECT item_type, order_count
FROM friday_orders
WHERE order_count = (
    SELECT MAX(order_count) FROM friday_orders
);

-- --------------------------------------------------------------------------------------------------------------
-- [Question 4]: You want to rank days of the week according to your order traffic. 
-- [5 + 5 marks]
-- --------------------------------------------------------------------------------------------------------------

-- Rank each day of the week according to the number of orders received (top rank goes to days with most orders)

SELECT 
    DAYNAME(o.order_date) AS day_of_week,
    COUNT(o.order_id) AS order_count,
    RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS day_rank
FROM orders o
GROUP BY DAYNAME(o.order_date)
ORDER BY day_rank;

-- Find out the top 2 ranked days

WITH ranked_days AS (
    SELECT 
        DAYNAME(o.order_date) AS day_of_week,
        COUNT(o.order_id) AS order_count,
        RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS day_rank
    FROM orders o
    GROUP BY DAYNAME(o.order_date)
)
SELECT day_of_week, order_count, day_rank
FROM ranked_days
WHERE day_rank <= 2
ORDER BY day_rank;







