-- Construction Operations & Performance Analytics
-- PostgreSQL
-- Run after loading data into construction_performance

-- 01. Dataset size
SELECT COUNT(*) AS total_records
FROM construction_performance;

-- 02. Overall KPI summary
SELECT
    COUNT(*) AS records,
    ROUND(AVG(risk_score),2) AS avg_risk_score,
    ROUND(AVG(equipment_utilization_rate),2) AS avg_equipment_utilization,
    ROUND(AVG(cost_deviation),2) AS avg_cost_deviation,
    ROUND(AVG(time_deviation),2) AS avg_time_deviation,
    SUM(safety_incidents) AS total_safety_incidents,
    SUM(material_shortage_alert) AS material_shortage_alerts
FROM construction_performance;

-- 03. Daily performance
SELECT
    DATE(timestamp) AS date,
    COUNT(*) AS observations,
    ROUND(AVG(risk_score),2) AS avg_risk,
    ROUND(AVG(cost_deviation),2) AS avg_cost_deviation,
    ROUND(AVG(time_deviation),2) AS avg_time_deviation
FROM construction_performance
GROUP BY DATE(timestamp)
ORDER BY date;

-- 04. Risk segmentation
SELECT
    risk_level,
    COUNT(*) AS observations,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),2) AS pct_records,
    ROUND(AVG(risk_score),2) AS avg_risk_score
FROM construction_performance
GROUP BY risk_level
ORDER BY avg_risk_score DESC;

-- 05. Machinery utilization by status
SELECT
    machinery_status,
    COUNT(*) AS observations,
    ROUND(AVG(equipment_utilization_rate),2) AS avg_utilization,
    ROUND(AVG(energy_consumption),2) AS avg_energy_consumption
FROM construction_performance
GROUP BY machinery_status
ORDER BY avg_utilization DESC;

-- 06. Material shortage analysis
SELECT
    DATE(timestamp) AS date,
    SUM(material_shortage_alert) AS shortage_alerts,
    COUNT(*) AS observations,
    ROUND(100.0 * SUM(material_shortage_alert) / COUNT(*),2) AS shortage_rate_pct
FROM construction_performance
GROUP BY DATE(timestamp)
ORDER BY shortage_rate_pct DESC;

-- 07. Safety analysis
SELECT
    DATE(timestamp) AS date,
    SUM(safety_incidents) AS safety_incidents,
    ROUND(AVG(risk_score),2) AS avg_risk_score
FROM construction_performance
GROUP BY DATE(timestamp)
ORDER BY safety_incidents DESC;

-- 08. Highest-risk observations
SELECT
    timestamp,
    risk_score,
    cost_deviation,
    time_deviation,
    safety_incidents,
    material_shortage_alert,
    equipment_utilization_rate,
    machinery_status
FROM construction_performance
ORDER BY risk_score DESC
LIMIT 20;

-- 09. Risk vs schedule deviation
SELECT
    risk_level,
    ROUND(AVG(time_deviation),2) AS avg_time_deviation,
    ROUND(AVG(cost_deviation),2) AS avg_cost_deviation,
    ROUND(AVG(equipment_utilization_rate),2) AS avg_utilization
FROM construction_performance
GROUP BY risk_level
ORDER BY avg_time_deviation DESC;

-- 10. Rolling risk score using a window function
SELECT
    timestamp,
    risk_score,
    ROUND(
        AVG(risk_score) OVER (
            ORDER BY timestamp
            ROWS BETWEEN 59 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_60_record_risk
FROM construction_performance
ORDER BY timestamp;

-- 11. Rank observations by operational risk
SELECT
    timestamp,
    risk_score,
    RANK() OVER (ORDER BY risk_score DESC) AS risk_rank
FROM construction_performance;

-- 12. Conditional KPI aggregation
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN risk_score >= 75 THEN 1 ELSE 0 END) AS high_risk_records,
    SUM(CASE WHEN safety_incidents > 0 THEN 1 ELSE 0 END) AS records_with_safety_events,
    SUM(CASE WHEN material_shortage_alert = 1 THEN 1 ELSE 0 END) AS material_alert_records,
    SUM(CASE WHEN time_deviation > 0 THEN 1 ELSE 0 END) AS delayed_records
FROM construction_performance;

-- 13. Daily operational scorecard
WITH daily AS (
    SELECT
        DATE(timestamp) AS date,
        AVG(risk_score) AS avg_risk,
        AVG(cost_deviation) AS avg_cost_dev,
        AVG(time_deviation) AS avg_time_dev,
        AVG(equipment_utilization_rate) AS avg_utilization,
        SUM(safety_incidents) AS safety_incidents,
        SUM(material_shortage_alert) AS material_alerts
    FROM construction_performance
    GROUP BY DATE(timestamp)
)
SELECT *
FROM daily
ORDER BY avg_risk DESC;

-- 14. Risk concentration by machinery status
SELECT
    machinery_status,
    COUNT(*) FILTER (WHERE risk_level = 'High') AS high_risk_records,
    COUNT(*) AS total_records,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE risk_level = 'High') / COUNT(*),
        2
    ) AS high_risk_pct
FROM construction_performance
GROUP BY machinery_status
ORDER BY high_risk_pct DESC;

-- 15. Monthly / period-level summary
SELECT
    DATE_TRUNC('week', timestamp) AS week,
    COUNT(*) AS observations,
    ROUND(AVG(risk_score),2) AS avg_risk,
    ROUND(AVG(equipment_utilization_rate),2) AS avg_utilization,
    SUM(safety_incidents) AS safety_incidents,
    SUM(material_shortage_alert) AS material_alerts
FROM construction_performance
GROUP BY DATE_TRUNC('week', timestamp)
ORDER BY week;
