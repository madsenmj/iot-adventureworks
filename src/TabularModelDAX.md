# Tabular Model DAX

## FactInternetSales Table Calculations

### Calculated Columns


``` DAX
[IoTKey] =[CustomerKey] & "_" & [SalesOrderNumber] & "_" & [ProductKey]
```
This key is used to connect the `FactInternetSales` table with the `tripdatafinal` table.

``` DAX
[IoTFirstUse] =MINX(  RELATEDTABLE(tripdatafinal),   tripdatafinal[tripstarttime])
```

``` DAX
[IoTLastUse] =MAXX(  RELATEDTABLE(tripdatafinal),   tripdatafinal[tripendtime])
```

``` DAX
[Days To First Use]=DATEDIFF(FactInternetSales[ShipDate],FactInternetSales[IoTFirstUse],DAY)
```

```DAX
[Total Use Days]=datediff([IoTFirstUse],[IoTLastUse],DAY)
```

### Measures
Calculate the number of people that have purchased a given quantity of an item.

``` DAX
CustomerKeyCount := 
countrows(
    filter(
        groupby(
            FactInternetSales,
            [CustomerKey],
            "entry", 
            countx(
                CURRENTGROUP(),FactInternetSales[ProductKey]
            )
        ), 
        [entry] = 
            Max(
                'Purchase Bins'[N Purchase Bins]
            )
    )
)
```

Get the current number of active users for a given date range (using the Calendar context).
``` DAX
Active Users:=
CALCULATE(
    COUNTROWS(FactInternetSales), 
    FILTER(
        FactInternetSales, 
        ([IoTFirstUse] <= Max('Calendar'[Date]) 
        && [IoTLastUse]>= MIN('Calendar'[Date]))
    ),
    FILTER(
        FactInternetSales,FactInternetSales[ProductKey]=222
    )
)
```
```DAX
Active Users by day:=CALCULATE(COUNTROWS(FactInternetSales), 
    FILTER(FactInternetSales, ([Total Use Days]>Max('Calendar'[Days Since First Use]) )),filter(FactInternetSales,FactInternetSales[ProductKey]=222))
```

```DAX
Fraction of Active Users by day:=divide([Active Users by day],CALCULATE(DISTINCTCOUNT([IoTKey]),FILTER(all(FactInternetSales),FactInternetSales[ProductKey]=222)))
```



## Calendar Table Calculations

### Calculated Columns

``` DAX
[DateKey]=format([Date],"yyyyMMdd")
```
This key is used to connect the `Calendar` table with the `startTimeKey` in the `tripdatafinal` table.

```DAX
[Days Since First Use]=datediff(date(2007,1,1),[Date],DAY)
```

```DAX
[DSFU]=ROUNDDOWN([Days Since First Use]/30,0)*30
```


## tripdatafinal Table Calculations

### Calculated Columns

```DAX
[startTimeKey]=format([tripstarttime],"yyyyMMdd")
```
This key is used to connect the `Calendar` table with the `startTimeKey` in the `tripdatafinal` table.

``` DAX
[Trip Duration (hours)] = datediff([tripstarttime],[tripendtime],SECOND)/3600
```

```DAX
[Days Since First Use]=datediff(related(FactInternetSales[IoTFirstUse]),[tripstarttime],DAY)
```

Columns to get the country location of the trip center.
```DAX
[GPSKey]="("&format([clat],"000.0")&","&format([clon],"000.0")&")"
```
Connect this key to the worldcitiespop data.

```DAX
[GPS Country]=if(related(worldcitiespop[Country])<>BLANK(),RELATED(worldcitiespop[Country]),
	if(LOOKUPVALUE(worldcitiespop[Country],worldcitiespop[GPSKey],"("&format([clat]+0.1,"000.0")&","&format([clon],"000.0")&")")<>BLANK(),
		LOOKUPVALUE(worldcitiespop[Country],worldcitiespop[GPSKey],"("&format([clat]+0.1,"000.0")&","&format([clon],"000.0")&")"),
		if(LOOKUPVALUE(worldcitiespop[Country],worldcitiespop[GPSKey],"("&format([clat],"000.0")&","&format([clon]+0.1,"000.0")&")")<>BLANK(),
			LOOKUPVALUE(worldcitiespop[Country],worldcitiespop[GPSKey],"("&format([clat],"000.0")&","&format([clon]+0.1,"000.0")&")"),
			LOOKUPVALUE(worldcitiespop[Country],worldcitiespop[GPSKey],"("&format([clat]+0.1,"000.0")&","&format([clon]+0.1,"000.0")&")")
		)
	)
)
```

### Measures
Measures to use as bins for average usage measure:
``` DAX
Hours Use bin1:=1
Hours Use bin2:=5
Hours Use bin3:=10
```

Measures for the average use time for different groups
```DAX
Users with less than 1 hour use time:=
calculate(
    COUNTROWS(
        filter( 
            groupby(
                tripdatafinal,
                [iotkey],
	            "Sums",
                sumx(
                    CURRENTGROUP(),
                    [Trip Duration (hours)]
                )
	        ),
	        [Sums] < [Hours Use bin1]
        )
    ),
    Filter(
        all(tripdatafinal),
        [Days Since First Use]<Max('Calendar'[Days Since First Use]) && 
        [Days Since First Use]>=MIN('Calendar'[Days Since First Use])
    )
)
```

