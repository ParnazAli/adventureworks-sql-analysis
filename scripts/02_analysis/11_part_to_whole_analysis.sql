/*
===============================================================================
Script:      11_part_to_whole_analysis.sql
Layer:       Analysis
===============================================================================
Purpose:
    Compare each product category's share of revenue against its share
    of the product catalog, to see which categories "punch above their
    weight."

Business Question:
    - Which product categories generate revenue disproportionately high
      relative to their representation in the product catalog?

Notes:
    - revenue_efficiency_ratio = (% of total revenue) / (% of total
      catalog). A ratio above 1.0 means the category earns more revenue
      share than its shelf-space share would predict; below 1.0 means
      the opposite. This single number is what actually answers the
      business question — the two percentage columns are there to show
      the reasoning behind it, not just the raw components.
    - SUM(...) OVER () (no PARTITION BY, no ORDER BY) is used to get the
      grand total alongside each category row without a self-join or a
      second pass over the table.
===============================================================================
*/

WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales,
        COUNT(DISTINCT p.product_key) AS total_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    total_products,
    SUM(total_sales) OVER () AS overall_sales,
    SUM(total_products) OVER () AS overall_products,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS revenue_percentage,
    ROUND((CAST(total_products AS FLOAT) / SUM(total_products) OVER ()) * 100, 2) AS catalog_percentage,
    ROUND(
        (CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) /
        (CAST(total_products AS FLOAT) / SUM(total_products) OVER ()), 2
    ) AS revenue_efficiency_ratio
FROM category_sales
ORDER BY revenue_efficiency_ratio DESC;
