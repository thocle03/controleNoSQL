/1
CREATE VIEW olist.products_category AS
SELECT 
    p.product_id,
    COALESCE(t.product_category_name_english, 'unknown') AS product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM olist.products_dataset p
LEFT JOIN olist.product_category_name_translation t
ON p.product_category_name = t.product_category_name;




/2
SELECT 
    c.customer_city,
    pc.product_category_name_english,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(oi.price) AS total_revenue
FROM olist.olist_order_items oi
JOIN olist.olist_orders o ON oi.order_id = o.order_id
JOIN olist.olist_customers c ON o.customer_id = c.customer_id
JOIN olist.products_category pc ON oi.product_id = pc.product_id
GROUP BY c.customer_city, pc.product_category_name_english
ORDER BY total_revenue DESC;


/3
SELECT 
    s.seller_city,
    COUNT(DISTINCT oi.seller_id) AS total_sellers,
    SUM(oi.price) AS total_revenue,
    SUM(oi.order_item_id) AS total_quantity_sold
FROM olist.order_items oi
JOIN olist.sellers s ON oi.seller_id = s.seller_id
GROUP BY s.seller_city
ORDER BY total_revenue DESC;


/4
SELECT 
    SUM(price) / COUNT(DISTINCT order_id) AS average_cart_value
FROM olist.order_items;

/5
SELECT 
    r.review_score,
    SUM(oi.price) / COUNT(DISTINCT oi.order_id) AS average_cart_value
FROM olist.order_items oi
JOIN olist.order_reviews r ON oi.order_id = r.order_id
GROUP BY r.review_score
ORDER BY r.review_score DESC;


/6

SELECT 
    r.review_score,
    AVG(DATE_DIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date)) AS avg_estimated_vs_actual_delivery,
    AVG(DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) AS avg_purchase_to_delivery_time
FROM olist.orders o
JOIN olist.order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score DESC;


/7
CREATE VIEW marketing AS
SELECT 
    q.mql_id,
    q.industry,
    q.lead_type,
    q.lead_source,
    c.won_date,
    c.revenue
FROM olist.leads_qualified q
LEFT JOIN leads_closed c ON q.mql_id = c.mql_id;


/8
SELECT 
    COUNT(DISTINCT c.mql_id) * 100.0 / COUNT(DISTINCT q.mql_id) AS conversion_rate
FROM olist.leads_qualified q
LEFT JOIN olist.leads_closed c ON q.mql_id = c.mql_id;

/9
SELECT 
    MIN(won_date) AS first_transaction,
    MAX(won_date) AS last_transaction,
    DATE_DIFF(MAX(won_date), MIN(won_date)) AS duration_days
FROM olist.leads_closed;

/10
SELECT 
    COUNT(*) AS saturday_transactions
FROM olist.leads_closed
WHERE EXTRACT(DAYOFWEEK FROM won_date) = 7;


/11
SELECT 
    sales_rep,
    COUNT(*) AS total_transactions
FROM olist.leads_closed
GROUP BY sales_rep
ORDER BY total_transactions DESC
LIMIT 10;

/12
SELECT 
    COUNT(*) AS cat_prospects_april
FROM olist.leads_closed
WHERE lead_type = 'cat' 
AND EXTRACT(MONTH FROM won_date) = 4;

/13
SELECT 
    industry,
    COUNT(*) AS total_transactions
FROM olist.leads_closed
GROUP BY industry
ORDER BY total_transactions DESC
LIMIT 10;

/14
SELECT 
    DATE_DIFF(won_date, (SELECT MIN(won_date) FROM leads_closed)) AS timelapse_days,
    COUNT(*) AS total_transactions
FROM olist.leads_closed
GROUP BY timelapse_days
ORDER BY timelapse_days;


/15
SELECT 
    EXTRACT(YEAR FROM won_date) AS year,
    EXTRACT(MONTH FROM won_date) AS month,
    SUM(revenue) AS total_revenue
FROM olist.leads_closed
GROUP BY year, month
ORDER BY year, month;

/16
SELECT 
    EXTRACT(YEAR FROM first_sale_date) AS cohort_year,
    EXTRACT(MONTH FROM first_sale_date) AS cohort_month,
    COUNT(DISTINCT seller_id) AS total_sellers
FROM (
    SELECT seller_id, MIN(order_approved_at) AS first_sale_date
    FROM olist.order_items oi
    JOIN olist.orders o ON oi.order_id = o.order_id
    GROUP BY seller_id
) AS first_sales
GROUP BY cohort_year, cohort_month
ORDER BY cohort_year, cohort_month;
