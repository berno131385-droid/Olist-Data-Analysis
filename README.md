# 🛒 Olist E-Commerce Analytics & Business Intelligence

[![SQL Server](https://img.shields.io/badge/Database-SQLServer-red.svg)](https://www.microsoft.com/en-us/sql-server/)
[![PowerBI](https://img.shields.io/badge/Visualization-PowerBI-yellow.svg)](https://powerbi.microsoft.com/)
[![Status](https://img.shields.io/badge/Status-In_Progress-brightgreen.svg)]()

An end-to-end data analytics project on Brazilian E-Commerce dataset (Olist) containing **100k+ real commercial orders** from 2016 to 2018. This project transforms raw, unstructured relational records into actionable business insights for decision-makers.

---

## 💡 Executive Summary & Strategic Recommendations

To drive profit growth and reduce churn, analysis was conducted across supply chain performance, customer behavior, and category revenue distribution.

| Business Domain | Key Finding / Insight | Impact on Business | Actionable Recommendation |
| :--- | :--- | :--- | :--- |
| 🚚 **Logistics & Quality** | Delivery delays drop review ratings from **4.29 to 1.62★** (over 10 days late). | Extreme customer churn and loss of repeat purchases (Repeat rate is currently <3%). | **Implement Seller SLAs:** Enforce mandatory 24-hour order fulfillment and automatically flag sellers exceeding average shipping limits. |
| 👥 **Customer Loyalty** | Over **97% of buyers make only a single purchase**; RFM analysis shows a heavily dormant base. | High Customer Acquisition Cost (CAC) is not offset by Customer Lifetime Value (LTV). | **Trigger-Based Marketing:** Launch automated 14-day post-delivery email flows offering targeted category discounts to "Potential Loyalists". |
| 📊 **Product Categories** | **15 out of 70+ categories generate 80% of total revenue** (Pareto 80/20 Rule). | Resource fragmentation across unprofitable low-volume categories. | **Category Focus:** Optimize platform search algorithm and ad spend toward Top-15 drivers (e.g., *bed_bath_table*, *health_beauty*, *sports_leisure*). |
| ⚠️ **Seller Risk** | Top 5% high-volume sellers account for a critical mass of 1-star delivery reviews. | Marketplace brand reputation loss due to unmonitored high-volume merchants. | **Tiered Merchant Limits:** Cap daily allowed order volumes for sellers with ratings below 3.5★ until QA compliance is met. |

---

## 🛠️ Tech Stack & Workflow Architecture

* **Database & Transformation:** SQL Server (SSMS) — Data cleaning, schema DDL, window functions, CTEs.
* **Data Modeling:** Star Schema (1 Fact Table, 4 Dimension Tables) via DBML / dbdiagram.io.
* **Business Analytics Engine:** RFM Segmentation, Pareto (80/20) Analysis, Logistics Delay Impact Metrics.
* **Data Visualization:** Power BI 

---

## 🧹 Step 1: Data Cleaning & Preprocessing

Raw transactional data contained missing values, text formatting inconsistencies, and geolocation duplicates.

### Key Cleaning Tasks Completed:
1. **Geolocation Deduplication:** Consolidated multiple coordinate records per ZIP code into a aggregated 1-to-1 lookup table (`dim_geolocation_clean`).
2. **Schema Alignment:** Fixed missing column mapping in translation datasets to ensure clean joins with English product categories.
3. **Missing Value Handling:** Replaced `NULL` values in category names and customer review titles with standardized text placeholders (`unspecified`, `No Title`).
4. **Data Integrity:** Validated freight costs, product dimensions, and payment thresholds to eliminate negative/zero anomalies.

📄 **[View SQL Cleaning Script](./Data_Cleaning.sql)**

---

## 📐 Step 2: Data Modeling (Star Schema)

To maximize query execution speed and optimize DAX measures in Power BI, the raw relational database was modeled into a **Star Schema** architecture.
# Olist-Data-Analysis
<img width="1397" height="1126" alt="Schema" src="https://github.com/user-attachments/assets/5704e547-f25e-4bfb-81d9-b9ad928720d0" />

---

## 📊 Step 3: Advanced SQL Business Analytics

Five comprehensive analytical scripts were developed to answer core operational and commercial questions:

1. **Monthly GMV & Revenue Growth:** Tracking order trends, average order value (AOV), and seasonal spikes.
2. **Delivery Delay Impact:** Measuring rating decay as shipping time exceeds estimated delivery dates.
3. **RFM Customer Segmentation:** Applying `NTILE(4)` window functions across *Recency*, *Frequency*, and *Monetary* vectors.
4. **Pareto 80/20 Category Analysis:** Calculating cumulative revenue percentages across 70+ product lines.
5. **Seller Performance & Risk Matrix:** Identifying underperforming merchants with high order volumes.

📄 **[View Business Analysis SQL Script](./Business_Analysis.sql)**

---

## 📈 Step 4: Power BI Interactive Dashboard
