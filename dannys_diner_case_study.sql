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
FROM members AS m
JOIN sales AS s
    ON m.customer_id = s.customer_id
JOIN menu
    ON s.product_id = menu.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY m.customer_id;