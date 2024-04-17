#### Find Revenue by Quarter ####

SET SQL_SAFE_UPDATES = 0;	# Fix MySQL error message

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));	# Fix MySQL error message

/* This table holds the price that the order was charged */
SELECT * FROM br_ecommerce.olist_order_payments_dataset;

/* Find the total revenue, number of orders, and the average order value */
SELECT ROUND(SUM(t.payment_value), 2) AS revenue, COUNT(t.order_id) AS number_of_orders, ROUND(SUM(t.payment_value) / COUNT(t.order_id) ,2) AS average_order_value, t.quarter 
FROM(
	/* Filter out processing orders, and add the year to each quater tag */
    SELECT s.order_id, s.order_purchase_timestamp, op.payment_value, CONCAT(YEAR(order_purchase_timestamp), ' ', quarter) AS quarter
	FROM(
		/* Filter out unavailable orders, attach quarter tag to each */
		SELECT *, 
		CASE 
			WHEN MONTH(order_purchase_timestamp) >= 1 AND MONTH(order_purchase_timestamp) < 4 THEN "Q1"	
			WHEN MONTH(order_purchase_timestamp) >= 4 AND MONTH(order_purchase_timestamp) < 7 THEN "Q2"
			WHEN MONTH(order_purchase_timestamp) >= 7 AND MONTH(order_purchase_timestamp) < 10 THEN "Q3"
			WHEN MONTH(order_purchase_timestamp) >= 10 THEN "Q4"
		END AS quarter 
		FROM(
			/* Filter out canceled orders */
			SELECT * 
			FROM br_ecommerce.olist_orders_dataset
			WHERE order_status NOT LIKE 'canceled'
		) f
		WHERE order_status NOT LIKE 'unavailable'
	) s
    /* Inner join the two table, a final entry should be found in the payment table and orders table */
	INNER JOIN br_ecommerce.olist_order_payments_dataset op
	ON s.order_id = op.order_id
	WHERE order_status NOT LIKE 'processing'
) t
GROUP BY t.quarter
ORDER BY t.quarter DESC;
