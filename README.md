
*Customer segmentation using RFM Analysis, Cohort Analysis and Churn Analysis on retail transactions


Most businesses collect transactional data but rarely use it to understand the humans behind the purchases. This project was an attempt to bridge that gap.
Working with 541,909 transactions from a UK based online retailer spanning 2010 to 2011, I built a multi-layered customer analytics framework in SQL Server. The objective was not just to describe the data but to produce insights that a marketing or growth team could act on immediately.
The entire analysis was written using advanced SQL concepts including Common Table Expressions, Window Functions, conditional aggregations, and date-based calculations,structured in a way that is both readable and scalable.

What I Built and Why?
RFM Scoring Engine:

The foundation of the project was an RFM model — a proven framework used widely in CRM and marketing analytics. I calculated three metrics for each customer using a single CTE — Recency measured as days since last purchase using DATEDIFF, Frequency as the count of distinct invoices using COUNT DISTINCT, and Monetary as total revenue contribution using SUM with TRY_CAST for safe type conversion.
Once the base metrics were established, I applied NTILE(4) window functions to rank customers into quartiles across each dimension independently. This approach avoids hardcoded thresholds and ensures the scoring adapts proportionally to the actual data distribution.


Customer Segmentation:

Building on the RFM scores, I used nested CTEs combined 
with CASE WHEN logic to classify every customer into one 
of four strategic segments. VIP Customers scored at the 
top quartile across all three dimensions. Loyal Customers 
showed strong recency and frequency even if monetary value 
was moderate. At Risk Customers had historically high 
frequency but declining recency, signaling disengagement. 
Lost Customers showed low scores across the board.

This segmentation transforms a table of numbers into 
a framework a business team can immediately understand 
and act upon.

Cohort Analysis

To understand acquisition trends, I identified each customer's first purchase date using MIN aggregation grouped by CustomerID, then formatted the result into 
year-month cohorts using the FORMAT function. Tracking new customer volume by cohort month reveals seasonality patterns, campaign effectiveness, and long term acquisition health,all from a single query.

Churn Detection Model:

For churn analysis, I calculated the number of days between each customer's last purchase and the dataset end date using DATEDIFF. Customers were then categorized into four buckets using CASE WHEN — Active for under 30 days, Warm for 31 to 60 days, Cold for 61 to 90 days, and Churned for anything beyond 90 days. I used SUM OVER as a window function to calculate percentage share dynamically without a subquery.



Key Findings

Customer Segmentation Results showed 488 VIP Customers as the highest value segment, 951 Loyal Customers with consistent purchase behavior, 729 At Risk Customers 
showing early churn signals, and 2,169 Lost Customers representing the largest and most urgent segment.

Churn Analysis revealed that 39.18 percent of customers remained Active, while 33.27 percent had fully churned. The remaining 27 percent split between Warm and Cold. Customers represent a recoverable segment if acted on quickly.

Cohort Analysis showed December 2010 as the peak acquisition month with 947 new customers, followed by a gradual decline through mid 2011 and a partial recovery in Q4 2011. This pattern strongly suggests the business relies heavily on seasonal demand cycles.


Business Recommendations

The 33 percent churn rate translates directly to lost revenue. A structured re-engagement sequence targeting the 729 Cold and At Risk customers, followed by a 
win-back campaign for the 2,169 Lost customers, represents the highest return opportunity identified in this analysis.
The 488 VIP customers contribute disproportionately to overall revenue. Protecting this segment through personalized outreach, loyalty incentives, and early 
access programs should be treated as a retention priority.
The December acquisition spike reveals an over-reliance on seasonal demand. Investing in Q2 and Q3 acquisition channels would reduce revenue volatility and create 
a more stable customer growth curve throughout the year.


Technical Skills Demonstrated

SQL Server, Common Table Expressions, Window Functions, NTILE Quartile Scoring, DATEDIFF Date Calculations, TRY_CAST Type Conversion, COUNT DISTINCT, Conditional 
Aggregation, RFM Modeling, Customer Segmentation, Cohort Analysis, Churn Modeling, Business Intelligence, Data Storytelling


Dataset
UCI Online Retail Dataset
https://www.kaggle.com/datasets/carrie1/ecommerce-data

Author

Shusitha Mucherla

MS in Information Technology Management

GitHub: github.com/shusithamucherla-analytics
