# 🛒 Olist E-Commerce Analytics & Business Intelligence

[![SQL Server](https://img.shields.io/badge/Database-SQLServer-red.svg)](https://www.microsoft.com/en-us/sql-server/)
[![PowerBI](https://img.shields.io/badge/Visualization-PowerBI-yellow.svg)](https://powerbi.microsoft.com/)
[![Status](https://img.shields.io/badge/Status-Completed-brightgreen.svg)]()

An end-to-end data analytics project on Brazilian E-Commerce dataset (Olist) containing **100k+ real commercial orders** from 2016 to 2018. This project transforms raw, unstructured relational records into actionable business insights for decision-makers.

---

## 💡 Executive Summary & Strategic Recommendations

To drive profit growth and reduce churn, analysis was conducted across supply chain performance, customer behavior, and category revenue distribution.

| Business Domain | Key Finding / Insight | Impact on Business | Actionable Recommendation |
| :--- | :--- | :--- | :--- |
| 🚚 **Logistics & Quality** | Delivery delays drop review ratings from **4.29 to 1.71★** (over 10 days late). | Extreme customer churn and loss of repeat purchases (Repeat rate is currently <3%). | **Implement Seller SLAs:** Enforce mandatory 24-hour order fulfillment and automatically flag sellers exceeding average shipping limits. |
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
The interactive Power BI report consists of three dedicated pages designed to transition from high-level executive metrics down to operational supply-chain issues and customer retention dynamics.

---

### Page 1: Executive Overview

> **Context:** This view provides a high-level summary of business performance, overall revenue generation, order volumes, and market geography.
<img width="1150" height="652" alt="1" src="https://github.com/user-attachments/assets/6064ed42-2b37-4bad-8f44-1b973f84d4cc" />

#### 💡 Key Insights:
* **Revenue Drivers:** Platform accumulated **$15.84M in Total GMV** across **99K orders**, maintaining an **Average Order Value (AOV) of $160.58**.
* **Regional Dominance:** The state of São Paulo (**SP**) generates the vast majority of total revenue, outperforming all other states by a significant margin.
* **Top Categories:** `health_beauty`, `watches_gifts`, and `bed_bath_table` lead in revenue, serving as the core commercial drivers for the platform.

---

### Page 2: Logistics & Quality Deep-Dive

> **Context:** This view investigates operational bottlenecks, evaluating how logistics fulfillment timelines directly impact customer review scores and brand reputation.


<img width="1137" height="652" alt="2" src="https://github.com/user-attachments/assets/4c082e2f-12cb-432d-b100-1592f0001899" />

#### 💡 Key Insights:
* **Rating Degradation:** Delivery speed is the single primary driver of customer satisfaction. On-time orders average a **4.29★ rating**, whereas severe delays (>10 days) cause scores to plummet to **1.71★**.
* **Geographic Friction:** Remote Northern states (e.g., **AP, RR, AM**) experience critical fulfillment delays, averaging **25–28 days per delivery**.
* **Seller Quality Control:** Isolated a group of **High-Risk Sellers** with high order volumes (>30 orders) but unacceptably low satisfaction ratings (<3.5★), providing actionable targets for vendor management.

---

### Page 3: Customer Retention & Purchasing Patterns

> **Context:** This view focuses on customer lifetime value drivers, analyzing repeat purchase behavior, order distribution across weekdays, and top revenue-generating municipalities.

<img width="1135" height="617" alt="3" src="https://github.com/user-attachments/assets/f599daec-6b8f-438c-93c4-a592553264da" />

#### 💡 Key Insights:
* **Retention Bottleneck:** The platform faces a severe retention challenge — **96.97% of customers are one-time buyers**, with a Repeat Customer Rate of just **~3.0%**.
* **Peak Activity:** Order volume spikes during weekdays (**Monday–Wednesday**) and drops noticeably over the weekend (lowest on **Saturday**), providing clear timing guidelines for promotional push notifications and marketing campaigns.
* **City Concentration:** Capital municipalities (**São Paulo, Rio de Janeiro, Belo Horizonte**) drive the core share of order volumes and customer acquisition.
