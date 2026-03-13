/*
===================================================
Data Analysis 
===================================================

Identify 'Utility' trip patterns to establish a target profile for 
casual-to-member conversion.
*/

--Goal:Determine on what days and what hours trips are taken by members and casuals to 
--whether they have the same travel patterns 
SELECT 
    membership_type,
    day_of_week,
    hour_of_day,
    COUNT(*) AS total_trips
FROM 
	trip_data_analysis
GROUP BY 
	membership_type, day_of_week, hour_of_day
ORDER BY 
	membership_type, total_trips DESC;
--Result: Most commutes by members take place on weekdays during the beginning and end of business days
--Casuals on the other hand travel more on the weekend and at an increasing rate throughout the day

--Goal: Determine the mean and standard deviation for members that show utility use 
SELECT 
    AVG(ride_length_m) AS utility_mean,
    STDEV(ride_length_m) AS utility_stdev
FROM trip_data_analysis
WHERE membership_type = 'member'
--Excludes leisure-heavy weekends and non-peak hours to identify core commuter metrics (Weekday Rush Hours: 7-9 AM, 4-6 PM).
  AND day_of_week NOT IN ('Saturday', 'Sunday')
  AND hour_of_day IN (7, 8,  16, 17, 18)
--Exclude outliers in ride length, therefore only keep travel times of between 1 and 60 minutes
  AND ride_length_m BETWEEN 1 AND 60;
--Result: Mean = 11 and Standard deviation = 8.46

--Goal: Create a table with rounded values to use in next query in order to speed up query
SELECT 
    ROUND(start_lat, 3) AS r_lat,
    ROUND(start_lng, 3) AS r_lng,
    day_of_week,
    hour_of_day,
    ride_length_m
INTO #CasualSummary -- This creates a temporary table
FROM trip_data_analysis
WHERE membership_type = 'casual';
--Result: Lattitude and Longitude rounded to 3 decimals, and only casual members selected

--Goal: Determine the cooridnates of casuals who mirror member behaviour
SELECT 
    FORMAT(r_lat, 'N3', 'en-US') AS lat_fixed,--Format do to be compatible with Tableau
    FORMAT(r_lng, 'N3', 'en-US') AS lng_fixed,--Format do to be compatible with Tableau
    COUNT(*) AS total_casual_rides,
--Only include casuals that fall within the specified criteria of core commuter identity
    SUM(CASE WHEN day_of_week NOT IN ('Saturday', 'Sunday') 
              AND hour_of_day IN (7, 8, 16, 17, 18) 
              AND ride_length_m BETWEEN 2.54 AND 19.46 THEN 1 ELSE 0 END) AS member_like_rides,
    --Determine the percentage of casual who behave like members
    FORMAT(
        (CAST(SUM(CASE WHEN day_of_week NOT IN ('Saturday', 'Sunday') 
                        AND hour_of_day IN (7, 8, 16, 17, 18) 
                        AND ride_length_m BETWEEN 2.54 AND 19.46 THEN 1 ELSE 0 END) AS FLOAT) 
         / NULLIF(COUNT(*), 0)) * 100, 
        'N3', 'en-US'
    ) AS behavior_match_pct
FROM #CasualSummary
GROUP BY r_lat, r_lng
HAVING COUNT(*) > 50
ORDER BY (CAST(SUM(CASE WHEN day_of_week NOT IN ('Saturday', 'Sunday') 
                        AND hour_of_day IN (7, 8, 16, 17, 18) 
                        --Looking for casuals who fall within 1 standard deviation of the previously calculated mean member bike ride length
                        AND ride_length_m BETWEEN 2.54 AND 19.46 THEN 1 ELSE 0 END) AS FLOAT) 
          / NULLIF(COUNT(*), 0)) DESC;
--Result: Collected data of casuals who mirror member hbehaviour

/*
=================================
Data Collection for Visualization
=================================
Aggregating data in order to create Visulaizations in Tableau*/

--Determine the number of member and casuals that travel at certain hours throughout the day
SELECT 
    membership_type,
	hour_of_day,
	COUNT(*) as ride_count
FROM 
	trip_data_analysis
GROUP BY
	membership_type,
	hour_of_day

--Determine the number of member and casuals that travel on certain days throughout the week
SELECT 
    membership_type,
    day_of_week,
    COUNT(*) as ride_count
FROM 
	trip_data_analysis
GROUP BY
	membership_type,
	day_of_week  

--Collect data for ride lengths in order to make hisotgram of distribution for member ride lengths
SELECT 
    ride_length_m
FROM trip_data_analysis
WHERE membership_type = 'member'
  AND day_of_week NOT IN ('Saturday', 'Sunday')
  AND hour_of_day IN (7, 8, 9, 16, 17, 18, 19)
  AND ride_length_m BETWEEN 1 AND 60