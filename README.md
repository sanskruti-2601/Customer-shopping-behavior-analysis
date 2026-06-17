# Customer Shopping Behavior Analysis

An end-to-end data analytics project on retail customer shopping data, covering data
cleaning and feature engineering in Python, business-question analysis in SQL, and an
interactive Power BI dashboard.

## Project Overview

This project works through a customer shopping trends dataset (3,900 customers, 18
attributes covering demographics, purchase details, and shopping habits) to answer a set of
business questions about customer spend, product performance, and discount behavior.

The dataset is a single snapshot — one row per customer, no transaction timestamps — so this
analysis is scoped to cross-sectional comparisons (how do segments differ from each other
right now) rather than time-series trends or retention cohorts. That distinction matters and
is called out explicitly rather than implied.

**What this project covers:**

- **Data preparation (Python / pandas):** cleaning, missing-value imputation, an outlier
  check, and feature engineering (age groups, a numeric purchase-frequency field, and a
  spend tier) needed for the analysis below
- **Business analysis (SQL):** eight queries answering specific questions about revenue,
  discount behavior, product performance, and customer value segmentation
- **Visualization (Power BI):** an interactive dashboard built on top of the SQL output
- **Findings & recommendations:** summarized below, and in more depth in the project report

## Key Findings

A few things stood out while working through the SQL queries:

- **Subscription status and discount usage are tightly linked.** Every subscribed customer
  in this dataset has a discount applied to their purchase, versus roughly 1 in 5
  non-subscribers. That's a much bigger gap than I expected, and it raises a real question
  for the business: is the subscription program actually working as a loyalty driver, or is
  it functioning as a backdoor discount mechanism that isn't differentiated from regular
  promotions?
- **Average spend per customer is remarkably flat across demographics.** Gender, age group,
  and payment method all show total revenue differences (because group sizes differ), but
  average spend per customer barely moves — it sits in a tight $59–$62 band almost
  everywhere. In other words, *who* a customer is doesn't predict *how much* they spend in
  this dataset nearly as well as I'd assumed going in. That's a useful negative finding: it
  suggests demographic targeting alone wouldn't be a strong lever for this business, and
  spend is probably driven more by what's actually being purchased than who's buying it.
- **`discount_applied` and `promo_code_used` turned out to be identical** for every customer
  — confirmed during EDA in the notebook. Rather than treating these as two separate signals
  (as the dataset structure implies), I dropped the redundant column and used the freed-up
  analysis angle to look at discount usage by season instead.

Full SQL output and the reasoning behind each question is in
[`customer_behavior_sql_queries.sql`](customer_behavior_sql_queries.sql); the data prep and
feature engineering behind it is in
[`Customer_Shopping_Behavior_Analysis.ipynb`](Customer_Shopping_Behavior_Analysis.ipynb).

## How to Run This Project

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/<your-repo-name>.git
   cd <your-repo-name>
   ```

2. **Open `Customer_Shopping_Behavior_Analysis.ipynb`**

   Covers data loading, cleaning, an outlier check, and feature engineering
   (`age_group`, `purchase_frequency_days`, `spend_tier`).

3. **Load the cleaned data into a SQL database**

   The notebook includes commented connection templates for PostgreSQL, MySQL, and MS SQL
   Server — uncomment the one matching your setup and set the relevant environment
   variables (`DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`, `DB_NAME`).

4. **Run the business questions**

   Open [`customer_behavior_sql_queries.sql`](customer_behavior_sql_queries.sql) and run
   against the `customer` table created in the previous step.

5. **Open the Power BI dashboard**

   `customer_behavior_dashboard.pbix` — connect it to the same SQL database to refresh with
   live data, or view the static version.

## Tech Stack

Python (pandas) · SQL (PostgreSQL/MySQL/MS SQL Server) · Power BI

## Dataset

[Customer Shopping Trends Dataset](https://www.kaggle.com/datasets/iamsouravbanerjee/customer-shopping-trends-dataset)
(Kaggle, public domain) — 3,900 rows, 18 columns.

## License

MIT
