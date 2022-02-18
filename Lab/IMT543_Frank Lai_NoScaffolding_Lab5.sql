

/*
M5 13 No Scaffolding Lab 5 

Server: IS-HAY09.ischool.uw.edu 
Database: SampleSuperStore 

*/

-- Q1) Write the SQL to determine which customers meet all of the following conditions:
-- condition a) Purchased fewer than 3 units of products that are product type 'Electronics' before 2013 
-- condition b) Spent less than $30 on Kitchen products between 1999 and 2008

SELECT C.CustomerID, C.Fname, C.Lname
FROM tblCUSTOMER C
JOIN (
    SELECT C.CustomerID
    FROM tblCUSTOMER C
    JOIN tblORDER O 
      ON C.CustomerID = O.CustomerID
    JOIN tblORDER_PRODUCT OP 
      ON O.OrderID = OP.OrderID
    JOIN tblPRODUCT P 
      ON OP.ProductID = P.ProductID
    JOIN tblPRODUCT_TYPE PT 
      ON P.ProdTypeID = PT.ProdTypeID
    WHERE PT.ProdTypeName = 'Electronics'
      AND O.OrderDate < '2013-01-01'
    GROUP BY C.CustomerID
    HAVING COUNT(C.CustomerID) < 3
) SUB1
  ON C.CustomerID = SUB1.CustomerID
JOIN (
    SELECT C.CustomerID
    FROM tblCUSTOMER C
    JOIN tblORDER O 
      ON C.CustomerID = O.CustomerID
    JOIN tblORDER_PRODUCT OP 
      ON O.OrderID = OP.OrderID
    JOIN tblPRODUCT P 
      ON OP.ProductID = P.ProductID
    JOIN tblPRODUCT_TYPE PT 
      ON P.ProdTypeID = PT.ProdTypeID
    WHERE PT.ProdTypeName = 'Kitchen'
      AND O.OrderDate BETWEEN '1999-01-01' AND '2008-12-31'
    GROUP BY C.CustomerID
    HAVING SUM(P.Price) < 30
) SUB2
  ON SUB1.CustomerID = SUB2.CustomerID;

-- Q2) Write the SQL query to determine the top 6 states for total dollars spend on products of type 'garden' for people younger than 33 years old at the time of purchase

SELECT TOP(6) C.CustState, SUM(OP.Calc_LineTotal) AS Total_Dollar_Spent
FROM tblCUSTOMER C
JOIN tblORDER O 
  ON C.CustomerID = O.CustomerID
JOIN tblORDER_PRODUCT OP 
  ON O.OrderID = OP.OrderID
JOIN tblPRODUCT P 
  ON OP.ProductID = P.ProductID
JOIN tblPRODUCT_TYPE PT 
  ON P.ProdTypeID = PT.ProdTypeID
WHERE PT.ProdTypeName = 'Garden'
  AND DATEDIFF(MONTH, C.BirthDate, O.OrderDate) < 396
GROUP BY C.CustState
ORDER BY SUM(OP.Calc_LineTotal) DESC;


-- Q3) Write the SQL to label and count the number of customers that meet the following conditions:
--		a) Purchased fewer than 20 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Blue'
--		b) Purchased between 20 and 30 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Green'
--		c) Purchased between 31 and 45 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Orange'
--		d) Purchased between 46 and 60 units of 'automotive' products lifetime AND spent BETWEEN $801 and $3000 lifetime of product type 'kitchen', label them 'Purple'
--		e) Else 'Unknown'
-- HINT: this is best written with a CASE statement drawing from 2 subqueries(!!) that each have an aggregated alias like 'AutoUnits' and 'TotalBucksKitchen'

