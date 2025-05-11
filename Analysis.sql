select top 1 * from Custs360
select top 1 * from Order360
select top 1 * from Product360
select top 1 * from Store360

--SALES INFORMATION

select SUM(Total_Amount) from Finalised_Records_1
select sum(Total_Revenue) from Cust360
select sum(Net_Sales) from Order360
select sum(Total_Revenue) from Product360
select sum(Net_Sales) from Store360

select SUM(Discount) from Finalised_Records_1
select sum(Total_Discount) from Cust360
select sum(Total_Discount) from Order360
select sum(Total_Discount) from Product360
select sum(Total_Discount) from Store360


select sum(Profit) from Cust360
select sum(Profit) from Order360
select sum(Profit) from Product360
select sum(Profit) from Store360

select SUM(Quantity) from Finalised_Records_1
select sum(Total_Quantity) from Cust360
select sum(Total_Quantity) from Order360
select sum(Total_Quantity_Sold) from Product360
select sum(Total_Quantity_Sold) from Store360

select sum(Cost_Per_Unit * Quantity) from Finalised_Records_1
select sum(Total_Cost) from Order360
select sum(Total_Cost) from Product360
select sum(Total_Cost) from Store360

--ORDERS INFORMATION

select COUNT(*) from Order360

select count(distinct Sales_Channel) from Order360

select count(Distinct Preferred_Payment_Method) from Custs360

select round(AVG(Profit),2) as avg_profit from Order360

select round(avg(Total_Quantity*1.0),3) as avg_auantity from Order360

select round(avg(Net_Sales),2) from Order360

SELECT  ROUND(AVG(Avg_rating * 1.0), 2) AS Avg_Rating FROM Order360


--CUSTOMER  INFORMATION

select COUNT(*) as Total_Cusrtomer from Custs360

select round(avg(Total_Revenue),2) from Custs360

select round(avg(Profit),2) as avg_profit from Custs360

select count(distinct Customer_State) from Custs360

select count(distinct Customer_City) from Custs360

select avg(Total_Discount * 1.0) from Custs360

select round(avg(Total_Quantity * 1.0),3) from Custs360


--STORE & PRODUCT INFORMATION

select COUNT(*) from Store360
select COUNT(*) from Product360

select round(Avg(Total_Quantity_Sold * 1.0),2) as avg_Quantity from Store360

select round(AVG(Categories_Sold * 1.0),2) as AVG_Categories_Sold from Store360

select round(Avg(Total_Quantity_Sold * 1.0),2) as avg_Quantity_per_product from Product360

select count(distinct State) from Store360

select count(distinct Region) from Store360



---1
select [Month],COUNT(*) as Total_Cust  from Custs360
group by [Month]
order by [Month]

--2
select Year, Month, sum(Total_Revenue) as Total_Revenue from Custs360
group by Year, Month
order by Year , Month

select Buy_Region, SUM(Total_Revenue) as Total_Revenue from Custs360
group by Buy_Region
order by Total_Revenue desc

select Sales_Channel, SUM(Total_Revenue) as Total_Revenue from Custs360
group by Sales_Channel
order by Total_Revenue desc

--2
select Customer_State, SUM(Total_Revenue) as Total_Revenue from Custs360
group by Customer_State
order by Total_Revenue desc

--3
select Sales_Channel,SUM(Total_Revenue) as Total_Revenue  from custs360
group by Sales_Channel

--4
select Preferred_Payment_Method ,SUM(Total_Revenue) as Total_Revenue from Custs360
group by Preferred_Payment_Method 

--5
select Gender ,COUNT(*) as Total_Cust  from Custs360
group by Gender

--6
select top 5 Customer_State ,COUNT(*) as Total_Cust  from Custs360
group by Customer_State
order by Total_Cust desc

--7
select top 5 Customer_State ,COUNT(*) as Total_Cust  from Custs360
group by Customer_State
order by Total_Cust asc

--8
select top 5 Category, SUM(Total_Revenue) as Total_Revenue from Products360
group by Category
order by Total_Revenue desc

--8
select top 5 Category, SUM(Total_Revenue) as Total_Revenue from Products360
group by Category
order by Total_Revenue asc

