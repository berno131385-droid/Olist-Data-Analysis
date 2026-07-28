USE BrazilianECommerce;
GO

SET NOCOUNT ON;

-- ====================================================================
-- SCRIPT: 03_business_analysis.sql
-- PROJECT: Olist Brazilian E-Commerce Analysis
-- PURPOSE: Advanced analytical queries, RFM segmentation, logistics 
--          impact analysis, and category revenue distribution.
-- ====================================================================


-- --------------------------------------------------------------------
-- QUERY 1: MONTHLY REVENUE & ORDER VOLUME TRENDS (GMV Growth)
-- Business Question: How is total GMV and order volume evolving over time?
-- --------------------------------------------------------------------
SELECT 
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.price) AS total_item_revenue,
    SUM(f.freight_value) AS total_freight_revenue,
    SUM(f.total_item_value) AS total_gmv,
    ROUND(AVG(f.total_item_value), 2) AS avg_order_item_value
FROM fact_order_items f
JOIN dim_date d ON f.purchase_date_key = d.date_key
WHERE f.order_status = 'delivered'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- --------------------------------------------------------------------
-- QUERY 2: LOGISTICS IMPACT - DELIVERY DELAY VS REVIEW SCORE
-- Business Question: How do shipping delays impact customer review ratings?
-- --------------------------------------------------------------------
WITH DeliveryStats AS (
    SELECT 
        f.order_id,
        r.review_score,
        f.estimated_vs_actual_diff,
        CASE 
            WHEN f.estimated_vs_actual_diff >= 0 THEN 'On-Time / Early'
            WHEN f.estimated_vs_actual_diff BETWEEN -5 AND -1 THEN '1-5 Days Late'
            WHEN f.estimated_vs_actual_diff BETWEEN -10 AND -6 THEN '6-10 Days Late'
            ELSE '10+ Days Late'
        END AS delivery_performance_bucket
    FROM fact_order_items f
    JOIN olist_order_reviews_dataset r ON f.order_id = r.order_id
    WHERE f.order_status = 'delivered' 
      AND f.estimated_vs_actual_diff IS NOT NULL
)
SELECT 
    delivery_performance_bucket,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(AVG(CAST(review_score AS FLOAT)), 2) AS avg_review_score,
    ROUND(COUNT(CASE WHEN review_score = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS pct_1_star_reviews
FROM DeliveryStats
GROUP BY delivery_performance_bucket
ORDER BY avg_review_score DESC;


-- --------------------------------------------------------------------
-- QUERY 3: RFM CUSTOMER SEGMENTATION (Recency, Frequency, Monetary)
-- Business Question: How are customers grouped based on purchasing behavior?
-- --------------------------------------------------------------------
-- Reference snapshot date set to max purchase date in dataset
DECLARE @MaxDate DATE;
SELECT @MaxDate = MAX(CAST(order_purchase_timestamp AS DATE)) FROM fact_order_items;

WITH CustomerRFM AS (
    SELECT 
        c.customer_unique_id,
        DATEDIFF(DAY, MAX(f.order_purchase_timestamp), @MaxDate) AS recency_days,
        COUNT(DISTINCT f.order_id) AS frequency_orders,
        SUM(f.price) AS monetary_value
    FROM fact_order_items f
    JOIN dim_customers c ON f.customer_id = c.customer_id
    WHERE f.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
RFMScores AS (
    SELECT 
        customer_unique_id,
        recency_days,
        frequency_orders,
        monetary_value,
        NTILE(4) OVER (ORDER BY recency_days ASC) AS R_Score,    -- 4 = Most Recent
        NTILE(4) OVER (ORDER BY frequency_orders DESC) AS F_Score,
        NTILE(4) OVER (ORDER BY monetary_value DESC) AS M_Score   -- 4 = Highest Spending
    FROM CustomerRFM
)
SELECT 
    R_Score,
    M_Score,
    COUNT(customer_unique_id) AS customer_count,
    ROUND(AVG(monetary_value), 2) AS avg_monetary_spend,
    ROUND(AVG(recency_days), 0) AS avg_days_since_last_purchase
FROM RFMScores
GROUP BY R_Score, M_Score
ORDER BY R_Score DESC, M_Score DESC;


-- --------------------------------------------------------------------
-- QUERY 4: PARETO ANALYSIS (80/20 RULE) ON PRODUCT CATEGORIES
-- Business Question: Which top product categories generate 80% of revenue?
-- --------------------------------------------------------------------
WITH CategoryRevenue AS (
    SELECT 
        p.product_category_name,
        SUM(f.price) AS total_category_revenue,
        COUNT(DISTINCT f.order_id) AS total_orders
    FROM fact_order_items f
    JOIN dim_products p ON f.product_id = p.product_id
    WHERE f.order_status = 'delivered'
    GROUP BY p.product_category_name
),
CumRevenue AS (
    SELECT 
        product_category_name,
        total_category_revenue,
        total_orders,
        SUM(total_category_revenue) OVER (ORDER BY total_category_revenue DESC) AS running_total_revenue,
        SUM(total_category_revenue) OVER () AS grand_total_revenue
    FROM CategoryRevenue
)
SELECT 
    product_category_name,
    total_category_revenue,
    total_orders,
    ROUND((total_category_revenue / grand_total_revenue) * 100, 2) AS pct_of_total_revenue,
    ROUND((running_total_revenue / grand_total_revenue) * 100, 2) AS cumulative_revenue_pct,
    CASE 
        WHEN (running_total_revenue / grand_total_revenue) <= 0.80 THEN 'Top 80% Driver (Class A)'
        ELSE 'Remaining 20% (Class B/C)'
    END AS pareto_class
FROM CumRevenue
ORDER BY total_category_revenue DESC;


-- --------------------------------------------------------------------
-- QUERY 5: SELLER QUALITY & RISK ANALYSIS
-- Business Question: Identify high-volume sellers with critically low ratings.
-- --------------------------------------------------------------------
SELECT TOP 20
    s.seller_id,
    s.seller_state,
    COUNT(DISTINCT f.order_id) AS total_orders_fulfilled,
    ROUND(SUM(f.price), 2) AS total_revenue_generated,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_seller_rating,
    ROUND(AVG(CAST(f.actual_delivery_days AS FLOAT)), 1) AS avg_delivery_days
FROM fact_order_items f
JOIN dim_sellers s ON f.seller_id = s.seller_id
JOIN olist_order_reviews_dataset r ON f.order_id = r.order_id
WHERE f.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_state
HAVING COUNT(DISTINCT f.order_id) >= 30 -- Filter for active sellers
ORDER BY avg_seller_rating ASC, total_revenue_generated DESC;
