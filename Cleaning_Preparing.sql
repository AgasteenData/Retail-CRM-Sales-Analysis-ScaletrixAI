--create database intern_retail

-- Step 1: Find sum of Total Amount from Orders table based on Order is and Customer id--(98671 rows affected)

SELECT Customer_id, Order_id, ROUND(SUM(Total_Amount), 0) AS TotalAmount 
INTO CustOrder
FROM Orders
GROUP BY Customer_id, Order_id;

-- Find sum of Payment value from Order Paymnets table based on order id--(99440 rows affected)

SELECT Order_ID, ROUND(SUM(payment_value), 0) AS PaymentTotal --(99440 rows affected)
INTO OrderPayment
FROM OrderPayments
GROUP BY Order_ID;s

-- Step 2: Find Matched Orders--(88629 rows affected)

SELECT c.*
INTO MatchedOrders
FROM CustOrder c
INNER JOIN OrderPayment op 
ON c.Order_id = op.Order_ID
AND c.TotalAmount = op.PaymentTotal;


-- Step 3: Find Orders Where Payment Exists But Does Not Match Order Amount--(10811 rows affected)

SELECT op.*
--INTO OrdersNotMatching
FROM OrderPayment op
LEFT JOIN CustOrder co
ON co.Order_id = op.Order_ID
AND co.TotalAmount = op.PaymentTotal
WHERE co.Customer_id IS NULL; -- Mismatched orders

/*
select * from Finalised_Records_1 
where Order_ID = '20fd43d1a1e8d1257044b8a17f3c7c5e'*/

-- Step 4: Get Remaining Orders That Can Be Corrected--(7268 rows affected)

SELECT o.Customer_id, o.Order_id, onm.PaymentTotal
--INTO RemainingOrders
FROM OrdersNotMatching onm
INNER JOIN Orders o
ON onm.Order_ID = o.Order_id
AND onm.PaymentTotal = ROUND(o.Total_Amount, 0);


-- Step 5: Merge Matched and Corrected Orders--(95898 rows affected)

SELECT o.*
--INTO NEW_ORDER_TABLE_2
FROM Orders o
INNER JOIN MatchedOrders mo
ON o.Customer_id = mo.Customer_id
AND o.Order_id = mo.Order_id

UNION ALL

SELECT o.*
FROM Orders o
INNER JOIN RemainingOrders ro
ON o.Customer_id = ro.Customer_id
AND o.Order_id = ro.Order_id
AND ro.PaymentTotal = ROUND(o.Total_Amount, 0);

-- Step 6: Create Integrated Table with Additional Information--(95898 rows affected)
SELECT * 
INTO Integrated_Table_1 
FROM (
    SELECT A.*, 
           D.Category, 
           C.Avg_rating, 
           E.seller_city, 
           E.seller_state, 
           E.Region, 
           F.customer_city, 
           F.customer_state, 
           F.Gender
    FROM NEW_ORDER_TABLE_2 A  

    -- Join order reviews to get the average rating per order
    INNER JOIN (
        SELECT A.ORDER_id, AVG(A.Customer_Satisfaction_Score) AS Avg_rating 
        FROM OrderReview_Ratings A 
        GROUP BY A.ORDER_id
    ) AS C ON C.ORDER_id = A.Order_id 

    -- Join product details
    INNER JOIN productsinfo AS D ON A.product_id = D.product_id

    -- Join store details (ensure unique store data)
    INNER JOIN (
        SELECT DISTINCT * FROM Storesinfo
    ) AS E ON A.Delivered_StoreID = E.StoreID

    -- Join customer details
    INNER JOIN Customer AS F ON A.Customer_id = F.Custid
) AS T;


-- Step 7: View Final Integrated Table
SELECT * FROM Integrated_Table_1;

-- Step 8: Merge Additional Orders with Different Delivery Stores--(2459 rows affected)
-- Identify Orders with Multiple Delivery Stores

SELECT DISTINCT A.*, 
       (A.Total_Amount / A.Quantity) AS Net_amount, 
       (A.Quantity / A.Quantity) AS Net_QTY  
--INTO Temp_Multiple_Store_Orders
FROM Orders A
JOIN Orders B 
ON A.order_id = B.order_id 
WHERE A.Delivered_StoreID <> B.Delivered_StoreID;

/*Store are not updated 
select * from Finalised_Records_1 
where Order_ID = '6c47b95ad53fe1aae994040c6de9ed16'
*/


