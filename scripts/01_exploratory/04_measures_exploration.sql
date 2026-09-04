/*
===============================================================================
Script:      04_measures_exploration.sql
Layer:       Exploratory
===============================================================================
Purpose:
    Produce a single-glance summary of the core numeric measures (KPIs)
    used throughout the rest of the project.

Business Question:
    - At a high level, how big is this business? (total sales, quantity,
      average price, order count, product count, customer count)

Notes:
    - UNION ALL is used instead of six separate queries so all headline
      KPIs land in one tidy, two-column result set that can be dropped
      straight into a report or dashboard header.
    - UNION ALL (not UNION) is intentional: there is no risk of duplicate
      rows here, and skipping the distinct-check keeps the query cheaper.
===============================================================================
*/

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers;
