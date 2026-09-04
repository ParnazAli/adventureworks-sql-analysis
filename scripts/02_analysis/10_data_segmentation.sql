/*
===============================================================================
Script:      10_data_segmentation.sql
Layer:       Analysis
===============================================================================
Purpose:
    Bucket products by cost and customers by loyalty/spending into
    business-friendly segments.

Business Question:
    - How many products fall into each cost range?
    - How many customers are VIP, Regular, or New, based on spending and
      loyalty?

Notes:
    - Segment thresholds are intentionally hardcoded business rules
      (see docs/data_dictionary.md for the exact definitions and the
      reasoning behind each cutoff) rather than derived statistically
      (e.g. quartiles) — the goal here is a stable, explainable
      definition of "VIP" that a stakeholder can repeat from memory.
    - The customer segmentation logic here is intentionally the same
      CASE expression used in 12_report_customers.sql; keeping the two
      in sync is a known trade-off of not centralizing it in a single
      view/function — see the README's "Known Limitations" section.
===============================================================================
*/

-- Segmentation Analysis: Products by Cost Range
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


-- Segmentation Analysis: Customers by VIP, Regular, and New Segments
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT
        customer_key,
        CASE
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
