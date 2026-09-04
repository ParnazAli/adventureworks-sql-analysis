/*
===============================================================================
Script:      08_cumulative_analysis.sql
Layer:       Analysis
===============================================================================
Purpose:
    Show how sales accumulate over time and how the average price trends,
    smoothing out year-to-year noise.

Business Question:
    - How do cumulative (running total) sales and average price evolve
      year over year?

Notes:
    - The yearly aggregation is computed first in a derived table, then
      the running total is layered on top with SUM() OVER (ORDER BY ...)
      — this two-step shape (aggregate, then window) keeps each part of
      the logic readable on its own and easy to unit-test independently.
===============================================================================
*/

SELECT
    order_year,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_year) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_year) AS moving_average_price
FROM (
    SELECT
        DATETRUNC(year, order_date) AS order_year,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) AS yearly_sales;
