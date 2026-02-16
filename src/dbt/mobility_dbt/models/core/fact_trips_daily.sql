{{ config(materialized='table') }}

SELECT
    trip_date,
    COUNT(*)                AS trip_count,
    SUM(total_amount)       AS total_revenue,
    AVG(fare_amount)        AS average_fare,
    AVG(trip_distance)      AS average_trip_distance,
    AVG(passenger_count)    AS average_passenger_count
FROM {{ ref('stage_trips') }}
GROUP BY trip_date