SELECT *
FROM products;

SELECT productline,
       buyprice,
       AVG(buyPrice) OVER (PARTITION BY productLine) AS averagebuyprice
FROM products;

SELECT owner,
       AVG(avg_row_len),
       AVG(avg_space),
       COVAR_POP(avg_row_len,avg_space)
FROM all_tables
GROUP BY owner;

SELECT productline,
       COUNT(productCode)
FROM products
GROUP BY productline;

CREATE OR REPLACE VIEW daywiseorders 
AS
SELECT TO_CHAR(o.orderdate,'month-dd') AS monthname,
       SUM(quantityOrdered*priceeach) AS orderperday
FROM orderdetails od
  JOIN orders o ON od.ordernumber = o.ordernumber
WHERE EXTRACT(YEAR FROM o.orderDate) = '2004'
GROUP BY TO_CHAR(o.orderdate,'month-dd')
ORDER BY 1;

CREATE OR REPLACE VIEW daywisepayments 
AS
SELECT TO_CHAR(paymentdate,'month-dd') AS monthname,
       SUM(amount) AS paymentperday
FROM payments
WHERE EXTRACT(YEAR FROM paymentDate) = '2004'
GROUP BY TO_CHAR(paymentdate,'month-dd')
ORDER BY 1;

SELECT *
FROM daywiseorders;

SELECT *
FROM daywisepayments;

SELECT *
FROM daywiseorders dor
  FULL OUTER JOIN daywisepayments dp ON dor.monthname = dp.monthname;

CREATE OR REPLACE VIEW dates 
AS
SELECT monthname
FROM daywiseorders
UNION
SELECT monthname
FROM daywisepayments;

SELECT productline,
       buyPrice,
       RANK() OVER (ORDER BY buyPrice ASC) AS RANK
FROM products;

SELECT productline,
       buyPrice,
       DENSE_RANK() OVER (ORDER BY buyPrice ASC) AS RANK
FROM products;

SELECT productName,
       productLine,
       FIRST_VALUE(buyPrice) OVER (PARTITION BY productLine ORDER BY buyprice DESC) AS "lowest"
FROM products;

SELECT productName,
       productline,
       FIRST_VALUE(buyPrice) OVER (ORDER BY buyprice ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following) AS "HIGHEST"
FROM products;

SELECT LISTAGG(productName,'---') WITHIN GROUP (ORDER BY productLine) AS list
FROM products;

SELECT productname,
       productLine,
       nth_value(buyPrice,2) OVER (PARTITION BY productline ORDER BY buyprice DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED following) AS "second highest"
FROM products;

SELECT productName,
       buyPrice,
       LAG(buyPrice,2) OVER (PARTITION BY productline ORDER BY buyPrice) AS lagBuyPrice
FROM products;

SELECT productName,
       buyPrice,
       LEAD(buyPrice,2) OVER (PARTITION BY productline ORDER BY buyPrice) AS leadBuyPrice
FROM products;

SELECT *
FROM orderdetails;

SELECT LISTAGG(productCode,',') WITHIN GROUP (ORDER BY OrderNumber) AS list
FROM orderdetails
WHERE ROWNUM < 20;

SELECT od.ordernumber,
       SUM(od.priceeach*od.quantityordered) OVER (PARTITION BY od.ordernumber ORDER BY od.ordernumber)
FROM orders o
  JOIN orderdetails od ON o.ordernumber = od.ordernumber
WHERE o.status = 'On Hold';

SELECT productname,
       productline,
       SUM(buyPrice) AS price
FROM products
GROUP BY productName,
         productline
ORDER BY 2;

SELECT EXTRACT(year FROM orderdate) AS year
FROM orders
GROUP BY EXTRACT(year FROM orderdate)
ORDER BY 1;

SELECT productline,
       COUNT(productline)
FROM products
GROUP BY productline;

SELECT *
FROM products;

SELECT TO_CHAR(paymentdate,'month-dd')
FROM payments
WHERE EXTRACT(year FROM paymentdate) = 2004
UNION
SELECT TO_CHAR(orderdate,'month-dd')
FROM orders;

CREATE TABLE productsinfo 
(
  productCode          VARCHAR(15) NOT NULL,
  productName          VARCHAR(70) NOT NULL,
  productLine          VARCHAR(50) NOT NULL,
  productScale         VARCHAR(10) NOT NULL,
  productVendor        VARCHAR(50) NOT NULL,
  productDescription   VARCHAR(500) NOT NULL,
  quantityInStock      NUMBER(6) NOT NULL,
  buyPrice             BINARY_DOUBLE NOT NULL,
  MSRP                 BINARY_DOUBLE NOT NULL,
  PRIMARY KEY (productCode)
);

INSERT INTO productsinfo
SELECT *
FROM products;

WHERE EXTRACT(year FROM orderdate) = 2004;

SELECT *
FROM products;

SELECT *
FROM salesrepprofit;

SELECT (e.firstname|| ' ' ||e.lastname) AS salesrepname,
       c.customername,
       p.productline,
       o.orderdate,
       od.quantityordered,
       od.priceeach,
       od.quantityordered*od.priceeach AS revenue,
       od.quantityordered*p.buyprice AS investment,
       (od.quantityordered*od.priceeach) -(od.quantityordered*p.buyprice) AS profit
FROM employees e
  JOIN customers c ON e.employeenumber = c.salesrepemployeenumber
  JOIN orders o ON c.customernumber = o.customernumber
  JOIN orderdetails od ON o.ordernumber = od.ordernumber
  JOIN products p ON od.productcode = p.productcode;
  
select * from products;

with p as (select 1  n from dual) select * from p;