--9 
select top 5 product_id , SUM(Total_Revenue) as Total_Revenue from Products360
group by product_id
order by Total_Revenue desc

--10 
select top 5 product_id , SUM(Total_Revenue) as Total_Revenue from Products360
group by product_id
order by Total_Revenue asc

--11
select top 5 product_id, sum(Total_Orders) as Total_Orders from Products360
group by product_id
order by Total_Orders desc

--12
select top 5 product_id, sum(Profit) as Profit from Products360
group by product_id
order by Profit  desc

--14
select top 10  Store_ID, sum(Net_Sales) as Total_Revenue from Store360
group by Store_ID
order by Total_Revenue

----------------------------------

select Year, Month, count(*) as No_of_customer, count(*) * 100/ (select  count(*) from Custs360)
from Custs360
group by Year, Month
order by Year, Month

select Year, Month, count(*) as No_of_customer, sum(Total_Revenue) as Total_Revenue  
from Custs360
group by Year, Month
order by Year, Month




select Customer_State, count(*) as No_of_customer 
from Custs360
group by Customer_State
order by No_of_customer desc


select Gender, count(*) as No_of_customer 
from Custs360
group by Gender
order by No_of_customer desc


select Value_Segment, COUNT(*) as No_of_customer, sum(Total_Revenue) as Total_Revenue
from Custs360
group by Value_Segment
order by Total_Revenue desc



select Value_Segment, COUNT(*) * 100 / (select COUNT(*) from Custs360 as No_of_customer) , 
sum(Total_Revenue) * 100 / (select sum(Total_Revenue) from Custs360 as No_of_customer) as Total_Revenue
from Custs360
group by Value_Segment
order by Total_Revenue desc

select Customer_State, count(*) No_of_customer  from Custs360
where Total_Discount > 0
group by Customer_State
order by No_of_customer desc

select Buy_Region, count(*) No_of_customer  from Custs360
where Total_Discount > 0
group by Buy_Region
order by No_of_customer desc


select Customer_State, count(*) No_of_customer  from Custs360
where Total_Discount = 0
group by Customer_State
order by No_of_customer desc

select Buy_Region, count(*) No_of_customer  from Custs360
where Total_Discount = 0
group by Buy_Region
order by No_of_customer desc


select COUNT(*) from Custs360
where Total_Discount > 0
union
select COUNT(*) from Custs360
where Total_Discount = 0

select AVG(Total_Revenue) from Custs360
where Total_Discount > 0
union
select AVG(Total_Revenue) from Custs360
where Total_Discount = 0

select Customer_State, COUNT(*) as No_of_customer  
from Custs360
where No_of_Transactions = 1
group by Customer_State
order by No_of_customer desc

select Customer_State, sum(Total_Revenue) as Total_Revenue  
from Custs360
where No_of_Transactions != 1
group by Customer_State
order by Total_Revenue desc



select Year, Month, sum(Total_Revenue) as Total_Revenue  
from Custs360
where No_of_Transactions = 1
group by Year, Month
order by Year, Month


select Category, sum(Unique_Customers)  as No_of_customer 
from Product360
group by Category
order by No_of_customer  desc


select Sales_Channel, COUNT(*) as No_of_customer
from Custs360
group by Sales_Channel
Order by  No_of_customer desc




--__________________________________(Customer360)Analysis_____________________________________________
select * from Cust360
--High-Level Metrics (KPIs)

--Total Number of Customers
select count(Customer_id) as Total_Customers 
from Customer360

--Total value generated by Customers.
SELECT sum(Total_Amount) FROM Finalised_Records_1;
select sum(Total_Revenue) as Total_Revenue
from Cust360

select avg(Total_Revenue) as Avg_revenue
from Cust360

--Total Profit Generated by Customers: ?
select sum(Profit) as Total_Profit from Cust360

--Avg_profit
select avg(Profit) as Total_Profit from Cust360

--Total_Discount
select sum(Total_Discount) as Total_Discount from Cust360

--Toatl Quantity
select sum(Total_Quantity) as Total_Quantity from Cust360 
--AVERAGE Quantity
select avg(Total_Quantity) as avg_Quantity from Cust360 

 

