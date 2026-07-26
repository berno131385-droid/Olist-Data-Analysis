USE BrazilianECommerce;
GO

SET NOCOUNT ON;

-- ====================================================================
-- SCRIPT: 01_data_cleaning.sql
-- PROJECT: Olist Brazilian E-Commerce Analysis
-- PURPOSE: Clean raw tables, handle NULLs, fix column schema issues,
--          and deduplicate geolocation data for analytical readiness.
-- ====================================================================

-- --------------------------------------------------------------------
-- STEP 1: INITIAL INSPECTION & RECORD COUNTS
-- --------------------------------------------------------------------
-- Check total row counts across all raw tables to establish a baseline.
SELECT 'olist_orders_dataset' AS table_name, COUNT(*) AS total_rows FROM olist_orders_dataset
UNION ALL
SELECT 'olist_order_items_dataset', COUNT(*) FROM olist_order_items_dataset
UNION ALL
SELECT 'olist_customers_dataset', COUNT(*) FROM olist_customers_dataset
UNION ALL
SELECT 'olist_products_dataset', COUNT(*) FROM olist_products_dataset
UNION ALL
SELECT 'olist_sellers_dataset', COUNT(*) FROM olist_sellers_dataset
UNION ALL
SELECT 'olist_order_payments_dataset', COUNT(*) FROM olist_order_payments_dataset
UNION ALL
SELECT 'olist_order_reviews_dataset', COUNT(*) FROM olist_order_reviews_dataset
UNION ALL
SELECT 'product_category_name_translation', COUNT(*) FROM product_category_name_translation;


-- --------------------------------------------------------------------
-- STEP 2: FIX TRANSLATION SCHEMA & COLUMN NAMES
-- --------------------------------------------------------------------
-- Auto-rename default imported columns (column1, column2) to standard names
-- to avoid Msg 207 (Invalid column name) during downstream joins.
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'product_category_name_translation' AND COLUMN_NAME = 'column1'
)
BEGIN
    EXEC sp_rename 'product_category_name_translation.column1', 'product_category_name', 'COLUMN';
    EXEC sp_rename 'product_category_name_translation.column2', 'product_category_name_english', 'COLUMN';
END;


-- --------------------------------------------------------------------
-- STEP 3: PRODUCTS DATASET - HANDLING MISSING CATEGORIES
-- --------------------------------------------------------------------
-- Fill NULL or empty product categories with 'unspecified' placeholder
UPDATE olist_products_dataset
SET product_category_name = 'unspecified'
WHERE product_category_name IS NULL OR LTRIM(RTRIM(product_category_name)) = '';


-- --------------------------------------------------------------------
-- STEP 4: REVIEWS DATASET - TEXT PLACEHOLDERS
-- --------------------------------------------------------------------
-- Fill missing review titles and messages with default text placeholders
UPDATE olist_order_reviews_dataset
SET review_comment_title = ISNULL(NULLIF(review_comment_title, ''), 'No Title'),
    review_comment_message = ISNULL(NULLIF(review_comment_message, ''), 'No Message');


-- --------------------------------------------------------------------
-- STEP 5: GEOLOCATION DEDUPLICATION (ZIP-CODE AGGREGATION)
-- --------------------------------------------------------------------
-- Problem: Raw geolocation table has duplicate ZIP prefixes with slightly different coordinates,
--          causing Many-to-Many join issues in Power BI.
-- Solution: Aggregate latitude/longitude to create a clean 1-to-1 lookup table.

IF OBJECT_ID('dim_geolocation_clean', 'U') IS NOT NULL 
    DROP TABLE dim_geolocation_clean;

SELECT 
    geolocation_zip_code_prefix AS zip_code_prefix,
    AVG(geolocation_lat) AS latitude,
    AVG(geolocation_lng) AS longitude,
    UPPER(TRIM(MIN(geolocation_city))) AS city,
    UPPER(TRIM(MIN(geolocation_state))) AS state
INTO dim_geolocation_clean
FROM olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix;

-- Verify 1-to-1 uniqueness
SELECT 
    COUNT(DISTINCT zip_code_prefix) AS unique_zip_codes, 
    COUNT(*) AS total_aggregated_rows 
FROM dim_geolocation_clean;


-- --------------------------------------------------------------------
-- STEP 6: DATA INTEGRITY & ANOMALY CHECKS
-- --------------------------------------------------------------------
-- Validate price and payment thresholds to ensure no corrupted financial metrics
SELECT 'Invalid Price Items' AS check_type, COUNT(*) AS anomaly_count
FROM olist_order_items_dataset
WHERE price <= 0 OR freight_value < 0
UNION ALL
SELECT 'Invalid Payments', COUNT(*)
FROM olist_order_payments_dataset
WHERE payment_value <= 0;
