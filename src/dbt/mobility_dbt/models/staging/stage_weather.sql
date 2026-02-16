{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'weather_raw') }}
),

aggregated AS (
    SELECT
        weather_date,
        AVG(average_temperature)    AS average_temperature,
        AVG(precipitation)          AS precipitation
    FROM source
    GROUP BY weather_date
)

SELECT * FROM aggregated