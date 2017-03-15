/*1*/ 
SELECT productLine,
       productName,
       ProductVendor,
       QuantityInStock,
       CASE
         WHEN QuantityInstock < 10 THEN 'YES'
         WHEN QuantityInstock >= 10 THEN 'NO'
       END AS tobeProcured
FROM products;

SELECT productLine,
       productName,
       ProductVendor,
       QuantityInStock,
       decode(SIGN(100-QuantityInstock),
             1,'yes',
             'no'
       ) AS tobeprocured
FROM products;

/*2*/ 
CREATE OR REPLACE VIEW reportInSameLocationView 
AS
SELECT (e1.firstName|| ' ' ||e1.lastName) AS ManagerFullName,
       COUNT(e2.reportsTo) AS ReportInSameLocation
FROM employees e1
  JOIN employees e2 ON e1.employeeNumber = e2.reportsTo
WHERE e1.officeCode = e2.officeCode
AND   e1.jobtitle LIKE '%Manager%'
GROUP BY e1.firstName|| ' ' ||e1.lastName;

CREATE OR REPLACE VIEW reportInDifferentLocationView 
AS
SELECT (e1.firstName|| ' ' ||e1.lastName) AS ManagerFullName,
       COUNT(e2.reportsTo) AS ReportIndifferentLocation
FROM employees e1
  JOIN employees e2 ON e1.employeeNumber = e2.reportsTo
WHERE e1.officeCode != e2.officeCode
AND   e1.jobtitle LIKE '%Manager%'
GROUP BY e1.firstName|| ' ' ||e1.lastName;

SELECT *
FROM employees;

SELECT v1.ManagerFullName,
       v1.ReportInsamelocation,
       v2.reportInDifferentLocation
FROM reportInSameLocationView v1
  FULL OUTER JOIN reportInDifferentLocationView v2 ON v1.ManagerFullName = v2.ManagerFullName;

/*3*/ 
CREATE OR REPLACE VIEW productSoldInYear 
AS;

SELECT p.productName,
       EXTRACT(year FROM o.orderDate) || '-' ||extract(month FROM o.orderDate) AS orderYear
FROM products p
  JOIN orderdetails od ON p.productCode = od.productCode
  JOIN orders o ON od.orderNumber = o.orderNumber;

CREATE OR REPLACE VIEW productSoldInYearStatus 
AS;

SELECT DISTINCT productName,
       orderYear,
       CASE
         WHEN orderYear = '2005-1' THEN 'YES'
         ELSE 'NO'
       END AS soldin2005,
       CASE
         WHEN orderYear = '2004-1' THEN 'YES'
         ELSE 'NO'
       END AS soldin2004
FROM productsoldinyear;

SELECT *
FROM productSoldInyearStatus
WHERE soldIn2005 NOT IN (SELECT soldin2004 FROM productSoldInyearStatus);

/*4*/ 
CREATE OR REPLACE VIEW currentMonthTotalsalesView 
AS
SELECT (EXTRACT(year FROM o.orderdate) || '-' ||extract (month FROM o.orderdate)) AS MonthDate,
       SUM(od.quantityOrdered*od.priceEach) AS currentMonthTotalSales
FROM employees e
  JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY (EXTRACT(year FROM o.orderdate) || '-' ||extract (month FROM o.orderdate));

CREATE OR REPLACE VIEW currentMonthSalesView 
AS
SELECT c.salesrepEmployeeNumber,
       (EXTRACT(year FROM o.orderdate) || '-' ||extract(month FROM o.orderdate)) AS MonthDate,
       (od.quantityordered*od.priceeach) AS salesInMonth
FROM employees e
  JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
ORDER BY c.salesrepemployeeNumber;

CREATE OR REPLACE VIEW view1 
AS
SELECT salesrepemployeeNumber,
       monthdate,
       salesInmonth,
       SUM(salesinmonth) OVER (PARTITION BY salesrepemployeeNumber ORDER BY monthdate) AS currentMonthSalesBySalesRep,
       SUM(salesInmonth) OVER (ORDER BY monthdate) AS currentMonthTotalSales
FROM currentMonthSalesView
ORDER BY salesrepemployeeNumber;

SELECT DISTINCT v1.monthdate,
       e.firstName,
       v1.salesrepemployeeNumber,
       v1.currentMonthSalesBySalesRep,
       v1.currentMonthTotalSales,
       LAG(v1.currentMonthSalesBySalesRep,1) OVER (PARTITION BY v1.salesrepemployeenumber ORDER BY v1.monthdate) AS previouMonthSalesBySalesRep
FROM view1 v1
  JOIN employees e ON v1.salesrepemployeeNumber = e.employeenumber
ORDER BY v1.salesrepemployeeNumber;

/*5*/ 
CREATE OR REPLACE VIEW ProductsInOrderView 
AS
SELECT o.orderdate,
       o.orderNumber,
       p.productName,
       od.quantityOrdered,
       od.priceEach,
       COUNT(p.productName) OVER (PARTITION BY o.orderNumber ORDER BY o.orderDate) AS NumberOfProductsInOrder
FROM orders o
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  JOIN products p ON od.productCode = p.productCode
ORDER BY o.orderdate;

SELECT orderDate,
       numberofproductsinorder,
       COUNT(NumberOfProductsInOrder) OVER (PARTITION BY orderdate ORDER BY NumberOfProductsInOrder) AS CountOfOrders,
       SUM(quantityOrdered*PriceEach) OVER (PARTITION BY orderdate ORDER BY NumberOfProductsInOrder) AS tOtalOrderAmount
FROM (SELECT o.orderdate,
             o.orderNumber,
             p.productName,
             od.quantityOrdered,
             od.priceEach,
             COUNT(p.productName) OVER (PARTITION BY o.orderNumber ORDER BY o.orderDate) AS NumberOfProductsInOrder
      FROM orders o
        JOIN orderdetails od ON o.orderNumber = od.orderNumber
        JOIN products p ON od.productCode = p.productCode
      ORDER BY o.orderdate)
ORDER BY orderDate,
         NumberofproductsInOrder;

