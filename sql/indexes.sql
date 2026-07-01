Description: Performance indexes on fact and dimension tables to optimize analytical query execution


CREATE INDEX idx_FactSales_Customer ON FactSales(CustomerKey);
CREATE INDEX idx_FactSales_Product ON FactSales(ProductKey);
CREATE INDEX idx_FactSales_Date ON FactSales(DateKey);
CREATE INDEX idx_FactSales_Country ON FactSales(CountryKey);
CREATE INDEX idx_FactSales_Return ON FactSales(IsReturn);
CREATE INDEX idx_Customer360_Segment ON Customer360(CustomerSegment);
CREATE INDEX idx_Customer360_Churn ON Customer360(ChurnStatus);
CREATE INDEX idx_Customer360_CLV ON Customer360(EstimatedCLV);
CREATE INDEX idx_DimDate_YearMonth ON DimDate(Year, Month);
CREATE INDEX idx_DimCustomer_Country ON DimCustomer(Country);
