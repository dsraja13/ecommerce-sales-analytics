create database sales_analytics

use sales_analytics;

create table customers (
customer_id varchar(50) primary key,
customer_name varchar(100),
gender  varchar(50),
customer_segment varchar(50),
customer_city varchar(100),
customer_state varchar(100),
customer_country varchar(100)
);


create table products(
product_id varchar(50) primary key,
product_name varchar(500),
product_category varchar(200),
product_subcategory varchar(200),
unit_price decimal(10,2),
product_cost decimal(10,2)
);

create table sales(
order_id varchar(50) primary key,
order_date  date,
order_status varchar(100),
customer_id varchar(50),
payment_method varchar(100),
foreign key (customer_id) references customers(customer_id)
);

create table orders(
order_id varchar(50),
product_id varchar(50),
quantity int,
unit_price decimal(10,2),
discount_percentage decimal(5,0),
foreign key (order_id) references sales(order_id),
foreign key (product_id) references products(product_id)
);


LOAD DATA INFILE'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items-selected-columns.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SELECT 'customers' AS tbl, COUNT(*) AS rows_ FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sales', COUNT(*) FROM sales
UNION ALL SELECT 'orders', COUNT(*) FROM orders








SELECT
  SUM(customer_id IS NULL) AS null_customer_id,
  SUM(customer_name IS NULL) AS null_customer_name,
  SUM(gender IS NULL) AS null_gender,
  SUM(customer_segment IS NULL) AS null_segment,
  SUM(customer_city IS NULL) AS null_city
FROM customers;


SELECT
  SUM(order_id IS NULL) AS null_order_id,
  SUM(order_date IS NULL) AS null_order_date,
  SUM(order_status IS NULL) AS null_status,
  SUM(customer_id IS NULL) AS null_customer_id,
  SUM(payment_method IS NULL) AS null_payment
FROM sales;


SELECT
  SUM(order_id IS NULL) AS null_order_id,
  SUM(product_id IS NULL) AS null_product_id,
  SUM(quantity IS NULL OR quantity <= 0) AS bad_quantity,
  SUM(unit_price IS NULL OR unit_price < 0) AS bad_unit_price,
  SUM(discount_percentage IS NULL) AS null_discount
FROM orders;

SELECT customer_id, COUNT(*) FROM customers GROUP BY customer_id HAVING COUNT(*) > 1;

SELECT order_id ,COUNT(*) FROM sales GROUP BY order_id HAVING COUNT(*) > 1;

SELECT COUNT(*) AS orphan_no_sale FROM orders o
LEFT JOIN sales s ON o.order_id = s.order_id
WHERE s.order_id IS NULL;

SELECT COUNT(*) AS orphan_no_product FROM orders o
LEFT JOIN products p ON o.product_id = p.product_id
WHERE p.product_id IS NULL;


CREATE OR REPLACE VIEW vw_sales_full AS
SELECT
    s.order_id,
    s.order_date,
    s.order_status,
    s.payment_method,
    c.customer_id,
    c.customer_name,
    c.gender,
    c.customer_segment,
    c.customer_city,
    c.customer_state,
    c.customer_country,
    p.product_id,
    p.product_name,
    p.product_category,
    p.product_subcategory,
    o.quantity,
    o.unit_price,
    o.discount_percentage,
    p.product_cost,
    ROUND(o.quantity * o.unit_price * (1 - o.discount_percentage / 100), 2) AS revenue,
    ROUND(o.quantity * p.product_cost, 2) AS total_cost,
    ROUND(
      (o.quantity * o.unit_price * (1 - o.discount_percentage / 100)) - (o.quantity * p.product_cost)
    , 2) AS profit
FROM orders o
JOIN sales s     ON o.order_id = s.order_id
JOIN products p  ON o.product_id = p.product_id
JOIN customers c ON s.customer_id = c.customer_id;

use sales_analytics

select count(*) from vW_sales_full
limit 20;


SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM vw_sales_full
GROUP BY month
ORDER BY month;

SELECT
    product_name,
    product_category,
    ROUND(SUM(revenue), 2) AS total_revenue,
    SUM(quantity) AS units_sold
FROM vw_sales_full
GROUP BY product_id, product_name, product_category
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    product_category,
    ROUND(SUM(revenue), 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(revenue) DESC) AS category_rank
FROM vw_sales_full
GROUP BY product_category;

SELECT
    customer_state,
    ROUND(SUM(revenue), 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(DISTINCT order_id) AS orders
FROM vw_sales_full
GROUP BY customer_state
ORDER BY total_revenue DESC;


SELECT
    ROUND(SUM(revenue) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM vw_sales_full;

WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS order_count, SUM(revenue) AS total_revenue
    FROM vw_sales_full
    GROUP BY customer_id
)
SELECT
    CASE WHEN order_count = 1 THEN 'New (1 order)' ELSE 'Repeat (2+ orders)' END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(SUM(total_revenue) * 100.0 / SUM(SUM(total_revenue)) OVER (), 1) AS pct_of_revenue
FROM customer_orders
GROUP BY customer_type;

WITH rfm_base AS (
    SELECT
        customer_id,
        customer_name,
        DATEDIFF((SELECT MAX(order_date) FROM sales), MAX(order_date)) AS recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(revenue), 2) AS monetary
    FROM vw_sales_full
    GROUP BY customer_id, customer_name
),
rfm_scored AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    customer_name,
    recency_days,
    frequency,
    monetary,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Loyal'
        WHEN (r_score + f_score + m_score) >= 5  THEN 'At Risk'
        ELSE 'Lost / Low Value'
    END AS rfm_segment
FROM rfm_scored
ORDER BY rfm_total DESC;


WITH cust_months AS (
    SELECT DISTINCT customer_id, DATE_FORMAT(order_date, '%Y-%m-01') AS order_month
    FROM vw_sales_full
),
retention AS (
    SELECT
        a.order_month,
        COUNT(DISTINCT a.customer_id) AS customers_this_month,
        COUNT(DISTINCT b.customer_id) AS retained_next_month
    FROM cust_months a
    LEFT JOIN cust_months b
        ON a.customer_id = b.customer_id
        AND b.order_month = DATE_ADD(a.order_month, INTERVAL 1 MONTH)
    GROUP BY a.order_month
)
SELECT
    order_month,
    customers_this_month,
    retained_next_month,
    ROUND(retained_next_month * 100.0 / customers_this_month, 1) AS retention_rate_pct
FROM retention
ORDER BY order_month;

SELECT
    order_status,
    COUNT(*) AS num_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_orders
FROM sales
GROUP BY order_status;

SELECT
    ROUND(SUM(revenue) / COUNT(DISTINCT customer_id), 2) AS avg_customer_ltv
FROM vw_sales_full;

select min(order_date),max(order_date) from sales