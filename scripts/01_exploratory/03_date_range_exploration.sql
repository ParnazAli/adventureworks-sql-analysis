/*
===============================================================================
Script:      03_date_range_exploration.sql
Layer:       Exploratory
===============================================================================
Purpose:
    Understand the time boundaries of the transactional data and the age
    distribution of the customer base, before building any time-series or
    demographic analysis.

Business Question:
    - What is the first and last order date, and how many months of sales
      history does the dataset actually cover?
    - Who are the youngest and oldest customers in the dataset?

Notes:
    - DATEDIFF(MONTH, ...) is used rather than a raw day-count subtraction
      because every downstream "lifespan"/"tenure" metric in this project
      (see reports 12 and 13) is expressed in months, so this script
      validates that convention against the real data range up front.
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;
