Description: Loads raw staging data into Star Schema dimension and fact tables using incremental logic


INSERT INTO DimCountry (Country, Region, MarketType)
SELECT DISTINCT
    Country,
    CASE
        WHEN Country = 'United Kingdom' THEN 'Western Europe'
        WHEN Country IN ('France','Germany','Spain','Italy',
            'Belgium','Netherlands','Switzerland','Portugal',
            'Austria','Denmark','Sweden','Norway','Finland',
            'EIRE','Cyprus','Greece','Malta','Lithuania') 
            THEN 'Western Europe'
        WHEN Country IN ('Australia','Japan','Singapore',
            'Hong Kong','Bahrain','UAE') THEN 'Asia Pacific'
        WHEN Country IN ('USA','Canada') THEN 'North America'
        WHEN Country IN ('Brazil') THEN 'Latin America'
        ELSE 'Other'
    END,
    CASE
        WHEN Country = 'United Kingdom' THEN 'Domestic'
        ELSE 'International'
    END
FROM ecommerce_data
WHERE Country IS NOT NULL
AND Country NOT IN (SELECT Country FROM DimCountry);

INSERT INTO DimCustomer (CustomerID, Country, Region, MarketType)
SELECT DISTINCT
    e.CustomerID,
    e.Country,
    c.Region,
    c.MarketType
FROM ecommerce_data e
JOIN DimCountry c ON e.Country = c.Country
WHERE e.CustomerID IS NOT NULL
AND e.CustomerID NOT IN (SELECT CustomerID FROM DimCustomer);

INSERT INTO DimProduct (StockCode, Description, AvgUnitPrice)
SELECT
    StockCode,
    MAX(Description),
    AVG(TRY_CAST(UnitPrice AS DECIMAL(10,2)))
FROM ecommerce_data
WHERE StockCode IS NOT NULL
AND Description IS NOT NULL
AND StockCode NOT IN (SELECT StockCode FROM DimProduct)
GROUP BY StockCode;

INSERT INTO DimDate (
    DateKey, FullDate, Year, Quarter, Month,
    MonthName, Day, DayName, IsWeekend
)
SELECT DISTINCT
    CAST(FORMAT(CAST(InvoiceDate AS DATETIME), 'yyyyMMdd') AS INT),
    CAST(CAST(InvoiceDate AS DATETIME) AS DATE),
    YEAR(CAST(InvoiceDate AS DATETIME)),
    DATEPART(QUARTER, CAST(InvoiceDate AS DATETIME)),
    MONTH(CAST(InvoiceDate AS DATETIME)),
    DATENAME(MONTH, CAST(InvoiceDate AS DATETIME)),
    DAY(CAST(InvoiceDate AS DATETIME)),
    DATENAME(WEEKDAY, CAST(InvoiceDate AS DATETIME)),
    CASE WHEN DATEPART(WEEKDAY, 
        CAST(InvoiceDate AS DATETIME)) IN (1,7) THEN 1 ELSE 0 END
FROM ecommerce_data
WHERE ISDATE(InvoiceDate) = 1
AND CAST(FORMAT(CAST(InvoiceDate AS DATETIME), 'yyyyMMdd') AS INT)
    NOT IN (SELECT DateKey FROM DimDate);

INSERT INTO FactSales (
    InvoiceNo, CustomerKey, ProductKey,
    DateKey, CountryKey, Quantity,
    UnitPrice, TotalRevenue, IsReturn
)
SELECT
    e.InvoiceNo,
    c.CustomerKey,
    p.ProductKey,
    CAST(FORMAT(CAST(e.InvoiceDate AS DATETIME), 'yyyyMMdd') AS INT),
    co.CountryKey,
    TRY_CAST(e.Quantity AS INT),
    TRY_CAST(e.UnitPrice AS DECIMAL(10,2)),
    TRY_CAST(e.Quantity AS INT) * 
        TRY_CAST(e.UnitPrice AS DECIMAL(10,2)),
    CASE WHEN TRY_CAST(e.Quantity AS INT) < 0 THEN 1 ELSE 0 END
FROM ecommerce_data e
JOIN DimCustomer c ON e.CustomerID = c.CustomerID
JOIN DimProduct p ON e.StockCode = p.StockCode
JOIN DimCountry co ON e.Country = co.Country
WHERE e.CustomerID IS NOT NULL
AND e.StockCode IS NOT NULL
AND ISDATE(e.InvoiceDate) = 1
AND TRY_CAST(e.Quantity AS INT) IS NOT NULL
AND TRY_CAST(e.UnitPrice AS DECIMAL(10,2)) IS NOT NULL;
