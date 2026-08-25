# ELZACH Technologies
# AXA Insurance Claims - Feature Engineering
# Portfolio Case Study

import pandas as pd
import numpy as np


# ------------------------------------------------------------
# 1. Load cleaned claims data
# ------------------------------------------------------------

claims = pd.read_csv("cleaned_claims.csv")

claims["claim_date"] = pd.to_datetime(
    claims["claim_date"],
    errors="coerce"
)


# ------------------------------------------------------------
# 2. Create claim year and month
# ------------------------------------------------------------

claims["claim_year"] = claims["claim_date"].dt.year

claims["claim_month"] = claims["claim_date"].dt.month


# ------------------------------------------------------------
# 3. Create claim amount bands
# ------------------------------------------------------------

claims["claim_amount_band"] = pd.cut(
    claims["claim_amount"],
    bins=[-np.inf, 25000, 50000, 100000, np.inf],
    labels=[
        "Low",
        "Medium",
        "High",
        "Very High"
    ]
)


# ------------------------------------------------------------
# 4. Create high-value claim indicator
# ------------------------------------------------------------

claims["high_value_claim"] = np.where(
    claims["claim_amount"] >= 100000,
    1,
    0
)


# ------------------------------------------------------------
# 5. Create fraud-risk indicator
# ------------------------------------------------------------

claims["fraud_risk_flag"] = np.where(
    (claims["fraud_indicator"] == 1)
    | (claims["high_value_claim"] == 1),
    1,
    0
)


# ------------------------------------------------------------
# 6. Claim status indicator
# ------------------------------------------------------------

claims["approved_claim"] = np.where(
    claims["claim_status"] == "Approved",
    1,
    0
)


# ------------------------------------------------------------
# 7. Aggregate claim frequency by policy
# ------------------------------------------------------------

policy_claim_frequency = (
    claims.groupby("policy_id")
    .agg(
        claim_count=("claim_id", "count"),
        total_claim_amount=("claim_amount", "sum"),
        average_claim_amount=("claim_amount", "mean"),
        fraud_flag_count=("fraud_indicator", "sum")
    )
    .reset_index()
)


# ------------------------------------------------------------
# 8. Create policy-level risk indicators
# ------------------------------------------------------------

policy_claim_frequency["multiple_claim_flag"] = np.where(
    policy_claim_frequency["claim_count"] > 1,
    1,
    0
)

policy_claim_frequency["high_claim_exposure_flag"] = np.where(
    policy_claim_frequency["total_claim_amount"] >= 100000,
    1,
    0
)


# ------------------------------------------------------------
# 9. Create a simple risk score
# ------------------------------------------------------------

policy_claim_frequency["risk_score"] = (
    policy_claim_frequency["multiple_claim_flag"]
    + policy_claim_frequency["high_claim_exposure_flag"]
    + np.where(
        policy_claim_frequency["fraud_flag_count"] > 0,
        1,
        0
    )
)


# ------------------------------------------------------------
# 10. Assign risk category
# ------------------------------------------------------------

policy_claim_frequency["risk_category"] = pd.cut(
    policy_claim_frequency["risk_score"],
    bins=[-1, 0, 1, 3],
    labels=[
        "Low Risk",
        "Medium Risk",
        "High Risk"
    ]
)


# ------------------------------------------------------------
# 11. Display engineered features
# ------------------------------------------------------------

print("Claim-level features:")
print(
    claims[
        [
            "claim_id",
            "claim_amount",
            "claim_amount_band",
            "high_value_claim",
            "fraud_risk_flag"
        ]
    ].head()
)


print("\nPolicy-level risk features:")
print(policy_claim_frequency.head())


# ------------------------------------------------------------
# 12. Save feature-engineered data
# ------------------------------------------------------------

claims.to_csv(
    "claims_feature_engineered.csv",
    index=False
)

policy_claim_frequency.to_csv(
    "policy_risk_features.csv",
    index=False
)

print("\nFeature engineering completed successfully.")
