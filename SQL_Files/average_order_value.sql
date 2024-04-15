#### Average Order Value ####

# Average Order Value is: total revenue for a period / the total number of orders completed during the same period

SET SQL_SAFE_UPDATES = 0;	# Fix MySQL error message

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));	# Fix MySQL error message

# Find the total number of orders per each quarter

SELECT *, COUNT(order_id) AS order_count FROM(
	/* Add the year to the quarter */
	SELECT t.order_id, t.customer_id, CONCAT(YEAR(t.order_purchase_timestamp), " " ,t.quarter) AS quarter FROM (
		SELECT *,
        /* This case statement defines what is a quarter */
		CASE 
			WHEN MONTH(order_purchase_timestamp) >= 1 AND MONTH(order_purchase_timestamp) < 4 THEN "Q1"	
			WHEN MONTH(order_purchase_timestamp) >= 4 AND MONTH(order_purchase_timestamp) < 7 THEN "Q2"
			WHEN MONTH(order_purchase_timestamp) >= 7 AND MONTH(order_purchase_timestamp) < 10 THEN "Q3"
			WHEN MONTH(order_purchase_timestamp) >= 10 THEN "Q4"
		END AS quarter FROM br_ecommerce.olist_orders_dataset
        /* Filter out only completed orders */
		WHERE order_status NOT LIKE "Canceled" OR order_status NOT LIKE "Unavailable") t
	ORDER BY quarter ASC) s 
GROUP BY quarter;

# Find the total revenue per each quarter based upon these order ids

SELECT ROUND(SUM(a.payment_value), 2) AS quarter_revenue, a.quarter FROM ( 
	SELECT op.order_id, op.payment_type, op.payment_installments, op.payment_value,  s.quarter FROM br_ecommerce.olist_order_payments_dataset op
    /* Right Join, since we filtered out all cancelled/incomplete orders in the subquery*/
	RIGHT JOIN (SELECT t.order_id, t.customer_id, CONCAT(YEAR(t.order_purchase_timestamp), " " ,t.quarter) AS quarter FROM (
		SELECT *,
		CASE 
			WHEN MONTH(order_purchase_timestamp) >= 1 AND MONTH(order_purchase_timestamp) < 4 THEN "Q1"
			WHEN MONTH(order_purchase_timestamp) >= 4 AND MONTH(order_purchase_timestamp) < 7 THEN "Q2"
			WHEN MONTH(order_purchase_timestamp) >= 7 AND MONTH(order_purchase_timestamp) < 10 THEN "Q3"
			WHEN MONTH(order_purchase_timestamp) >= 10 THEN "Q4"
		END AS quarter FROM br_ecommerce.olist_orders_dataset
		WHERE order_status NOT LIKE "Canceled" OR order_status NOT LIKE "Unavailable") t
		ORDER BY quarter ASC) s 
	ON op.order_id = s.order_id) a
GROUP BY a.quarter;

# Find the average order value per quarter:
/* We are combining the two queries listed above to find the average order value */

SELECT ROUND(b.quarter_revenue / c.order_count, 2) AS AOV, b.quarter_revenue, c.order_count, b.quarter FROM(
	SELECT ROUND(SUM(a.payment_value), 2) AS quarter_revenue, a.quarter FROM (
		SELECT op.order_id, op.payment_type, op.payment_installments, op.payment_value,  s.quarter FROM br_ecommerce.olist_order_payments_dataset op
		RIGHT JOIN (SELECT t.order_id, t.customer_id, CONCAT(YEAR(t.order_purchase_timestamp), " " ,t.quarter) AS quarter FROM (
			SELECT *,
			CASE 
				WHEN MONTH(order_purchase_timestamp) >= 1 AND MONTH(order_purchase_timestamp) < 4 THEN "Q1"
				WHEN MONTH(order_purchase_timestamp) >= 4 AND MONTH(order_purchase_timestamp) < 7 THEN "Q2"
				WHEN MONTH(order_purchase_timestamp) >= 7 AND MONTH(order_purchase_timestamp) < 10 THEN "Q3"
				WHEN MONTH(order_purchase_timestamp) >= 10 THEN "Q4"
			END AS quarter FROM br_ecommerce.olist_orders_dataset
			WHERE order_status NOT LIKE "Canceled" OR order_status NOT LIKE "Unavailable") t
			ORDER BY quarter ASC) s 
		ON op.order_id = s.order_id) a
	GROUP BY a.quarter) b
RIGHT JOIN (SELECT *, COUNT(order_id) AS order_count FROM(
	SELECT t.order_id, t.customer_id, CONCAT(YEAR(t.order_purchase_timestamp), " " ,t.quarter) AS quarter FROM (
		SELECT *,
		CASE 
			WHEN MONTH(order_purchase_timestamp) >= 1 AND MONTH(order_purchase_timestamp) < 4 THEN "Q1"
			WHEN MONTH(order_purchase_timestamp) >= 4 AND MONTH(order_purchase_timestamp) < 7 THEN "Q2"
			WHEN MONTH(order_purchase_timestamp) >= 7 AND MONTH(order_purchase_timestamp) < 10 THEN "Q3"
			WHEN MONTH(order_purchase_timestamp) >= 10 THEN "Q4"
		END AS quarter FROM br_ecommerce.olist_orders_dataset
		WHERE order_status NOT LIKE "Canceled" OR order_status NOT LIKE "Unavailable") t
	ORDER BY quarter ASC) s 
GROUP BY quarter) c
ON b.quarter = c.quarter
ORDER BY b.quarter DESC;






