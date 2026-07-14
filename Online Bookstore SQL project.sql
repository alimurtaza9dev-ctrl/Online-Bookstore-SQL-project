CREATE DATABASE OnlineBookstore;
USE OnlineBookstore;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Books (
    Book_ID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);

CREATE TABLE Customers (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);

CREATE TABLE Orders (
    Order_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID INT,
    Book_ID INT,
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);
SHOW TABLES;
SELECT COUNT(*) FROM Books;
SELECT COUNT(*) FROM Customers;
SELECT COUNT(*) FROM Orders;
SELECT * FROM Books LIMIT 5;
SELECT * FROM Customers LIMIT 5;
SELECT * FROM Orders LIMIT 5;
SELECT Order_ID, Order_Date, Total_Amount,
       SUM(Total_Amount) OVER (ORDER BY Order_Date, Order_ID) AS Running_Total
FROM Orders
ORDER BY Order_Date, Order_ID;
SELECT Book_ID, Title, Genre, Price,
       RANK() OVER (PARTITION BY Genre ORDER BY Price DESC) AS Price_Rank
FROM Books
ORDER BY Genre, Price_Rank;
SELECT c.Customer_ID, c.Name
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 FROM Orders o WHERE o.Customer_ID = c.Customer_ID
);
SELECT c.Customer_ID, c.Name, SUM(o.Total_Amount) AS Total_Spent
FROM Customers c
JOIN Orders o ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Name
HAVING SUM(o.Total_Amount) > (
    SELECT AVG(cust_total) FROM (
        SELECT SUM(Total_Amount) AS cust_total
        FROM Orders
        GROUP BY Customer_ID
    ) AS per_customer_totals
);
WITH monthly AS (
    SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS Sales_Month,
           SUM(Total_Amount) AS Revenue
    FROM Orders
    GROUP BY Sales_Month
)
SELECT Sales_Month, Revenue,
       Revenue - LAG(Revenue) OVER (ORDER BY Sales_Month) AS Change_From_Prev_Month
FROM monthly
ORDER BY Sales_Month;
WITH ranked AS (
    SELECT Book_ID, Title, Genre, Price,
           DENSE_RANK() OVER (PARTITION BY Genre ORDER BY Price DESC) AS rnk
    FROM Books
)
SELECT Book_ID, Title, Genre, Price
FROM ranked
WHERE rnk = 2;
SELECT
    CASE WHEN SUBSTRING_INDEX(Email, '@', -1) = 'gmail.com' THEN 'gmail.com'
         ELSE 'other' END AS Domain_Type,
    COUNT(*) AS Customer_Count
FROM Customers
GROUP BY Domain_Type;
