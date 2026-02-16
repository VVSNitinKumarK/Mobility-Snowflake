{{ config(materialized='view') }}

WITH source AS (

    SELECT * FROM {{ source('raw', 'trips_raw') }}
    WHERE pickup_datetime IS NOT NULL
      AND dropoff_datetime IS NOT NULL
      AND trip_distance IS NOT NULL
      AND trip_distance > 0
      AND total_amount IS NOT NULL
      AND total_amount > 0

),

parsed AS (

    SELECT
        vendor_id,

        COALESCE(
            TRY_TO_TIMESTAMP_NTZ(pickup_datetime,  'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP_NTZ(pickup_datetime,  'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP_NTZ(pickup_datetime)
        ) AS pickup_timestamp,

        COALESCE(
            TRY_TO_TIMESTAMP_NTZ(dropoff_datetime, 'DD-MM-YYYY HH24:MI'),
            TRY_TO_TIMESTAMP_NTZ(dropoff_datetime, 'YYYY-MM-DD HH24:MI:SS'),
            TRY_TO_TIMESTAMP_NTZ(dropoff_datetime)
        ) AS dropoff_timestamp,

        passenger_count,
        trip_distance,

        pickup_longitude,
        pickup_latitude,
        rate_code_id,
        store_and_forward_flag,

        dropoff_longitude,
        dropoff_latitude,

        payment_type,

        fare_amount,
        extra_amount,
        mta_tax_amount,
        tip_amount,
        tolls_amount,
        improvement_surcharge_amount,
        total_amount

    FROM source

),

renamed AS (

    SELECT
        vendor_id,
        pickup_timestamp,
        dropoff_timestamp,
        TO_DATE(pickup_timestamp) AS trip_date,

        passenger_count,
        trip_distance,

        pickup_longitude,
        pickup_latitude,
        rate_code_id,
        store_and_forward_flag,

        dropoff_longitude,
        dropoff_latitude,

        payment_type,

        fare_amount,
        extra_amount,
        mta_tax_amount,
        tip_amount,
        tolls_amount,
        improvement_surcharge_amount,
        total_amount

    FROM parsed
    WHERE pickup_timestamp IS NOT NULL
      AND dropoff_timestamp IS NOT NULL

)

SELECT * FROM renamed