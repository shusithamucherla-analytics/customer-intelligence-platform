Description: Stored procedures automating RFM scoring, churn detection, VIP reporting, and monthly analytics


CREATE PROCEDURE UpdateRFMScores
AS
BEGIN
    WITH RFMScored AS (
        SELECT f.CustomerKey,
            NTILE(4) OVER (ORDER BY 
                DATEDIFF(day, MAX(d.FullDate), '2011-12-09') DESC) AS R,
            NTILE(4) OVER (ORDER BY 
                COUNT(DISTINCT f.InvoiceNo) ASC) AS F,
            NTILE(4) OVER (ORDER BY 
                ROUND(SUM(f.TotalRevenue), 2) ASC) AS M
        FROM FactSales f
        JOIN DimDate d ON f.DateKey = d.DateKey
        WHERE f.IsReturn = 0
        GROUP BY f.CustomerKey
    )
    UPDATE Customer360
    SET
        RecencyScore = r.R,
        FrequencyScore = r.F,
        MonetaryScore = r.M,
        RFMScore = CONCAT(CAST(r.R AS VARCHAR),
            CAST(r.F AS VARCHAR), CAST(r.M AS VARCHAR)),
        CustomerSegment = CASE
            WHEN r.R = 4 AND r.F = 4 AND r.M = 4 THEN 'VIP'
            WHEN r.R >= 3 AND r.F >= 3 THEN 'Loyal'
            WHEN r.R >= 3 AND r.F <= 2 THEN 'Potential Loyalist'
            WHEN r.R = 4 AND r.F = 1 THEN 'New Customer'
            WHEN r.R <= 2 AND r.F >= 3 THEN 'At Risk'
            ELSE 'Lost'
        END,
        LastUpdated = GETDATE()
    FROM Customer360 c
    JOIN RFMScored r ON c.CustomerKey = r.CustomerKey;
END;
GO


CREATE PROCEDURE DetectChurn
AS
BEGIN
    SELECT
        c.CustomerID, c.Country, c.CustomerSegment,
        c.ChurnStatus, c.DaysSinceLastPurchase,
        c.TotalRevenue, c.EstimatedCLV, c.RevenueAtRisk,
        CASE
            WHEN c.ChurnStatus = 'Cold' THEN 'High Priority'
            WHEN c.ChurnStatus = 'Warm' THEN 'Medium Priority'
            WHEN c.ChurnStatus = 'Churned' THEN 'Win-Back Campaign'
            ELSE 'Monitor'
        END AS ActionRequired
    FROM Customer360 c
    WHERE c.ChurnStatus IN ('Cold', 'Churned', 'Warm')
    ORDER BY c.RevenueAtRisk DESC;
END;
GO


CREATE PROCEDURE GenerateVIPCustomers
AS
BEGIN
    SELECT TOP 100
        c.CustomerID, c.Country, c.CustomerSegment,
        c.TotalOrders, c.TotalRevenue, c.EstimatedCLV,
        c.RFMScore,
        RANK() OVER (ORDER BY c.TotalRevenue DESC) AS RevenueRank
    FROM Customer360 c
    WHERE c.CustomerSegment IN ('VIP', 'Loyal')
    ORDER BY c.TotalRevenue DESC;
END;
GO


CREATE PROCEDURE GenerateMonthlyCustomerReport
    @Year INT = 2011,
    @Month INT = 11
AS
BEGIN
    SELECT
        COUNT(DISTINCT f.CustomerKey) AS ActiveCustomers,
        COUNT(DISTINCT f.InvoiceNo) AS TotalOrders,
        ROUND(SUM(f.TotalRevenue), 2) AS TotalRevenue,
        ROUND(AVG(f.TotalRevenue), 2) AS AvgOrderValue
    FROM FactSales f
    JOIN DimDate d ON f.DateKey = d.DateKey
    WHERE d.Year = @Year AND d.Month = @Month
    AND f.IsReturn = 0;

    SELECT CustomerSegment,
        COUNT(*) AS Customers,
        ROUND(SUM(TotalRevenue), 2) AS Revenue
    FROM Customer360
    GROUP BY CustomerSegment
    ORDER BY Revenue DESC;
END;
GO
