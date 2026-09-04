/*
===============================================================================
Script:      01_database_exploration.sql
Layer:       Exploratory
===============================================================================
Purpose:
    Get a first look at the database before writing any analytical query.
    Confirms which tables exist and what columns/data types the key
    dimension table (dim_customers) has.

Business Question:
    - What tables are available in this database?
    - What columns and data types does dim_customers expose?

Notes:
    - INFORMATION_SCHEMA is used instead of sp_help or vendor-specific
      catalog views because it is ANSI-standard and portable across most
      relational databases (not just SQL Server).
    - This script produces no business insight on its own — it is a
      reconnaissance step that de-risks every script that follows it.
===============================================================================
*/

-- Retrieve a list of all tables in the database
SELECT
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

-- Retrieve all columns for a specific table (dim_customers)
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
