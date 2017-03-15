/*general queries*/
/* 10. What is the percentage value of each product in inventory sorted by the highest percentage first (Hint: Create a view first)*/
/*with out OLAP*/
CREATE OR REPLACE VIEW totalStock 
AS
SELECT SUM(quantityInStock) AS totalQuantity
FROM products;
SELECT productName,
       (quantityInStock*100) /(SELECT totalQuantity FROM totalStock)
AS percentagevalue
FROM products
ORDER BY 2 DESC;

/*with OLAP*/
SELECT productName,
       SUM(quantityinstock) OVER (PARTITION BY productcode) AS productQuantity,
       SUM(quantityinstock) OVER () AS totalQuantity,
       ((SUM(quantityinstock) OVER (PARTITION BY productcode)) /(SUM(quantityinstock) OVER ()))*100 AS percentage
FROM products
ORDER BY percentage DESC;

/*14 What is the ratio the value of payments made to orders received for each month of 2004. (i.e., divide the value of payments made by the orders received)?*/
