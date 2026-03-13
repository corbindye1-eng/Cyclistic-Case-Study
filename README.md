# Cyclistic Bike-Share: Behavioral Analysis and Conversion Strategy

## Project Overview
This repository contains a full-cycle data analysis project focused on Cyclistic, a fictional bike-share company in Chicago. The objective was to identify behavioral differences between **Annual Members** and **Casual Riders** to design a data-driven marketing strategy for increasing membership conversions.



## Business Task
To maximize growth, the marketing team aims to convert casual riders into annual members. This analysis seeks to answer: **How do annual members and casual riders use Cyclistic bikes differently?**

## Tech Stack
* **Data Processing:** SQL Server (TSQL)
* **Data Visualization:** Tableau
* **Methodology:** Medallion Architecture (Bronze/Silver/Gold layers)



## Data Pipeline & Cleaning
The analysis processed **5.5 million+ records** from the 2025 fiscal year. Key cleaning steps included:
* **Consolidation:** Unified 12 monthly datasets into a single relational table.
* **Integrity Audits:** Removed "false starts" (trips <60 seconds) and system errors (trips >24 hours).
* **Operational Logic:** Reclassified NULL station entries for electric bikes as "On-street" to preserve GPS-tracked trip data.
* **Feature Engineering:** Extracted `ride_length_m`, `day_of_week`, and `hour_of_day` for behavioral segmentation.

## Key Insights
1. **The "M-Pulse" vs. Leisure Curve:** Members exhibit a distinct "M-shaped" pulse during weekday rush hours (7-9 AM, 4-7 PM), indicating utility-driven commuting. Casual riders show a "Bell Curve" peaking in the late afternoon and weekends, characteristic of leisure use.
2. **The Utility Benchmark:** By isolating member commutes, I established a "Commuter Gold Standard" with a **Mean of 11 minutes** and a **Standard Deviation of 8.56 minutes**.
3. **The "Green Island" Discovery:** Utilizing geospatial mapping, I identified specific coordinate clusters in Chicago's Commercial Core where **25%-50% of casual riders** already display member-like behaviors.



## Strategic Recommendations
* **Geo-Fenced Marketing:** Launch digital media campaigns targeting the "Green Island" zip codes during peak commuting windows.
* **Physical Saturation:** Place high-visibility branding and transit partnerships at hubs (e.g., Union Station) within high-utility zones.
* **Personalized Savings Reports:** Use trip data to show "Mirror-Image" casuals the direct ROI of switching to an annual membership based on their 11-minute riding habits.

## Repository Structure
* `/SQL_Scripts`: End-to-end scripts from data presence checks to final analysis.
* `/Report`: The final PDF Analytical Report for executive stakeholders.
* `README.md`: Project summary and key findings.

## Data Source
The data was provided by Motivate International Inc. under this [Data License Agreement](https://divvy-tripdata.s3.amazonaws.com/data_license_agreement.html).

---
**[View Interactive Tableau Dashboard Here](REPLACE_WITH_YOUR_LINK)**
