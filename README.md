
# 🛒 Zepto E-commerce SQL Data Analyst Portfolio Project
This is a complete, real-world data analyst portfolio project based on an e-commerce inventory dataset scraped from [Zepto](https://www.zeptonow.com/) — one of India’s fastest-growing quick-commerce startups. This project simulates real analyst workflows, from raw data exploration to business-focused data analysis.

## 📌 Project Overview

The goal is to simulate how actual data analysts in the e-commerce or retail industries work behind the scenes to use SQL to:

✅ Set up a messy, real-world e-commerce inventory **database**

✅ Perform **Exploratory Data Analysis (EDA)** to explore product categories, availability, and pricing inconsistencies

✅ Implement **Data Cleaning** to handle null values, remove invalid entries, and convert pricing from paise to rupees

✅ Write **business-driven SQL queries** to derive insights around **pricing, inventory, stock availability, revenue** and more

## 📁 Dataset Overview
The dataset was sourced from [Kaggle](https://www.kaggle.com/datasets/palvinder2006/zepto-inventory-dataset/data?select=zepto_v2.csv) and was originally scraped from Zepto’s official product listings. It mimics what you’d typically encounter in a real-world e-commerce inventory system.

Each row represents a unique SKU (Stock Keeping Unit) for a product. Duplicate product names exist because the same product may appear multiple times in different package sizes, weights, discounts, or categories to improve visibility – exactly how real catalog data looks.

🧾 Columns:
- **sku_id:** Unique identifier for each product entry (Synthetic Primary Key)

- **name:** Product name as it appears on the app

- **category:** Product category like Fruits, Snacks, Beverages, etc.

- **mrp:** Maximum Retail Price (originally in paise, converted to ₹)

- **discountPercent:** Discount applied on MRP

- **discountedSellingPrice:** Final price after discount (also converted to ₹)

- **availableQuantity:** Units available in inventory

- **weightInGms:** Product weight in grams

- **outOfStock:** Boolean flag indicating stock availability

- **quantity:** Number of units per package (mixed with grams for loose produce)

## 🔧 Project Workflow

Here’s a step-by-step breakdown of what we do in this project:

### 1. Database & Table Creation
We start by creating a SQL table with appropriate data types:

```sql
CREATE TABLE zepto (
    sku_id INT IDENTITY(1,1) PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(8,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(8,2),
    weightInGms INT,
    outOfStock BIT,
    quantity INT
)
```
### 2. Data Import

The primary challenge was that the source CSV file did not contain a primary key (sku_id), which is mandatory for maintaining unique product identification. This was solved by implementing an auto-incrementing identity column in SQL Server.

Table Design:
- Created a normalized product table (zepto) with proper data types for pricing, discounts, stock, and weight.
- Implemented sku_id as an IDENTITY(1,1) primary key to auto-generate unique product IDs.
- Used optimized numeric data types (DECIMAL) for accurate price and discount calculations.
- Implemented BIT datatype for stock availability for storage efficiency.

CSV Data Import Strategy
- Used SQL Server’s Import Flat File Wizard to bulk load raw CSV data into a staging table (zepto_stage).
- Excluded sku_id from the CSV file and allowed SQL Server to auto-generate it during final insertion.
- Applied data transformation logic to clean stock availability and numeric fields.
- Inserted validated data from the staging table into the main table while automatically generating unique SKU IDs.

Then Moving Data Into Main Table  
```SQL
INSERT INTO zepto
(category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity)
SELECT 
category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity
FROM zepto_stage;
```
Cleanup Staging Table
```SQL
DROP TABLE zepto_stage;
```

### 3. 🔍 Data Exploration
```SQL
-- 1. Count Rows ----

Select Count(*) from zepto as total_rows

-- 2. Sample Data ---

Select  Top 10 * From zepto

-- 3. Null Values ---

Select * from zepto
where name is Null 
OR
category is Null 
OR
mrp is Null 
OR
discountPercent is Null 
OR
availableQuantity is Null 
OR
discountedSellingPrice is Null 
OR
weightInGms is Null 
OR
outOfStock is Null 
OR
quantity is Null;

-- 4. Different Product Category --

Select Distinct category
From zepto
order by category;

-- 5. Productas in stock VS out of stock --

Select outOfStock , count(sku_id) as count_of_product
from zepto
group by outOfStock;

-- 6. Product Names Present Multiple Times --

Select name , count(sku_id) as Num_of_SKU
from zepto
group by name
having count(sku_id) >1
order by count(sku_id) DESC;
```

### 4. 🧹 Data Cleaning
```SQL
-- 1. Products with Zero Price --

Select * From zepto
where mrp = 0 or discountedSellingPrice = 0;

Delete From zepto
where mrp = 0;

-- 2. Convert Paisa into Rupee --

UPDATE Zepto
SET mrp = mrp/100.0, discountedSellingPrice = discountedSellingPrice/100.0;

Select * from zepto
```
### 5. 📊 Data Analysis - Business Insights
```SQL
-- Q1. Find the top 10 best-value products based on the discount percentage.

Select Top 10 name, discountPercent
from zepto 
order by discountPercent DESC

--Q2.What are the Products with MRP which above 300 but Out of Stock

Select name,mrp, outOfStock 
from zepto
where outOfStock = 1 AND mrp >300
order by mrp desc

--Q3.Calculate Estimated Revenue for each category

Select category, SUM(discountedSellingPrice*quantity) AS Total_Revenue
from zepto
group by category
order by Total_Revenue DESC;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.

Select name,mrp,discountPercent
from zepto
Where mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.

Select TOP 5 category, ROUND(AVG(discountPercent),2) As Avg_disc
From zepto
group by category
order by Avg_disc DESC;

-- Q6. Find the price per gram for products above 100g and sort by best value.

Select DISTINCT name,weightInGms,discountedSellingPrice,(discountedSellingPrice/weightInGms) AS Price_Per_Gram
From zepto
where weightInGms > 100
order by Price_Per_Gram DESC;

--Q7.Group the products into categories like Low, Medium, Bulk.

SELECT DISTINCT name,weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
     WHEN weightInGms < 5000 THEN 'Medium'
     ELSE 'Bulk'
     END as Weight_Category
FRom zepto

--Q8.What is the Total Inventory Weight Per Category 

Select category, SUM(weightInGms*availableQuantity) as total_inventory_weight
From zepto
group by category
order by total_inventory_weight;
```

## Key Findings:

1. Over 95% of products have valid pricing, but a small portion contained zero-MRP errors which were cleaned.

2. Multiple SKUs were found for the same product names, indicating variant-based inventory management.

3. Grocery and household categories contributed the highest estimated revenue share.

4. Several high-value products (₹300+ MRP) were found out of stock, indicating possible lost sales opportunities.

5. Bulk products (5kg+) showed better price-per-gram value compared to smaller packs.

6. Only a few categories provided consistently high average discounts, which can be targeted for promotions.

## Project Summary:

1. Designed an automated SKU generation system using SQL Server identity columns.

2. Built a complete ETL pipeline for CSV bulk loading and data cleaning.

3. Standardized pricing from paisa to rupees and removed invalid records.

4. Performed business-driven SQL analysis on pricing, stock, discounts, and revenue.

5. Delivered actionable insights for pricing strategy, inventory planning, and promotional targeting.

## Conclusion:

This project demonstrates a complete SQL Server–based ETL and analytics workflow for e-commerce product data, including automated SKU generation, data cleaning, and business-focused analysis. The insights support smarter inventory planning, pricing strategy, and revenue optimization through data-driven decision making.

## Author - Hetanshi Gandhi

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

Thank you for your support, and I look forward to connecting with you!
