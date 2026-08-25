# ELZACH Technologies
# AXA Insurance Claims - Analysis & Business Insights
# Portfolio Case Study

import pandas as pd
import matplotlib.pyplot as plt


# ------------------------------------------------------------
# 1. Load feature-engineered claims data
# ------------------------------------------------------------

claims = pd.read_csv(
    "claims_feature_engineered.csv"
)

claims["claim_date"] = pd.to_datetime(
    claims["claim_date"],
    errors="coerce"
)


# ------------------------------------------------------------
# 2. Overall claims KPIs
# ------------------------------------------------------------

total_claims = len(claims)

total_claim_amount = claims["claim_amount"].sum()

average_claim_amount = claims["claim_amount"].mean()

fraud_flagged_claims = claims["fraud_indicator"].sum()


print("AXA Claims Analysis")
print("-------------------")

print("Total Claims:", total_claims)

print(
    "Total Claim Amount:",
    round(total_claim_amount, 2)
)

print(
    "Average Claim Amount:",
    round(average_claim_amount, 2)
)

print(
    "Fraud Flagged Claims:",
    fraud_flagged_claims
)


# ------------------------------------------------------------
# 3. Claims by status
# ------------------------------------------------------------

claims_by_status = (
    claims.groupby("claim_status")
    .agg(
        claim_count=("claim_id", "count"),
        total_claim_amount=("claim_amount", "sum"),
        average_claim_amount=("claim_amount", "mean")
    )
    .reset_index()
)

print("\nClaims by Status:")
print(claims_by_status)


# ------------------------------------------------------------
# 4. Monthly claims trend
# ------------------------------------------------------------

monthly_claims = (
    claims.groupby(
        claims["claim_date"].dt.to_period("M")
    )
    .agg(
        claim_count=("claim_id", "count"),
        total_claim_amount=("claim_amount", "sum")
    )
    .reset_index()
)

monthly_claims["claim_date"] = (
    monthly_claims["claim_date"]
    .astype(str)
)


print("\nMonthly Claims Trend:")
print(monthly_claims)


# ------------------------------------------------------------
# 5. High-value claims
# ------------------------------------------------------------

high_value_claims = claims[
    claims["claim_amount"] >= 100000
].sort_values(
    "claim_amount",
    ascending=False
)

print("\nHigh-Value Claims:")
print(
    high_value_claims[
        [
            "claim_id",
            "policy_id",
            "claim_amount",
            "claim_status"
        ]
    ].head(10)
)


# ------------------------------------------------------------
# 6. Fraud analysis
# ------------------------------------------------------------

fraud_analysis = (
    claims.groupby("fraud_indicator")
    .agg(
        claim_count=("claim_id", "count"),
        total_claim_amount=("claim_amount", "sum"),
        average_claim_amount=("claim_amount", "mean")
    )
    .reset_index()
)

print("\nFraud Analysis:")
print(fraud_analysis)


# ------------------------------------------------------------
# 7. Visualize claim amount distribution
# ------------------------------------------------------------

plt.figure(figsize=(10, 5))

plt.hist(
    claims["claim_amount"],
    bins=30
)

plt.title("AXA Insurance Claims - Claim Amount Distribution")

plt.xlabel("Claim Amount")

plt.ylabel("Number of Claims")

plt.tight_layout()

plt.show()


# ------------------------------------------------------------
# 8. Visualize monthly claim volume
# ------------------------------------------------------------

plt.figure(figsize=(10, 5))

plt.plot(
    monthly_claims["claim_date"],
    monthly_claims["claim_count"],
    marker="o"
)

plt.title("Monthly Claim Volume")

plt.xlabel("Month")

plt.ylabel("Number of Claims")

plt.xticks(rotation=45)

plt.tight_layout()

plt.show()


# ------------------------------------------------------------
# 9. Export business summary
# ------------------------------------------------------------

business_summary = pd.DataFrame({
    "metric": [
        "Total Claims",
        "Total Claim Amount",
        "Average Claim Amount",
        "Fraud Flagged Claims"
    ],
    "value": [
        total_claims,
        round(total_claim_amount, 2),
        round(average_claim_amount, 2),
        fraud_flagged_claims
    ]
})

business_summary.to_csv(
    "claims_business_summary.csv",
    index=False
)

print(
    "\nBusiness analysis completed successfully."
)
