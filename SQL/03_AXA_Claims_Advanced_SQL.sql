-- ELZACH Technologies
-- AXA Insurance Claims - Advanced SQL
-- Portfolio Case Study
-- SQL: MySQL

/*
ADVANCED SQL ANALYSIS
---------------------
This section demonstrates advanced SQL techniques used
for insurance claims and risk analysis.

Techniques:
- Common Table Expressions (CTEs)
- Window Functions
- Ranking
- Conditional Aggregation
- Subqueries
*/


-- ============================================================
-- 1. Rank claims by amount within each region
-- ============================================================

SELECT
    cu.region,
    c.claim_id,
    c.claim_amount,
    RANK() OVER (
        PARTITION BY cu.region
        ORDER BY c.claim_amount DESC
    ) AS claim_rank
FROM claims c
JOIN policies p
    ON c.policy_id = p.policy_id
JOIN customers cu
    ON p.customer_id = cu.customer_id
ORDER BY
    cu.region,
    claim_rank;


-- ============================================================
-- 2. Rank customers by total claim amount
-- ============================================================

WITH customer_claims AS (
    SELECT
        cu.customer_id,
        cu.customer_name,
        SUM(c.claim_amount) AS total_claim_amount
    FROM customers cu
    JOIN policies p
        ON cu.customer_id = p.customer_id
    JOIN claims c
        ON p.policy_id = c.policy_id
    GROUP BY
        cu.customer_id,
        cu.customer_name
)

SELECT
    customer_id,
    customer_name,
    ROUND(total_claim_amount, 2) AS total_claim_amount,
    DENSE_RANK() OVER (
        ORDER BY total_claim_amount DESC
    ) AS customer_rank
FROM customer_claims
ORDER BY customer_rank;


-- ============================================================
-- 3. Running total of claims by date
-- ============================================================

SELECT
    claim_date,
    claim_id,
    claim_amount,
    SUM(claim_amount) OVER (
        ORDER BY claim_date, claim_id
    ) AS running_claim_amount
FROM claims
ORDER BY
    claim_date,
    claim_id;


-- ============================================================
-- 4. Average claim amount by region
-- ============================================================

WITH regional_claims AS (
    SELECT
        cu.region,
        COUNT(c.claim_id) AS claim_count,
        SUM(c.claim_amount) AS total_claim_amount,
        AVG(c.claim_amount) AS average_claim_amount
    FROM customers cu
    JOIN policies p
        ON cu.customer_id = p.customer_id
    JOIN claims c
        ON p.policy_id = c.policy_id
    GROUP BY cu.region
)

SELECT
    region,
    claim_count,
    ROUND(total_claim_amount, 2) AS total_claim_amount,
    ROUND(average_claim_amount, 2) AS average_claim_amount
FROM regional_claims
ORDER BY total_claim_amount DESC;


-- ============================================================
-- 5. Customers whose claim amount is above the overall average
-- ============================================================

SELECT
    c.claim_id,
    cu.customer_name,
    c.claim_amount
FROM claims c
JOIN policies p
    ON c.policy_id = p.policy_id
JOIN customers cu
    ON p.customer_id = cu.customer_id
WHERE c.claim_amount > (
    SELECT AVG(claim_amount)
    FROM claims
)
ORDER BY c.claim_amount DESC;


-- ============================================================
-- 6. Fraud rate by region
-- ============================================================

SELECT
    cu.region,
    COUNT(c.claim_id) AS total_claims,
    SUM(
        CASE
            WHEN c.fraud_indicator = 1 THEN 1
            ELSE 0
        END
    ) AS fraud_claims,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN c.fraud_indicator = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(c.claim_id),
        2
    ) AS fraud_rate_percentage
FROM customers cu
JOIN policies p
    ON cu.customer_id = p.customer_id
JOIN claims c
    ON p.policy_id = c.policy_id
GROUP BY cu.region
ORDER BY fraud_rate_percentage DESC;


-- ============================================================
-- 7. Identify high-risk customers using multiple indicators
-- ============================================================

WITH customer_risk AS (
    SELECT
        cu.customer_id,
        cu.customer_name,
        COUNT(c.claim_id) AS claim_count,
        SUM(c.claim_amount) AS total_claim_amount,
        SUM(
            CASE
                WHEN c.fraud_indicator = 1 THEN 1
                ELSE 0
            END
        ) AS fraud_flag_count
    FROM customers cu
    JOIN policies p
        ON cu.customer_id = p.customer_id
    JOIN claims c
        ON p.policy_id = c.policy_id
    GROUP BY
        cu.customer_id,
        cu.customer_name
)

SELECT
    customer_id,
    customer_name,
    claim_count,
    ROUND(total_claim_amount, 2) AS total_claim_amount,
    fraud_flag_count,
    CASE
        WHEN fraud_flag_count >= 2
             AND total_claim_amount >= 100000
            THEN 'High Risk'
        WHEN fraud_flag_count >= 1
             OR total_claim_amount >= 100000
            THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM customer_risk
ORDER BY total_claim_amount DESC;
