USE ROLE mobility_role;
USE WAREHOUSE mobility_wh;
USE DATABASE mobility_db;
USE SCHEMA raw;

-- 1) File format for CSV ingestion
CREATE OR REPLACE FILE FORMAT taxi_trips_csv_file_format
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    TRIM_SPACE = TRUE;

-- 2) Internal stage for trip data files
CREATE OR REPLACE STAGE taxi_trips_internal_stage
    FILE_FORMAT = taxi_trips_csv_file_format;

-- 3) Raw trips table
CREATE OR REPLACE TABLE trips_raw (
    vendor_id STRING,
    pickup_datetime STRING,
    dropoff_datetime STRING,
    passenger_count NUMBER,
    trip_distance FLOAT,
    pickup_longitude FLOAT,
    pickup_latitude FLOAT,
    rate_code_id NUMBER,
    store_and_forward_flag STRING,
    dropoff_longitude FLOAT,
    dropoff_latitude FLOAT,
    payment_type NUMBER,
    fare_amount FLOAT,
    extra_amount FLOAT,
    mta_tax_amount FLOAT,
    tip_amount FLOAT,
    tolls_amount FLOAT,
    improvement_surcharge_amount FLOAT,
    total_amount FLOAT
);

-- 4) Load data from stage into raw table
COPY INTO trips_raw
FROM @taxi_trips_internal_stage
FILE_FORMAT = (FORMAT_NAME = taxi_trips_csv_file_format)
PATTERN = '.*yellow_tripdata_2015-01\.csv.*'
ON_ERROR = 'CONTINUE';

-- 5) Quick verification
SELECT COUNT(*) AS trips_row_count FROM trips_raw;

SELECT
    vendor_id,
    pickup_datetime,
    dropoff_datetime,
    passenger_count,
    trip_distance,
    pickup_longitude,
    pickup_latitude,
    dropoff_longitude,
    dropoff_latitude,
    total_amount
FROM trips_raw
LIMIT 20;