# Customer Retention & Cohort Analysis

![Python](https://img.shields.io/badge/Python-3.9%2B-blue?style=for-the-badge&logo=python)
![Pandas](https://img.shields.io/badge/Pandas-Feature%20Engineering-150458?style=for-the-badge&logo=pandas)
![SQL](https://img.shields.io/badge/PostgreSQL-Advanced%20Analytics-336791?style=for-the-badge&logo=postgresql)
![Tableau](https://img.shields.io/badge/Tableau-Visualization-E97627?style=for-the-badge&logo=tableau)

Tableau link: https://public.tableau.com/app/profile/viktoriia.kazniienko/viz/CustomerRetention_17675576526660/Dashboard1
<img width="1360" height="857" alt="image_2026-01-05_14-16-11" src="https://github.com/user-attachments/assets/791f3c9f-2bc5-4c78-a292-ad39b7b95148" />


## 📌 Project Overview
This project analyzes customer behavior for an online retail business using **Cohort Analysis**. The goal is to understand how well the company retains customers after their first purchase and identify where the biggest drop-offs occur. 

By tracking user behavior over time, I identified key patterns in customer loyalty, churn, and the optimal timing for re-engagement campaigns.

---

##  Business Problem
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

* **Source:** E-Commerce Data https://www.kaggle.com/datasets/carrie1/ecommerce-data
* **Size:** ~540k rows.
* **Key Features:** `InvoiceNo`, `StockCode`, `Quantity`, `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country`.

---

## 📊 Methodology
1.  **Data Cleaning:** Handled missing `CustomerID`s, duplacates and validated date ranges.
2.  **Cohort Engineering:** Assigned a **Cohort Month** (first purchase month) to every user and calculated the **Cohort Index** (months since first purchase).
3.  **SQL Analysis:** Calculated monthly retention rates, churn rates, and repeat purchase ratios using complex SQL queries.
4.  **Visualization:** Built retention heatmaps and curves to visualize the decay in user activity.

### Key Metrics Definitions
* **Retention Rate:** The percentage of the original cohort that made a purchase in a subsequent month.
* **Churn Rate:** Percentage of customers who haven't made a purchase in 90+ days.
* **Repeat Purchase Rate:** Percentage of customers with >1 unique invoice.
* **Time to 2nd Purchase:** The number of days between the first and second order.

---

## 💡 Key Insights

👥 **Strong Customer Loyalty**
Contrary to typical e-commerce trends where churn is high, this business enjoys a **high retention rate**.
* **65.58%** of customers are **Repeat Buyers** (purchased 2+ times).
* Only **34.42%** are One-Time buyers.
* Total unique customers analyzed: **4,338**.

🎄 **Seasonal Outlier**
The **December 2010** cohort performed significantly better (~37% retention in Month 1) compared to 2011 cohorts, suggesting high-quality holiday traffic.

⏳ **The "Golden Window"**
For customers who do return, the median time to the second purchase is **~50 days**. If a user doesn't return by day 60, they are likely churned.

---

## Business Recommendations

1.  **Automated Reactivation Flow (Day 45):** Since the median time to repurchase is 50 days, send a personalized email/offer at Day 45 to nudge users before they slip away.
2.  **Bridge the "Month 2" Gap:** The analysis reveals a steep drop-off immediately after the first month. To fix this "leaky bucket," marketing efforts must specifically **incentivize a second purchase in the month following the first transaction**.
3.  **Investigate Holiday Strategy:** Analyze the marketing channels used in Dec 2010. The users acquired then were more loyal—replicating that strategy could improve overall cohort quality.

---

## 💻 How to Reproduce

### 1. Clone the repository
```bash
git clone https://github.com/iktorin-vi/customer-retention-analysis.git
cd customer-retention-analysis
### 2. Install
pip install pandas matplotlib seaborn sqlalchemy psycopg2
### 3.Run the analysis
Run the Jupyter Notebooks in the notebooks/ folder sequentially:
01_data_cleaning.ipynb
02_visual_analysis.ipynb
SQL scripts are available in the sql/ folder.
The Tableau workbook (.twbx) is located in the tableau/ folder.

Done by : Viktoriia Kazniienko
LinkedIn: https://www.linkedin.com/in/viktoriia-kazniienko-71605b327/
