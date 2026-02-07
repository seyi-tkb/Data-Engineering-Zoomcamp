-- create external table
CREATE OR REPLACE EXTERNAL TABLE `terraform-demo-485118.zoomcamp.external_green_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://seyi-kestra-bucket/trip_data/green_tripdata_2019-*.csv', 'gs://seyi-kestra-bucket/trip_data/green_tripdata_2020-*.csv', 'gs://seyi-kestra-bucket/trip_data/green_tripdata_2021-*.csv']
);

-- check external table
SELECT *
FROM terraform-demo-485118.zoomcamp.external_green_tripdata;

-- create partitioned table
CREATE OR REPLACE TABLE terraform-demo-485118.zoomcamp.green_trip_partitioned
PARTITION BY DATE(lpep_pickup_datetime)
AS
SELECT * FROM terraform-demo-485118.zoomcamp.external_green_tripdata;

-- create NON-partitioned table
CREATE OR REPLACE TABLE terraform-demo-485118.zoomcamp.green_trip_non_partitioned
AS
SELECT * FROM terraform-demo-485118.zoomcamp.external_green_tripdata;

-- check partitioned table against non-partitioned
SELECT *
FROM terraform-demo-485118.zoomcamp.green_trip_partitioned
WHERE lpep_pickup_datetime BETWEEN '2020-06-01' AND '2020-06-30';

SELECT *
FROM terraform-demo-485118.zoomcamp.green_trip_non_partitioned
WHERE lpep_pickup_datetime BETWEEN '2020-06-01' AND '2020-06-30';


-- table details
SELECT table_name, partition_id, total_rows
FROM zoomcamp.INFORMATION_SCHEMA.PARTITIONS
WHERE table_name = 'green_trip_partitioned'
ORDER BY total_rows DESC;


-- create (partitioned table and) clustered table
CREATE OR REPLACE TABLE terraform-demo-485118.zoomcamp.green_trip_partitioned
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY VendorID
AS
SELECT * FROM terraform-demo-485118.zoomcamp.external_green_tripdata;
