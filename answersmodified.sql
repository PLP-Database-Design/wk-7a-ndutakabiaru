--question 1
-- Create a new table to hold the 1NF structure
CREATE TABLE OrderProducts_1NF (
    OrderID INT,
    CustomerName VARCHAR(255),
    Product VARCHAR(255)
);

-- Insert data into the 1NF table by splitting the Products column
INSERT INTO OrderProducts_1NF (OrderID, CustomerName, Product)
SELECT
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ProductDetail.Products, ',', n.n), ',', -1)) AS Product
FROM
    ProductDetail
CROSS JOIN (
    SELECT a.N + b.N * 10 + 1 AS n
    FROM
        (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
        CROSS JOIN (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
) n
ON LENGTH(ProductDetail.Products) - LENGTH(REPLACE(ProductDetail.Products, ',', '')) >= n.n - 1;

-- You can now query the OrderProducts_1NF table which is in 1NF
SELECT * FROM OrderProducts_1NF;

-- question 2
-- Create a new table for Customers to remove the partial dependency
CREATE TABLE Customers_2NF (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(255)
);

-- Populate the Customers table with unique OrderID and CustomerName pairs
INSERT INTO Customers_2NF (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Create a new table for Order Items without the CustomerName (fully dependent on the composite key)
CREATE TABLE OrderItems_2NF (
    OrderID INT,
    Product VARCHAR(255),
    Quantity INT,
    PRIMARY KEY (OrderID, Product), -- Composite primary key
    FOREIGN KEY (OrderID) REFERENCES Customers_2NF(OrderID)
);

-- Populate the OrderItems table
INSERT INTO OrderItems_2NF (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- You can now query the 2NF tables
SELECT * FROM Customers_2NF;
SELECT * FROM OrderItems_2NF;

