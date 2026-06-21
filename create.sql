 Dimension Table: DimCustomer,Stores unique customer profile and geographic information

CREATE TABLE DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID VARCHAR(20) UNIQUE NOT NULL,
    Country VARCHAR(100),
    Region VARCHAR(100),
    MarketType VARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE()
);


  Dimension Table: DimProduct, Stores unique product catalog with pricing information

CREATE TABLE DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    StockCode VARCHAR(20) UNIQUE NOT NULL,
    Description VARCHAR(500),
    AvgUnitPrice DECIMAL(10,2),
    CreatedDate DATETIME DEFAULT GETDATE()
);


  Dimension Table: DimDate, Stores a fully expanded date dimension for time intelligence

CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Year INT,
    Quarter INT,
    Month INT,
    MonthName VARCHAR(20),
    Day INT,
    DayName VARCHAR(20),
    IsWeekend BIT,
    IsHoliday BIT DEFAULT 0
);


  Dimension Table: DimCountry, Stores country level geographic and market classification

CREATE TABLE DimCountry (
    CountryKey INT IDENTITY(1,1) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE NOT NULL,
    Region VARCHAR(100),
    MarketType VARCHAR(50)
);


-- Fact Table: FactSales
-- Central fact table connecting all dimensions
-- Contains one row per transaction line item

CREATE TABLE FactSales (
    SalesKey INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceNo VARCHAR(20),
    CustomerKey INT FOREIGN KEY REFERENCES DimCustomer(CustomerKey),
    ProductKey INT FOREIGN KEY REFERENCES DimProduct(ProductKey),
    DateKey INT FOREIGN KEY REFERENCES DimDate(DateKey),
    CountryKey INT FOREIGN KEY REFERENCES DimCountry(CountryKey),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    TotalRevenue DECIMAL(12,2),
    IsReturn BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE()
);


  Customer 360 Table, Unified customer view combining transactional behavior, RFM scores, segmentation, CLV, and churn status.This is the single source of truth for customer analytics.

CREATE TABLE Customer360 (
    CustomerKey INT PRIMARY KEY,
    CustomerID VARCHAR(20),
    Country VARCHAR(100),
    Region VARCHAR(100),
    FirstPurchaseDate DATE,
    LastPurchaseDate DATE,
    DaysSinceLastPurchase INT,
    TotalOrders INT,
    TotalRevenue DECIMAL(12,2),
    AvgOrderValue DECIMAL(10,2),
    AvgBasketSize DECIMAL(10,2),
    PurchaseFrequencyDays DECIMAL(10,2),
    CustomerLifespanDays INT,
    EstimatedCLV DECIMAL(12,2),
    RecencyScore INT,
    FrequencyScore INT,
    MonetaryScore INT,
    RFMScore VARCHAR(10),
    CustomerSegment VARCHAR(50),
    ChurnStatus VARCHAR(20),
    RevenueAtRisk DECIMAL(12,2),
    LastUpdated DATETIME DEFAULT GETDATE()
);
