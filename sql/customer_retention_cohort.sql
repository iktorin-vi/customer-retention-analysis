/*
=============================================================================
PROJECT: CUSTOMER RETENTION ANALYSIS (ONLINE RETAIL)
=============================================================================
Author: Viktoria Kazniienko
Date: 2025-12-29
Database: retention_db
Status: Production Ready

DESCRIPTION:
This script performs a comprehensive Cohort Analysis to evaluate customer 
retention, churn, and repeat purchase behavior.

KEY METRICS:
1. Cohort Retention Rate (Monthly)
2. Repeat Purchase Rate
3. Time to 2nd Purchase (Avg & Median)
4. Churn Rate (90-day logic)
=============================================================================
*/

-- ==========================================================================
-- 1. DATABASE SETUP & DDL
-- ==========================================================================

-- CREATE DATABASE retention_db; -- Run separately if needed

DROP TABLE IF EXISTS retail_transactions;

CREATE TABLE retail_transactions (
    -- Transaction Details
    invoice_no VARCHAR(50),      -- Varchar to handle 'C' prefixes (cancellations)
    stock_code VARCHAR(50),      -- Alpha-numeric codes
    description TEXT,
    quantity INTEGER,
    invoice_date TIMESTAMP,      -- Exact timestamp of purchase
    unit_price NUMERIC(12, 2),   -- Money must ALWAYS be Numeric/Decimal for precision
    customer_id VARCHAR(50),     -- Storing IDs as strings is safer for portability
    country VARCHAR(100),
    
    -- Engineered Time Features
    invoice_month TIMESTAMP,     -- Normalized to 1st day of the month
    first_purchase_date TIMESTAMP,
    order_date DATE,             -- Date only (no time)
    order_month VARCHAR(7),      -- Format 'YYYY-MM'
    
    -- Cohort Features
    cohort_date DATE,
    cohort_month VARCHAR(7),
    
    -- Analytical Metrics
    cohort_index INTEGER,        -- Month number in customer lifecycle (1, 2, 3...)
    total_sum NUMERIC(12, 2)     -- Total Order Value
);

-- ==========================================================================
-- 2. DATA IMPORT NOTE
-- ==========================================================================
/* NOTE: Data is loaded via DBeaver Import Wizard or COPY command 
   from 'data/processed/online_retail_features.csv'.
   Ensure Null values are handled correctly before running analysis.
*/

-- ==========================================================================
-- 3. INDEXING & OPTIMIZATION
-- ==========================================================================

-- Index for customer lookups (Accelerates JOINs and WHERE clauses)
CREATE INDEX idx_customer_id ON retail_transactions(customer_id);

-- Indexes for time-series aggregation
CREATE INDEX idx_invoice_date ON retail_transactions(invoice_date);
CREATE INDEX idx_cohort_month ON retail_transactions(cohort_month);

-- ==========================================================================
-- 4. DATA VALIDATION & SANITY CHECKS
-- ==========================================================================

-- 4.1. Row Count Verification
SELECT COUNT(*) as total_rows FROM retail_transactions;

-- 4.2. Date Range Check
SELECT 
    MIN(order_date) as start_date, 
    MAX(order_date) as end_date 
FROM retail_transactions;

-- 4.3. Unique Customer Count
SELECT COUNT(DISTINCT customer_id) as unique_customers 
FROM retail_transactions;

-- 4.4. Data Sampling (Check format)
SELECT * FROM retail_transactions LIMIT 5;

-- ==========================================================================
-- 5. CORE ANALYSIS: MONTHLY RETENTION COHORTS
-- ==========================================================================
/* Business Value: Shows the percentage of users returning in subsequent months.
   A healthy product should see the curve flatten out, not drop to zero.
*/

WITH cohort_base AS (
    -- Select unique customer-month pairs
    SELECT DISTINCT
        customer_id,
        cohort_month,
        order_month,
        cohort_index
    FROM retail_transactions
    WHERE customer_id IS NOT NULL
),
cohort_sizes AS (
    -- Denominator: How many customers started in each cohort?
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) as original_size
    FROM cohort_base
    GROUP BY cohort_month
),
retention_counts AS (
    -- Numerator: How many of them were active in subsequent months?
    SELECT 
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_id) as active_customers
    FROM cohort_base
    GROUP BY cohort_month, cohort_index
)
-- Final Retention Matrix
SELECT 
    r.cohort_month,
    s.original_size,
    r.cohort_index,
    r.active_customers,
    ROUND((r.active_customers::numeric / s.original_size) * 100, 2) as retention_rate