-- Step 9: Merge Additional Orders into Finalized Table--(98,379)

SELECT * 
INTO Finalised_Records_no 
FROM Integrated_Table_1;

INSERT INTO Finalised_Records_no  
SELECT T.Customer_id, T.order_id, T.product_id, T.Channel, T.Delivered_StoreID, 
       T.Bill_date_timestamp, SUM(T.Net_QTY) AS Quantity, T.Cost_Per_Unit, T.MRP, 
       T.Discount, SUM(T.Net_amount) AS Total_Amount, 
       C.Category, F.Customer_Satisfaction_Score AS Avg_rating,
       G.seller_city, G.seller_state, G.Region, 
       E.customer_city, E.customer_state, E.Gender  
FROM Temp_Multiple_Store_Orders T
INNER JOIN productsinfo C ON T.product_id = C.product_id  
INNER JOIN orderpayments D ON T.order_id = D.order_id  
INNER JOIN Customer E ON T.Customer_id = E.Custid  
INNER JOIN OrderReview_Ratings F ON T.order_id = F.order_id  
INNER JOIN Storesinfo G ON T.Delivered_StoreID = G.StoreID  
GROUP BY T.Customer_id, T.order_id, T.product_id, T.Channel, T.Bill_date_timestamp, 
         T.Cost_Per_Unit, T.Delivered_StoreID, T.Discount, T.MRP, T.Total_Amount, 
         T.Quantity, T.Net_amount, T.Net_QTY, C.Category, 
         F.Customer_Satisfaction_Score, G.seller_city, G.seller_state, G.Region, 
         E.customer_city, E.customer_state, E.Gender;

select * from Finalised_Records_no

-- Step 10: Create the `Add_records` Table (Fixing the Order of Operations)--(2326 rows affected)
-- This stores additional orders that had multiple delivery stores (created before using it in Step 11)

SELECT * 
--INTO Add_records 
FROM (
    SELECT T.Customer_id, T.order_id, T.product_id, T.Channel, T.Delivered_StoreID, 
           T.Bill_date_timestamp, SUM(T.Net_QTY) AS Quantity, T.Cost_Per_Unit, 
           T.MRP, T.Discount, SUM(Net_amount) AS Total_Amount, 
           C.Category, F.Customer_Satisfaction_Score AS Avg_rating,
           G.seller_city, G.seller_state, G.Region, 
           E.customer_city, E.customer_state, E.Gender
    FROM Temp_Multiple_Store_Orders T
    INNER JOIN productsinfo C ON T.product_id = C.product_id
    INNER JOIN orderpayments D ON T.order_id = D.order_id
    INNER JOIN Customer E ON T.Customer_id = E.Custid
    INNER JOIN OrderReview_Ratings F ON T.order_id = F.order_id
    INNER JOIN Storesinfo G ON T.Delivered_StoreID = G.StoreID
    GROUP BY T.Customer_id, T.order_id, T.product_id, T.Channel, T.Bill_date_timestamp, 
             T.Cost_Per_Unit, T.Delivered_StoreID, T.Discount, T.MRP, 
             C.Category, F.Customer_Satisfaction_Score, G.seller_city, 
             G.seller_state, G.Region, E.customer_city, E.customer_state, E.Gender
) A;


select * from Add_records


-- Step 11: Remove Duplicates and Create Finalized Records Table--(98277 rows affected)
-- Now that `Add_records` exists, we can use it to clean the final table

SELECT * 
--INTO Finalised_Records_1
FROM (
    SELECT * FROM Finalised_Records_no
    EXCEPT
    SELECT A.* FROM Add_records A
    INNER JOIN Integrated_Table_1 B
    ON A.order_id = B.order_id
) X;


-- Step 12: View Finalized Table--(98277 rows)
SELECT * FROM Finalised_Records_1

/* Missmatching amounts and quantitys(leads to duplicates)
select * from Finalised_Records_1 
where Order_ID = '62ce4e3989a3477928510bb4d1064cc4'
*/



---1.Deleteing records outside of the time period provided (2021-09-01 to 2023-10-31)--3

select *  from Finalised_Records_1
where Bill_date_timestamp not between '2021-09-01' and '2023-10-31'

Delete  from Finalised_Records_1
where Bill_date_timestamp not between '2021-09-01' and '2023-10-31'


