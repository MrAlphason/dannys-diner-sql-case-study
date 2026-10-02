-- Q1. Total amount spent by each customer

SELECT
    s.customer_id,
    SUM(m.price) AS total_spent
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY s.customer_id;


-- Q2. Number of days each customer visited

SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id;


-- Q3. First item purchased by each customer

SELECT
    s.customer_id,
    m.product_name,
    s.order_date
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
WHERE s.order_date = (
    SELECT MIN(s2.order_date)
    FROM sales s2
    WHERE s2.customer_id = s.customer_id
)
AND s.product_id = (
    SELECT MIN(s3.product_id)
    FROM sales s3
    WHERE s3.customer_id = s.customer_id
    AND s3.order_date = s.order_date
);


-- Q4. Most purchased item overall

SELECT
    m.product_name,
    COUNT(s.product_id) AS purchase_count
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_count DESC
LIMIT 1;


-- Q5. Most popular item for each customer

SELECT
    customer_id,
    product_name,
    purchase_count
FROM (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(*) AS purchase_count,
        RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY COUNT(*) DESC
        ) AS item_rank
    FROM sales s
    JOIN menu m
        ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
) ranked
WHERE item_rank = 1
ORDER BY customer_id;


-- Q6. First item purchased after becoming a member

SELECT
    m.customer_id,
    menu.product_name,
    s.order_date
FROM members m
JOIN sales s
    ON m.customer_id = s.customer_id
JOIN menu
    ON s.product_id = menu.product_id
WHERE s.order_date >= m.join_date
AND s.order_date = (
    SELECT MIN(s2.order_date)
    FROM sales s2
    WHERE s2.customer_id = m.customer_id
    AND s2.order_date >= m.join_date
)
ORDER BY m.customer_id;


-- Q7. Item purchased just before becoming a member

SELECT
    m.customer_id,
    menu.product_name,
    s.order_date
FROM members m
JOIN sales s
    ON m.customer_id = s.customer_id
JOIN menu
    ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date
AND s.order_date = (
    SELECT MAX(s2.order_date)
    FROM sales s2
    WHERE s2.customer_id = m.customer_id
    AND s2.order_date < m.join_date
)
ORDER BY m.customer_id, s.order_date;


-- Q8. Total items and amount spent before membership

SELECT
    m.customer_id,
    COUNT(s.product_id) AS total_items,
    SUM(menu.price) AS total_spent
FROM members m
JOIN sales s
    ON m.customer_id = s.customer_id
JOIN menu
    ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id;


-- Q9. Loyalty points

SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS points
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY s.customer_id;


-- Q10. Loyalty points by the end of January

SELECT
    m.customer_id,
    SUM(
        CASE
            WHEN s.order_date BETWEEN m.join_date
                AND DATE_ADD(m.join_date, INTERVAL 6 DAY)
                THEN menu.price * 20
            WHEN menu.product_name = 'sushi'
                THEN menu.price * 20
            ELSE menu.price * 10
        END
    ) AS points
FROM members m
JOIN sales s
    ON m.customer_id = s.customer_id
JOIN menu
    ON s.product_id = menu.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY m.customer_id;