FROM retention_counts r
JOIN cohort_sizes s ON r.cohort_month = s.cohort_month
ORDER BY r.cohort_month, r.cohort_index;

-- ==========================================================================
-- 6. ADVANCED METRICS & DEEP DIVES
-- ==========================================================================

-- --------------------------------------------------------------------------
-- Metric 1: Purchase History Logic (Window Function)
-- Used to validate the sequence of orders per customer.
-- --------------------------------------------------------------------------
WITH customer_orders AS (
    SELECT DISTINCT
        customer_id,
        invoice_no,
        order_date
    FROM retail_transactions
),
ranked_orders AS (
    SELECT 
        customer_id,
        invoice_no,
        order_date,
        -- Rank orders: 1st purchase, 2nd purchase...
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) as order_num
    FROM customer_orders
)
SELECT * FROM ranked_orders LIMIT 10; -- Sample view

-- --------------------------------------------------------------------------
-- Metric 2: Repeat Customer Rate
-- Business Value: Measures loyalty. What % of customers buy more than once?
-- --------------------------------------------------------------------------
WITH customer_stats AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT invoice_no) as total_orders
    FROM retail_transactions
    GROUP BY customer_id
)
SELECT 
    COUNT(customer_id) as total_customers,
    COUNT(CASE WHEN total_orders >= 2 THEN 1 END) as repeat_customers,
    -- Calculate percentage
    ROUND(
        COUNT(CASE WHEN total_orders >= 2 THEN 1 END)::numeric / COUNT(customer_id) * 100, 
    2) as repeat_rate_percent
FROM customer_stats;

-- --------------------------------------------------------------------------
-- Metric 3: Time to 2nd Purchase
-- Business Value: Helps define the "window of opportunity" for retargeting emails.
-- --------------------------------------------------------------------------
WITH customer_orders AS (
    SELECT DISTINCT customer_id, invoice_no, order_date
    FROM retail_transactions
),
ranked_orders AS (
    SELECT 
        customer_id,
        order_date,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) as rn
    FROM customer_orders
),
second_purchase_diff AS (
    SELECT 
        t1.customer_id,
        -- Calculate gap between 2nd (t2) and 1st (t1) purchase
        (t2.order_date - t1.order_date) as days_diff
    FROM ranked_orders t1
    JOIN ranked_orders t2 ON t1.customer_id = t2.customer_id
    WHERE t1.rn = 1 AND t2.rn = 2 
)
SELECT 
    ROUND(AVG(days_diff), 1) as avg_days_to_2nd_order,
    PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY days_diff) as median_days
FROM second_purchase_diff;

-- --------------------------------------------------------------------------
-- Metric 4: Churn Analysis (90-Day Logic)
-- Business Value: Estimating lost customers. 90 days is a standard threshold for retail.
-- --------------------------------------------------------------------------
WITH last_purchase AS (
    SELECT 
        customer_id,
        MAX(order_date) as last_order_date
    FROM retail_transactions
    GROUP BY customer_id
),
-- Define "Current Date" as the dataset's max date
global_max_date AS (
    SELECT MAX(order_date) as max_date FROM retail_transactions
)
SELECT 
    COUNT(lp.customer_id) as total_customers,
    -- Count churned if last purchase > 90 days ago
    COUNT(CASE WHEN (gmd.max_date - lp.last_order_date) > 90 THEN 1 END) as churned_customers,
    -- Churn Rate Calculation
    ROUND(
        COUNT(CASE WHEN (gmd.max_date - lp.last_order_date) > 90 THEN 1 END)::numeric 
        / COUNT(lp.customer_id) * 100, 
    2) as churn_rate
FROM last_purchase lp, global_max_date gmd;

-- --------------------------------------------------------------------------
-- Metric 5: Cohort Quality (One-Time Buyers)
-- Business Value: Identify which cohorts had low quality (many one-time buyers).
-- --------------------------------------------------------------------------
WITH customer_stats AS (
    SELECT 
        customer_id,
        cohort_month,
        COUNT(DISTINCT invoice_no) as orders_count
    FROM retail_transactions
    GROUP BY customer_id, cohort_month
)
SELECT 
    cohort_month,
    COUNT(customer_id) as cohort_size,
    COUNT(CASE WHEN orders_count = 1 THEN 1 END) as one_time_buyers,
    -- Share of one-time buyers (Lower is better)
    ROUND(
        COUNT(CASE WHEN orders_count = 1 THEN 1 END)::numeric / COUNT(customer_id) * 100, 
    1) as one_time_share_pct
FROM customer_stats
GROUP BY cohort_month
ORDER BY cohort_month;