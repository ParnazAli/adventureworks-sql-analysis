/*
===============================================================================
Script:      02_dimensions_exploration.sql
Layer:       Exploratory
===============================================================================
Purpose:
    Explore the distinct categorical (non-numeric) values in the dimension
    tables before any aggregation is written.

Business Question:
    - Which countries do customers come from?
    - What product categories, subcategories, and product names exist?

Notes:
    - DISTINCT is used deliberately here, before any GROUP BY-based
      analysis, to catch data-quality issues early (typos, inconsistent
      casing, unexpected NULLs) that would otherwise silently split a
      single real-world category into multiple rows downstream.
===============================================================================
*/

-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT
    country
FROM gold.dim_customers
ORDER BY country;

-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;