SELECT (
    CASE 
        WHEN AutoUnits < 20 AND TotalBucksKitchen < 800
          THEN 'Blue'
        WHEN AutoUnits BETWEEN 20 AND 30 AND TotalBucksKitchen < 800
          THEN 'Green'
        WHEN AutoUnits BETWEEN 31 AND 45 AND TotalBucksKitchen < 800
          THEN 'Orange'
        WHEN AutoUnits BETWEEN 46 AND 60 AND TotalBucksKitchen BETWEEN 801 AND 3000
          THEN 'Purple'
        ELSE 'Unknown'
        END
) AS LABEL, COUNT(*) AS NumberOfCustomers
FROM (
    SELECT C.CustomerID, SUM(OP.Calc_LineTotal) as TotalBucksKitchen
    FROM tblCUSTOMER C
    JOIN tblORDER O 
      ON C.CustomerID = O.CustomerID
    JOIN tblORDER_PRODUCT OP 
      ON O.OrderID = OP.OrderID
    JOIN tblPRODUCT P 
      ON OP.ProductID = P.ProductID
    JOIN tblPRODUCT_TYPE PT 
      ON P.ProdTypeID = PT.ProdTypeID
    WHERE PT.ProdTypeName = 'Kitchen'
    GROUP BY C.CustomerID) SUB1
JOIN (
    SELECT C.CustomerID, SUM(OP.Quantity) as AutoUnits
    FROM tblCUSTOMER C
    JOIN tblORDER O 
      ON C.CustomerID = O.CustomerID
    JOIN tblORDER_PRODUCT OP 
      ON O.OrderID = OP.OrderID
    JOIN tblPRODUCT P 
      ON OP.ProductID = P.ProductID
    JOIN tblPRODUCT_TYPE PT 
      ON P.ProdTypeID = PT.ProdTypeID
    WHERE PT.ProdTypeName = 'Automotive'
    GROUP BY C.CustomerID
) SUB2
  ON SUB1.CustomerID = SUB2.CustomerID
GROUP BY (
    CASE 
        WHEN AutoUnits < 20 AND TotalBucksKitchen < 800
          THEN 'Blue'
        WHEN AutoUnits BETWEEN 20 AND 30 AND TotalBucksKitchen < 800
          THEN 'Green'
        WHEN AutoUnits BETWEEN 31 AND 45 AND TotalBucksKitchen < 800
          THEN 'Orange'
        WHEN AutoUnits BETWEEN 46 AND 60 AND TotalBucksKitchen BETWEEN 801 AND 3000
          THEN 'Purple'
        ELSE 'Unknown'
        END
)
ORDER BY NumberOfCustomers DESC;


-- Q4) Write the SQL to create a stored procedure to INSERT a new row into tblPRODUCT under the following conditions:
-- a) pass in parameters of @ProdName, @ProdTypeName, and @Price
-- b) DECLARE a variable to look-up the associated ProdTypeID for @ProdTypeName parameter (no error-handling required)
-- c) make the INSERT statement inside an explicit transaction

CREATE PROCEDURE uspINSERT_Product
@ProdName VARCHAR(100),
@ProdTypeName VARCHAR(50),
@Price NUMERIC
AS
DECLARE @ProdTypeID INT

SET @ProdTypeID = (SELECT ProdTypeID
                   FROM tblPRODUCT_TYPE
                   WHERE ProdTypeName = @ProdTypeName
)

BEGIN TRANSACTION T1
INSERT INTO tblPRODUCT(ProductName, ProdTypeID, Price)
VALUES (@ProdName, @ProdTypeID, @Price)
COMMIT TRANSACTION T1
GO

-- Q5) Write the SQL to create a stored procedure to UPDATE the price of a single product in SampleSuperStore database with the following conditions:
-- a) be sure to affect only a single row (hint: populate a variable and set that to the PK of tblPRODUCT)
-- b) make the UPDATE statement inside an explicit transaction
-- c) pass in parameters of @ProdName and @NewPrice

CREATE PROCEDURE uspUPDATE_Product
@ProdName VARCHAR(100),
@NewPrice NUMERIC
AS
DECLARE @ProductID INT

SET @ProductID = (SELECT ProductID
                   FROM tblPRODUCT
                   WHERE ProductName = @ProdName
)

BEGIN TRANSACTION T1
UPDATE tblPRODUCT
SET Price = @NewPrice
WHERE ProductID = @ProductID
COMMIT TRANSACTION T1
GO