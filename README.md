# Performance Analytics Kimia Farma Business Year (2020-2023)

Tools:
1. Google Cloud Platform - BigQuery

Google Cloud Platform, is a collection of cloud computing services offered by Google. GCP runs on the same infrastructure used by Google for its internal products, such as Google Search, YouTube and Gmail. BigQuery is a fully managed enterprise data warehouse that helps manage and analyze data with built-in features such as machine learning, geospatial analysis, and business intelligence.

2. Google - Looker Studio Overview

Looker Studio is a tool used to transform data into dashboards and reports that are informative, easy to read, easy to share, and fully customizable according to available data sources.

## Project Background - Kimia Farma Big Data Analytics Project Based Internship Program 2024
The Project Based Internship Program in collaboration with Rakamin Academy and Kimia Farma Big Data Analytics is a self-development and career acceleration program intended to deepen the position of Big Data Analytics and introduce the skills that Big Data Analytics must have in companies. As a Big Data Analytics Intern at Kimia Farma, my task is to create a Performance Analytics Dashboard for Kimia Farma Business Year 2020-2023.

## 1. Preparation Before Data Processing
There are several steps I took before starting data processing. The first step I have to do is prepare the raw data into structured data so that the data is ready to be processed. The steps taken when preparing the data are:
### A. Download the data set provided by Kimia Farma, the data is as follows:
   - kf_final_transaction.csv
   - kf_inventory.csv
   - kf_kantor_cabang.csv
   - kf_product.csv
### B. Create a new project in Google Cloud Platform - BigQuery with the existing name conditions
### C. Import a dataset from data provided by Kimia Farma, create a new name for the table uploaded to Google Cloud Platform - BigQuery, and provide auto-detect on the schema to create a new schema display according to the data that was previously imported into the dataset

## 2. Data Processing to Create Data Mart Design
There are stages used before designing the Kimia Farma Business Year 2020-2023 Performance Analytics Dashboard. I will create queries and tables on Google Cloud Platform - BigQuery as a basis for designing dashboard.
<details><summary>QUERIES</summary>

```sql
--ANALYZE AND DESIGN QUERIES TO CREATE DATA MART--
CREATE TABLE Kimia_Farma.Transaction_Analysis AS
SELECT 
    ft.transaction_id,
    ft.date,
    kc.branch_id,
    kc.branch_name,
    kc.kota,
    kc.provinsi,
    kc.rating AS rating_cabang,
    ft.customer_name,
    p.product_id,
    p.product_name,
    ft.price AS actual_price,
    ft.discount_percentage,
    CASE
        WHEN ft.price <= 50000 THEN 0.10
        WHEN ft.price > 50000 - 100000 THEN 0.15
        WHEN ft.price > 100000 - 300000 THEN 0.20
        WHEN ft.price > 300000 - 500000 THEN 0.25
        WHEN ft.price > 50000 THEN 0.30
        ELSE 0.30
    END AS persentase_gross_laba,
    ft.price * (1 - ft.discount_percentage) AS nett_sales,
    (ft.price * (1 - ft.discount_percentage) *
        CASE
            WHEN ft.price <= 50000 THEN 0.10
            WHEN ft.price > 50000 - 100000 THEN 0.15
            WHEN ft.price > 100000 - 300000 THEN 0.20
            WHEN ft.price > 300000 - 500000 THEN 0.25
            WHEN ft.price > 50000 THEN 0.30
            ELSE 0.30
      END) AS nett_profit,
    ft.rating AS rating_transaksi
FROM
    Kimia_Farma.kf_final_transaction AS ft
LEFT JOIN
    Kimia_Farma.kf_kantor_cabang AS kc ON ft.branch_id = kc.branch_id
LEFT JOIN
    Kimia_Farma.kf_product AS p ON ft.product_id = p.product_id
;

--CREATE AGGREGATE TABLE 1: KIMIA FARMA COMPANY INCOME YEAR-ON-YEAR--
CREATE TABLE Kimia_Farma.Pendapatan_Pertahun AS
SELECT
    EXTRACT(YEAR FROM date) AS tahun,
    SUM(nett_sales) AS pendapatan,
    AVG(nett_sales) AS avg_pendapatan
FROM
    `Kimia_Farma.Transaction_Analysis` 
GROUP BY
    tahun
ORDER BY
    tahun
;

--CREATE AGGREGATE TABLE 2: TOP 10 TOTAL PROVINCE BRANCH TRANSACTIONS--
CREATE TABLE Kimia_Farma.Top10_Total_Transaksi_Cabang_Provinsi AS 
SELECT 
    provinsi,
    COUNT(*) AS total_transaksi,
    SUM(nett_sales) AS total_pendapatan

FROM 
    `Kimia_Farma.Transaction_Analysis` 
GROUP BY 
    provinsi
ORDER BY 
    total_transaksi DESC
LIMIT 10
;

--CREATE AGGREGATE TABLE 3: TOP 10 PROVINCE BRANCH NETT SALES--
CREATE TABLE Kimia_Farma.Top10_Penjualan_Bersih_Cabang_Provinsi AS 
SELECT 
    provinsi, 
    SUM(nett_sales) AS nett_sales_cabang,
    COUNT(product_name) AS total_produk_terjual
FROM 
    `Kimia_Farma.Transaction_Analysis` 
GROUP BY 
    provinsi
ORDER BY 
    nett_sales_cabang DESC
LIMIT 10
;

--CREATE AGGREGATE TABLE 4: TOTAL PROFIT FOR EACH PROVINCE--
CREATE TABLE Kimia_Farma.Total_Profit_Masing2_Provinsi AS
SELECT
    provinsi,
    SUM(nett_profit) AS total_profit,
    COUNT(product_id) AS total_produk_terjual
FROM
    `Kimia_Farma.Transaction_Analysis`
GROUP BY
    provinsi
ORDER BY
    total_profit DESC
;

--CREATE AGGREGATE TABLE 5: TOP 10 CITY NETT SALES--
CREATE TABLE Kimia_Farma.Top10_Penjualan_Bersih_Kota AS 
SELECT 
    kota, 
    SUM(nett_sales) AS nett_sales_kota,
    COUNT(product_id) AS total_produk_terjual
FROM 
    `Kimia_Farma.Transaction_Analysis` 
GROUP BY 
    kota
ORDER BY 
    nett_sales_kota DESC
LIMIT 10
;

--CREATE AGGREGATE TABLE 6: TOP 10 TOTAL CITY TRANSACTIONS--
CREATE TABLE Kimia_Farma.Top10_Total_Transaksi_Kota AS 
SELECT 
    kota,
    COUNT(*) AS total_transaksi,
    SUM(nett_sales) AS total_pendapatan

FROM 
    `Kimia_Farma.Transaction_Analysis` 
GROUP BY 
    kota
ORDER BY 
    total_transaksi DESC
LIMIT 10
;

--CREATE AGGREGATE TABLE 7: TOP 5 BRANCHES WITH THE HIGHEST RATING, BUT THE LOWEST TRANSACTION RATING--
CREATE TABLE `Kimia_Farma.Top5_Cabang_Dengan_Rating_Tertinggi_Namun_Rating_Transaksi_Terendah` AS 
SELECT
    branch_name,
    kota,
    kc.rating AS rating_cabang,
    AVG(ft.rating) AS avg_rating_transaksi
FROM
    `Kimia_Farma.kf_final_transaction` AS ft
LEFT JOIN
    `Kimia_Farma.kf_kantor_cabang` AS kc
ON
    ft.branch_id = kc.branch_id
GROUP BY
    branch_name, kota, kc.rating
ORDER BY
    kc.rating DESC, AVG(ft.rating) ASC
LIMIT 5
;
```
</details>

