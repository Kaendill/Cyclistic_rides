SELECT * FROM rides limit 10

ALTER TABLE rides
RENAME COLUMN "end_station_id  " TO "end_station_id";

ALTER TABLE rides
RENAME COLUMN "member_casual" TO "user_type";
-- checking for missing values in the station_id columns
select 
  count(end_station_name)AS null_end_station,
  count(start_station_name) AS null_start_station,
  count(end_station_id) AS null_end_station_id,
  count(start_station_id) AS null_start_station_id
from rides
where end_station_id IS NULL OR start_station_id IS NULL 
-- replacing the NULL values with unknown

UPDATE rides
SET start_station_name = 'Unknown'
WHERE start_station_name IS NULL

UPDATE rides
SET end_station_name = 'Unknown'
WHERE end_station_name IS NULL

UPDATE rides
SET end_station_id = 'Unknown'
WHERE end_station_id IS NULL


UPDATE rides
SET start_station_id = 'Unknown'
WHERE start_station_id IS NULL

-- check consistency of ride_id columns

SELECT
  LENGTH(ride_id) AS ride_id_length
from rides
group by ride_id
having length(ride_id) <> 16

-- ensuring consistency in timestamp column by limiting timeperiod to seconds not milliseconds
UPDATE rides
SET started_at = DATE_TRUNC('second', started_at)

UPDATE rides
SET ended_at = DATE_TRUNC('seconds', ended_at)

-- Checking for duplicates
SELECT ride_id,
COUNT(*)
FROM rides
GROUP BY ride_id, started_at, ended_at, user_type, start_station_name, end_station_name, rideable_type
HAVING COUNT(*) > 1
-- inspecting the duplicates
SELECT *
FROM rides
WHERE ride_id IN (
    SELECT ride_id
    FROM rides
    GROUP BY ride_id
    HAVING COUNT(*) > 1
) ORDER BY ride_id, started_at -- shows rows with duplicate values
-- create table with distinct ride_id

CREATE TABLE rides_clean AS
SELECT DISTINCT ON(ride_id)ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, user_type
FROM rides
--GROUP BY ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, user_type
ORDER BY ride_id, started_at
-- preview the new table
SELECT * FROM rides_clean
limit 10
-- verify the duplicates have been removed
SELECT ride_id, COUNT(*)
FROM rides_clean
GROUP BY ride_id
HAVING COUNT(*) > 1 -- RETURNS NOTHING

-- BEGIN ANALYSIS

-- Create column 'trip_duration'
ALTER TABLE rides_clean
ADD COLUMN trip_duration INTERVAL

-- Calculate 'trip_duration'
UPDATE rides_clean
SET trip_duration = ended_at - started_at

-- Create column for 'day_of_week'
ALTER TABLE rides_clean
ADD COLUMN day_of_week INTERGER

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
UPDATE rides_clean
SET started_at = ended_at,
    ended_at = started_at
WHERE ended_at < started_at 

-- run summary stat again
-- still returns negative


-- checking using the INTERVAL datatype
SELECT COUNT(*)
FROM rides_clean
WHERE trip_duration < INTERVAL '0 seconds'
--
SELECT ride_id, user_type, started_at, ended_at, trip_duration
FROM rides_clean
WHERE trip_duration < INTERVAL '0 second'
ORDER BY trip_duration ASC
LIMIT 10;
 
-- Now swap again
UPDATE rides_clean
SET started_at = ended_at,
    ended_at = started_at
WHERE trip_duration < INTERVAL '0 second'

-- run summary stat again
--returns negative again

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
