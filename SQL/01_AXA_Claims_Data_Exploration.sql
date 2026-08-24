-- ELZACH Technologies
-- AXA Insurance Claims - Data Exploration
-- Portfolio Case Study
-- SQL: MySQL

/*
BUSINESS OBJECTIVE
------------------
Explore insurance claims data to identify:
1. Claim patterns
2. High-value claims
3. Claim frequency
4. Policyholder risk indicators
5. Regional claim trends

NOTE:
This portfolio uses a representative insurance schema
based on the AXA Insurance Claims project described by ELZACH.
*/

-- ============================================================
-- TABLES USED
-- ============================================================
-- customers
-- policies
-- claims


-- ============================================================
-- 1. View customer records
-- ============================================================

SELECT
    customer_id,
    customer_name,
    age,
    gender,
    region
FROM customers;


-- ============================================================
-- 2. View policy information
-- ============================================================

SELECT
    policy_id,
    customer_id,
    policy_type,
    policy_start_date,
    policy_end_date,
    premium_amount
FROM policies;


-- ============================================================
-- 3. View claims information
-- ============================================================

SELECT
    claim_id,
    policy_id,
    claim_date,
    claim_amount,
    claim_status,
    fraud_indicator
FROM claims;


-- ============================================================
-- 4. Total number of claims
-- ============================================================

SELECT
    COUNT(*) AS total_claims
FROM claims;


-- ============================================================
-- 5. Total claim amount
-- ============================================================

SELECT
    ROUND(SUM(claim_amount), 2) AS total_claim_amount
FROM claims;


-- ============================================================
-- 6. Average claim amount
-- ============================================================

SELECT
    ROUND(AVG(claim_amount), 2) AS average_claim_amount
FROM claims;


-- ============================================================
-- 7. Highest-value claims
-- ============================================================

SELECT
    claim_id,
    policy_id,
    claim_date,
    claim_amount,
    claim_status
FROM claims
ORDER BY claim_amount DESC
LIMIT 10;


-- ============================================================
-- 8. Claim count by status
-- ============================================================

SELECT
    claim_status,
    COUNT(*) AS claim_count
FROM claims
GROUP BY claim_status
ORDER BY claim_count DESC;


-- ============================================================
-- 9. Total claim amount by status
-- ============================================================

SELECT
    claim_status,
    ROUND(SUM(claim_amount), 2) AS total_claim_amount
FROM claims
GROUP BY claim_status
ORDER BY total_claim_amount DESC;


-- ============================================================
-- 10. Claims flagged as potential fraud
-- ============================================================

SELECT
    claim_id,
    policy_id,
    claim_date,
    claim_amount,
    fraud_indicator
FROM claims
WHERE fraud_indicator = 1
ORDER BY claim_amount DESC;