----Total Number of Customers in terms of Gender wise
select Gender, count(*) as Total_Customer 
from Cust360
group by Gender



--Avg Discount
select avg(Total_Discount) as Avg_Discount from Cust360

--Avg Profit per Customer: 
select AVG(Profit) as avg_profit from Cust360

--Avg Revenue per Customer: 
select AVG(Total_Revenue) as avg_Revenue from Cust360

--Average rating (4)
select avg(Avg_rating) as Avg_ratting from Cust360


--State with the most customers
select Buy_Region, COUNT(*) as No_of_Cust from Cust360
group by Buy_Region
order by No_of_Cust desc



-- State wise Customers 
select Customer_state, count(*) as Total_Customers 
from Cust360
group by Customer_state
order by Total_Customers desc

--Top 10 highest-spending customers and with percentage
select * from Customers360

SELECT 
    Customer_id,
    Total_Revenue,
    ROUND((Total_Revenue * 100.0) / (SELECT SUM(Total_Revenue) FROM Customers360), 2) AS Spent_Percentage
FROM (
    SELECT TOP 10 *
    FROM Cust360
    ORDER BY Total_Revenue DESC
) AS TopCustomers

--Top 10 highest-spending customers and calculate what percentage of the overall customer spending they represent

SELECT 
    SUM(Total_Revenue) AS Total_Spent_10,
    ROUND((SUM(Total_Revenue) * 100.0) / (SELECT SUM(Total_Revenue) FROM Customer360), 2) AS Spent_Percentage
FROM (
    SELECT TOP 10 Total_Revenue
    FROM Customer360
    ORDER BY Total_Revenue DESC
) AS TopCustomers


--Total customer spend per state.
SELECT 
    Customer_state,
    SUM(Total_Revenue) AS Total_Spent,
    ROUND((SUM(Total_Revenue) * 100.0) / (SELECT SUM(Total_Revenue) FROM Customer360), 2) AS Spent_Percentage
FROM Customer360
GROUP BY Customer_state
ORDER BY Total_Spent DESC


--______________________________Order360(Analysis)______________________________________
select * from Order360
--Key Metrics

SELECT COUNT(DISTINCT order_id) AS Total_Orders FROM Order360

SELECT SUM(Net_Sales) AS Total_Sales FROM Order360

--Avg_Order_Value(AOV)
SELECT   ROUND(SUM(Net_Sales) * 1.0 / COUNT(order_id), 2) AS Avg_Order_Value FROM Order360

-- Total Quantity Sold:
SELECT   SUM(Total_Quantity) AS Total_Quantity_Sold FROM Order360

--Average Quantity per Order: 1.18 units
SELECT  ROUND(SUM(Total_Quantity) * 1.0 / COUNT(order_id), 2) AS Avg_Quantity_Per_Order FROM Order360

--Average Order Rating: 4.0 / 5

SELECT  ROUND(AVG(Avg_rating), 2) AS Avg_Rating FROM Order360

select Channels_Used, sum(Total_Amount) as Total_Amount from Order360
group by Channels_Used

--Revenue from Orders with Rating < 3: 
SELECT sum(Net_Sales) as Total_Amount 
FROM Order360
WHERE Avg_rating < 3;


--Total Orders & Customers
SELECT 
    COUNT(DISTINCT order_id) AS Total_Orders,
    COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM Order360;

--2. Total Gross Sales, Net Sales & Profit
SELECT 
    SUM(Gross_Sales) AS Total_Gross_Sales,
    SUM(Net_Sales) AS Total_Net_Sales,
    SUM(Profit) AS Total_Profit
FROM Order360;

--Average Profit Margin
SELECT 
    ROUND(AVG(Profit / NULLIF(Net_Sales, 0)) * 100, 2) AS Avg_Profit_Margin_Percent
FROM Order360;

--3. Top Sales Channel
SELECT top 1
    Sales_Channel,
    SUM(Net_Sales) AS Channel_Sales
FROM Order360
GROUP BY Sales_Channel
ORDER BY Channel_Sales DESC

select Region, AVG(Profit_Margin) *100 from Order360
group by Region

