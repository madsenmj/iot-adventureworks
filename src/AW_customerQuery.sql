select 
	fc.ProductKey,
	fc.CustomerKey,
	fc.OrderDateKey,
	fc.ShipDateKey,
	fc.SalesOrderNumber,
	REPLACE(dc.AddressLine1, ',' ,' ' ) as AddressLine1,
	dc.AddressLine2,
	dg.City,
	dg.StateProvinceName,
	dg.EnglishCountryRegionName
 from FactInternetSales as fc
JOIN DimCustomer as dc on fc.CustomerKey=dc.CustomerKey
and fc.ProductKey IN ( 220, 221, 222 )
JOIN DimGeography as dg on dc.GeographyKey=dg.GeographyKey