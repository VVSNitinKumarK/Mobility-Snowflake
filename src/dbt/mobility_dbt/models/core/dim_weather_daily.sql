{{ config(materialized='table') }}

WITH staged AS (

    SELECT * FROM {{ ref('stage_weather') }}

)

SELECT
    weather_date,
    average_temperature,
    precipitation,
    COALESCE(precipitation > 0, FALSE) AS is_rainy_day
FROM staged