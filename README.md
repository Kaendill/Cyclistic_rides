
#  Ride Data Overview

### Objective:
This projects analyzes 12 months data to uncover trends, identify peak periods, and provide actionable insights to maximize annual memberships.

## Procedure
This project analyzes 12 months (Feb 2024 - Jan 2025) of ride data using **SQL** for data cleaning, exploration, analysis and **Tableau** for visualization.

# Questions Asked

1. How do annual members and casual riders use Cyclistic bikes differently? 
2. Why would casual riders buy Cyclistic annual memberships?  
3. How can Cyclistic use digital media to influence casual riders to become members?

# Tools Used

- Data source: The data has been made available by Motivate International Inc, available for download from the Google Data Analytics Cerificate Course. The dataset includes 12 CSV files, each representing one month's ride data from **February 2024 to January 2025**.
- PgAdmin 4: Data cleaning was performed using **SQL** in **PostgreSQL** and involved  Removing duplicate entries, handling null values in key columns, correcting inconsistent date formats.
- Tableau: For data visualizations

# Analysis
## 1.  Data Cleaning

I created the table first in PostgreSQL using the create table menu, the imported the files into the table, for each file, representing each month. after which i started the cleaning process; renaming columns, renaming NULL values, ensuring datatype consistencies and handling duplicate values.

``` sql
-- check consistency of ride_id columns

SELECT
  LENGTH(ride_id) AS ride_id_length
from rides
group by ride_id
having length(ride_id) <> 16

-- replacing the NULL values with unknown

UPDATE rides
SET start_station_name = 'Unknown'
WHERE start_station_name IS NULL

```

Take a look at my detailed file here
[data cleaning)[]

## 2. Data Exploration
Next, i proceeded to create columns for analysis such as trip_duration, day_of_week . Also ran summary ststistics to get an overview, and check for inconsistencies and i found some incorrect values, and i handled them. 

``` sql
-- Create column 'trip_duration'
ALTER TABLE rides_clean
ADD COLUMN trip_duration INTERVAL

-- Summary analysis
SELECT user_type,
       MAX(trip_duration) AS max_trip,
       MIN(trip_duration) AS min_trip,
       AVG(trip_duration) AS avg_trip
FROM rides_clean
GROUP BY user_type

```
See the detailed file here:
(data_exploration)[]

## 3. Data Analysis
 i created a temporary table for my analysis, with only columns i was interesed in working with. Then my individual analysis:

### 3.i. Average Trip per user

#### Visualize the result

``` sql
SELECT user_type,
  DATE_TRUNC('seconds', AVG(trip_duration)) AS avg_trip_duration
FROM rides_temp
GROUP BY user_type

```
#### Results
![averag]()

*plot*

### Insights
 - On an average, members take more trips compared to casual riders.

#### 3.ii.  Percentage of Rides Counts

#### Visualize the result

```sql
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

```

#### Results

---

## 📊 Project Overview
This analysis explores key metrics such as:
- 🚗 **Total Rides per Month**
- 💰 **Revenue Trends**
- 📍 **Top Pickup & Drop-off Locations**
- 🕒 **Peak Ride Hours**
- 📈 **Monthly Growth Patterns**

---

## 🔍 Data Source
The dataset includes 12 CSV files, each representing one month's ride data from **February 2024 to January 2025**.

### **Sample Columns:**
- `ride_id` – Unique identifier for each ride  
- `ride_date` – Date and time of the ride  
- `pickup_location` & `dropoff_location` – Location details  
- `fare_amount` – Cost of the ride  
- `ride_duration` – Duration of the trip in minutes  

---

## 🧹 Data Cleaning Process
Data cleaning was performed using **SQL** in **PostgreSQL** and involved:
1. Removing duplicate entries
2. Handling null values in key columns
3. Correcting inconsistent date formats
4. Standardizing location names

**Example SQL Query:**
```sql
SELECT 
    ride_date, 
    pickup_location, 
    dropoff_location, 
    fare_amount
FROM ride_data
WHERE fare_amount > 0;
