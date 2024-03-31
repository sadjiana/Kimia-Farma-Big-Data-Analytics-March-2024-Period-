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

--CREATE AGGREGATE TABLE 1: KIMIA FARMA COMPANY REVENUE YEAR-ON-YEAR--
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

--CREATE AGGREGATE TABLE 3: TOP 10 PROVINCE BRANCH NET SALES--
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

--CREATE AGGREGATE TABLE 5: TOP 10 CITY NET SALES--
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

--CREATE AGGREGATE TABLE 7: Top 5 BRANCHES WITH THE HIGHEST RATING, BUT THE LOWEST TRANSACTION RATING--
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
