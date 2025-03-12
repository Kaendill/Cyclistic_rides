-- Data Exploration

-- Create column 'trip_duration'
ALTER TABLE rides_clean
ADD COLUMN trip_duration INTERVAL

-- Calculate 'trip_duration'
UPDATE rides_clean
SET trip_duration = ended_at - started_at

-- Create column for 'day_of_week'
ALTER TABLE rides_clean
ADD COLUMN day_of_week INTEGER

-- calculate 'day_of_week'
UPDATE rides_clean
SET day_of_week = EXTRACT(DOW FROM started_at) -- Sunday = 0, saturday = 6

-- preview data
SELECT * FROM rides_clean
LIMIT 10

-- Summary analysis
SELECT user_type,
       MAX(trip_duration) AS max_trip,
       MIN(trip_duration) AS min_trip,
       AVG(trip_duration) AS avg_trip
FROM rides_clean
GROUP BY user_type -- returns a negative max_trip, data requires more cleaning

-- find the problem

SELECT COUNT(*)
FROM rides_clean
WHERE ended_at < started_at -- results is 207 rows

-- investigate the rows
SELECT ride_id, started_at, ended_at, ended_at - started_at AS trip_duration
FROM rides_clean
WHERE ended_at < started_at 

-- best case scenerio, swap the timestamps

-- check for rows where ended is earlier than started
SELECT started_at, ended_at, trip_duration
FROM rides_clean
WHERE started_at > ended_at
LIMIT 10; -- returns rows

-- reverse the rows

UPDATE rides_clean
SET started_at = ended_at,
    ended_at = started_at
WHERE started_at > ended_at;

-- recalculate trip_duration

UPDATE rides_clean
SET trip_duration = ended_at - started_at;

-- run summary stat again
-- returns positive values, but with unrealistic values
-- Using the 95th percentile to determine trips longer than usual AND set mininum trip duration to 1 minute

SELECT *
FROM rides_clean
WHERE trip_duration BETWEEN INTERVAL '60 seconds' AND
(
SELECT PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY trip_duration) AS real_max_duration
FROM rides_clean
) 
ORDER BY trip_duration 