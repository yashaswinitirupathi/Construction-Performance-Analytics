# Construction Operations & Performance Analytics

### SQL | Python | Power BI | Data Analytics

## Project Overview
This project analyzes 50,000 time-stamped construction records to monitor cost and schedule deviations, equipment utilization, material shortages, safety incidents, and operational risk.

The project demonstrates an end-to-end analytics workflow:
Raw Data → Data Validation → Python EDA → SQL Analysis → KPI Engineering → Power BI Dashboard → Operational Insights

## Business Questions
- How does operational performance vary over time?
- Which periods show higher operational risk?
- How efficiently is construction equipment being utilized?
- When do material shortage alerts occur?
- How are safety incidents distributed?
- How do cost and schedule deviations change over time?
- Which operational areas require closer monitoring?

## Dataset
The cleaned dataset contains 50,000 timestamped construction observations with workforce, machinery, material, safety, cost, schedule, environmental and risk-related variables.

## Tools
- SQL / PostgreSQL
- Python: pandas, numpy, matplotlib, seaborn
- Power BI
- Excel
- Git/GitHub

## Repository Structure
```text
construction-performance-analytics/
├── README.md
├── data/
│   ├── construction_performance_cleaned.csv
│   ├── daily_kpis.csv
│   ├── machinery_summary.csv
│   ├── optimization_summary.csv
│   ├── risk_level_summary.csv
│   └── utilization_summary.csv
├── sql/
│   └── construction_analysis.sql
├── python/
│   └── exploratory_analysis.py
├── powerbi/
│   └── POWERBI_BUILD_GUIDE.md
├── screenshots/
└── requirements.txt
```

## Data Quality Note
The `performance_score` field has no meaningful variation in this dataset, so it is not used as a machine-learning target. The project therefore focuses on descriptive and diagnostic operational analytics. Relationships are interpreted as associations, not causal effects.