--2.Updateing storeID with the lower storeid number.(1198)
WITH StoreUpdate AS (
    SELECT 
        Customer_id, 
        Order_id, 
        Channel, 
        MIN(Delivered_StoreID) OVER (PARTITION BY Customer_id, Order_id) AS NewStoreID
    FROM Finalised_Records_1
	where Channel = 'Instore'
)
UPDATE O
SET Delivered_StoreID = SU.NewStoreID
FROM Finalised_Records_1 O
JOIN StoreUpdate SU
ON O.Customer_id = SU.Customer_id 
AND O.Order_id = SU.Order_id 
AND O.Delivered_StoreID <> SU.NewStoreID;


--3.Updateing with the latest timestamp.(331)

WITH TimestampUpdate AS (
    SELECT *, 
        MAX(Bill_date_timestamp) OVER (PARTITION BY Customer_id, Order_id, Delivered_StoreID) AS NewTimestamp
    FROM Finalised_Records_1
	
)

UPDATE O
SET Bill_date_timestamp = TU.NewTimestamp
FROM Finalised_Records_1 O
JOIN TimestampUpdate TU
ON O.Customer_id = TU.Customer_id 
AND O.Order_id = TU.Order_id 
AND O.Delivered_StoreID = TU.Delivered_StoreID 
AND O.Bill_date_timestamp <> TU.NewTimestamp;

select * from Finalised_Records_1
where Customer_id = 1144123878




--4.Duplicate rows--204
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Customer_id, Order_id, Delivered_StoreID, Bill_date_timestamp,
                            Product_id, Channel, Quantity
               ORDER BY Customer_id  
           ) AS rn
    FROM Finalised_Records_1
)
Delete FROM CTE
WHERE rn > 1;



select sum(Total_Amount) from Finalised_Records_1

select sum(Total_Revenue) from Cust360
select sum(Net_Sales) from Order360
select sum(Total_Revenue) from Product360
select sum(Net_Sales) from Store360


select Preferred_Payment_Method, sum(Total_Revenue), sum(Total_Revenue) * 100 / (select sum(Total_Revenue) from Cust360)  from Cust360
group by Preferred_Payment_Method





--________________________________Customer360_______________________________________________

WITH PaymentSummary AS (
    SELECT 
        order_id,
        COUNT(DISTINCT payment_type) AS Payment_Methods_Used,
        SUM(CASE WHEN payment_type = 'Voucher' THEN 1 ELSE 0 END) AS Voucher_Payments,
        SUM(CASE WHEN payment_type = 'Credit Card' THEN 1 ELSE 0 END) AS CreditCard_Payments,
        SUM(CASE WHEN payment_type = 'Debit Card' THEN 1 ELSE 0 END) AS DebitCard_Payments,
        SUM(CASE WHEN payment_type = 'UPI' THEN 1 ELSE 0 END) AS UPI_Payments,
        MAX(payment_type) AS Preferred_Payment_Method
    FROM orderpayments
    GROUP BY order_id
),

ProductCategory AS (
    SELECT 
        product_id,
        MAX(Category) AS Category
    FROM productsinfo
    GROUP BY product_id
),

StoreInfo AS (
    SELECT 
        StoreID,
        MAX(seller_city) AS seller_city,
        MAX(seller_state) AS seller_state,
        MAX(Region) AS seller_region
    FROM Storesinfo
    GROUP BY StoreID
)

