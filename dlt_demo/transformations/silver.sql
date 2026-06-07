  CREATE OR REFRESH STREAMING TABLE silver_customers_clean(
  CONSTRAINT valid_customer_id EXPECT (customer_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT valid_customer_name EXPECT (customer_name IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_telephone EXPECT (LENGTH(telephone) >= 10),
  CONSTRAINT valid_email EXPECT (email IS NOT NULL),
  CONSTRAINT valid_date_of_birth EXPECT(date_of_birth >= '1920-01-01') 
  )
  COMMENT 'Cleaned customers data'
  TBLPROPERTIES ('quality' = 'silver')
  AS
  SELECT customer_id,
       customer_name,
       CAST(date_of_birth AS DATE) AS date_of_birth,
       telephone,
       email,
       CAST(created_date AS DATE) AS created_date
  FROM STREAM(LIVE.bronze_customers)
  ;

  CREATE OR REFRESH STREAMING TABLE silver_customers
  COMMENT 'SCD Type 1 customers data'
  TBLPROPERTIES ('quality' = 'silver');

  APPLY CHANGES INTO LIVE.silver_customers
  FROM STREAM(LIVE.silver_customers_clean)
  KEYS (customer_id)
  SEQUENCE BY created_date
  STORED AS SCD TYPE 1; -- Optional. Type 1 is the default value



  CREATE OR REFRESH STREAMING TABLE silver_orders_clean(
  CONSTRAINT valid_customer_id EXPECT (customer_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT valid_order_id EXPECT (order_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT valid_order_status EXPECT (order_status IN ('Pending', 'Shipped', 'Cancelled', 'Completed')),
  CONSTRAINT valid_payment_method EXPECT (payment_method IN ('Credit Card', 'Bank Transfer', 'PayPal'))
  )
  COMMENT "Cleaned orders data"
  TBLPROPERTIES ("quality" = "silver")
  AS
  SELECT order_id,
       customer_id,
       CAST(order_timestamp AS TIMESTAMP) AS order_timestamp,
       payment_method,
       items,
       order_status
  FROM STREAM(LIVE.bronze_orders);

  CREATE STREAMING TABLE silver_orders_expand
  AS
  SELECT order_id,
      customer_id,
      order_timestamp,
      payment_method,
      order_status,
      item.item_id,
      item.name AS item_name,
      item.price AS item_price,
      item.quantity AS item_quantity,
      item.category AS item_category
  FROM (SELECT order_id,
              customer_id,
              order_timestamp,
              payment_method,
              order_status,
              explode(items) AS item
          FROM STREAM(LIVE.silver_orders_clean));


  CREATE OR REFRESH STREAMING TABLE silver_orders
  COMMENT 'SCD Type 1 orders data'
  TBLPROPERTIES ('quality' = 'silver');

  APPLY CHANGES INTO LIVE.silver_orders
  FROM STREAM(LIVE.silver_orders_expand)
  KEYS (order_id)
  SEQUENCE BY order_timestamp
  STORED AS SCD TYPE 1; -- Optional. Type 1 is the default value


  CREATE OR REFRESH STREAMING TABLE silver_addresses_clean(
  CONSTRAINT valid_customer_id EXPECT (customer_id IS NOT NULL) ON VIOLATION FAIL UPDATE,
  CONSTRAINT valid_address EXPECT (address_line_1 IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_postcode EXPECT (LENGTH(postcode) = 5)
  )
  COMMENT "Cleaned addresses data"
  TBLPROPERTIES ("quality" = "silver")
  AS
  select customer_id,
       address_line_1,
       city,
       state,
       postcode,
       created_date::date as created_date
  from STREAM(LIVE.bronze_addresses);

  CREATE OR REFRESH STREAMING TABLE silver_addresses
  COMMENT 'SCD Type 2 addresses data'
  TBLPROPERTIES ('quality' = 'silver');

  APPLY CHANGES INTO LIVE.silver_addresses
  FROM STREAM(LIVE.silver_addresses_clean)
  KEYS (customer_id)
  SEQUENCE BY created_date
  STORED AS SCD TYPE 2; 


