USE ROLE mobility_role;
USE WAREHOUSE mobility_wh;
USE DATABASE mobility_db;
USE SCHEMA raw;

CREATE OR REPLACE VIEW weather_raw AS
WITH new_york_city_stations AS (
    SELECT
        noaa_weather_station_id     AS station_id,
        noaa_weather_station_name   AS station_name,
        latitude,
        longitude
    FROM snowflake_public_data_free.public_data_free.noaa_weather_station_index
    WHERE latitude BETWEEN 40 AND 41
      AND longitude BETWEEN -75 AND -73
),

weather_metrics AS (
    SELECT
        noaa_weather_station_id AS station_id,
        date::DATE              AS weather_date,
        variable_name,
        value
    FROM snowflake_public_data_free.public_data_free.noaa_weather_metrics_timeseries
    WHERE date >= '2015-01-01'
      AND date <  '2015-02-01'
)

SELECT
    weather_metrics.weather_date,
    weather_metrics.station_id,
    new_york_city_stations.station_name,
    new_york_city_stations.latitude,
    new_york_city_stations.longitude,

    MAX(CASE
        WHEN weather_metrics.variable_name LIKE 'Average daily temperature%'
        THEN weather_metrics.value
    END) AS average_temperature,

    MAX(CASE
        WHEN weather_metrics.variable_name = 'Precipitation'
        THEN weather_metrics.value
    END) AS precipitation

FROM weather_metrics
JOIN new_york_city_stations
  ON weather_metrics.station_id = new_york_city_stations.station_id

GROUP BY
    weather_metrics.weather_date,
    weather_metrics.station_id,
    new_york_city_stations.station_name,
    new_york_city_stations.latitude,
    new_york_city_stations.longitude;