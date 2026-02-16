{{ config(materialized='table') }}

SELECT
    fact_trips_daily.trip_date,

    fact_trips_daily.trip_count,
    fact_trips_daily.total_revenue,
    fact_trips_daily.average_fare,
    fact_trips_daily.average_trip_distance,
    fact_trips_daily.average_passenger_count,

    dim_weather_daily.average_temperature,
    dim_weather_daily.precipitation,
    dim_weather_daily.is_rainy_day

FROM {{ ref('fact_trips_daily') }}      AS fact_trips_daily
LEFT JOIN {{ ref('dim_weather_daily') }} AS dim_weather_daily
  ON fact_trips_daily.trip_date = dim_weather_daily.weather_date