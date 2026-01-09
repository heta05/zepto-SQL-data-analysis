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
);
select * from zepto_stage

INSERT INTO zepto
(category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity)
SELECT 
category,name,mrp,discountPercent,availableQuantity,discountedSellingPrice,weightInGms,outOfStock,quantity
FROM zepto_stage;

DROP TABLE zepto_stage;


---- DATA EXPLORATION ------


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

--- DATA CLEANING ---

-- 1. Products with Zero Price --

Select * From zepto
where mrp = 0 or discountedSellingPrice = 0;

Delete From zepto
where mrp = 0;

-- 2. Convert Paisa into Rupee --

UPDATE Zepto
SET mrp = mrp/100.0, discountedSellingPrice = discountedSellingPrice/100.0;

Select * from zepto

--- DATA ANALYSIS - BUSINESS PROBLEMS ---

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












