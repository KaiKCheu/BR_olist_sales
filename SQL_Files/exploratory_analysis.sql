#### Look into olist_orders_dataset ####

SELECT * FROM br_ecommerce.olist_orders_dataset; 

# Get the total amount of rows
SELECT COUNT(order_id) FROM br_ecommerce.olist_orders_dataset; 

# Check the total amount of rows against distinct customer ids for any repeating customers
SELECT COUNT(DISTINCT(customer_id)) FROM br_ecommerce.olist_orders_dataset; 

#### Look into olist_order_payments_dataset ####

SELECT * FROM br_ecommerce.olist_order_payments_dataset;

# List all of the payment types out
SELECT DISTINCT(payment_type) FROM br_ecommerce.olist_order_payments_dataset;

SELECT COUNT(DISTINCT(order_id)) FROM br_ecommerce.olist_order_payments_dataset;

# Count the total orders in comparison to distinct for any differences in data
SELECT COUNT(order_id) FROM br_ecommerce.olist_order_payments_dataset;

# Search for the highest payment value
SELECT * FROM br_ecommerce.olist_order_payments_dataset
ORDER BY payment_value DESC;

# Search for the lowest payment value
SELECT * FROM br_ecommerce.olist_order_payments_dataset
ORDER BY payment_value ASC;

#### Look into olist_products_dataset ####

SELECT * FROM br_ecommerce.olist_products_dataset;

SELECT COUNT(*) FROM br_ecommerce.olist_products_dataset;

# Check to see if thre are any repeating product_ids
SELECT COUNT(DISTINCT(product_id)) FROM br_ecommerce.olist_products_dataset;

#### Look into olist_order_items_dataset ####

SELECT * FROM br_ecommerce.olist_order_items_dataset;

# Check total count
SELECT COUNT(*) FROM br_ecommerce.olist_order_items_dataset;

# Check for any differences in the Data
SELECT COUNT(DISTINCT(order_id)) FROM br_ecommerce.olist_order_items_dataset;

# Check for any differences in the Data
SELECT COUNT(DISTINCT(product_id)) FROM br_ecommerce.olist_order_items_dataset;

# look into use case from the example provided on kaggle
SELECT * FROM br_ecommerce.olist_order_items_dataset
WHERE order_id LIKE "00143d0f86d6fbd9f9b38ab440ac16f5";

#### Look into olist_order_reviews_dataset ####

SELECT * FROM br_ecommerce.olist_order_reviews_dataset;

# Check how many unique review comment titles there are
SELECT COUNT(DISTINCT(review_comment_title)) FROM br_ecommerce.olist_order_reviews_dataset;

#### Look into olist_order_customer_dataset ####

SELECT * FROM br_ecommerce.olist_customers_dataset;

# Total Row Count
SELECT COUNT(*) FROM br_ecommerce.olist_customers_dataset;

# Count the amount of distinct cities olist has customers in
SELECT COUNT(DISTINCT(customer_city)) FROM br_ecommerce.olist_customers_dataset;

# Count the amount of distinct states have customers
SELECT COUNT(DISTINCT(customer_state)) FROM br_ecommerce.olist_customers_dataset;

#### Look into olist_sellers_dataset ####

SELECT * FROM br_ecommerce.olist_sellers_dataset;

SELECT COUNT(*) FROM br_ecommerce.olist_sellers_dataset;

# Find the distinct amount of sellers listed
SELECT COUNT(DISTINCT(seller_id)) FROM br_ecommerce.olist_sellers_dataset;

#### Look into olist_geolocation_dataset ####

SELECT * FROM br_ecommerce.olist_geolocation_dataset;