```DAX
Users with use time between 1 and 5 hours:=
calculate(
    COUNTROWS(
        filter( 
            groupby(
                tripdatafinal,
                [iotkey],
	            "Sums",
                sumx(
                    CURRENTGROUP(),
                    [Trip Duration (hours)]
                )
	        ),
	        [Sums] < [Hours Use bin2] && [Sums] >= [Hours Use bin1]
        )
    ),
    Filter(
        all(tripdatafinal),
        [Days Since First Use]<Max('Calendar'[Days Since First Use]) && 
        [Days Since First Use]>=min('Calendar'[Days Since First Use])
    )
)
```

```DAX
Users with use time between 5 and 10 hours:=
calculate(
    COUNTROWS(
        filter( 
            groupby(
                tripdatafinal,
                [iotkey],
	            "Sums",
                sumx(
                    CURRENTGROUP(),
                    [Trip Duration (hours)]
                )
	        ),
	        [Sums] < [Hours Use bin3] && [Sums] >= [Hours Use bin2]
        )
    ),
    Filter(
        all(tripdatafinal),
        [Days Since First Use]<Max('Calendar'[Days Since First Use]) && 
        [Days Since First Use]>=min('Calendar'[Days Since First Use])
    )
)
```

```DAX
Users with use time more than 10 hours:=
calculate(
    COUNTROWS(
        filter( 
            groupby(
                tripdatafinal,
                [iotkey],
	            "Sums",
                sumx(
                    CURRENTGROUP(),
                    [Trip Duration (hours)]
                )
	        ),
	        [Sums] >= [Hours Use bin3]
        )
    ),
    Filter(
        all(tripdatafinal),
        [Days Since First Use]<Max('Calendar'[Days Since First Use]) && 
        [Days Since First Use]>=min('Calendar'[Days Since First Use])
    )
)
```

Measures for crash occurances.

```DAX
Number of Minor Crashes:=
calculate(
    calculate(
        DISTINCTCOUNT(tripdatafinal[tripid]),
        filter(
            tripdatafinal,
            tripdatafinal[tripmaxacc] >  10 &&tripdatafinal[tripmaxacc] < 30  
        )
    ),
    Filter(
        all(tripdatafinal),
        [Days Since First Use]<Max('Calendar'[Days Since First Use])
    )
)
```

```DAX
Number of serious crashes:=
calculate(
    calculate(
        DISTINCTCOUNT(tripdatafinal[tripid]),
        filter(
            tripdatafinal,
            tripdatafinal[tripmaxacc] >=  30 && tripdatafinal[tripmaxacc] < 60  
        )
    ),
    Filter(
        all(tripdatafinal),
        [Days Since First Use]<Max('Calendar'[Days Since First Use])
    )
)
```

```DAX
Number of serious crashes:=
calculate(
    calculate(
        DISTINCTCOUNT(tripdatafinal[tripid]),
        filter(
            tripdatafinal,
            tripdatafinal[tripmaxacc] >=  30 && tripdatafinal[tripmaxacc] < 60  
        )
    ),
    Filter(
        all(tripdatafinal),
        [Days Since First Use]<Max('Calendar'[Days Since First Use])
    )
)
```

```DAX
Number of major crashes:=
calculate(
    calculate(
        DISTINCTCOUNT(tripdatafinal[tripid]),
        filter(
            tripdatafinal,
            tripdatafinal[tripmaxacc] >=  60  
        )
    ),
    Filter(
        all(tripdatafinal),
        [Days Since First Use]<Max('Calendar'[Days Since First Use])
    )
)
```

```DAX
Minor Crash Fraction:=
Divide(
    [Number of Minor Crashes],
    calculate(
        DISTINCTCOUNT([iotkey]),
        filter(
            all(tripdatafinal),
            TRUE()
        )
    )
)
```

```DAX
Serious Crash Fraction:=
Divide(
    [Number of serious crashes],
    calculate(
        DISTINCTCOUNT([iotkey]),
        filter(
            all(tripdatafinal),
            TRUE()
        )
    )
)
```

```DAX
Major Crash Fraction:=
Divide(
    [Number of major crashes],
    calculate(
        DISTINCTCOUNT([iotkey]),
        filter(
            all(tripdatafinal),
            TRUE()
        )
    )
)
```

```DAX
Total Replacable Helmet Fraction:=[Major Crash Fraction]+[Serious Crash Fraction]
```

```DAX
IoTActiveUsers:=
COUNTROWS(
    filter(
        GROUPBY(
            tripdatafinal,
            [iotkey],
            "firstuse",
            minx(
                CURRENTGROUP(),
                tripdatafinal[tripstarttime]
            ),
            "lastuse",
            maxx(
                CURRENTGROUP(),
                tripdatafinal[tripendtime]
            )
        ), 
        ([firstuse]<= Max('Calendar'[Date]) && 
            [lastuse]>= MIN('Calendar'[Date]))
    )
)
```

```DAX
Total Distance (km):=sum([tripdistance])
```

```DAX
Total Distance per person (km):=divide([Total Distance (km)],[IoTActiveUsers])
```

## worldcititespop Table

### Calculated Columns
```DAX
[GPSKey]="("&format([Latitude],"000.0")&","&format([Longitude],"000.0")&")"
```

## marketKmperperson Table
This table was loaded, the `year` column selected, and the function `Unpivot other columns` used to unpivot the table.

### Calculated Columns
```DAX
[IoT Avg Distance]=
calculate(
    [Total Distance per person (km)],
    filter(
        tripdatafinal,
        format(tripdatafinal[tripstarttime],"yyyy") = 
          format(marketDistances[Year],"#") &&
            tripdatafinal[GPS Country]=marketDistances[Country]
    )
)
```

```DAX
[Comparison to market average]=divide([IoT Avg Distance],[Avg km per person])
```