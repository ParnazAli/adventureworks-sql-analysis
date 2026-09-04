/*
===============================================================================
Script:      05_magnitude_analysis.sql
Layer:       Analysis
===============================================================================
Purpose:
    Quantify the scale of the business across its main dimensions: where
    customers are, who they are, what is sold, and what it costs.

Business Question:
    - How many customers per country, and by gender?
    - How many products per category, and what does each category cost
      on average?
    - How much revenue does each category and each customer generate?
    - How many items are sold in each country?

Notes:
    - LEFT JOIN (not INNER JOIN) is used for every fact-to-dimension join
      in this project so that a sale is never silently dropped just
      because its product or customer key is missing/unmatched — a
      missing dimension attribute is a data-quality signal worth seeing,
      not a row worth losing.
===============================================================================
*/

-- Total customers by country
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Total customers by gender
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Total products by category
SELECT
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Average cost by each category
SELECT
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Total revenue by each category
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Total revenue by each customer
SELECT
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

-- Distribution of sold items by country
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;
