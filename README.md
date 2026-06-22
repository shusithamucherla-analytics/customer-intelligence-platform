Enterprise Customer Intelligence Platform

SQL Server  |  Python  |  Power BI  |  Data Warehousing  |  Star Schema


Overview

Working with 541,909 real retail transactions from a UK based online
retailer spanning 2010 to 2011, I designed and built a complete
enterprise analytics platform from the ground up. The project was
designed using data warehousing and analytics engineering practices
commonly used in enterprise reporting environments.


Business Impact Summary

Processed 541,909 retail transactions across 38 countries
Built Customer360 profiles for 4,371 unique customers
Identified 488 VIP customers driving disproportionate revenue
Detected a 33.27 percent churn rate with revenue at risk quantified
Analyzed 8.3 million GBP in total revenue across 14 months
Reduced monthly reporting query execution time by 87.8 percent
Classified customers into 6 behavioral segments for targeted action


Repository Metrics

Metric                    Value
Raw Records               541,909
Valid Transactions         403,722
Unique Customers           4,371
Unique Products            3,684
Countries Covered          38
Total Revenue              8.3 million GBP
Star Schema Tables         5
Analytical Views           7
Stored Procedures          4
Performance Indexes        10


Repository Structure

customer-intelligence-platform/
├── sql/
│   ├── create_tables.sql
│   ├── load_data.sql
│   ├── customer_360.sql
│   ├── views.sql
│   ├── procedures.sql
│   └── indexes.sql
├── etl/
│   └── etl.py
├── powerbi/
│   └── dashboard.pbix
├── docs/
│   ├── architecture.png
│   └── erd.png
└── screenshots/
    ├── executive-dashboard.png
    ├── customer-segmentation.png
    ├── revenue-trends.png
    ├── product-performance.png
    └── geographic-analysis.png


Business Problem

A retail company needed answers to four critical questions. Who are
the most valuable customers and how do we protect them? Which customers
are drifting away before it becomes a revenue problem? What is each
customer actually worth over their lifetime? And how do we move from
gut feel to data driven retention decisions?

This platform was built to answer all four.


Project Architecture

Raw CSV Data
        |
        v
Python ETL Pipeline  extract, validate, clean, transform
        |
        v
SQL Server Star Schema Data Warehouse
FactSales connected to DimCustomer, DimProduct, DimDate, DimCountry
        |
        v
Customer 360 Table  unified customer profile
        |
        v
Analytical Views and Stored Procedures
        |
        v
Power BI Executive Dashboard  5 pages

See docs/architecture.png for the full architecture diagram.
See docs/erd.png for the entity relationship diagram.


Data Warehouse Design

I designed a Star Schema with one central fact table and four dimension
tables. This structure was chosen to support efficient analytical
queries, direct Power BI integration, and scalable reporting as data
volume grows.

FactSales is the central fact table containing 403,722 validated
transaction records with foreign keys to all four dimensions.

DimCustomer stores unique customer profiles enriched with geographic
and market classification data.

DimProduct stores the product catalog with pricing information derived
from transaction history.

DimDate is a fully expanded date dimension supporting year, quarter,
month, week, and weekend level time intelligence.

DimCountry classifies each market by region and domestic versus
international status.


Customer 360

The Customer360 layer provides a consolidated analytical view of
customer behavior, revenue contribution, retention risk, and lifetime
value. It consolidates every behavioral and financial metric per
customer into a single queryable profile including first and last
purchase dates, lifetime revenue, average order value, purchase
frequency, customer lifespan, estimated CLV, RFM score, segment
classification, and churn status with revenue at risk.


Customer 360 Schema

Column                    Description
CustomerID                Unique customer identifier
Country                   Customer country of origin
FirstPurchaseDate         Date of first recorded transaction
LastPurchaseDate          Date of most recent transaction
DaysSinceLastPurchase     Days inactive as of dataset end date
TotalOrders               Count of distinct invoices
TotalRevenue              Cumulative spend in GBP
AvgOrderValue             Average revenue per order
AvgBasketSize             Average units per transaction
PurchaseFrequencyDays     Average days between purchases
CustomerLifespanDays      Days between first and last purchase
EstimatedCLV              Projected 3 year customer lifetime value
RecencyScore              RFM recency quartile score 1 to 4
FrequencyScore            RFM frequency quartile score 1 to 4
MonetaryScore             RFM monetary quartile score 1 to 4
RFMScore                  Concatenated 3 digit RFM score
CustomerSegment           VIP, Loyal, Potential Loyalist, New, At Risk, Lost
ChurnStatus               Active, Warm, Cold, or Churned
RevenueAtRisk             Estimated revenue loss if customer churns


SQL Engineering