select Region, round(COUNT(*) * 100  / (select COUNT(*)  from Order360),2) from Order360
group by Region

--1.Monthly Sales Trend
SELECT 
    FORMAT(Order_Date, 'MM') AS Month,
    SUM(Net_Sales) AS Monthly_Sales
FROM Order360
GROUP BY FORMAT(Order_Date, 'MM')
ORDER BY Month


--2.Yaerly Sales Trend
SELECT 
    FORMAT(Order_Date, 'yyyy') AS Year,
    SUM(Net_Sales) AS Yearly_Sales
FROM Order360
GROUP BY FORMAT(Order_Date, 'yyyy')
ORDER BY Year


--3.Total Sales & Orders by Channel
SELECT 
    Sales_Channel, 
    COUNT(order_id) AS Total_Orders,
    SUM(Net_Sales) AS Total_Sales,
	round(SUM(Net_Sales) * 100 / (SELECT sum(Net_Sales) as Total_Amount FROM Order360),2) per_revenue,
	COUNT(order_id) * 100 / (SELECT COUNT(order_id) as Total_Amount FROM Order360) per_orders
FROM Order360
GROUP BY Sales_Channel
ORDER BY Total_Sales DESC


--4.Total Quantity Sold by Channel
SELECT 
    Sales_Channel,
    SUM(Total_Quantity) AS Total_Quantity_Sold
FROM Order360
GROUP BY Sales_Channel
ORDER BY Total_Quantity_Sold DESC


--5.Average Rating by Channel
SELECT 
    Sales_Channel,
    ROUND(AVG(Avg_rating), 2) AS Avg_Customer_Rating
FROM Order360
GROUP BY Sales_Channel
ORDER BY Avg_Customer_Rating DESC


--______________________________Store360(Analysis)______________________________________
--Store-Level Metrics
select * from Store360

--Total Stores (Total Active Stores: 37)
SELECT COUNT(DISTINCT Store_ID) AS Total_Stores FROM Store360

--Total Orders Across All Stores

SELECT SUM(Total_Orders) AS Total_Orders FROM Store360

--Avg Orders per Store: 2,647
SELECT 
  ROUND(SUM(Total_Orders) * 1.0 / COUNT(DISTINCT Store_ID), 2) AS Avg_Orders_Per_Store 
FROM Store360;

--Top Performing Store: ST103
SELECT top 1 Store_ID, SUM(Total_Orders) AS Total_Orders
FROM Store360
GROUP BY Store_ID
ORDER BY Total_Orders DESC

SELECT Region, ROUND(SUM(Total_Revenue), 0) AS Revenue
FROM Store360
GROUP BY Region
ORDER BY Revenue DESC;

--Total Gross Sales
select Sum(Gross_Sales) as Total_Gross from Store360

--Toatal Net Sales
select Sum(Net_Sales) as Total_Net from Store360

--Total_profit
select Sum(Profit) as Total_profit from Store360
--Avg Profit_Margin
select Avg(Profit_Margin) as Avg_Profit_Margin from Store360 

--Total Product Sold
select sum(Products_Sold) as Avg_Products_Sold from Store360 

--Avg Products_Sold
select Avg(Products_Sold) as Avg_Products_Sold from Store360 
--Avg_Categories_Sold
select Avg(Categories_Sold) as Avg_Categories_Sold from Store360 

--Total_Discount
select Sum(Total_Discount) as Total_Discount from Store360 
--Discount_Rate
select avg(Discount_Rate) as Discount_Rate from Store360 


--Total Quantity Sold Across All Stores

SELECT SUM(Total_Qty) AS Total_Quantity_Sold FROM Store360

--Total Sales (Revenue) Across All Stores

SELECT SUM(Total_Spent) AS Total_Sales FROM Store360

--Average Order Value per Store

SELECT ROUND(SUM(Net_Sales) * 1.0 / NULLIF(SUM(Total_Orders), 0), 2) AS Avg_Order_Value
FROM Store360

--
select * from Store360
where Total_Orders > 0



--1.Top 5 Stores by Total Sales

SELECT TOP 5 StoreID, Total_Spent
FROM Store360
ORDER BY Total_Spent DESC

--Top 5 Cities by Total Orders

