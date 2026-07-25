/*
  SQL Script: 01_cohort_retention_query.sql
  Purpose: Calculates customer retention rates using Cohort Analysis.
  Output: Cohort_Month, Month_Index, Active_Users
*/

-- Step 1: Define the Cohort (First Purchase Date) for every customer
WITH Customer_Cohort AS (
    SELECT
        "Customer ID",
        MIN(date(InvoiceDate)) as First_Purchase_Date
    FROM transactions
    GROUP BY "Customer ID"
),

-- Step 2: Calculate the difference in months between each transaction and the Cohort Date
Calculated_Months AS (
    SELECT
        t."Customer ID",
        -- Extract the Year-Month of the Cohort Start
        strftime('%Y-%m', c.First_Purchase_Date) as Cohort_Month,
        -- Calculate the difference in months (This is the critical analysis step)
        (strftime('%Y', t.InvoiceDate) - strftime('%Y', c.First_Purchase_Date)) * 12 +
        (strftime('%m', t.InvoiceDate) - strftime('%m', c.First_Purchase_Date)) as Month_Index
    FROM transactions t
    JOIN Customer_Cohort c ON t."Customer ID" = c."Customer ID"
)

-- Step 3: Final Aggregation: Count unique active customers per Cohort and Month Index
SELECT
    Cohort_Month,
    Month_Index,
    COUNT(DISTINCT "Customer ID") as Active_Users
FROM Calculated_Months
GROUP BY Cohort_Month, Month_Index
ORDER BY Cohort_Month, Month_Index;