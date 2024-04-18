#### Find The most popular order routes ####

SET SQL_SAFE_UPDATES = 0;	# Fix MySQL error message

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));	# Fix MySQL error message

# Find the most common routes by seller city to customer city

SELECT *, COUNT(route) AS common_routes 
FROM (
	/* Create a pairing of the possible routes from sellers to customers */
	SELECT s.order_id, s.order_item_id, s.seller_id, s.price, s.freight_value, s.seller_city, s.seller_state, s.customer_id,  c.customer_city, c.customer_state, CONCAT(seller_city, ", ", customer_city) AS routes, s.order_id 
	FROM (
		SELECT oi.order_id, oi.order_item_id,oi.product_id, oi.seller_id, oi.price, oi.freight_value, os.seller_zip_code_prefix, os.seller_city, os.seller_state, o.customer_id, o.purchase_date
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

SELECT * FROM br_ecommerce.olist_customers_dataset;

/* Find the most popular routes per quarter */
SELECT COUNT(route) AS num_of_shipments, route, quarter
FROM(
	/* Seller state ships -> customer state. Create pairs of route data */
	SELECT *, CONCAT(seller_city, ', ', customer_city) AS route
	FROM(
		SELECT oi.order_id, oi.seller_id, sd.seller_city, sd.seller_state, s.customer_id, c.customer_city, c.customer_state, s.quarter, s.order_status FROM br_ecommerce.olist_order_items_dataset oi
		INNER JOIN (
			SELECT order_id, customer_id, order_status, CONCAT(YEAR(f.order_purchase_timestamp), ' ', f.quarter) AS quarter
			FROM(
				/* Divide the dataset into quarters */
				SELECT *,
				CASE
					WHEN MONTH(order_purchase_timestamp) < 4 THEN 'Q1'
					WHEN MONTH(order_purchase_timestamp) >= 4 AND MONTH(order_purchase_timestamp) < 7 THEN "Q2"
					WHEN MONTH(order_purchase_timestamp) >= 7 AND MONTH(order_purchase_timestamp) < 10 THEN "Q3"
					WHEN MONTH(order_purchase_timestamp) >= 10 THEN "Q4"
				END AS quarter FROM br_ecommerce.olist_orders_dataset
                /* Filter out shipments that are unavailable */
				WHERE order_status NOT LIKE "unavailable"
			) f
            /* Filter out shipments that are canceled */
            WHERE order_status NOT LIKE "canceled"
		) s
		ON s.order_id = oi.order_id
        /* Join the customers data set to get the customer city, state.  Inner Join to remove any null seller city/state information */
		INNER JOIN br_ecommerce.olist_customers_dataset c
		ON s.customer_id = c.customer_id
        /* Inner Join the sellers dataset to get the seller city, state.  Inner join to remove any null seller city/state information */
		INNER JOIN br_ecommerce.olist_sellers_dataset sd
		ON oi.seller_id = sd.seller_id
        /* Filter out any shipments that are processing */
        WHERE s.order_status NOT LIKE 'processing'
	) t
) e
/* Group by route and quarter to see the most popular routes for each quarter */
GROUP BY e.route, e.quarter
/* only look for shipments that have at occur at least 100 times a quarter */
HAVING num_of_shipments > 100
ORDER BY route DESC, num_of_shipments DESC;

/* RANK the most popular routes per quarter */
SELECT * 
FROM (
	SELECT *, DENSE_RANK() OVER(PARTITION BY quarter ORDER BY num_of_shipments DESC) AS 'rankings'
	FROM (
		SELECT COUNT(route) AS num_of_shipments, route, quarter
		FROM(
			/* Seller state ships -> customer state. Create pairs of route data */
			SELECT *, CONCAT(seller_city, ', ', customer_city) AS route
			FROM(
				SELECT oi.order_id, oi.seller_id, sd.seller_city, sd.seller_state, s.customer_id, c.customer_city, c.customer_state, s.quarter, s.order_status FROM br_ecommerce.olist_order_items_dataset oi
				INNER JOIN (
					SELECT order_id, customer_id, order_status, CONCAT(YEAR(f.order_purchase_timestamp), ' ', f.quarter) AS quarter
					FROM(
						/* Divide the dataset into quarters */
						SELECT *,
						CASE
							WHEN MONTH(order_purchase_timestamp) < 4 THEN 'Q1'
							WHEN MONTH(order_purchase_timestamp) >= 4 AND MONTH(order_purchase_timestamp) < 7 THEN "Q2"
							WHEN MONTH(order_purchase_timestamp) >= 7 AND MONTH(order_purchase_timestamp) < 10 THEN "Q3"
							WHEN MONTH(order_purchase_timestamp) >= 10 THEN "Q4"
						END AS quarter FROM br_ecommerce.olist_orders_dataset
						/* Filter out shipments that are unavailable */
						WHERE order_status NOT LIKE "unavailable"
					) f
					/* Filter out shipments that are canceled */
					WHERE order_status NOT LIKE "canceled"
				) s
				ON s.order_id = oi.order_id
				/* Join the customers data set to get the customer city, state.  Inner Join to remove any null seller city/state information */
				INNER JOIN br_ecommerce.olist_customers_dataset c
				ON s.customer_id = c.customer_id
				/* Inner Join the sellers dataset to get the seller city, state.  Inner join to remove any null seller city/state information */
				INNER JOIN br_ecommerce.olist_sellers_dataset sd
				ON oi.seller_id = sd.seller_id
				/* Filter out any shipments that are processing */
				WHERE s.order_status NOT LIKE 'processing'
			) t
		) e
		/* Group by route and quarter to see the most popular routes for each quarter */
		GROUP BY e.route, e.quarter
		/* only look for shipments that have at occur at least 100 times a quarter */
		HAVING num_of_shipments > 20
		ORDER BY route DESC, num_of_shipments DESC
	) a
) b
WHERE rankings <= 10;


