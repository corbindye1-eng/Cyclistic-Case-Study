/*

=========================
Data Presence Check
=========================

The following script simplies checks that all data has successfully been imported into the Data Base.
*/

--Goal: Check that all data has been imported

SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_01;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_02;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_03;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_04;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_05;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_06;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_07;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_08;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_09;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_10;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_11;
SELECT COUNT(ride_id) AS total_count FROM trip_data_2025_12;

--Result: All data imported