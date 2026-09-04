/*
===============================================================================
Script:      07_change_over_time_analysis.sql
Layer:       Analysis
===============================================================================
Purpose:
    Track how sales, customer activity, and quantity evolve month by
    month.

Business Question:
    - What are the monthly sales, active-customer, and quantity trends?

Notes:
    - DATETRUNC(month, order_date) is used instead of FORMAT(order_date,
      'yyyy-MM') because it returns a real DATE value (not a string), so
      the result stays sortable and chart-ready without an extra CAST.
===============================================================================
*/

SELECT
    DATETRUNC(month, order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);
