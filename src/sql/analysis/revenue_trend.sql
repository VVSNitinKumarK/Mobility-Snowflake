-- Daily revenue and average fare for January 2015
SELECT
    trip_date,
    total_revenue,
    average_fare,
    SUM(total_revenue) OVER (ORDER BY trip_date) AS cumulative_revenue
FROM mobility_db.mart.daily_mobility_weather_metrics
ORDER BY trip_date;