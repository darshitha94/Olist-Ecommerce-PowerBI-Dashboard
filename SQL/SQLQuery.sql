--Q1:Which product categories generate the highest sales revenue?


Select p.product_category_name,
       SUM(i.price) as Sales_revenue
FROM Products p
INNER JOIN Order_items i
     ON p.product_id = i.product_id
GROUP BY p.product_category_name
ORDER BY Sales_revenue Desc;


--Q2: Which Brazilian states generate the highest sales revenue?

Select
      s.seller_state,
      SUM(i.price) AS Sales_revenue
FROM Sellers s
INNER JOIN Order_items i
   ON s.seller_id = i.seller_id
GROUP BY s.seller_state
ORDER BY Sales_revenue Desc;


--Q3: Which Top 10 sellers with the highest sales value?

Select TOP 10
      s.seller_id,
      SUM(i.price) AS Sales_value
FROM Sellers s
INNER JOIN Order_items i
   ON s.seller_id = i.seller_id
GROUP BY s.seller_id
ORDER BY Sales_value Desc;


--Q4:What percentage of customers place repeat orders?


WITH CustomerOrders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS Total_Orders
    FROM orders o
    INNER JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),
CustomerSummary AS (
    SELECT
        COUNT(*) AS Total_Customers,
        SUM(CASE
                WHEN Total_Orders > 1 THEN 1
                ELSE 0
            END) AS Repeat_Customers
    FROM CustomerOrders
)
SELECT
    Total_Customers,
    Repeat_Customers,
    CAST(
        Repeat_Customers * 100.0 / Total_Customers
        AS DECIMAL(5,2)
    ) AS Repeat_Customer_Percentage
FROM CustomerSummary;



--Q5: What is the average order value?

Select SUM(price + freight_value) * 1.0
          /COUNT(DISTINCT order_id) AS Average_Order_value
FROM Order_items;


--Q6: Which states have the highest late-delivery rates?


Select c.customer_state,
       SUM(CASE
               WHEN o.order_delivered_customer_date >
                    o.order_estimated_delivery_date
               THEN 1
               ELSE 0
            END) *100.0 / COUNT(*) AS Late_delivery_Rate
FROM Orders o
INNER JOIN Customers c
   ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY Late_delivery_Rate DESC;


--Q7: Do late deliveries correspond to lower customer review scores?


SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time or Early'
    END AS Delivery_Status,
    AVG(r.review_score) AS Average_Review_Score
FROM orders o
JOIN Reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time or Early'
    END;



--Q8:How does monthly sales revenue change compared with the previous month?

WITH MonthlySales AS (
    SELECT
        FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS Sales_Month,
        SUM(oi.price + oi.freight_value) AS Revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
)
SELECT
    Sales_Month,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Sales_Month) AS Previous_Month,
    Revenue - LAG(Revenue) OVER (ORDER BY Sales_Month) AS Revenue_Change
FROM MonthlySales
ORDER BY Sales_Month;


--Q9:Which product categories receive the lowest average review scores?


Select p.product_category_name,
       AVG(r.review_score) AS Avg_review_score
FROM Order_items oi
JOIN Products p
   ON oi.product_id = p.product_id
JOIN Reviews r
   ON oi.order_id = r.order_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY Avg_review_score Asc;
 

--Q10:Which payment methods generate the highest total payment value?

Select payment_type,
       SUM(payment_value) AS Total_payment
FROM Payments
GROUP BY payment_type
ORDER BY Total_payment Desc;


--Q11: Which sellers have high sales but poor customer review scores?


SELECT oi.seller_id,
       SUM(oi.price) AS Total_Sales,
       AVG(r.review_score) AS Customer_review_score
FROM Order_items oi
INNER JOIN Reviews r 
    ON oi.order_id = r.order_id
GROUP BY oi.seller_id
ORDER BY Total_Sales Desc,
         Customer_review_score Asc;



--Q12: Which products generate the highest sales value?


Select
      product_id,
      SUM(price) AS Total_sales
FROM Order_items
GROUP BY product_id
ORDER BY Total_sales Desc;