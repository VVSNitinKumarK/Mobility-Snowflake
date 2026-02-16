-- Temperature vs trip count relationship
SELECT
    trip_date,
    average_temperature,
    trip_count,
    CORR(average_temperature, trip_count) OVER () AS temperature_demand_correlation
FROM mobility_db.mart.daily_mobility_weather_metrics
WHERE average_temperature IS NOT NULL
ORDER BY average_temperature;