SELECT 
    FR.Customer_id,
    MAX(C.customer_city) AS Customer_City,
    MAX(C.customer_state) AS Customer_State,
    MAX(C.Gender) AS Gender,

    -- Buy location
    MAX(SI.seller_state) AS Buy_State,
    MAX(SI.seller_region) AS Buy_Region,
	MIN(FR.Channel) AS Sales_Channel,
    -- Ratings
    ROUND(AVG(FR.Avg_rating), 2) AS Avg_rating,

    -- Dates
    MIN(FR.Bill_date_timestamp) AS First_Transaction_Date,
    MAX(FR.Bill_date_timestamp) AS Last_Transaction_Date,
    DATEDIFF(DAY, MIN(FR.Bill_date_timestamp), MAX(FR.Bill_date_timestamp)) AS Tenure,
    DATEDIFF(DAY, MAX(FR.Bill_date_timestamp), GETDATE()) AS Inactive_Days,

    -- Frequency
    COUNT(DISTINCT FR.order_id) AS No_of_Transactions,

    -- Monetary
    SUM(FR.Total_Amount) AS Total_Revenue,
    SUM(FR.Total_Amount - FR.Cost_Per_Unit * FR.Quantity) AS Profit,
    SUM(FR.Discount) AS Total_Discount,

    -- Quantity
    SUM(FR.Quantity) AS Total_Quantity,
    COUNT(DISTINCT FR.product_id) AS Distinct_Items_Purchased,
    COUNT(DISTINCT PC.Category) AS Distinct_Categories_Purchased,

    -- Discount & Loss
    COUNT(DISTINCT CASE WHEN FR.Discount > 0 THEN FR.order_id END) AS Transactions_With_Discount,
    COUNT(DISTINCT CASE WHEN (FR.Total_Amount - FR.Cost_Per_Unit * FR.Quantity) < 0 THEN FR.order_id END) AS Transactions_With_Loss,

    -- Channel / Store / City
    COUNT(DISTINCT FR.Channel) AS Channels_Used,
    COUNT(DISTINCT FR.Delivered_StoreID) AS Distinct_Stores,
    COUNT(DISTINCT SI.seller_city) AS Distinct_Cities,

    -- Payment Types
    SUM(ISNULL(PS.Payment_Methods_Used, 0)) AS Payment_Methods_Used,
    SUM(ISNULL(PS.Voucher_Payments, 0)) AS Voucher_Payments,
    SUM(ISNULL(PS.CreditCard_Payments, 0)) AS CreditCard_Payments,
    SUM(ISNULL(PS.DebitCard_Payments, 0)) AS DebitCard_Payments,
    SUM(ISNULL(PS.UPI_Payments, 0)) AS UPI_Payments,
    ISNULL(MAX(PS.Preferred_Payment_Method), 'Unknown') AS Preferred_Payment_Method,

    -- Time-Based
    COUNT(CASE WHEN DATENAME(WEEKDAY, FR.Bill_date_timestamp) IN ('Saturday', 'Sunday') THEN 1 END) AS Weekend_Transactions,
    COUNT(CASE WHEN DATENAME(WEEKDAY, FR.Bill_date_timestamp) NOT IN ('Saturday', 'Sunday') THEN 1 END) AS Weekday_Transactions,
    COUNT(CASE WHEN MONTH(FR.Bill_date_timestamp) IN (1, 8, 12) THEN 1 END) AS Sales_Season_Transactions
	into Cust360
FROM Finalised_Records_1 FR
LEFT JOIN Customer C ON FR.Customer_id = C.Custid
LEFT JOIN ProductCategory PC ON FR.product_id = PC.product_id
LEFT JOIN StoreInfo SI ON FR.Delivered_StoreID = SI.StoreID
LEFT JOIN PaymentSummary PS ON FR.order_id = PS.order_id
GROUP BY FR.Customer_id;




-------------Vlue Based segmentation------------------------

select *,    
    CASE 
        WHEN Total_Revenue >= 3000 THEN 'Platinum'
        WHEN Total_Revenue BETWEEN 2000 AND 3000 THEN 'Gold'
        WHEN Total_Revenue BETWEEN 1000 AND 2000 THEN 'Silver'
        ELSE 'Standard'
    END AS Value_Segment, YEAR(First_Transaction_Date) [Year], MONTH( First_Transaction_Date) [Month], DATENAME(WEEKDAY, First_Transaction_Date) [Weeday_Name]
into Custs360
from Cust360




-----RFM Segmentaion---------------------------- 
WITH rfm AS (
    SELECT 
        Customer_id,
        COUNT(DISTINCT order_id) AS f,  -- Frequency
        ROUND(SUM(Total_Amount), 0) AS m,  -- Monetary (Total Amount)
        DATEDIFF(DAY, MAX(Bill_date_timestamp), (SELECT MAX(Bill_date_timestamp) FROM Finalised_Records_1)) AS r  -- Recency
    FROM Finalised_Records_1
    GROUP BY Customer_id
),
segment AS (
    SELECT 
        Customer_id,
        m,
        NTILE(3) OVER (ORDER BY r ASC) AS recency,      -- Lower 'r' is better
        NTILE(3) OVER (ORDER BY f DESC) AS frequency,    -- Higher is better
        NTILE(3) OVER (ORDER BY m DESC) AS monetary      -- Higher is better
    FROM rfm
)
SELECT 
    Customer_id,recency,frequency,monetary,
    m AS Total_Amount,
    CASE 
        WHEN (recency + frequency + monetary) >= 8 THEN 'Champions'
        WHEN (recency + frequency + monetary) BETWEEN 4 AND 7 THEN 'Potential_Loyalists'
        ELSE 'Risk_Customers'
    END AS Customer_Segment
	--into rfm_segment