<p align="center">
  <img src="/IMAGES/DESIGN QUERIES TO CREATE DATA MART.png">
  <br>1. DESIGN QUERIES TO CREATE DATA MART</br>
  
  <img src="/IMAGES/AGGREGATE TABLE 1 - KIMIA FARMA COMPANY INCOME (YoY).png">
  <br>2. KIMIA FARMA COMPANY INCOME (YoY)</br>

  <img src="IMAGES/AGGREGATE TABLE 2 - TOP 10 TOTAL PROVINCE BRANCH TRANSACTIONS.png">
  <br>3. TOP 10 TOTAL PROVINCE BRANCH TRANSACTIONS</br>

  <img src="IMAGES/AGGREGATE TABLE 3 - TOP 10 PROVINCE BRANCH NET SALES.png">
  <br>4. TOP 10 PROVINCE BRANCH NET SALES</br>

  <img src="IMAGES/AGGREGATE TABLE 4 - TOTAL PROFIT FOR EACH PROVINCE.png">
  <br>5. TOTAL PROFIT FOR EACH PROVINCE</br>

  <img src="IMAGES/AGGREGATE TABLE 5 - TOP 10 CITY NETT SALES.png">
  <br>6. TOP 10 CITY NETT SALES</br>
  
  <img src="IMAGES/AGGREGATE TABLE 6 - TOP 10 TOTAL CITY TRANSACTIONS.png">
  <br>7. TOP 10 TOTAL CITY TRANSACTIONS</br>

  <img src="IMAGES/AGGREGATE TABLE 7 - TOP 5 BRANCHES WITH THE HIGHEST RATING, BUT THE LOWEST TRANSACTION RATING.png">
  <br>8. TOP 5 BRANCHES WITH THE HIGHEST RATING, BUT THE LOWEST TRANSACTION RATING</br>
  
</p>

## 3. Dashboard Performance Analytics Kimia Farma Business Year (2020-2023)
After completing data processing by designing a Data Mart and analyzing tables from the dataset contained in Google Cloud Platform - BigQuery, the steps I took for the final step were, I created a Kimia Farma Business Year 2020-2023 Performance Analytics Dashboard in Google - Looker Studio Overview. My dashboard can be accessed at this link: https://lookerstudio.google.com/reporting/3559b561-7854-404f-9230-4df8a5cfa0a5

<p align="center">
  <img src="/IMAGES/DASHBOARD.png">
  <br>9. DASHBOARD PERFORMANCE ANALYTICS KIMIA FARMA BUSINESS YEAR (2020-2023)</br>
</p>
