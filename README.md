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

The starting point for this project is the [AdventurWorks2012DW data file for SQL server](https://msftdbprodsamples.codeplex.com/releases/view/55330). The downloaded database is then [attached to the SQL Server using SSMS](https://docs.microsoft.com/en-us/sql/relational-databases/databases/attach-a-database). Once attached the following query is run on the database to extract the bicycle helmet users that have purchased the bicycle helmet (model HL-U509-B): [SQL Query](/src/AW_customerQuery.sql). The output is then copied (select all, right-click, use `Copy with Headers`) from the window in SSMS and pasted into a [csv file](/data/AW_helmet_customerData.csv).

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

The `tripdata` folder is then uploaded to a Hadoop cluster for processing. See [this information](https://hortonworks.com/products/sandbox/) for details on how to provision a virual Hadoop cluster and tutorials on moving the data and running Hive scripts.

The data are moved to the `HDFS` to a new folder `tripdata` in `/user/maria_dev/`. The [Hive script](/src/aggregate_trip_data.hive) is then executed which summarizes the data and saves the output summary in a new file in `HDFS`: `/user/maria_dev/tripdata/summary/`. The filenames vary depending on the size of the input dataset, but will be numbered sequentially. A sample of this data (with added column headers) is provided [here](/data/tripdata_hive_sample.csv).

# Connecting to Power Pivot

Following [this tutorial](https://ayadshammout.com/2013/05/27/import-hadoop-data-into-sql-bi-semantic-model-tabular/), create the ODBC link between the Hadoop table and Power Pivot. 
* [Download Hive ODBC Driver](https://hortonworks.com/downloads/)
* [Configure ODBC driver](http://hortonworks.com/wp-content/uploads/2015/10/Hortonworks-Hive-ODBC-Driver-User-Guide.pdf)
* Use the `iotdata` database and the `maria_dev` username.
* Load the data into Power Pivot using the ODBC data source (using `Load to...` create a connection and load to the data model).


# Tabular Model

The sample PowerPivot tables and charts are provided [here](/src/TabularModel.xlsx).

Connect to the SQL Server AdventureWorks database in the same Power Pivot notebook. Import the following tables:
* `DimCustomer`
* `DimGeography`
* `DimProduct`
* `DimProductCategory`
* `DimProductSubcategory`
* `FactInternetSales`

## Power Query Editor

I edited the input tables, removing unneeded columns and converting column types to appropriate values. After adding the `IoTKey` calculated column in the `FactInternetSales` table, connect the key from the `tripdatafinal` table in the relationships.

I also filtered the `ProductKey` column in the `FactInternetSales` table to show only the product `222`, which is the product used for the IoT simulation.

## Additional Data

I added a date table (`Design\Date Table`) and set the date range from `1/1/2007` to `12/31/2017`.

I added a new tab with a table `N Purchase Bins` which is a sequence of numbers counting up from `0` to `100`. I added this table to the model as `Purchase Bins`.

Finally I added a [geographical database](\data\worldcitiespop.txt) that has geocode information for different world cities and countries. This data comes from [here](https://www.maxmind.com/en/free-world-cities-database) and has been reduced for the purpose of this project.

## DAX Patterns

The `DAX` patterns for the tabular model are described [here](\src\TabularModelDAX.md).


