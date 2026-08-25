# ELZACH Technologies
# AXA Insurance Claims - Risk Modeling
# Portfolio Case Study

import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    classification_report,
    confusion_matrix,
    roc_auc_score
)


# ------------------------------------------------------------
# 1. Load feature-engineered data
# ------------------------------------------------------------

claims = pd.read_csv(
    "claims_feature_engineered.csv"
)


# ------------------------------------------------------------
# 2. Select modeling features
# ------------------------------------------------------------

features = [
    "claim_amount",
    "high_value_claim",
    "fraud_risk_flag"
]

target = "fraud_indicator"


X = claims[features]
y = claims[target]


# ------------------------------------------------------------
# 3. Split data into training and testing sets
# ------------------------------------------------------------

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)


# ------------------------------------------------------------
# 4. Train Random Forest classifier
# ------------------------------------------------------------

model = RandomForestClassifier(
    n_estimators=100,
    max_depth=6,
    random_state=42,
    class_weight="balanced"
)

model.fit(
    X_train,
    y_train
)


# ------------------------------------------------------------
# 5. Generate predictions
# ------------------------------------------------------------

y_pred = model.predict(X_test)

y_probability = model.predict_proba(
    X_test
)[:, 1]


# ------------------------------------------------------------
# 6. Model evaluation
# ------------------------------------------------------------

print("Confusion Matrix:")
print(confusion_matrix(y_test, y_pred))


print("\nClassification Report:")
print(
    classification_report(
        y_test,
        y_pred,
        zero_division=0
    )
)


# ------------------------------------------------------------
# 7. ROC-AUC
# ------------------------------------------------------------

if y_test.nunique() > 1:
    auc_score = roc_auc_score(
        y_test,
        y_probability
    )

    print("\nROC-AUC:", round(auc_score, 4))
else:
    print(
        "\nROC-AUC cannot be calculated because "
        "the test set contains only one class."
    )


# ------------------------------------------------------------
# 8. Feature importance
# ------------------------------------------------------------

feature_importance = pd.DataFrame({
    "feature": features,
    "importance": model.feature_importances_
}).sort_values(
    "importance",
    ascending=False
)


print("\nFeature Importance:")
print(feature_importance)


# ------------------------------------------------------------
# 9. Save feature importance
# ------------------------------------------------------------

feature_importance.to_csv(
    "claim_risk_feature_importance.csv",
    index=False
)

print(
    "\nRisk modeling completed successfully."
)
