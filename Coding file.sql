-- Specifying database and schema to be used
USE CATALOG brightlearn;
USE SCHEMA data;

--previewing dataset
SELECT*
FROM bright_coffee_shop_sales;

--describe the data type and checking for nulls
DESCRIBE TABLE bright_coffee_shop_sales;

--finding unique store location

SELECT DISTINCT store_location
FROM bright_coffee_shop_sales;

-- counting the number of rows in a table and checking for dublicates in transaction_IDS
SELECT COUNT (transaction_id) AS trans_ID_count,
       COUNT (DISTINCT transaction_id) AS dist_trans_ID_count
FROM bright_coffee_shop_sales;

--finding the row containng nulls
SELECT *
FROM bright_coffee_shop_sales
WHERE transaction_id IS NULL
    OR transaction_date IS NULL
    OR transaction_time IS NULL
    OR transaction_qty IS NULL
    OR unit_price IS NULL
    OR store_id IS NULL
    OR store_location IS NULL
    OR product_id IS NULL
    OR product_category IS NULL
    OR product_type IS NULL
    OR product_detail IS NULL;
--replacing nulls with zero

SELECT*
FROM bright_coffee_shop_sales;

--data range of dataset
SELECT MIN(transaction_date) AS earliest_date,
       MAX(transaction_date) AS latest_date
FROM bright_coffee_shop_sales;

--removing timestamp
SELECT transaction_time,
       DATE_FORMAT(transaction_time,'HH:mm:ss') AS clean_time
FROM bright_coffee_shop_sales;

--product levels
SELECT DISTINCT product_category
FROM bright_coffee_shop_sales;

SELECT DISTINCT product_type
FROM bright_coffee_shop_sales;

SELECT DISTINCT product_detail
FROM bright_coffee_shop_sales;

--finding the total nunber of transctions
SELECT COUNT(DISTINCT transaction_id) AS total_transactions
FROM bright_coffee_shop_sales;

--transaction per day
SELECT transaction_date,
       COUNT ( DISTINCT transaction_id) AS total_transactions
FROM bright_coffee_shop_sales
GROUP BY transaction_date;

--transaction per month
SELECT MONTHNAME(transaction_date) AS month,
      COUNT(DISTINCT transaction_id) AS total_transactions
FROM bright_coffee_shop_sales
GROUP BY month;

--revenue per month
SELECT MONTHNAME(transaction_date) AS month,
      COUNT(DISTINCT transaction_id) AS total_transactions
FROM bright_coffee_shop_sales
GROUP BY month;

SELECT unit_price,
       transaction_qty, 
CAST(transaction_qty AS DOUBLE) * CAST(REPLACE(unit_price,',','.') AS DOUBLE) AS revenue
FROM bright_coffee_shop_sales;


SELECT MONTHNAME(transaction_date) AS month,
     ROUND(SUM (CAST(transaction_qty AS DOUBLE) * CAST(REPLACE(unit_price,',','.') AS DOUBLE)),2) AS revenue
FROM bright_coffee_shop_sales
GROUP BY month;

--case statements buckets
SELECT transaction_time,
       DATE_FORMAT(transaction_time,'HH:mm:ss') AS clean_time,
       CASE
       WHEN HOUR(transaction_time) BETWEEN 6 AND 10 THEN 'morning'
       WHEN HOUR(transaction_time) BETWEEN 10 AND 13 THEN 'afternoon'
       ELSE'evening'
      END AS time_bucket
FROM bright_coffee_shop_sales;

SELECT DAYNAME(transaction_date),
       DAYOFWEEK(transaction_date),
       CASE
          WHEN DAYNAME(transaction_date) IN('Sat','Sun') THEN'weekend'
          ELSE 'weekday'
      END AS day_type
FROM bright_coffee_shop_sales;

SELECT MAX(unit_price) AS maximum_price
FROM bright_coffee_shop_sales;


-------------------------------------------------------------------------------------------
--final big query with all new columns
SELECT*
FROM bright_coffee_shop_sales;


SELECT transaction_id,
       transaction_date,      
       DATE_FORMAT(transaction_time,'HH:mm:ss')AS clean_time,--clean time removes timestamp
       transaction_qty,
       store_id,
       store_location,
       product_id,
       unit_price,
       product_category,
       product_type,
       product_detail,
       DAYNAME(transaction_date) AS day_name,--day name(monday,tuesday--)
       MONTHNAME(transaction_date) AS month_name,--month name (January,February..)
       DAYOFMONTH(transaction_date) AS day_number, --day of month(1-31)

              CASE
          WHEN DAYNAME(transaction_date) IN('Sat','Sun') THEN'weekend'
          ELSE 'weekday'
      END AS day_type,  --weekend vs weekday
     
               CASE
       WHEN HOUR(transaction_time) BETWEEN 6 AND 10 THEN 'morning'
       WHEN HOUR(transaction_time) BETWEEN 10 AND 13 THEN 'afternoon'
       WHEN HOUR(transaction_time) BETWEEN 13 AND 10 THEN 'late_afternoon'
       ELSE'evening'
      END AS time_bucket,   --time bucket

                CASE
                  WHEN DAYOFMONTH(transaction_date) BETWEEN 1 AND 10 THEN 'early month'
                  WHEN DAYOFMONTH(transaction_date) BETWEEN 11 AND 20 THEN 'mid month'
                ELSE 'month_end'
            END AS month_period, --month_period bucket

            CASE
               WHEN(CAST(transaction_qty AS DOUBLE)* CAST(REPLACE(unit_price,',','.')AS DOUBLE))<=50 THEN 'Cheap spend'
               WHEN(CAST(transaction_qty AS DOUBLE)* CAST(REPLACE(unit_price,',','.')AS DOUBLE))BETWEEN 51 AND 200 THEN 'Low spend'
               WHEN(CAST(transaction_qty AS DOUBLE)* CAST(REPLACE(unit_price,',','.')AS DOUBLE))BETWEEN 201 AND 300 THEN 'Medium spend'
               
            ELSE 'Expensive spend'
            END AS spend_bucket,

     CAST(REPLACE(unit_price,',','.')AS DOUBLE )AS clean_unit_price, ---clean numeric price
     ROUND((CAST(transaction_qty AS DOUBLE) * CAST(REPLACE(unit_price,',','.')AS DOUBLE)),2) AS revenue  ---revenue per row     
FROM bright_coffee_shop_sales;
