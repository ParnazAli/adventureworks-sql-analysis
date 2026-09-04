/*
===============================================================================
Script:      12_report_customers.sql
Layer:       Reports
===============================================================================
Purpose:
    Build a single, reusable, consolidated view of customer behavior and
    demographics — a "one-stop" table for any downstream reporting tool
    or ad-hoc analysis, so nobody has to re-derive age, segment, or
    recency logic from scratch.

Business Question:
    - What does the complete behavioral and demographic profile of each
      customer look like (age, segment, spend, order history, recency)?

View: gold.report_customers

Columns:
    customer_key        Surrogate key of the customer
    customer_number      Natural/business key of the customer
    customer_name         Full name (first + last)
    age                        Current age, computed from birthdate
    age_group              Bucketed age range
    customer_segment    VIP / Regular / New (see docs/data_dictionary.md)
    last_order_date       Most recent order date
    recency                    Months since the last order
    total_orders            Distinct order count
    total_sales              Lifetime revenue from this customer
    total_quantity          Lifetime units purchased
    total_products          Distinct products ever purchased
    lifespan                    Months between first and last order
    avg_order_value       total_sales / total_orders
    avg_monthly_spend  total_sales / lifespan

Notes:
    - The customer_segment thresholds intentionally mirror the ones in
      10_data_segmentation.sql; see that script's header for why the
      logic is duplicated rather than centralized.
    - Both avg_order_value and avg_monthly_spend guard their denominator
      directly (total_orders = 0 / lifespan = 0) rather than checking
      total_sales, so the guard is correct even in edge cases where
      total_sales is non-zero but the denominator is still zero.
===============================================================================
*/

CREATE VIEW gold.report_customers AS
WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(year, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),

customer_aggregation AS (
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation;
