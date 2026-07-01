Description: Analytical views that abstract the Star Schema and serve as the direct data source for Power BI dashboards and executive reporting workflows

View 1: Executive KPIs
Top level business metrics for the executive summary page. Aggregates total revenue, orders, customers, AOV, and churn rate into a single row dashboard feed


CREATE VIEW vw_ExecutiveKPIs AS
SELECT
    ROUND(SUM(f.TotalRevenue), 2) AS TotalRevenue,
    COUNT(DISTINCT f.InvoiceNo) AS TotalOrders,
    COUNT(DISTINCT f.CustomerKey) AS TotalCustomers,
    ROUND(AVG(f.TotalRevenue), 2) AS AvgOrderValue,
    ROUND(
        CAST(SUM(CASE WHEN f.IsReturn = 1 
            THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2
    ) AS ReturnRate,
    ROUND(
        CAST(COUNT(DISTINCT CASE 
            WHEN c.ChurnStatus = 'Churned' 
            THEN c.CustomerKey END) AS FLOAT)
        / COUNT(DISTINCT f.CustomerKey) * 100, 2
    ) AS ChurnRate
FROM FactSales f
LEFT JOIN Customer360 c ON f.CustomerKey = c.CustomerKey;
GO


View 2: Monthly Revenue Trends
Month over month revenue, orders, and AOV for trend analysis and forecasting on the sales trends dashboard page

CREATE VIEW vw_MonthlyRevenue AS
SELECT
    d.Year,
    d.Month,
    d.MonthName,
    d.Quarter,
    COUNT(DISTINCT f.InvoiceNo) AS TotalOrders,
    COUNT(DISTINCT f.CustomerKey) AS UniqueCustomers,
    ROUND(SUM(f.TotalRevenue), 2) AS TotalRevenue,
    ROUND(AVG(f.TotalRevenue), 2) AS AvgOrderValue,
    SUM(f.Quantity) AS TotalUnitsSold
FROM FactSales f
JOIN DimDate d ON f.DateKey = d.DateKey
WHERE f.IsReturn = 0
GROUP BY d.Year, d.Month, d.MonthName, d.Quarter;
GO


View 3: Customer Segment Performance
Revenue, orders, and CLV metrics broken down by segment. Powers the customer segments dashboard page

CREATE VIEW vw_CustomerSegments AS
SELECT
    c.CustomerSegment,
    c.ChurnStatus,
    COUNT(*) AS TotalCustomers,
    ROUND(SUM(c.TotalRevenue), 2) AS TotalRevenue,
    ROUND(AVG(c.AvgOrderValue), 2) AS AvgOrderValue,
    ROUND(AVG(c.EstimatedCLV), 2) AS AvgCLV,
    ROUND(SUM(c.RevenueAtRisk), 2) AS TotalRevenueAtRisk,
    ROUND(AVG(c.DaysSinceLastPurchase), 0) AS AvgDaysSinceLastPurchase
FROM Customer360 c
GROUP BY c.CustomerSegment, c.ChurnStatus;
GO


View 4: Product Performance
Top and bottom performing products by revenue and quantity. Powers the product intelligence dashboard page

CREATE VIEW vw_ProductPerformance AS
SELECT
    p.StockCode,
    p.Description,
    COUNT(DISTINCT f.InvoiceNo) AS TotalOrders,
    SUM(f.Quantity) AS TotalUnitsSold,
    ROUND(SUM(f.TotalRevenue), 2) AS TotalRevenue,
    ROUND(AVG(f.UnitPrice), 2) AS AvgUnitPrice,
    ROUND(
        SUM(f.TotalRevenue) * 100.0 /
        SUM(SUM(f.TotalRevenue)) OVER(), 2
    ) AS RevenueContributionPct
FROM FactSales f
JOIN DimProduct p ON f.ProductKey = p.ProductKey
WHERE f.IsReturn = 0
GROUP BY p.StockCode, p.Description;
GO


 View 5: Geographic Performance
 Country level revenue, orders, and customer metrics. Powers the geographic intelligence dashboard page

CREATE VIEW vw_GeographicPerformance AS
SELECT
    co.Country,
    co.Region,
    co.MarketType,
    COUNT(DISTINCT f.CustomerKey) AS UniqueCustomers,
    COUNT(DISTINCT f.InvoiceNo) AS TotalOrders,
    ROUND(SUM(f.TotalRevenue), 2) AS TotalRevenue,
    ROUND(AVG(f.TotalRevenue), 2) AS AvgOrderValue,
    ROUND(
        SUM(f.TotalRevenue) * 100.0 /
        SUM(SUM(f.TotalRevenue)) OVER(), 2
    ) AS RevenueSharePct
FROM FactSales f
JOIN DimCountry co ON f.CountryKey = co.CountryKey
WHERE f.IsReturn = 0
GROUP BY co.Country, co.Region, co.MarketType;
GO


View 6: Cohort Acquisition
 Monthly new customer acquisition for cohort analysis Powers the cohort analysis dashboard page

CREATE VIEW vw_CohortAcquisition AS
SELECT
    FORMAT(c.FirstPurchaseDate, 'yyyy-MM') AS CohortMonth,
    c.Region,
    COUNT(*) AS NewCustomers,
    ROUND(SUM(c.TotalRevenue), 2) AS CohortRevenue,
    ROUND(AVG(c.EstimatedCLV), 2) AS AvgCLV
FROM Customer360 c
GROUP BY FORMAT(c.FirstPurchaseDate, 'yyyy-MM'), c.Region;
GO


 View 7: Churn Dashboard
 Detailed churn metrics including revenue at risk and lost revenue by segment and status

CREATE VIEW vw_ChurnDashboard AS
SELECT
    c.ChurnStatus,
    c.CustomerSegment,
    COUNT(*) AS TotalCustomers,
    ROUND(SUM(c.TotalRevenue), 2) AS TotalRevenue,
    ROUND(SUM(c.RevenueAtRisk), 2) AS RevenueAtRisk,
    ROUND(AVG(c.DaysSinceLastPurchase), 0) AS AvgInactiveDays,
    ROUND(AVG(c.EstimatedCLV), 2) AS AvgCLV
FROM Customer360 c
GROUP BY c.ChurnStatus, c.CustomerSegment;
GO