The SQL layer demonstrates advanced techniques applied to real
business problems. CTEs were used throughout to keep complex multi
step logic readable and maintainable. NTILE window functions drive
the RFM quartile scoring system, avoiding hardcoded thresholds and
ensuring scores adapt proportionally to actual data distribution.
CASE WHEN logic maps numeric scores into business ready segment
labels. Seven analytical views abstract the Star Schema for Power
BI consumption. Four stored procedures automate RFM refresh, churn
detection, VIP reporting, and monthly executive reporting.


Query Performance Optimization

Implemented 10 indexes across fact and dimension tables.

Monthly executive reporting query
Before optimization    7.4 seconds
After optimization     0.9 seconds
Performance gain       87.8 percent

RFM scoring query across 4,371 customers
Before optimization    4.2 seconds
After optimization     0.6 seconds
Performance gain       85.7 percent


Customer Segmentation

VIP customers score at the top quartile across all three RFM
dimensions. Loyal customers show strong recency and frequency.
Potential Loyalists are recent buyers who have not yet purchased
frequently. New Customers made their first purchase recently.
At Risk customers have historically high frequency but declining
recency. Lost customers show low engagement across all dimensions.


Churn Framework

Active customers purchased within 30 days. Warm customers last
purchased between 31 and 60 days ago. Cold customers are between
61 and 90 days inactive and flagged as high priority. Churned
customers have been inactive for over 90 days and are targeted
for win-back campaigns.

The analysis identified a 33.27 percent churn rate with revenue
at risk calculated per customer to prioritize outreach by financial
impact.


Customer Lifetime Value

CLV is estimated per customer using average order value, purchase
frequency derived from transaction intervals, and an assumed three
year customer lifespan. This drives the CLV distribution dashboard
and supports long term retention investment decisions.


Python ETL Pipeline

The extraction stage reads 541,909 records from source. The
validation stage removes duplicates, filters missing customer
identifiers, flags invalid dates, and removes non positive unit
prices. The transformation stage standardizes text fields, parses
dates, calculates derived metrics, and enriches each record with
regional and market type classifications. The pipeline generates a
full execution report on every run.


Dashboard Preview

Executive Dashboard
(executive-dashboard.png)

Customer Segmentation
(customer-segmentation.png)

Revenue Trends
(revenue-trends.png)

Product Performance
(product-performance.png)

Geographic Analysis
(geographic-analysis.png)


Technical Challenges

Handling 135,120 invalid records including missing customer IDs,
cancelled invoices flagged with negative quantities, and malformed
date strings required building a multi-stage validation pipeline
before any analysis could begin.

Designing RFM thresholds that adapt to actual data distribution
rather than hardcoded values was solved using NTILE window functions
which proportionally distribute customers across quartiles regardless
of data skew.

Building the Customer360 table required joining five tables across
multiple aggregation levels in a single query while maintaining
performance on 403,722 rows, solved through layered CTEs and
targeted indexing.

Optimizing the monthly executive reporting query from 7.4 seconds
to 0.9 seconds required analyzing execution plans and applying
composite indexes on the most frequently filtered column
combinations.


Business Recommendations

The 33 percent churn rate represents a significant and recoverable
revenue opportunity. A structured win-back campaign targeting churned
customers combined with a re-engagement sequence for Cold and Warm
customers should be the immediate priority.

The 488 VIP customers generate disproportionate revenue. Protecting
this segment through personalized outreach and loyalty incentives
is a low cost high return retention strategy.

The December acquisition spike confirms heavy seasonal dependence.
Diversifying acquisition investment across Q2 and Q3 would reduce
revenue volatility and create a more stable growth curve.


Production Considerations

If deployed in a production environment this platform would include
incremental ETL loading to process only new and changed records,
automated scheduling via Apache Airflow or SQL Server Agent, data
quality monitoring with threshold alerting, structured logging and
pipeline failure notifications, cloud storage integration with AWS
S3 or Azure Data Lake, and row level security in Power BI to
restrict data access by role or region.


SQL Techniques Demonstrated

Common Table Expressions, Window Functions, NTILE Quartile Scoring,
DATEDIFF and DATEPART Date Calculations, TRY CAST Type Conversion,
COUNT DISTINCT, Conditional Aggregation, Star Schema Design,
Incremental Loading, Analytical Views, Stored Procedures,
Performance Indexing


Tools and Technologies

SQL Server, SQL Server Management Studio, Python, Pandas, PyODBC,
Power BI, DAX, Star Schema, Data Warehousing, ETL Pipeline Design,
Customer Segmentation, RFM Modeling, Cohort Analysis, Churn
Analysis, Customer Lifetime Value, GitHub


Dataset

Source: UCI Online Retail Dataset

The dataset contains 541,909 transactions from a UK based online
retailer between December 2010 and December 2011, covering 38
countries and 3,684 unique products.

https://www.kaggle.com/datasets/carrie1/ecommerce-data


Author


Shusitha Mucherla

MS in Information Technology Management

GitHub: github.com/shusithamucherla-analytics

