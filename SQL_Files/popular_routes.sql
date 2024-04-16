#### Find The most popular order routes ####

SET SQL_SAFE_UPDATES = 0;	# Fix MySQL error message

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));	# Fix MySQL error message

# Find the most common routes by seller city to customer city

SELECT *, COUNT(route) AS common_routes 
FROM (
	/* Create a pairing of the possible routes from sellers to customers */
	SELECT s.order_id, s.order_item_id, s.seller_id, s.price, s.freight_value, s.seller_city, s.seller_state, s.customer_id,  c.customer_city, c.customer_state, CONCAT(seller_city, ", ", customer_city) AS route 
	FROM (
		SELECT oi.order_id, oi.order_item_id,oi.product_id, oi.seller_id, oi.price, oi.freight_value, os.seller_zip_code_prefix, os.seller_city, os.seller_state, o.customer_id
		FROM br_ecommerce.olist_order_items_dataset oi
		/* Get the seller information by left joining onto the item dataset */
        LEFT JOIN br_ecommerce.olist_sellers_dataset os
		ON oi.seller_id = os.seller_id
        /* Get the customer_ids from the orders dataset */
		LEFT JOIN br_ecommerce.olist_orders_dataset o
		ON oi.order_id = o.order_id) s
	/* Get the customer's zip code, city, state from the customer's dataset */
	LEFT JOIN br_ecommerce.olist_customers_dataset c
	ON s.customer_id = c.customer_id) j
GROUP BY route
/* only look into routes that have at least 20 orders */
HAVING common_routes > 20
ORDER BY common_routes DESC;

