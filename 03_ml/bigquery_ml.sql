-- INFORMATION SCHEMA
  -- columns in a table
SELECT column_name
FROM `terraform-demo-485118.zoomcamp.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'green_trip_partitioned';
  -- partitions of a table
SELECT partition_id, total_rows
FROM `project.dataset.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'your_table';
  -- tables in a project
SELECT table_name, table_type, creation_time
FROM `project.dataset.INFORMATION_SCHEMA.TABLES`;
  -- datasets in a project
SELECT schema_name
FROM `terraform-demo-485118.INFORMATION_SCHEMA.SCHEMATA`;




-- SELECT THE COLUMNS INTERESTED FOR YOU
SELECT passenger_count, trip_distance, PULocationID, DOLocationID, payment_type, fare_amount, tolls_amount, tip_amount
FROM `terraform-demo-485118.zoomcamp.green_trip_partitioned` WHERE fare_amount != 0;



-- CREATE A ML TABLE WITH APPROPRIATE TYPE
CREATE OR REPLACE TABLE `terraform-demo-485118.zoomcamp.green_tripdata_ml` (
`passenger_count` INTEGER,
`trip_distance` FLOAT64,
`PULocationID` STRING,
`DOLocationID` STRING,
`payment_type` STRING,
`fare_amount` FLOAT64,
`tolls_amount` FLOAT64,
`tip_amount` FLOAT64
) AS (
SELECT passenger_count, trip_distance, cast(PULocationID AS STRING), CAST(DOLocationID AS STRING),
CAST(payment_type AS STRING), fare_amount, tolls_amount, tip_amount
FROM `terraform-demo-485118.zoomcamp.green_trip_partitioned` WHERE fare_amount != 0
);

-- CREATE MODEL WITH DEFAULT SETTING
CREATE OR REPLACE MODEL `terraform-demo-485118.zoomcamp.tip_ml_model`
OPTIONS
(model_type='linear_reg',
input_label_cols=['tip_amount'],
DATA_SPLIT_METHOD='AUTO_SPLIT') AS
SELECT
*
FROM
`terraform-demo-485118.zoomcamp.green_tripdata_ml`
WHERE
tip_amount IS NOT NULL;

-- CHECK FEATURES
 -- shows statistical distribution (like a `df.describe`)
SELECT * FROM ML.FEATURE_INFO(MODEL `terraform-demo-485118.zoomcamp.tip_ml_model`);

-- EVALUATE THE MODEL
 -- is this against test data?
 -- doubt, make sure to evaluate against test data you create
SELECT 
*
FROM
ML.EVALUATE(MODEL `terraform-demo-485118.zoomcamp.tip_ml_model`,
(
SELECT
*
FROM
`terraform-demo-485118.zoomcamp.green_tripdata_ml`
WHERE
tip_amount IS NOT NULL
));

-- PREDICT THE MODEL
SELECT
*
FROM
ML.PREDICT(MODEL `terraform-demo-485118.zoomcamp.tip_ml_model`,
(
SELECT
*
FROM
`terraform-demo-485118.zoomcamp.green_tripdata_ml`
WHERE
tip_amount IS NOT NULL
));

-- PREDICT AND EXPLAIN
SELECT
*
FROM
ML.EXPLAIN_PREDICT(MODEL `terraform-demo-485118.zoomcamp.tip_ml_model`,
(
SELECT
*
FROM
`terraform-demo-485118.zoomcamp.green_tripdata_ml`
WHERE
tip_amount IS NOT NULL
), STRUCT(3 as top_k_features));

-- HYPER PARAM TUNNING
  -- added more options/parameters
CREATE OR REPLACE MODEL `terraform-demo-485118.zoomcamp.tip_ml_model_tuned`
OPTIONS
(model_type='linear_reg',
input_label_cols=['tip_amount'],
DATA_SPLIT_METHOD='AUTO_SPLIT',
num_trials=5,
max_parallel_trials=2,
l1_reg=hparam_range(0, 20),
l2_reg=hparam_candidates([0, 0.1, 1, 10])) AS
SELECT
*
FROM
`terraform-demo-485118.zoomcamp.green_tripdata_ml`
WHERE
tip_amount IS NOT NULL;
