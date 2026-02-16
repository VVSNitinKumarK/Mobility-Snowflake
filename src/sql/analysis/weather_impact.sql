-- Rain vs non-rain day comparison: average trips, average revenue, average fare
SELECT
    is_rainy_day,
    COUNT(*) AS number_of_days,
    ROUND(AVG(trip_count), 0) AS average_daily_trips,
    ROUND(AVG(total_revenue), 2) AS average_daily_revenue,
    ROUND(AVG(average_fare), 2) AS average_fare
FROM mobility_db.mart.daily_mobility_weather_metrics
GROUP BY is_rainy_day
ORDER BY is_rainy_day;