SELECT TOP 5 seller_city, SUM(Total_Orders) AS Total_Orders
FROM Store360
GROUP BY seller_city
ORDER BY Total_Orders DESC

--Total Sales by Region

SELECT Region, SUM(Total_Spent) AS Total_Sales
FROM Store360
GROUP BY Region
ORDER BY Total_Sales DESC

--Stores with Zero Orders
SELECT StoreID, seller_city, seller_state
FROM Store360
WHERE Total_Orders = 0

--Sales Percentage Contribution of Top Store

SELECT 
    StoreID,
    Total_Spent,
    ROUND((Total_Spent * 100.0) / (SELECT SUM(Total_Spent) FROM Store360), 2) AS Sales_Percentage
FROM Store360
ORDER BY Total_Spent DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY


--______________________________Product 360 (Analysis)______________________________________

--Total Products Sold
SELECT SUM(Total_Quantity_Sold) AS Total_Products_Sold FROM Products360;
SELECT SUM(Total_Quantity_Sold) AS Total_Products_Sold FROM Product360;

select * from Product360

--Avg_Total_Products_Sold
SELECT ROUND(AVG(Total_Quantity_Sold), 2) AS Avg_Total_Products_Sold FROM Products360;

--Avg_rating
SELECT AVG(Avg_rating) AS Avg_rating FROM Products360;

-- Revenue by Category
SELECT Category, ROUND(SUM(Total_Revenue), 0) AS Revenue 
FROM Product360
GROUP BY Category
ORDER BY Revenue DESC;

--Total Revenue 
select product_id, SUM(Total_Revenue) as Total_Revenue from Product360
group by product_id
order by Total_Revenue desc

-- Total Discount Given: ?4.92 Lakhs
select SUM(Total_Discount) as Total_Discount from Product360

--Average Discount per Product: ?14
select avg(Total_Discount) as Avg_Discount from Products360


--Product 360 View
--Total Products Sold
SELECT SUM(Total_Quantity_Sold) AS Total_Products_Sold FROM Product360;

select * from Products360

--Avg_Total_Products_Sold
SELECT ROUND(AVG(Total_Quantity_Sold), 2) AS Avg_Total_Products_Sold FROM Products360;

--Avg_rating
SELECT AVG(Avg_rating) AS Avg_rating FROM Products360;

-- Revenue by Category
SELECT Category, ROUND(SUM(Total_Revenue), 0) AS Revenue 
FROM Products360
GROUP BY Category
ORDER BY Revenue DESC;

--Total Revenue 
select SUM(Total_Revenue) as Total_Revenue from Products360

-- Total Discount Given: ?4.92 Lakhs
select SUM(Total_Discount) as Total_Discount from Product360

--Average Discount per Product: ?14
select avg(Total_Discount) as Avg_Discount from Products360

select distinct product_id from Products360

--Top-Selling Product Category
SELECT top 1 
    Category,
    SUM(Total_Revenue) AS Total_Revenue,
    SUM(Total_Orders) AS Total_Orders,
    SUM(Total_Quantity_Sold) AS Total_Quantity_Sold
FROM 
    Product360  -- Replace with your actual table name
GROUP BY 
    Category
ORDER BY 
    Total_Revenue DESC


SELECT 
    Channels_Used,
    SUM(Total_Revenue) AS Revenue_Generated
FROM 
    Products360
GROUP BY 
    Channels_Used
ORDER BY 
    Revenue_Generated DESC


--Average Profit Margin
SELECT 
    ROUND(AVG(Profit / NULLIF(Total_Revenue, 0)) * 100, 2) AS Average_Profit_Margin_Percent
FROM 
    Products360;

select COUNT(*) from Finalised_Records_1
select COUNT(*) from Product360
select SUM(Total_Revenue) from Product360
select SUM(Total_Revenue) as Total_Revenue from Products360
select COUNT(*)  as Total_Revenue from Products360


select product_id, count(*) as Total_Revenue from Products360
group by product_id
order by Total_Revenue desc

SELECT TOP 1 product_id, sum(Total_Orders) AS Total_Orders
FROM Products360
GROUP BY product_id
ORDER BY Total_Orders asc;
