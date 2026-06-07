CREATE OR REFRESH MATERIALIZED VIEW gold_customer_order_summary
AS
SELECT c.customer_id,
       c.customer_name,
       c.date_of_birth,
       c.telephone,
       c.email,
       a.address_line_1,
       a.city,
       a.state,
       a.postcode,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(o.item_quantity) AS total_items_ordered,
       SUM(o.item_quantity * o.item_price) AS total_order_amount
  FROM LIVE.silver_customers c
  JOIN LIVE.silver_addresses a ON c.customer_id = a.customer_id
  JOIN LIVE.silver_orders o ON c.customer_id = o.customer_id
 WHERE a.__END_AT IS NULL
 GROUP BY ALL;