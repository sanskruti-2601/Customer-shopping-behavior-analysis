-- =====================================================================
-- Customer Shopping Behavior Analysis — SQL Business Questions
-- =====================================================================
-- Note on Q1/Q7 below: total revenue by group is influenced by group
-- size, so each revenue query is paired with an average-spend-per-
-- customer metric to separate "this group is bigger" from "this group
-- spends more per person."
-- =====================================================================


-- Q1. Which gender and age group combination has the highest average
-- spend per customer (not just total revenue)?
SELECT gender,
       age_group,
       COUNT(customer_id)        AS customer_count,
       ROUND(AVG(purchase_amount), 2) AS avg_spend_per_customer,
       ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY gender, age_group
ORDER BY avg_spend_per_customer DESC;


-- Q2. Does paying with a particular payment method correlate with a
-- higher average order value?
SELECT payment_method,
       COUNT(customer_id)            AS total_orders,
       ROUND(AVG(purchase_amount), 2) AS avg_order_value
FROM customer
GROUP BY payment_method
ORDER BY avg_order_value DESC;


-- Q3. Are subscribed customers less likely to need a discount to make
-- a purchase, compared to non-subscribers?
SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS discount_usage_rate_pct,
       ROUND(AVG(purchase_amount), 2) AS avg_spend
FROM customer
GROUP BY subscription_status;


-- Q4. Which category + size combinations have the lowest average
-- review rating — a potential quality or fit issue worth flagging?
SELECT category,
       size,
       COUNT(customer_id)              AS total_orders,
       ROUND(AVG(review_rating), 2)    AS avg_review_rating
FROM customer
GROUP BY category, size
HAVING COUNT(customer_id) >= 20          -- exclude combinations too small to be meaningful
ORDER BY avg_review_rating ASC
LIMIT 10;


-- Q5. How does average purchase amount vary by shipping type within
-- each product category? (does shipping preference shift by what's
-- being bought, not just overall)
SELECT category,
       shipping_type,
       COUNT(customer_id)              AS total_orders,
       ROUND(AVG(purchase_amount), 2)  AS avg_spend
FROM customer
GROUP BY category, shipping_type
ORDER BY category, avg_spend DESC;


-- Q6. Customer value tiers, based on BOTH purchase frequency history
-- (previous_purchases) and average spend — not previous_purchases
-- alone. Quartiles of previous_purchases are used as the cut points
-- since the field is roughly uniformly distributed across 1-50
-- (25th pct ~13, median ~25, 75th pct ~38), making quartiles a more
-- defensible split than an arbitrary fixed threshold.
WITH customer_value AS (
    SELECT customer_id,
           previous_purchases,
           purchase_amount,
           CASE
               WHEN previous_purchases <= 13 THEN 'Low History'
               WHEN previous_purchases <= 38 THEN 'Mid History'
               ELSE 'High History'
           END AS history_tier,
           CASE
               WHEN purchase_amount < 39 THEN 'Low Spend'
               WHEN purchase_amount <= 81 THEN 'Mid Spend'
               ELSE 'High Spend'
           END AS spend_tier
    FROM customer
)
SELECT history_tier,
       spend_tier,
       COUNT(*) AS customer_count
FROM customer_value
GROUP BY history_tier, spend_tier
ORDER BY history_tier, spend_tier;


-- Q7. Top 3 most purchased items within each category, with their
-- average rating alongside order volume (volume alone doesn't tell
-- you if a popular item is also a well-reviewed one).
WITH item_summary AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id)            AS total_orders,
           ROUND(AVG(review_rating), 2)  AS avg_review_rating,
           ROW_NUMBER() OVER (
               PARTITION BY category
               ORDER BY COUNT(customer_id) DESC
           ) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT category, item_rank, item_purchased, total_orders, avg_review_rating
FROM item_summary
WHERE item_rank <= 3
ORDER BY category, item_rank;


-- Q8. Promo code usage and discount usage were found to be identical
-- for every customer in this dataset during EDA (see notebook) — so
-- rather than treat them as two separate levers, this checks whether
-- discounted purchases skew toward any particular season.
SELECT season,
       COUNT(customer_id) AS total_orders,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS discount_usage_rate_pct
FROM customer
GROUP BY season
ORDER BY discount_usage_rate_pct DESC;
