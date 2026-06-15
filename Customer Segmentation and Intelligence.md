

### &#x20;**Project: Customer Intelligence \& Segmentation**

##### &#x20;Author: Shusitha Mucherla

##### &#x20;Tool: SQL Server Management Studio

##### &#x20;Dataset: UCI UK Online Retail (2010-2011)



&#x20;I analyzed customer purchasing behavior to help businesses understand who their best customers are,who is slipping away,and who they have already lost





###### &#x20;Query 1: RFM Base Analysis

&#x20;Before segmenting customers, I first calculated three core metrics for each customer, Also mentioned

&#x20;Recency - how recently they purchased

&#x20;Frequency - how often they purchased

&#x20;Monetary - how much they spent in total



WITH RFM\_Base AS (

&#x20;   SELECT 

&#x20;       CustomerID,

&#x20;       DATEDIFF(day, MAX(CAST(InvoiceDate AS DATETIME)), 

&#x20;           '2011-12-09') AS Recency,

&#x20;       COUNT(DISTINCT InvoiceNo) AS Frequency,

&#x20;       ROUND(SUM(TRY\_CAST(Quantity AS INT) \* 

&#x20;           TRY\_CAST(UnitPrice AS DECIMAL(10,2))), 2) AS Monetary

&#x20;   FROM ecommerce\_data

&#x20;   WHERE CustomerID IS NOT NULL

&#x20;   AND ISDATE(InvoiceDate) = 1

&#x20;   AND TRY\_CAST(Quantity AS INT) > 0

&#x20;   GROUP BY CustomerID

)

SELECT TOP 20 \*

FROM RFM\_Base

ORDER BY Monetary DESC;









###### &#x20;Query 2: Customer Segmentation

&#x20;Using the RFM scores, I grouped customers into foursegments. This helps businesses decide where to focus their marketing and retention efforts. The foursegments are:

VIP - recently active, frequent, high spenders

Loyal - regularly purchasing customers

At Risk - used to buy often but have gone quiet

Lost - have not purchased in a long time



WITH RFM\_Base AS (

&#x20;   SELECT 

&#x20;       CustomerID,

&#x20;       DATEDIFF(day, MAX(CAST(InvoiceDate AS DATETIME)), 

&#x20;           '2011-12-09') AS Recency,

&#x20;       COUNT(DISTINCT InvoiceNo) AS Frequency,

&#x20;       ROUND(SUM(TRY\_CAST(Quantity AS INT) \* 

&#x20;           TRY\_CAST(UnitPrice AS DECIMAL(10,2))), 2) AS Monetary

&#x20;   FROM ecommerce\_data

&#x20;   WHERE CustomerID IS NOT NULL

&#x20;   AND ISDATE(InvoiceDate) = 1

&#x20;   AND TRY\_CAST(Quantity AS INT) > 0

&#x20;   GROUP BY CustomerID

),

RFM\_Scores AS (

&#x20;   SELECT \*,

&#x20;       NTILE(4) OVER (ORDER BY Recency DESC) AS R\_Score,

&#x20;       NTILE(4) OVER (ORDER BY Frequency ASC) AS F\_Score,

&#x20;       NTILE(4) OVER (ORDER BY Monetary ASC) AS M\_Score

&#x20;   FROM RFM\_Base

)

SELECT 

&#x20;   Customer\_Segment,

&#x20;   COUNT(\*) AS Total\_Customers

FROM (

&#x20;   SELECT \*,

&#x20;       CASE 

&#x20;           WHEN R\_Score = 4 AND F\_Score = 4 AND M\_Score = 4 

&#x20;               THEN 'VIP Customer'

&#x20;           WHEN R\_Score >= 3 AND F\_Score >= 3 

&#x20;               THEN 'Loyal Customer'

&#x20;           WHEN R\_Score <= 2 AND F\_Score >= 3 

&#x20;               THEN 'At Risk Customer'

&#x20;           ELSE 'Lost Customer'

&#x20;       END AS Customer\_Segment

&#x20;   FROM RFM\_Scores

) AS Segments

GROUP BY Customer\_Segment

ORDER BY Total\_Customers DESC;







###### &#x20;Query 3: Cohort Analysis

Here, I wanted to understand when customers first started buying. This helps identify which months brought  most new customers and whether acquisition improved or declined over time.



WITH FirstPurchase AS (

&#x20;   SELECT 

&#x20;       CustomerID,

&#x20;       MIN(CAST(InvoiceDate AS DATETIME)) AS First\_Purchase\_Date,

&#x20;       FORMAT(MIN(CAST(InvoiceDate AS DATETIME)), 'yyyy-MM') 

&#x20;           AS Cohort\_Month

&#x20;   FROM ecommerce\_data

&#x20;   WHERE CustomerID IS NOT NULL

&#x20;   AND ISDATE(InvoiceDate) = 1

&#x20;   GROUP BY CustomerID

)

SELECT 

&#x20;   Cohort\_Month,

&#x20;   COUNT(DISTINCT CustomerID) AS New\_Customers

FROM FirstPurchase

GROUP BY Cohort\_Month

ORDER BY Cohort\_Month;







###### &#x20;Query 4: Churn Analysis

&#x20;Here I identified customers based on how long it has been since their last purchase. Customers inactivefor more than 90 days are flagged as churned. This gives the business a clear picture of how many customers they are losing and how urgently they need to act on retention.



WITH LastPurchase AS (

&#x20;   SELECT 

&#x20;       CustomerID,

&#x20;       MAX(CAST(InvoiceDate AS DATETIME)) AS Last\_Purchase\_Date,

&#x20;       DATEDIFF(day, MAX(CAST(InvoiceDate AS DATETIME)), 

&#x20;           '2011-12-09') AS Days\_Since\_Last\_Purchase

&#x20;   FROM ecommerce\_data

&#x20;   WHERE CustomerID IS NOT NULL

&#x20;   AND ISDATE(InvoiceDate) = 1

&#x20;   GROUP BY CustomerID

)

SELECT 

&#x20;   CASE 

&#x20;       WHEN Days\_Since\_Last\_Purchase <= 30 THEN 'Active'

&#x20;       WHEN Days\_Since\_Last\_Purchase <= 60 THEN 'Warm'

&#x20;       WHEN Days\_Since\_Last\_Purchase <= 90 THEN 'Cold'

&#x20;       ELSE 'Churned'

&#x20;   END AS Customer\_Status,

&#x20;   COUNT(\*) AS Total\_Customers,

&#x20;   ROUND(COUNT(\*) \* 100.0 / SUM(COUNT(\*)) OVER(), 2) 

&#x20;       AS Percentage

FROM LastPurchase

GROUP BY 

&#x20;   CASE 

&#x20;       WHEN Days\_Since\_Last\_Purchase <= 30 THEN 'Active'

&#x20;       WHEN Days\_Since\_Last\_Purchase <= 60 THEN 'Warm'

&#x20;       WHEN Days\_Since\_Last\_Purchase <= 90 THEN 'Cold'

&#x20;       ELSE 'Churned'

&#x20;   END

ORDER BY Total\_Customers DESC;

