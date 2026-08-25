# ELZACH Technologies
# AXA Insurance Claims - Data Cleaning
# Portfolio Case Study

import pandas as pd
import numpy as np


# ------------------------------------------------------------
# 1. Load claims data
# ------------------------------------------------------------

claims = pd.read_csv("claims.csv")

print("Dataset shape:", claims.shape)
print("\nFirst 5 records:")
print(claims.head())


# ------------------------------------------------------------
# 2. Inspect data types and missing values
# ------------------------------------------------------------

print("\nData types:")
print(claims.dtypes)

print("\nMissing values:")
print(claims.isnull().sum())


# ------------------------------------------------------------
# 3. Remove duplicate records
# ------------------------------------------------------------

duplicate_count = claims.duplicated().sum()

print("\nDuplicate records:", duplicate_count)

claims = claims.drop_duplicates()


# ------------------------------------------------------------
# 4. Handle missing claim amounts
# ------------------------------------------------------------

claims["claim_amount"] = pd.to_numeric(
    claims["claim_amount"],
    errors="coerce"
)

claims["claim_amount"] = claims["claim_amount"].fillna(
    claims["claim_amount"].median()
)


# ------------------------------------------------------------
# 5. Standardize claim status
# ------------------------------------------------------------

claims["claim_status"] = (
    claims["claim_status"]
    .astype(str)
    .str.strip()
    .str.title()
)


# ------------------------------------------------------------
# 6. Convert claim date
# ------------------------------------------------------------

claims["claim_date"] = pd.to_datetime(
    claims["claim_date"],
    errors="coerce"
)


# ------------------------------------------------------------
# 7. Validate claim amounts
# ------------------------------------------------------------

invalid_claims = claims[
    claims["claim_amount"] < 0
]

print(
    "\nInvalid claim amounts:",
    len(invalid_claims)
)

claims.loc[
    claims["claim_amount"] < 0,
    "claim_amount"
] = np.nan

claims["claim_amount"] = claims["claim_amount"].fillna(
    claims["claim_amount"].median()
)


# ------------------------------------------------------------
# 8. Standardize fraud indicator
# ------------------------------------------------------------

claims["fraud_indicator"] = (
    pd.to_numeric(
        claims["fraud_indicator"],
        errors="coerce"
    )
    .fillna(0)
    .astype(int)
)


# ------------------------------------------------------------
# 9. Final validation
# ------------------------------------------------------------

print("\nCleaned dataset shape:", claims.shape)

print("\nRemaining missing values:")
print(claims.isnull().sum())


# ------------------------------------------------------------
# 10. Save cleaned dataset
# ------------------------------------------------------------

claims.to_csv(
    "cleaned_claims.csv",
    index=False
)

print("\nCleaned claims data saved successfully.")
