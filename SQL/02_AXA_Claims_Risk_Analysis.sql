-- ELZACH Technologies
-- AXA Insurance Claims - Risk Analysis
-- Portfolio Case Study
-- SQL: MySQL

/*
BUSINESS OBJECTIVE
------------------
Identify policyholders and claims that may require
additional risk investigation.

Representative portfolio schema:
customers, policies, claims
*/


-- ============================================================
-- 1. Claims with customer and policy information
-- ============================================================

SELECT
    c.claim_id,
    p.policy_id,
    cu.customer_id,
    cu.customer_name,
    cu.region,
    p.policy_type,
    c.claim_date,
    c.claim_amount,
    c.claim_status,
    c.fraud_indicator
FROM claims c
JOIN policies p
    ON c.policy_id = p.policy_id
JOIN customers cu
    ON p.customer_id = cu.customer_id;


-- ============================================================
-- 2. Total claims and claim amount by customer
-- ============================================================

SELECT
    cu.customer_id,
    cu.customer_name,
    COUNT(c.claim_id) AS claim_count,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_amount,
    ROUND(AVG(c.claim_amount), 2) AS average_claim_amount
FROM customers cu
JOIN policies p
    ON cu.customer_id = p.customer_id
JOIN claims c
    ON p.policy_id = c.policy_id
GROUP BY
    cu.customer_id,
    cu.customer_name
ORDER BY total_claim_amount DESC;


-- ============================================================
-- 3. Customers with multiple claims
-- ============================================================

SELECT
    cu.customer_id,
    cu.customer_name,
    COUNT(c.claim_id) AS claim_count
FROM customers cu
JOIN policies p
    ON cu.customer_id = p.customer_id
JOIN claims c
    ON p.policy_id = c.policy_id
GROUP BY
    cu.customer_id,
    cu.customer_name
HAVING COUNT(c.claim_id) > 1
ORDER BY claim_count DESC;


-- ============================================================
-- 4. High-value claims
-- ============================================================

SELECT
    c.claim_id,
    cu.customer_name,
    cu.region,
    c.claim_amount,
    c.claim_status
FROM claims c
JOIN policies p
    ON c.policy_id = p.policy_id
JOIN customers cu
    ON p.customer_id = cu.customer_id
WHERE c.claim_amount >= 100000
ORDER BY c.claim_amount DESC;


-- ============================================================
-- 5. Potential fraud indicators
-- ============================================================

SELECT
    c.claim_id,
    cu.customer_name,
    cu.region,
    c.claim_amount,
    c.fraud_indicator,
    c.claim_status
FROM claims c
JOIN policies p
    ON c.policy_id = p.policy_id
JOIN customers cu
    ON p.customer_id = cu.customer_id
WHERE c.fraud_indicator = 1
ORDER BY c.claim_amount DESC;


-- ============================================================
-- 6. Regional claims analysis
-- ============================================================

SELECT
    cu.region,
    COUNT(c.claim_id) AS claim_count,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_amount,
    ROUND(AVG(c.claim_amount), 2) AS average_claim_amount
FROM customers cu
JOIN policies p
    ON cu.customer_id = p.customer_id
JOIN claims c
    ON p.policy_id = c.policy_id
GROUP BY cu.region
ORDER BY total_claim_amount DESC;


-- ============================================================
-- 7. Risk classification using CASE
-- ============================================================

SELECT
    c.claim_id,
    cu.customer_name,
    c.claim_amount,
    c.fraud_indicator,
    CASE
        WHEN c.fraud_indicator = 1
             AND c.claim_amount >= 100000
            THEN 'High Risk'
        WHEN c.fraud_indicator = 1
            THEN 'Medium Risk'
        WHEN c.claim_amount >= 100000
            THEN 'Review Required'
        ELSE 'Normal'
    END AS risk_category
FROM claims c
JOIN policies p
    ON c.policy_id = p.policy_id
JOIN customers cu
    ON p.customer_id = cu.customer_id
ORDER BY c.claim_amount DESC;


-- ============================================================
-- 8. High-risk policyholders
-- ============================================================

SELECT
    cu.customer_id,
    cu.customer_name,
    COUNT(c.claim_id) AS claim_count,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_amount,
    SUM(CASE
        WHEN c.fraud_indicator = 1 THEN 1
        ELSE 0
    END) AS fraud_flag_count
FROM customers cu
JOIN policies p
    ON cu.customer_id = p.customer_id
JOIN claims c
    ON p.policy_id = c.policy_id
GROUP BY
    cu.customer_id,
    cu.customer_name
HAVING
    COUNT(c.claim_id) > 1
    OR SUM(CASE
        WHEN c.fraud_indicator = 1 THEN 1
        ELSE 0
    END) > 0
ORDER BY total_claim_amount DESC;
