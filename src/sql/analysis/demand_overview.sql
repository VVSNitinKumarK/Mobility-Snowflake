-- Daily trip count trend for January 2015
SELECT
    trip_date,
    trip_count,
    AVG(trip_count) over (
        ORDER BY trip_date
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
    ) As trip_count_5day_average
FROM mobility_db.mart.daily_mobility_weather_metrics
ORDER BY trip_date;