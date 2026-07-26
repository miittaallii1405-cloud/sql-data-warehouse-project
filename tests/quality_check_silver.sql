/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Purpose:
    Re-run the same checks used on Bronze, now against Silver, to confirm
    the cleaning/transformation actually fixed the problems.
    Every check below should now return NO results if Silver is clean.
===============================================================================
*/

-- ===============================================
-- Checking 'silver.crm_cust_info'
-- ===============================================
-- Check for duplicate or NULL primary keys
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces
SELECT cst_firstname FROM silver.crm_cust_info WHERE cst_firstname != TRIM(cst_firstname);
SELECT cst_lastname FROM silver.crm_cust_info WHERE cst_lastname != TRIM(cst_lastname);
SELECT cst_key FROM silver.crm_cust_info WHERE cst_key != TRIM(cst_key);

-- Data standardization: confirm only readable values now exist
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;


-- ===============================================
-- Checking 'silver.crm_prd_info'
-- ===============================================
-- Check for duplicate or NULL primary keys
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces
SELECT prd_nm FROM silver.crm_prd_info WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or negative numbers in cost
SELECT prd_cost FROM silver.crm_prd_info WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data standardization: confirm only readable product line values exist
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

-- Check for invalid date orders
SELECT * FROM silver.crm_prd_info WHERE prd_end_dt < prd_start_dt;


-- ===============================================
-- Checking 'silver.crm_sales_details'
-- ===============================================
-- Check for invalid dates (should now all be real DATE values or NULL)
SELECT * FROM silver.crm_sales_details WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check sales = quantity * price consistency
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ===============================================
-- Checking 'silver.erp_cust_az12'
-- ===============================================
-- Check for out-of-range birthdates
SELECT bdate FROM silver.erp_cust_az12 WHERE bdate > GETDATE();

-- Data standardization: confirm only Female/Male/n-a values exist
SELECT DISTINCT gen FROM silver.erp_cust_az12;


-- ===============================================
-- Checking 'silver.erp_loc_a101'
-- ===============================================
-- Data standardization: confirm full country names now exist, no blanks/codes
SELECT DISTINCT cntry FROM silver.erp_loc_a101 ORDER BY cntry;


-- ===============================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ===============================================
-- Check for unwanted spaces
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Data standardization: check maintenance values
SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2;
