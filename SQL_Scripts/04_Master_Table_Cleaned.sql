/*
==================================================================
Master Table Cleaning and Schema Standardization (Silver Layer)
==================================================================

This script cleans the data of all problems identified in the Data Quality Check script, so that it is ready for analysis
Task:
Convert data types for analysis
Remove data anomalies
Provide clarity for certain entries
*/

SELECT 
	--Change data types for attributes to allow analysis
	CAST(ride_id AS NVARCHAR(50)) AS ride_id,  
	CAST(member_casual AS NVARCHAR(20)) AS membership_type,
	CAST(rideable_type AS NVARCHAR(50)) AS rideable_type,
	CAST(started_at AS DATETIME2) AS start_time,
	CAST(ended_at AS DATETIME2) AS end_time,
	--Logic: All electric bikes that do not have end stations have been left somewhere else as these bikes have GPS tracking and can be left anywhere in the city
	--Solution: Change all electric bikes with NULL values for start and end station to 'On-street'
	ISNULL(CAST(start_station_name AS NVARCHAR(100)),
		   CASE WHEN rideable_type = 'electric_bike' THEN 'On-street' 
		   ELSE 'Unknown/System Error' 
		   END) AS start_station_name,
	ISNULL(CAST(end_station_name AS NVARCHAR(100)),
		   CASE WHEN rideable_type = 'electric_bike' THEN 'On-street'
		   ELSE 'Unknown/System Error' 
		   END) AS end_station_name,
	--Change data types for attributes to allow for analysis
	CAST(start_lat AS FLOAT) AS start_lat,
	CAST(start_lng AS FLOAT) AS start_lng,
    CAST(end_lat AS FLOAT) AS end_lat,
    CAST(end_lng AS FLOAT) AS end_lng
INTO 
	trip_data_full_year_cleaned
FROM 
	trip_data_full_year_raw
WHERE 
	--Logic: Trips cannot have start times that are later than end times
	--Solution: Remove all entries where this is the case as it is an error in data capture
	CAST(started_at AS DATETIME2) < CAST(ended_at AS DATETIME2)
	--Logic: Classic bikes still have to be returned to dock stations and if they are not they can be considered stolen or lost
	--Solution: Remove all classic bikes that were not returned to their stations
	AND NOT(
	rideable_type = 'classic_bike'
	AND end_station_name IS NULL
	AND DATEDIFF(hour, CAST(started_at AS DATETIME2), CAST(ended_at AS DATETIME2)) >= 24
	)
	--Logic: Some users may have taken out a bike and returned it immediatley and therefore it would provide unreliable analysis values if included
	--Solution: Remove all bikes with travel times <60 seconds
	AND NOT(
	DATEDIFF(second, CAST(started_at AS DATETIME2), CAST(ended_at AS DATETIME2)) < 60
	);

/*
==================================
Feature Engineering (Gold Layer)
==================================

This script adds time-series variables to the dataset to allow for further analysis of the data
*/
SELECT 
	*,
	DATEDIFF(minute, start_time, end_time) AS ride_length_m,--Determine trip lenght in minutes
	DATENAME(weekday, start_time) AS day_of_week,--Determine what day a trip was taken
	DATENAME(month, start_time) AS month_name,--Determine what month a trip was taken 
	DATEPART(hour, start_time) AS hour_of_day--Determine what time of the day a trip was taken 
INTO 
	trip_data_analysis
FROM 
	trip_data_full_year_cleaned;

