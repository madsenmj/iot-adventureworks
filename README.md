# Aventure Works IoT Demonstration

Utilizing simulated IoT data to enrich enterprise data stores.

# Documentation

The demonstration presentation is [here](/docs/AW_IoT_Data_Insights_Demo.pptx) with a video presentation [here](https://youtu.be/zPx1lYUaAwk)

# Description

The goal of this project is to create a set of simulated Internet of Things (IoT) data to accompany the Microsoft AdventureWorks database. This enables a demonstration of how IoT data could be utilized to improve business outcomes. The simulated IoT data is based on a simulated bicycle helmet that has
1. A GPS reciever that records lattitude, longitude, and time stamps
2. An accelerometer that measures average helment acceleration and can detect potential crashes
3. A mobile emitter (cellular network) that connects to an IoT Hub. 

The device transmits the telemetry data on 10 second intervals for as long as the helmet is turned on. 

# Initial Data

The starting point for this project is the [AdventurWorks2012DW data file for SQL server](https://msftdbprodsamples.codeplex.com/releases/view/55330). The downloaded database is then [attached to the SQL Server using SSMS](https://docs.microsoft.com/en-us/sql/relational-databases/databases/attach-a-database). Once attached the following query is run on the database to extract the bicycle helmet users that have purchased the bicycle helmet (model HL-U509-B): [SQL Query](/src/AW_customerQuery.sql). The output is then copied (select all, right-click, use `Copy with Headers`) from the window in SSMS and pasted into a [csv file](/data/AW_helment_customerData.csv).

# Simulate IoT Data.

A Python notebook, [Simulate_IoT_Data](/src/Simulate_IoT_Data.ipynb), reads in the data extracted from the SQL database and does the following steps to simulate device use:
1. Generate the GeoCodes for each address in the database to use as a starting position for bicycle rides (stored in [this file](/data/GeoCodeLocations.csv))
2. Generate a set of simulated characteristics for the bicycle riders including
    * Average Trip Speed
    * Trip Consistency (how constant does the rider keep their speed)
    * Average Trip Distance
    * Average Days between uses
3. The notebook then runs through all of the rows in the extracted data and simulates trips for each customer. Each trip is given a `UUID`. The simulated raw trip data are saved in a folder: `/data/tripdata/data_' + iotID + '.csv'` where the `iotID` consists of the `CustomerKey + SalesOrderNumber + ProductKey`.

A [data file](/data/updatedCustomerDatabase.csv) is maintained with the generated information and whether the rider has quit using their helmet. This file is updated after each simulated trip. A subset of the data are included in this repository in the [`data/simulated_tripdata_sample`](/data/simulated_tripdata_sample) folder.

# Initial Trip Data Analysis

The tripdata folder is then uploaded to a Hadoop cluster for processing using the a [Hive script](/src/aggregate_trip_data.hive). 

# Tabular Model

From there the data in the new hive table is connected to the tabular model for analysis. An example of the output hive table is found in /data/tripdata_hive_sample.csv from the raw data found in the /data/simulated_tripdata_sample folder.


