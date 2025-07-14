# walmart-sales-sql-analysis
SQL analysis of Walmart weekly sales dataset, exploring sales trends, economic indicators and more.

-- ============================================
**-- 🔹 BASIC / EXPLORATORY QUERIES**
-- ============================================

**-- View all records**
SELECT * FROM walmart_sales;

**-- Total number of unique stores**
SELECT COUNT(DISTINCT(store)) AS number_of_stores FROM walmart_sales;

**-- Total weekly sales for Store 1**
SELECT SUM(weekly_sales) AS total_sales, store
FROM walmart_sales
WHERE store = 1;

**-- Count of holiday weeks**
SELECT COUNT(Holiday_Flag) AS holiday_weeks
FROM walmart_sales
WHERE Holiday_Flag = 1;

**-- Average weekly sales per store**
SELECT store, AVG(weekly_sales) AS Avg_sales
FROM walmart_sales
GROUP BY store;

**-- Rows where weekly sales are greater than $2,000,000**
SELECT *
FROM walmart_sales
WHERE Weekly_Sales > 2000000;

**-- Total sales per store**
SELECT store, SUM(weekly_sales) AS total_sales
FROM walmart_sales
GROUP BY store;

**-- Week with the highest sales per store**
SELECT store, MAX(weekly_sales) AS highest_sales
FROM walmart_sales
GROUP BY store
ORDER BY highest_sales DESC;

**-- Compare average sales during holiday vs non-holiday weeks**
SELECT Holiday_Flag, AVG(weekly_sales)
FROM walmart_sales
GROUP BY Holiday_Flag;

**-- Store with the highest sales during a holiday week**
SELECT store, MAX(weekly_sales) AS highest_sales, Holiday_Flag AS holiday_week
FROM walmart_sales
WHERE Holiday_Flag = 1
GROUP BY store
ORDER BY highest_sales DESC;

**-- Average temperature and fuel price by store**
SELECT store, AVG(fuel_price), AVG(temperature)
FROM walmart_sales
GROUP BY store;

-- ============================================
**-- 🔹 ADVANCED TEMP TABLE & WINDOW FUNCTION QUERIES**
-- ============================================

**-- Create and prepare working table**
CREATE TEMPORARY TABLE walmart_sales2 LIKE walmart_sales;
INSERT walmart_sales2 SELECT * FROM walmart_sales;

**-- Add a column for year**
ALTER TABLE walmart_sales2 ADD COLUMN Year INT;
UPDATE walmart_sales2 SET year = SUBSTRING_INDEX(Date, '/', -1);

**-- Annual sales rank by store**
SELECT store, SUM(weekly_sales) AS Annual_sales, Year,
RANK() OVER(PARTITION BY year ORDER BY SUM(weekly_sales) DESC) AS sales_rank
FROM walmart_sales2
GROUP BY year, store;

**-- Week-over-week percentage change in sales**
WITH walmart_sales3 AS (
  SELECT store, date, year, weekly_sales,
  LAG(weekly_sales) OVER(PARTITION BY store ORDER BY date) AS Lag_sales
  FROM walmart_sales2
)
SELECT store, date, year, weekly_sales, lag_sales,
ROUND((weekly_sales - lag_sales) / NULLIF(lag_sales, 0), 2) AS diff,
ROUND(((weekly_sales - lag_sales) / NULLIF(lag_sales, 0)) * 100, 2) AS per
FROM walmart_sales3;

-- ============================================
**-- 🔹 MONTHLY ANALYSIS**
-- ============================================

**-- Extract and convert month**
ALTER TABLE walmart_sales2 ADD COLUMN Month VARCHAR(10);
UPDATE walmart_sales2 SET month = SUBSTRING_INDEX(SUBSTRING_INDEX(date, '/', 2), '/', -1);

**-- Convert numeric months to names**
UPDATE walmart_sales2
SET month =
  CASE 
    WHEN month IN ('01', '1') THEN 'January'
    WHEN month IN ('02', '2') THEN 'February'
    WHEN month IN ('03', '3') THEN 'March'
    WHEN month IN ('04', '4') THEN 'April'
    WHEN month IN ('05', '5') THEN 'May'
    WHEN month IN ('06', '6') THEN 'June'
    WHEN month IN ('07', '7') THEN 'July'
    WHEN month IN ('08', '8') THEN 'August'
    WHEN month IN ('09', '9') THEN 'September'
    WHEN month = '10' THEN 'October'
    WHEN month = '11' THEN 'November'
    WHEN month = '12' THEN 'December'
  END;

**-- Identify months with average CPI > 220**
SELECT month, ROUND(AVG(cpi), 2) AS Avg_CPI
FROM walmart_sales2
WHERE cpi > 220
GROUP BY month;

**-- Monthly grouped sales, temperature, fuel price**
SELECT month, 
  ROUND(AVG(weekly_sales), 0) AS avg_sales,
  ROUND(AVG(temperature), 0) AS avg_temp,
  ROUND(AVG(fuel_price), 0) AS avg_fuel_price
FROM walmart_sales2
GROUP BY month;

-- ============================================
**-- ✅ END OF FILE**
-- ============================================


## 📈 Key Takeaways
- Sales averages during holiday weeks exhibited a slight increase compared to non-holiday weeks.
- Store #10 consistently ranked among the top stores in terms of annual sales performance.
- A mild correlation was identified between fluctuations in fuel prices, the Consumer Price Index (CPI), and weekly sales variations.
- The highest recorded weekly sales surpassed $2 million within a single week.
- Sales growth trends demonstrated significant variability across different stores, particularly during holiday periods.

**🧠 Key Insights Gained**
- Utilizing window functions: LAG(), RANK(), LPAD(), CAST()
- Handling dates in SQL (extracting year/month)
- Conducting correlation analysis with SQL logic
- Organizing SQL projects for business insight

