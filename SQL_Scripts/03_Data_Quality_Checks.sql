/*
=======================
Data Quality Check
=======================

The purpose of this script is to identify any issues and inconsistencies in our data
that could result in inaccurate analysis results later on
*/

--Goal: Check for duplicate rides in the data
SELECT 
	COUNT(ride_id) AS total_id,
	COUNT(DISTINCT(ride_id)) AS total_distinct_id
FROM
	trip_data_full_year_raw
--Result: No duplicate rides detected


--Goal: Check that no rideable falls out of specified categories (classic/electric)
SELECT 
	DISTINCT rideable_type 
FROM 
	trip_data_full_year_raw	
--Result: All rideables fall inside the two categories


--Goal: Check that no customer falls out of specified categories (member/casual)
SELECT 
	DISTINCT member_casual 
FROM
	trip_data_full_year_raw
--Result: All customers fall inside the two categories


--Goal: Check if there are any data entries where the starting time is after the end time
SELECT 
	ride_id,
	started_at,
	ended_at
FROM 
	trip_data_full_year_raw 
WHERE 
	CAST(started_at AS datetime2) >= CAST(ended_at AS datetime2)--Converted to DateTime as data was imported as NVARCHAR
--Result: There were 29 entries that had starting times after ending times


--Goal: Determine why such a large percentage of bikes have no start/end station entries
SELECT 
	SUM(CASE WHEN start_station_name IS NULL AND start_station_id IS NULL THEN 1 ELSE 0 END) AS both_start_null,
	SUM(CASE WHEN end_station_name IS NULL AND end_station_id IS NULL THEN 1 ELSE 0 END) AS both_end_null
FROM 
	trip_data_full_year_raw

SELECT 
	SUM(CASE WHEN start_station_name IS NULL AND start_station_id IS NULL AND rideable_type = 'electric_bike' THEN 1 ELSE 0 END) AS both_start_null,
	SUM(CASE WHEN end_station_name IS NULL AND end_station_id IS NULL AND rideable_type = 'electric_bike' THEN 1 ELSE 0 END) AS both_end_null
FROM 
	trip_data_full_year_raw
--Result:99% of the bikes with no end station are electric bikes and are not required to be stopped at station as they can be tracked


--Goal: Check if the classic bikes with no return station is due to a system error or were actually not returned
SELECT 
	COUNT(*) 
FROM 
	trip_data_full_year_raw 
WHERE
	(end_station_name IS NULL OR start_station_name IS NULL)
	AND rideable_type = 'classic_bike'

SELECT 
	COUNT(*) 
FROM 
	trip_data_full_year_raw 
WHERE
	(end_station_name IS NULL OR start_station_name IS NULL) 
	AND rideable_type = 'classic_bike' 
	AND DATEDIFF(hour, CAST(started_at AS DATETIME2),  CAST(ended_at AS DATETIME2)) = 25 
--Result: It appears that almost all the bikes that do not have end stations were not returned due to them all being out for exactly the same
-- amount of time, this suggests that there is an automatic cap on bike times when they are not returned (25 hours)


--Goal: See if all trips were complete trips
SELECT 
    COUNT(*) AS false_starts
FROM trip_data_full_year_raw
WHERE start_lat = end_lat 
  AND start_lng = end_lng
  AND DATEDIFF(second, CAST(started_at AS DATETIME2), CAST(ended_at AS DATETIME2)) < 60;--Cast as datetime2 as data was imported as string to prevent errors
--Result: Over 100 000 trips registered lasted less than 60 seconds making them false trips 


--Goal: Check that all trips recorded were in the same region to ensure data was taken from the same area
SELECT 
    AVG(CAST(start_lat AS FLOAT)) AS avg_lat,
    MIN(CAST(start_lat AS FLOAT)) AS min_lat,
    MAX(CAST(start_lat AS FLOAT)) AS max_lat,
	AVG(CAST(start_lng AS FLOAT)) AS avg_lng,
    MIN(CAST(start_lng AS FLOAT)) AS min_lng, 
    MAX(CAST(start_lng AS FLOAT)) AS max_lng
FROM trip_data_full_year_raw;
--Result: All data was recorded in the same area/ No outliers


--Goal:Check if some stations have more than one ID due to changes in the ID system through the year
SELECT 
    start_station_name, 
    COUNT(DISTINCT start_station_id) AS id_count
FROM 
    trip_data_full_year_raw
GROUP BY 
    start_station_name
HAVING 
    COUNT(DISTINCT start_station_id) > 1
--Result: some stations did in fact have have more than 1 ID 

/*SUMMARY

-No duplicates found
-9 records with starting time > end time
-Most bikes with no end station are electric and can be tracked with GPS
-~100k records flagged for false starts where travel time was less than a minute
-All trips took place in the same geographic area
-Many stations have stations have more than one ID so cannot use station IDs for analysis
