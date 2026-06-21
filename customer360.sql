Description: Builds the Customer 360 unified view by combining transactional behavior, RFM scoring, CLV estimation, segmentation, and churn classification into a single queryable table


 Step 1: Populate Customer 360
This query joins FactSales with dimension tables to compute every behavioral and financial metric per customer.CLV is estimated using average order value multiplied by purchase frequency and an assumed 3 year customer lifespan.

INSERT INTO Customer360 (
    CustomerKey, CustomerID, Country, Region,
    FirstPurchaseDate, LastPurchaseDate,
    DaysSinceLastPurchase, TotalOrders, TotalRevenue,
    AvgOrderValue, AvgBasketSize, PurchaseFrequencyDays,
    CustomerLifespanDays, EstimatedCLV,
    RecencyScore, FrequencyScore, MonetaryScore,
    RFMScore, CustomerSegment, ChurnStatus, RevenueAtRisk
)
WITH CustomerMetrics AS (
    SELECT
        f.CustomerKey,
        c.CustomerID,
        c.Country,
        c.Region,
        MIN(d.FullDate) AS FirstPurchaseDate,
        MAX(d.FullDate) AS LastPurchaseDate,
        DATEDIFF(day, MAX(d.FullDate), '2011-12-09')
            AS DaysSinceLastPurchase,
        COUNT(DISTINCT f.InvoiceNo) AS TotalOrders,
        ROUND(SUM(f.TotalRevenue), 2) AS TotalRevenue,
        ROUND(AVG(f.TotalRevenue), 2) AS AvgOrderValue,
        ROUND(AVG(CAST(f.Quantity AS FLOAT)), 2) AS AvgBasketSize,
        ROUND(
            CAST(DATEDIFF(day, MIN(d.FullDate), 
                MAX(d.FullDate)) AS FLOAT)
            / NULLIF(COUNT(DISTINCT f.InvoiceNo) - 1, 0), 2
        ) AS PurchaseFrequencyDays,
        DATEDIFF(day, MIN(d.FullDate), MAX(d.FullDate))
            AS CustomerLifespanDays
    FROM FactSales f
    JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
    JOIN DimDate d ON f.DateKey = d.DateKey
    WHERE f.IsReturn = 0
    GROUP BY f.CustomerKey, c.CustomerID, c.Country, c.Region
),
RFMScores AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY DaysSinceLastPurchase DESC)
            AS RecencyScore,
        NTILE(4) OVER (ORDER BY TotalOrders ASC)
            AS FrequencyScore,
        NTILE(4) OVER (ORDER BY TotalRevenue ASC)
            AS MonetaryScore
    FROM CustomerMetrics
),
CLVCalculation AS (
    SELECT *,
        CONCAT(
            CAST(RecencyScore AS VARCHAR),
            CAST(FrequencyScore AS VARCHAR),
            CAST(MonetaryScore AS VARCHAR)
        ) AS RFMScore,
        ROUND(
            AvgOrderValue *
            (365.0 / NULLIF(PurchaseFrequencyDays, 0)) * 3, 2
        ) AS EstimatedCLV,
        CASE
            WHEN RecencyScore = 4
                AND FrequencyScore = 4
                AND MonetaryScore = 4
                THEN 'VIP'
            WHEN RecencyScore >= 3
                AND FrequencyScore >= 3
                THEN 'Loyal'
            WHEN RecencyScore >= 3
                AND FrequencyScore <= 2
                THEN 'Potential Loyalist'
            WHEN RecencyScore = 4
                AND FrequencyScore = 1
                THEN 'New Customer'
            WHEN RecencyScore <= 2
                AND FrequencyScore >= 3
                THEN 'At Risk'
            ELSE 'Lost'
        END AS CustomerSegment,
        CASE
            WHEN DaysSinceLastPurchase <= 30 THEN 'Active'
            WHEN DaysSinceLastPurchase <= 60 THEN 'Warm'
            WHEN DaysSinceLastPurchase <= 90 THEN 'Cold'
            ELSE 'Churned'
        END AS ChurnStatus
    FROM RFMScores
)
SELECT
    CustomerKey, CustomerID, Country, Region,
    FirstPurchaseDate, LastPurchaseDate,
    DaysSinceLastPurchase, TotalOrders, TotalRevenue,
    AvgOrderValue, AvgBasketSize, PurchaseFrequencyDays,
    CustomerLifespanDays, EstimatedCLV,
    RecencyScore, FrequencyScore, MonetaryScore,
    RFMScore, CustomerSegment, ChurnStatus,
    CASE
        WHEN ChurnStatus IN ('Cold', 'Churned')
            THEN TotalRevenue * 0.3
        ELSE 0
    END AS RevenueAtRisk
FROM CLVCalculation;


 Step 2: Segment Summary
Quick business summary of customer distribution across segments and churn categories

SELECT
    CustomerSegment,
    ChurnStatus,
    COUNT(*) AS TotalCustomers,
    ROUND(SUM(TotalRevenue), 2) AS TotalRevenue,
    ROUND(AVG(EstimatedCLV), 2) AS AvgCLV,
    ROUND(SUM(RevenueAtRisk), 2) AS TotalRevenueAtRisk
FROM Customer360
GROUP BY CustomerSegment, ChurnStatus
ORDER BY TotalRevenue DESC;
