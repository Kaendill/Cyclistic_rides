-- Data Analysis

-- create temporary table to perform analysis on
CREATE TEMP TABLE rides_temp AS
(
SELECT ride_id, rideable_type, start_station_name, end_station_name, user_type, day_of_week, trip_duration,start_lat, end_lat, start_lng, end_lng,
EXTRACT (HOUR FROM started_at) AS hour_of_day,
EXTRACT(MONTH FROM started_at) AS trip_month
FROM rides_clean
WHERE trip_duration BETWEEN INTERVAL '60 seconds' AND
(
SELECT PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY trip_duration) AS real_max_duration
FROM rides_clean
))
-- preview data
SELECT *
FROM rides_temp
LIMIT 10

-- Average trip_duration by user_type
SELECT user_type,
  DATE_TRUNC('seconds', AVG(trip_duration)) AS avg_trip_duration
FROM rides_temp
GROUP BY user_type

-- Count of trips by user_types and percentages
WITH total_rides AS (
  SELECT COUNT(*) AS total 
  FROM rides_temp
)
SELECT user_type,
    COUNT(ride_id) AS ride_count,
	ROUND((COUNT(ride_id) * 100) / (SELECT total FROM total_rides), 2) AS percentages
FROM rides_temp
GROUP BY user_type
ORDER BY ride_count DESC


-- Rides per month
SELECT 
	COUNT(ride_id) AS number_of_rides,
	user_type,
    trip_month
FROM rides_temp
GROUP BY user_type,trip_month
ORDER BY trip_month

-- Rides per Hour of the day
SELECT
  COUNT(ride_id) AS number_of_rides,
  user_type,
  hour_of_day
FROM rides_temp
GROUP BY user_type, hour_of_day
ORDER BY hour_of_day
	
-- Rides per day of week

SELECT 
  COUNT(ride_id) AS number_of_rides,
  user_type,
  day_of_week
FROM rides_temp
GROUP BY user_type, day_of_week
ORDER BY day_of_week;

-- Top end_stations by users
SELECT
   user_type,
   end_station_name,
   end_lat,
   end_lng,
   COUNT(ride_id) AS number_of_rides
FROM rides_temp
WHERE end_station_name != 'Unknown'
GROUP BY user_type, end_station_name, end_lat, end_lng
ORDER BY number_of_rides DESC
LIMIT 10

-- Top 10 start_station by users

SELECT
   user_type,
   start_station_name,
   start_lat,
   start_lng,
   COUNT(ride_id) AS number_of_rides
FROM rides_temp
WHERE start_station_name != 'Unknown'
GROUP BY user_type, start_station_name, start_lat, start_lng
ORDER BY number_of_rides DESC
LIMIT 10

-- ridesble type by users
SELECT
  user_type,
  rideable_type,
  COUNT(ride_id) AS number_of_rides
FROM rides_temp
GROUP BY user_type, rideable_type
ORDER BY  rideable_type 