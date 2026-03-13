/*

==============================
Raw Master Table Creation
=============================

This script aggregates all trip data over the last 12 months into one single, unified table for the entire
year allowing for data quality checks and data cleaning of all the data in single queries

All tables share an indentical schema, therefore can be unified with no alterations. This master table
serves as the bronze layer for subsequent data cleaning and validation
*/

--Goal: Create one large table for all data for the year

SELECT * INTO trip_data_full_year_raw
FROM(
	SELECT * FROM trip_data_2025_01
	UNION ALL 
	SELECT * FROM trip_data_2025_02
	UNION ALL 
	SELECT * FROM trip_data_2025_03
	UNION ALL 
	SELECT * FROM trip_data_2025_04
	UNION ALL 
	SELECT * FROM trip_data_2025_05
	UNION ALL 
	SELECT * FROM trip_data_2025_06
	UNION ALL 
	SELECT * FROM trip_data_2025_07
	UNION ALL 
	SELECT * FROM trip_data_2025_08
	UNION ALL 
	SELECT * FROM trip_data_2025_09
	UNION ALL
	SELECT * FROM trip_data_2025_10
	UNION ALL 
	SELECT * FROM trip_data_2025_11
	UNION ALL 
	SELECT * FROM trip_data_2025_12) AS all_months

--Result: One large table for the year created