CREATE OR REFRESH STREAMING TABLE BRONZE_CUSTOMERS
COMMENT 'raw customer data ingestion from source system operational_data'
TBLPROPERTIES ('quality' = 'bronze')
AS
SELECT
  *, _metadata.file_path AS input_file_path,
  current_timestamp() AS ingestion_timestamp
FROM cloud_files(
  '/Volumes/circuitbox/landing/operational_data/customers/',
  'json',
  map(
    'cloudFiles.inferColumnTypes', 'true',
    'cloudFiles.schemaHints', 'customer_id STRING, name STRING, email STRING'
  )
);


CREATE OR REFRESH STREAMING TABLE BRONZE_ORDERS
COMMENT 'raw orders data ingestion from source system operational_data'
TBLPROPERTIES ('quality' = 'bronze')
AS
SELECT
  *,
  _metadata.file_path AS input_file_path,
  current_timestamp() AS ingestion_timestamp
FROM cloud_files(
  '/Volumes/circuitbox/landing/operational_data/orders/',
  'json',
  map(
    'cloudFiles.inferColumnTypes', 'true',
    'cloudFiles.schemaHints', 'order_id STRING, customer_id STRING, order_timestamp TIMESTAMP'
  )
);

CREATE OR REFRESH STREAMING TABLE BRONZE_ADDRESSES
COMMENT 'raw addressses data ingestion from source system operational_data'
TBLPROPERTIES ('quality' = 'bronze')
AS
SELECT
  *,
  _metadata.file_path AS input_file_path,
  current_timestamp() AS ingestion_timestamp
FROM cloud_files(
  '/Volumes/circuitbox/landing/operational_data/addresses/',
  'csv',
  map(
    'cloudFiles.inferColumnTypes', 'true'
  )
);

