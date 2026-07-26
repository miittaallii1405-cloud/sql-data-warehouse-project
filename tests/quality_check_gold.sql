/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Purpose:
    Validate the integrity, consistency, and accuracy of the Gold Layer.
    - Uniqueness of surrogate keys in dimension tables
    - Referential integrity between fact and dimension tables
    - Validation of relationships in the data model

Run these AFTER building the views in gold_transformation_views.sql.
===============================================================================
*/

-- ===============================================
-- Checking 'gold.dim_customers'
-- Check for uniqueness of Customer Key
-- Expectation: No results
-- ===============================================
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ===============================================
-- Checking 'gold.dim_products'
-- Check for uniqueness of Product Key
-- Expectation: No results
-- ===============================================
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ===============================================
-- Checking 'gold.fact_sales'
-- Check the data model connectivity between fact and dimensions
-- Expectation: No results
-- If a row comes back, it means a sale points to a
-- product or customer that doesn't exist in the dimension tables
-- ===============================================
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;
