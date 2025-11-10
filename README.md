# flight_performance_analysis
This Project analyzes airline performance using (Postgre) SQL for data cleaning, transformation and analysis, and Power BI for interactive visualization and reporting.

Flight Performance Analysis using SQL & Power BI

Overview

This project showcases an end-to-end data analytics workflow using PostgreSQL and Power BI. The objective was to analyze flight performance data, explore patterns in delays, and build an interactive dashboard that provides actionable insights for decision-making.
The project highlights skills in data loading, cleaning, SQL querying, EDA, data modeling, and visualization.

Dataset
Source: Publicly available flight dataset (flights.csv)
Records: 336775 Rows, 21 Columns
Features Include:
Flight date & time
Airline & tail number
Origin & destination airport
Distance, air-time
Arrival & departure delays

Tools & Technologies
Category	Tools
Database	PostgreSQL (PSQL)
Querying & EDA	SQL
Visualization	Power BI Desktop
Data Prep	Power BI Power Query
Documentation	Markdown, GitHub

Project Steps

1️. Data Loading into PostgreSQL
Imported the raw CSV file into PostgreSQL database.
Created the flights table, defined appropriate data types and constraints.

2. Data Cleaning & Pre-processing
Handled missing values, outliers, and inconsistent data.
Converted date/time columns into proper formats.
Created derived columns such as on-time status, time of day categories, and delay flags for better analysis.

3️. Exploratory Data Analysis (EDA) Using SQL
Performed SQL-based EDA including:
Summary statistics (min, max, avg delays)
On-Time vs Delayed performance
Delay patterns by airline, airport, and time of day
Month-over-Month trends
Top/bottom performing routes

4️. Core SQL Queries Executed
Examples include:
Total flights and delay rates
Delay analysis by time period and airline
MoM flight volume and delay trends
Correlation between distance and delay using corr()

5️. Data Modeling for Power BI
Integrated PostgreSQL with Power BI using Import mode
Built a Calendar table for time intelligence calculations
Created DAX measures for KPIs such as:
Total Flights
Average Delay(Departure, Arrival)
On-Time %
Delayed Flights
Average Air-time

6️. Interactive Power BI Dashboard

Designed a dashboard highlighting:

Dashboard Page
Airline Performance: Avg delay per airline, on-time ratings, 
Time-Based Trends: Hour of the day analysis
Detailed View: Drill-through to individual flight performance
Button Slicer: To pinpoint specific Airline for detailed information.

Results & Key Insights
The Night time (12am to 5am) total flights were very low (1849) compared to Afternoon time (123707).
Frontier Airlines showed Avg 20 min Dep and Arrival delay, while US Airways showed the least amount of delay 4 min and 3 min respectively.
The most flown flight route was New York to Los Angeles.
October showed a huge spike in business whereas February was the least performing month

How to Run the Project
Requirements:
PostgreSQL installed
Power BI Desktop
Flight dataset (CSV)

Steps to Execute
Clone the repository to your local machine.
Import the dataset into PostgreSQL using the provided SQL script.
Run data cleaning and EDA SQL queries from the /sql folder.

Open the Power BI file (.pbix) to view the dashboard.

Refresh the dataset to connect with your local PostgreSQL instance.
