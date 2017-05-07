# Aventure Works IoT Demonstration

Utilizing simulated IoT data to enrich enterprise data stores.

# Documentation

The demonstration presentation is [here](/docs/AW_IoT_Data_Insights_Demo.pptx) with a video presentation [here](https://youtu.be/zPx1lYUaAwk)

# Description

Get the customers from the Adventure Works Cycles demo SQL Server database that have purchased the bicycle helmet (model HL-U509-B). 

Input data from SQL query TODO: get this /data/AW_helmet_customerData.csv

Then simulate data runs: /src/Simulate_IoT_data.ipynb outputs the following:

1) /data/GeoCodeLocations.csv (added geocode locations to the Adventure Works data)
2) /data/updatedCustomerDatabase.csv
3) A folder with the raw trip data in it: /data/tripdata/data_' + iotID + '.csv' where the iotID consists of the CustomerKey + the SalesOrderNumber + the ProductKey

The tripdata folder is then uploaded to a Hadoop cluster for processing using the /src/aggregate_trip_data.hive script. From there the data in the new hive table is connected to the tabular model for analysis. An example of the output hive table is found in /data/tripdata_hive_sample.csv from the raw data found in the /data/simulated_tripdata_sample folder.


