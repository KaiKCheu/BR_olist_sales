#### Find The Most Popular Categories sold per quarter ####

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));	# Fix MySQL error message

/* This dataset contains product_category in portugese to english translation */
SELECT * FROM br_ecommerce.product_category_name_translation;

/* Rename column to something easier to understand */
#ALTER TABLE br_ecommerce.product_category_name_translation RENAME COLUMN ï»¿product_category_name TO product_category_name;

/* This data set contains order_id and product_id, seller_id, price, freight_value */
SELECT * FROM br_ecommerce.olist_order_items_dataset;

/* This dataset contains product_id, product_category_name */
SELECT * FROM br_ecommerce.olist_products_dataset;

SELECT * FROM br_ecommerce.olist_orders_dataset;

SELECT ROUND(SUM(s.price), 2) AS total_sales, s.product_category_name, s.product_category_name_english, order_purchase_timestamp
FROM(
	SELECT oi.order_id, oi.order_item_id, oi.product_id, oi.price, oi.freight_value, p.product_category_name, cn.product_category_name_english, o.order_purchase_timestamp
    FROM br_ecommerce.olist_order_items_dataset oi
    LEFT JOIN br_ecommerce.olist_orders_dataset o
    ON oi.order_id = o.order_id
	/* Inner Join the products that appear in both sets, some products sold may not have a category */
	LEFT JOIN br_ecommerce.olist_products_dataset p
	ON oi.product_id = p.product_id
	LEFT JOIN br_ecommerce.product_category_name_translation cn
	ON p.product_category_name = cn.product_category_name
)s 
GROUP BY s.product_category_name
ORDER BY total_sales DESC;

/* Find the most popular categories by quarter */
SELECT * FROM(
	SELECT s.total_sales, s.product_category_name, s.product_category_name_english, s.quarter, DENSE_RANK() OVER(PARTITION BY s.quarter ORDER BY s.total_sales DESC) AS "rankings"
	FROM (
		SELECT ROUND(SUM(f.price), 2) AS total_sales, f.product_category_name, f.product_category_name_english, CONCAT(YEAR(f.order_purchase_timestamp), " ", f.quarter) AS quarter
		FROM (
			SELECT oi.order_id, oi.order_item_id, oi.product_id, oi.price, oi.freight_value, p.product_category_name, cn.product_category_name_english, o.order_purchase_timestamp, 
			CASE
				WHEN MONTH(order_purchase_timestamp) >= 1 AND MONTH(order_purchase_timestamp) < 4 THEN "Q1"	
				WHEN MONTH(order_purchase_timestamp) >= 4 AND MONTH(order_purchase_timestamp) < 7 THEN "Q2"
				WHEN MONTH(order_purchase_timestamp) >= 7 AND MONTH(order_purchase_timestamp) < 10 THEN "Q3"
				WHEN MONTH(order_purchase_timestamp) >= 10 THEN "Q4"
			END AS quarter
			FROM br_ecommerce.olist_order_items_dataset oi
			LEFT JOIN br_ecommerce.olist_orders_dataset o
			ON oi.order_id = o.order_id
			/* Inner Join the products that appear in both sets, some products sold may not have a category */
			LEFT JOIN br_ecommerce.olist_products_dataset p
			ON oi.product_id = p.product_id
			LEFT JOIN br_ecommerce.product_category_name_translation cn
			ON p.product_category_name = cn.product_category_name
		) f
		GROUP BY f.quarter, f.product_category_name
	) s
) t
WHERE rankings <= 10;