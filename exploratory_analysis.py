"""
Construction Operations & Performance Analytics
Python EDA script

Run:
    pip install -r requirements.txt
    python exploratory_analysis.py
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

DATA = "../data/construction_performance_cleaned.csv"
OUT = "../screenshots"
os.makedirs(OUT, exist_ok=True)

df = pd.read_csv(DATA)
df["timestamp"] = pd.to_datetime(df["timestamp"], errors="coerce")

print("Shape:", df.shape)
print("\nMissing values:\n", df.isna().sum().sort_values(ascending=False).head(15))
print("\nDuplicate rows:", df.duplicated().sum())

numeric = df.select_dtypes(include=np.number)
print("\nNumeric summary:\n", numeric.describe().T)

# If the engineered risk level exists, use it; otherwise create a simple operational flag.
if "risk_level" not in df.columns and "risk_score" in df.columns:
    df["risk_level"] = pd.cut(
        df["risk_score"],
        bins=[-np.inf, 50, 75, np.inf],
        labels=["Low", "Medium", "High"]
    )

# Daily KPI table
daily = (
    df.set_index("timestamp")
      .resample("D")
      .agg(
          observations=("risk_score", "size"),
          avg_risk=("risk_score", "mean"),
          avg_cost_deviation=("cost_deviation", "mean"),
          avg_time_deviation=("time_deviation", "mean"),
          avg_utilization=("equipment_utilization_rate", "mean"),
          safety_incidents=("safety_incidents", "sum"),
          material_alerts=("material_shortage_alert", "sum"),
      )
      .reset_index()
)
daily.to_csv("../data/daily_kpis_python.csv", index=False)

# Risk distribution
if "risk_level" in df.columns:
    plt.figure(figsize=(8,5))
    sns.countplot(data=df, x="risk_level", order=["Low","Medium","High"])
    plt.title("Operational Risk Distribution")
    plt.xlabel("Risk Level")
    plt.ylabel("Observations")
    plt.tight_layout()
    plt.savefig(f"{OUT}/risk_distribution.png", dpi=180)
    plt.close()

# Risk trend
daily.set_index("timestamp")["avg_risk"].plot(figsize=(10,5))
plt.title("Average Operational Risk Over Time")
plt.xlabel("Date")
plt.ylabel("Average Risk Score")
plt.tight_layout()
plt.savefig(f"{OUT}/risk_trend.png", dpi=180)
plt.close()

# Utilization vs energy
if {"equipment_utilization_rate","energy_consumption"}.issubset(df.columns):
    plt.figure(figsize=(8,5))
    sns.scatterplot(
        data=df.sample(min(5000, len(df)), random_state=42),
        x="equipment_utilization_rate",
        y="energy_consumption",
        alpha=0.35
    )
    plt.title("Equipment Utilization vs Energy Consumption")
    plt.tight_layout()
    plt.savefig(f"{OUT}/utilization_energy.png", dpi=180)
    plt.close()

print("\nEDA completed. Outputs saved to data/ and screenshots/.")
