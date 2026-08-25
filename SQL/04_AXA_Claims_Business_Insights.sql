-- ELZACH Technologies
-- AXA Insurance Claims - Business Insights
-- Portfolio Case Study
-- SQL: MySQL

/*
BUSINESS OBJECTIVE
------------------
Convert claims analysis into business-oriented insights
that can support insurance risk management and reporting.
*/


-- ============================================================
-- 1. Overall claims KPI summary
-- ============================================================

SELECT
    COUNT(*) AS total_claims,
    ROUND(SUM(claim_amount), 2) AS total_claim_amount,
    ROUND(AVG(claim_amount), 2) AS average_claim_amount,
    ROUND(MAX(claim_amount), 2) AS highest_claim_amount,
    SUM(
        CASE
            WHEN fraud_indicator = 1 THEN 1
            ELSE 0
        END
    ) AS fraud_flagged_claims
FROM claims;


-- ============================================================
-- 2. Claims and risk metrics by region
-- ============================================================

SELECT
    cu.region,
    COUNT(c.claim_id) AS total_claims,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_amount,
    ROUND(AVG(c.claim_amount), 2) AS average_claim_amount,
    SUM(
        CASE
            WHEN c.fraud_indicator = 1 THEN 1
            ELSE 0
        END
    ) AS fraud_flagged_claims
FROM customers cu
JOIN policies p
    ON cu.customer_id = p.customer_id
JOIN claims c
    ON p.policy_id = c.policy_id
GROUP BY cu.region
ORDER BY total_claim_amount DESC;


-- ============================================================
-- 3. Policy type performance
-- ============================================================

SELECT
    p.policy_type,
    COUNT(c.claim_id) AS total_claims,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_amount,
    ROUND(AVG(c.claim_amount), 2) AS average_claim_amount
FROM policies p
JOIN claims c
    ON p.policy_id = c.policy_id
GROUP BY p.policy_type
ORDER BY total_claim_amount DESC;


-- ============================================================
-- 4. High-value claims requiring review
-- ============================================================

SELECT
    c.claim_id,
    cu.customer_name,
    cu.region,
    p.policy_type,
    c.claim_amount,
    c.claim_status,
    c.fraud_indicator,
    CASE
        WHEN c.fraud_indicator = 1
             AND c.claim_amount >= 100000
            THEN 'Immediate Review'
        WHEN c.claim_amount >= 100000
            THEN 'High Value Review'
        WHEN c.fraud_indicator = 1
            THEN 'Fraud Review'
        ELSE 'Standard'
    END AS review_priority
FROM claims c
JOIN policies p
    ON c.policy_id = p.policy_id
JOIN customers cu
    ON p.customer_id = cu.customer_id
ORDER BY c.claim_amount DESC;


-- ============================================================
-- 5. Top policyholders by total claim exposure
-- ============================================================

SELECT
    cu.customer_id,
    cu.customer_name,
    cu.region,
    COUNT(c.claim_id) AS claim_count,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_exposure,
    ROUND(AVG(c.claim_amount), 2) AS average_claim_amount
FROM customers cu
JOIN policies p
    ON cu.customer_id = p.customer_id
JOIN claims c
    ON p.policy_id = c.policy_id
GROUP BY
    cu.customer_id,
    cu.customer_name,
    cu.region
ORDER BY total_claim_exposure DESC
LIMIT 10;


-- ============================================================
-- 6. Fraud exposure analysis
-- ============================================================

SELECT
    CASE
        WHEN fraud_indicator = 1 THEN 'Fraud Flagged'
        ELSE 'Not Flagged'
    END AS fraud_status,
    COUNT(*) AS claim_count,
    ROUND(SUM(claim_amount), 2) AS total_claim_amount,
    ROUND(AVG(claim_amount), 2) AS average_claim_amount
FROM claims
GROUP BY
    CASE
        WHEN fraud_indicator = 1 THEN 'Fraud Flagged'
        ELSE 'Not Flagged'
    END
ORDER BY total_claim_amount DESC;


-- ============================================================
-- 7. Claims by year
-- ============================================================

SELECT
    YEAR(claim_date) AS claim_year,
    COUNT(*) AS claim_count,
    ROUND(SUM(claim_amount), 2) AS total_claim_amount,
    ROUND(AVG(claim_amount), 2) AS average_claim_amount
FROM claims
GROUP BY YEAR(claim_date)
ORDER BY claim_year;


-- ============================================================
-- 8. Business-oriented risk summary
-- ============================================================

SELECT
    cu.region,
    COUNT(c.claim_id) AS total_claims,
    SUM(
        CASE
            WHEN c.fraud_indicator = 1 THEN 1
            ELSE 0
        END
    ) AS fraud_flagged_claims,
    ROUND(SUM(c.claim_amount), 2) AS total_claim_amount,
    CASE
        WHEN
            SUM(
                CASE
                    WHEN c.fraud_indicator = 1 THEN 1
                    ELSE 0
                END
            ) >= 5
            OR SUM(c.claim_amount) >= 1000000
            THEN 'High Risk Region'

        WHEN
            SUM(
                CASE
                    WHEN c.fraud_indicator = 1 THEN 1
                    ELSE 0
                END
            ) >= 2
            OR SUM(c.claim_amount) >= 500000
            THEN 'Medium Risk Region'

        ELSE 'Lower Risk Region'
    END AS regional_risk_category
FROM customers cu
JOIN policies p
    ON cu.customer_id = p.customer_id
JOIN claims c
    ON p.policy_id = c.policy_id
GROUP BY cu.region
ORDER BY total_claim_amount DESC;