FROM segment;


--__________________________________________Order360___________________________________________
SELECT 
    O.order_id,
    --MIN(O.Customer_id) AS Customer_ID,
    
    -- Order Details
    MIN(O.Bill_date_timestamp) AS Order_Date,
    DATENAME(MONTH, MIN(O.Bill_date_timestamp)) AS Order_Month,
    DATEPART(QUARTER, MIN(O.Bill_date_timestamp)) AS Order_Quarter,
    DATEPART(YEAR, MIN(O.Bill_date_timestamp)) AS Order_Year,
    MIN(O.Channel) AS Sales_Channel,
    MIN(O.Delivered_StoreID) AS Store_ID,

    --  Customer Demographics
    MIN(O.customer_city) AS Customer_City,
    MIN(O.customer_state) AS Customer_State,
    MIN(O.Region) AS Region,
    MIN(O.Gender) AS Gender,

    --  Product/Order Mix
    COUNT(DISTINCT O.product_id) AS Product_Count,
    COUNT(DISTINCT O.Category) AS Category_Count,

    --  Quantity and Pricing
    SUM(O.Quantity) AS Total_Quantity,
    AVG(O.Quantity) AS Avg_Quantity_Per_Item,
    SUM(O.MRP * O.Quantity) AS Gross_Sales,
    SUM(O.Total_Amount) AS Net_Sales,
    SUM(O.Discount) AS Total_Discount,
    ROUND(SUM(O.Discount) * 1.0 / NULLIF(SUM(O.MRP * O.Quantity), 0), 4) AS Discount_Percentage,

    --  Cost, Margin, Profit
    SUM(O.Cost_Per_Unit * O.Quantity) AS Total_Cost,
    SUM(O.Total_Amount - ISNULL(O.Cost_Per_Unit, 0) * ISNULL(O.Quantity, 0)) AS Profit,
    ROUND(SUM(O.Total_Amount - O.Cost_Per_Unit * O.Quantity) * 1.0 / NULLIF(SUM(O.Total_Amount), 0), 4) AS Profit_Margin,

    -- Rating and Feedback
    AVG(O.Avg_rating) AS Avg_Rating,
    
    --  Seller Info
    COUNT(DISTINCT O.seller_city) AS Seller_City_Count,
    COUNT(DISTINCT O.seller_state) AS Seller_State_Count,

    -- Flags & Insights
    CASE 
        WHEN SUM(O.Quantity) > 10 THEN 'Bulk Order' 
        ELSE 'Regular Order' 
    END AS Order_Type,

    CASE 
        WHEN COUNT(DISTINCT O.Category) > 3 THEN 'Cross Category'
        ELSE 'Single Category'
    END AS Category_Mix,

    CASE 
        WHEN SUM(O.Discount) > 0 THEN 'Discounted' 
        ELSE 'Non-Discounted' 
    END AS Discount_Type
	into Order360
FROM 
    Finalised_Records_1 O
GROUP BY 
    O.order_id;

	

--_____________________________________Store360________________________________________

SELECT 
    O.Delivered_StoreID AS Store_ID,

    -- Store Location Details
    MIN(S.seller_city) AS City,
    MIN(S.seller_state) AS State,
    MIN(S.Region) AS Region,

    --  Order & Customer Metrics
    COUNT(DISTINCT O.order_id) AS Total_Orders,
    COUNT(DISTINCT O.Customer_id) AS Unique_Customers,

    -- Sales Volume Metrics
    ISNULL(SUM(O.Quantity), 0) AS Total_Quantity_Sold,
    ISNULL(SUM(O.MRP * O.Quantity), 0) AS Gross_Sales,
    ISNULL(SUM(O.Total_Amount), 0) AS Net_Sales,
    ISNULL(SUM(O.Discount), 0) AS Total_Discount,
    ROUND(SUM(O.Discount) * 1.0 / NULLIF(SUM(O.MRP * O.Quantity), 0), 4) AS Discount_Rate,

    -- Cost & Profitability
    ISNULL(SUM(O.Cost_Per_Unit * O.Quantity), 0) AS Total_Cost,
    ISNULL(SUM(O.Total_Amount - ISNULL(O.Cost_Per_Unit, 0) * ISNULL(O.Quantity, 0)), 0) AS Profit,
    ROUND(SUM(O.Total_Amount - O.Cost_Per_Unit * O.Quantity) * 1.0 / NULLIF(SUM(O.Total_Amount), 0), 4) AS Profit_Margin,

    --  Product Mix
    COUNT(DISTINCT O.product_id) AS Products_Sold,
    COUNT(DISTINCT P.Category) AS Categories_Sold,
    ROUND(AVG(O.Avg_rating), 2) AS Avg_Product_Rating,

    --  Smart Store Flags
    CASE 
        WHEN SUM(O.Total_Amount) > 100000 THEN 'Top Performing'
        ELSE 'Regular Store'
    END AS Store_Performance,

    CASE 
        WHEN COUNT(DISTINCT O.Customer_id) > 50 THEN 'High Footfall'
        ELSE 'Low Footfall'
    END AS Footfall_Type,

    CASE 
        WHEN COUNT(DISTINCT P.Category) > 5 THEN 'Wide Category Range'
        ELSE 'Limited Category'
    END AS Category_Coverage
	into Store360
