/*
===============================================================================
Script:      13_report_products.sql
Layer:       Reports
===============================================================================
Purpose:
    Build a single, reusable, consolidated view of product performance —
    the product-side counterpart to gold.report_customers.

Business Question:
    - What does the complete sales performance profile of each product
      look like (segment, revenue, orders, recency, monthly run-rate)?

View: gold.report_products

Columns:
    product_key             Surrogate key of the product
    product_name           Product name
    category / subcategory  Product classification
    cost                          Unit cost
    last_sale_date          Most recent sale date
    recency_in_months     Months since the last sale
    product_segment       High-Performer / Mid-Range / Low-Performer
                                   (see docs/data_dictionary.md)
    lifespan                     Months between first and last sale
    total_orders             Distinct order count
    total_sales               Lifetime revenue from this product
    total_quantity           Lifetime units sold
    total_customers        Distinct customers who bought it
    avg_selling_price      Average realized price per unit sold
    avg_order_revenue     total_sales / total_orders
    avg_monthly_revenue  total_sales / lifespan

Notes:
    - avg_selling_price divides sales_amount by quantity per row (not by
      the product's list price) so it reflects the price actually
      realized after any line-level discounting, not the catalog price.
    - Both avg_order_revenue and avg_monthly_revenue guard their own
      denominator (total_orders = 0 / lifespan = 0) directly, the same
      pattern used in gold.report_customers.
===============================================================================
*/

CREATE VIEW gold.report_products AS
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL  -- only consider valid sales dates
),

product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM product_aggregations;
