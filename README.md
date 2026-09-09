# Ecommerce Sales & Customer Analytics Dashboard

An end-to-end analytics project analyzing 5 years of ecommerce transaction data using **MySQL** for data cleaning and analysis, and **Power BI** for building an interactive 3-page dashboard.

## Business Problem

The goal was to turn raw, unexamined ecommerce transaction data into actionable insight — identifying revenue trends, top-performing products and regions, and understanding customer behavior well enough to inform retention strategy.

## Dataset

- **Source:** [E-commerce Sales and Customer Analytics](https://www.kaggle.com/datasets/datascikhan/e-commerce-sales-and-customer-analytics) (Kaggle)
- **Scale:** 25,000 customers, 1,175 products, 138,116 orders and line items, spanning **January 2021 – December 2025**
- **Structure:** 4 relational tables (`customers`, `products`, `sales`, `orders`) imported into MySQL

## Tools Used

- **MySQL** — data cleaning, validation, a unified analytical view, and 10+ SQL queries (aggregations, window functions, CTEs, RFM segmentation)
- **Power BI** — data modeling, DAX measures, and a 3-page interactive dashboard
- **DAX** — Total Revenue, Total Profit, AOV, Profit Margin %, Avg CLV, and time-intelligence calculations

## Process

1. **Data quality checks** — verified the dataset for nulls, duplicate keys, and orphaned records across all 4 tables. Result: zero nulls, zero duplicates, zero orphan rows — a clean starting dataset.
2. **Built a unified SQL view** (`vw_sales_full`) joining all 4 tables with revenue and profit pre-calculated per line item, becoming the single source Power BI connects to.
3. **Ran business analysis queries** in SQL: monthly revenue trends, month-over-month growth, top products, category/regional breakdowns, AOV, new vs. repeat customer split.
4. **Built RFM (Recency, Frequency, Monetary) customer segmentation** using window functions (`NTILE`), classifying all 25,000 customers into Champions / Loyal / At Risk / Lost segments.
5. **Modeled the data in Power BI**: built a proper Date table with DAX, connected it to the fact view, and wrote core measures.
6. **Designed a 3-page dashboard**: Sales Overview, Customer Analytics, and Regional & Product Performance — each interactive with slicers.

## Key Insights

- **Total revenue of ₹71.61M** across 138K orders, with an overall profit margin of ~48%.
- **99.6% of revenue came from repeat customers** — only 524 of ~25,000 customers were one-time buyers, yet they drove almost none of total revenue ($271K vs. $71.3M). This is the single strongest finding in the dataset and a clear signal that customer retention, not acquisition, is where the business creates most of its value.
- **Strong, consistent seasonal spikes every November–December**, repeating across all 5 years of data — a clear holiday-driven demand pattern worth planning inventory and marketing around.
- **Electronics and Jewelry were the top two product categories** by revenue (15.54M and 9.78M respectively), while **USA was the leading market**, followed by UK and Germany.
- **RFM segmentation** revealed a healthy distribution across Champions, Loyal, At Risk, and Lost/Low Value customers — giving a concrete basis for targeted retention campaigns.
- Month-to-month **customer retention rate fluctuated between roughly 4–12%**, with no long-term decline — a stable, if not exceptional, retention pattern.

## Dashboard Pages

**1. Sales Overview** — KPI cards (Revenue, Profit, Orders, AOV), 5-year monthly revenue trend, top 10 products, revenue by category, date range slicer.

**2. Customer Analytics** — RFM segment breakdown, average customer lifetime value, monthly retention rate trend, new vs. repeat customer revenue split.

**3. Regional & Product Performance** — revenue by country, category performance matrix (revenue & profit margin by category × country), revenue by product category, category and country slicers.

*(Add your exported page screenshots here — see upload instructions below.)*

## Files in This Repository

- `ecommerce_analytics.sql` — full SQL script: data quality checks, cleaning, the master view, and all analysis queries
- `dashboard.pdf` — exported 3-page Power BI dashboard
- `screenshots/` — individual page images for quick viewing