FROM 
    Finalised_Records_1 O
LEFT JOIN Storesinfo S ON O.Delivered_StoreID = S.StoreID
LEFT JOIN productsinfo P ON O.product_id = P.product_id
GROUP BY 
    O.Delivered_StoreID;



select * from Customer360	
--_____________________________________Product360_____________________________________	

SELECT 
    FR.product_id,
    P.Category,

    -- Core Sales Metrics
    COUNT(FR.order_id) AS Total_Orders,
    COUNT(FR.Customer_id) AS Unique_Customers,
    ISNULL(SUM(FR.Quantity), 0) AS Total_Quantity_Sold,
    ISNULL(SUM(FR.Total_Amount), 0) AS Total_Revenue,
    ISNULL(SUM(FR.Discount), 0) AS Total_Discount,
    ISNULL(SUM(FR.MRP * FR.Quantity), 0) AS Gross_Revenue,
    
    -- Cost and Profitability
    ISNULL(SUM(FR.Cost_Per_Unit * FR.Quantity), 0) AS Total_Cost,
    ISNULL(SUM(FR.Total_Amount - ISNULL(FR.Cost_Per_Unit, 0) * ISNULL(FR.Quantity, 0)), 0) AS Profit,
    ROUND(SUM(FR.Total_Amount - FR.Cost_Per_Unit * FR.Quantity) * 1.0 / NULLIF(SUM(FR.Total_Amount), 0), 4) AS Profit_Margin,
    ROUND(SUM(FR.Discount) * 1.0 / NULLIF(SUM(FR.MRP * FR.Quantity), 0), 4) AS Discount_Percentage,

    -- Ratings & Satisfaction
    ROUND(AVG(FR.Avg_rating), 2) AS Avg_Rating,
    COUNT(CASE WHEN FR.Avg_rating >= 4 THEN 1 END) AS High_Rated_Orders,
    
    --  Reach
    COUNT(DISTINCT FR.Delivered_StoreID) AS Stores_Sold_In,
    COUNT(DISTINCT S.seller_city) AS Cities_Sold_In,
    COUNT(DISTINCT FR.Channel) AS Channels_Used,
    
    --  Time-Based Metrics
    MIN(FR.Bill_date_timestamp) AS First_Sold_Date,
    MAX(FR.Bill_date_timestamp) AS Last_Sold_Date,
    DATEDIFF(DAY, MIN(FR.Bill_date_timestamp), MAX(FR.Bill_date_timestamp)) AS Active_Selling_Period,

    --  Risk/Performance Flags
    COUNT(DISTINCT CASE WHEN ISNULL(FR.Discount, 0) > 0 THEN FR.order_id END) AS Discounted_Orders,
    COUNT(DISTINCT CASE WHEN (FR.Total_Amount - FR.Cost_Per_Unit * FR.Quantity) < 0 THEN FR.order_id END) AS Loss_Making_Orders,

    CASE 
        WHEN SUM(FR.Quantity) > 1000 THEN 'High Volume Product'
        ELSE 'Regular Volume'
    END AS Volume_Type,

    CASE 
        WHEN ROUND(AVG(FR.Avg_rating), 2) >= 4 THEN 'Well Rated'
        ELSE 'Needs Improvement'
    END AS Rating_Tag

INTO Product360
FROM Finalised_Records_1 FR
LEFT JOIN productsinfo P ON FR.product_id = P.product_id
LEFT JOIN Storesinfo S ON FR.Delivered_StoreID = S.StoreID
GROUP BY 
    FR.product_id, P.Category;











