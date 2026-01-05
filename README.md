# Customer Retention & Cohort Analysis
# 🛒 Customer Retention & Cohort Analysis

![Python](https://img.shields.io/badge/Python-3.9%2B-blue?style=for-the-badge&logo=python)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Analysis-150458?style=for-the-badge&logo=pandas)
![SQL](https://img.shields.io/badge/PostgreSQL-Data%20Engineering-336791?style=for-the-badge&logo=postgresql)
![Tableau](https://img.shields.io/badge/Tableau-Visualization-E97627?style=for-the-badge&logo=tableau)

<img width="1360" height="857" alt="image_2026-01-05_14-16-11" src="https://github.com/user-attachments/assets/791f3c9f-2bc5-4c78-a292-ad39b7b95148" />


## 📌 Project Overview
This project analyzes customer behavior for an online retail business using **Cohort Analysis**. The goal is to understand how well the company retains customers after their first purchase and identify where the biggest drop-offs occur. 

By tracking user behavior over time, I identified key patterns in customer loyalty, churn, and the optimal timing for re-engagement campaigns.

---

## 💼 Business Problem
Customer acquisition is expensive. For a business to grow sustainable revenue, it must retain existing users. The key business questions addressed in this analysis are:

* **The "Leaky Bucket":** At what point do we lose the majority of our customers?
* **Loyalty:** What percentage of users are one-time buyers vs. repeat loyalists?
* **Timing:** When is the best time to send a retargeting email to encourage a second purchase?
* **Seasonality:** Do customers acquired during the holidays behave better than others?

---

## 🛠 Tech Stack & Pipeline
The project follows a full-cycle data engineering and analytics pipeline:

* **Python (Pandas):** Data cleaning, preprocessing, and feature engineering (creating Cohort Month, Cohort Index).
* **PostgreSQL:** Data storage and advanced SQL analysis using Window Functions and CTEs.
* **Python (Matplotlib/Seaborn):** Exploratory data analysis and static visualization of retention curves.
* **Tableau:** Interactive dashboard for stakeholders to filter data by country and cohorts.

---

## 📂 Data Description
The dataset contains transaction data for a UK-based online wholesaler (2010-2011).

* **Source:** [Online Retail Dataset (Kaggle/UCI)](https://archive.ics.uci.edu/ml/datasets/online+retail)
* **Size:** ~540k rows.
* **Key Features:** `InvoiceNo`, `StockCode`, `Quantity`, `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country`.

---

## 📊 Methodology
1.  **Data Cleaning:** Handled missing `CustomerID`s, removed cancelled transactions ('C' prefix), and validated date ranges.
2.  **Cohort Engineering:** Assigned a **Cohort Month** (first purchase month) to every user and calculated the **Cohort Index** (months since first purchase).
3.  **SQL Analysis:** Calculated monthly retention rates, churn rates, and repeat purchase ratios using complex SQL queries.
4.  **Visualization:** Built retention heatmaps and curves to visualize the decay in user activity.

### 🔑 Key Metrics Definitions
* **Retention Rate:** The percentage of the original cohort that made a purchase in a subsequent month.
* **Churn Rate:** Percentage of customers who haven't made a purchase in 90+ days.
* **Repeat Purchase Rate:** Percentage of customers with >1 unique invoice.
* **Time to 2nd Purchase:** The number of days between the first and second order.

---

## 💡 Key Insights

📉 **The "Cliff" Drop-off**
Retention drops from 100% to **~20-25% immediately in Month 1**. This indicates a struggle with activation—most users buy once and leave.

👤 **High One-Time Buyer Ratio**
**~65-70%** of the customer base made only a single purchase.

🎄 **Seasonal Outlier**
The **December 2010** cohort performed significantly better (~37% retention in Month 1) compared to 2011 cohorts, suggesting high-quality holiday traffic.

⏳ **The "Golden Window"**
For customers who do return, the median time to the second purchase is **~50 days**. If a user doesn't return by day 60, they are likely churned.

---

## 🚀 Business Recommendations

1.  **Automated Reactivation Flow (Day 45):** Since the median time to repurchase is 50 days, send a personalized email/offer at Day 45 to nudge users before they slip away.
2.  **Focus on the Second Purchase:** With 70% of users being one-time buyers, the marketing strategy should shift from "Acquisition" to "Activation". Implement a post-purchase onboarding series (e.g., "How to use", Cross-sell).
3.  **Investigate Holiday Strategy:** Analyze the marketing channels used in Dec 2010. The users acquired then were more loyal—replicating that strategy could improve overall cohort quality.

---

## 💻 How to Reproduce

### 1. Clone the repository
```bash
git clone [https://github.com/your-username/customer-retention-analysis.git](https://github.com/your-username/customer-retention-analysis.git)
cd customer-retention-analysis
This project analyzes customer retention and repeat purchase behavior using e-commerce transactional data.

## Objectives
- Analyze customer retention and churn
- Perform cohort analysis
- Identify repeat purchase patterns

## Tech Stack
- Python (Pandas)
- PostgreSQL
- SQL
- Matplotlib
- Tableau
