-- Data Cleaning

SELECT * FROM rides limit 10 -- view the table

-- renaming column names
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
SELECT DISTINCT ON(ride_id)ride_id, rideable_type, started_at, ended_at, start_station_name, end_station_name, user_type,start_lat, end_lat, start_lng, end_lng
FROM rides
ORDER BY ride_id, started_at

-- preview the new table

SELECT * FROM rides_clean
limit 10
-- verify the duplicates have been removed
SELECT ride_id, COUNT(*)
FROM rides_clean
GROUP BY ride_id
HAVING COUNT(*) > 1 -- RETURNS NOTHING