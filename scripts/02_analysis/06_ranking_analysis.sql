/*
===============================================================================
Script:      06_ranking_analysis.sql
Layer:       Analysis
===============================================================================
Purpose:
    Rank products, customers, and countries to surface top and bottom
    performers.

Business Question:
    - Which 5 products generate the most revenue?
    - Which 5 products generate the least revenue?
    - Who are the top 10 customers by revenue, and top 3 by order count?
    - Which countries buy with unusually high intensity per customer?

Notes:
    - The "Top 5 by revenue" query is written twice on purpose: once with
      TOP (simple, fast, but ties are broken arbitrarily) and once with
      RANK() OVER (...) in a subquery (slightly more verbose, but ties
      share the same rank and the logic is reusable if the threshold
      ever needs to change from "<= 5" to something else).
    - "Purchasing intensity" is defined as total quantity sold divided by
      the number of distinct customers in that country — it highlights
      markets that buy more per customer, not just markets with more
      customers.
===============================================================================
*/

-- Top 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Top 5 products by revenue using RANK() (ties share a rank)
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;

-- 5 worst-performing products by revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- Top 10 customers by revenue
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- Top 3 customers by number of distinct orders
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders DESC;

-- Purchasing intensity by country (sales quantity per customer)
SELECT
    c.country,
    COUNT(DISTINCT f.customer_key) AS total_customers,
    SUM(f.quantity) AS total_quantity,
    ROUND(CAST(SUM(f.quantity) AS FLOAT) / COUNT(DISTINCT f.customer_key), 2) AS quantity_per_customer
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY quantity_per_customer DESC;
