/*Single Entity*/ /*1. Prepare a list of offices sorted by country, state, city.*/ 
SELECT *
FROM offices
ORDER BY country,
         state,
         city;

/*2. How many employees are there in the company?*/ 
SELECT COUNT(*) AS numberofEmployees
FROM employees;

/*3. What is the total of payments received?*/ 
SELECT SUM(amount) totalPayments
FROM payments;

/*4 List the product lines that contain 'Cars'.*/ 
SELECT productLine
FROM productlines
WHERE productLine LIKE '%Cars';

/*5Report total payments for October 28, 2004.*/ 
SELECT SUM(amount) AS totalpayments
FROM payments
WHERE TO_CHAR(paymentDate,'yyyy-mm-dd') = '2004-10-28';

/*6 Report those payments greater than $100,000*/ 
SELECT *
FROM payments
WHERE amount > 100000;

/*7 List the products in each product line*/ 
SELECT productName,
       productLine
FROM products
ORDER BY productLine;

/*8 How many products in each product line*/ 
SELECT productLine,
       COUNT(*) AS totalProducts
FROM products
GROUP BY productLine;

/*9 What is the minimum payment received*/ 
SELECT customerNumber,
       amount
FROM payments
WHERE amount IN (SELECT MIN(amount) FROM payments);

/*10. List all payments greater than twice the average payment*/ 
SELECT customerNumber,
       amount
FROM payments
WHERE amount > 2*(SELECT AVG(amount) FROM payments);

/*11. What is the average percentage markup of the MSRP on buyPrice?*/ 
SELECT AVG((MSRP - buyPrice)*100 / buyPrice) AS averagepercentagemarkup
FROM products;

/*12. How many distinct products does ClassicModels sell*/ 
SELECT COUNT(DISTINCT productCode) AS NumberOfProductsSold
FROM orderdetails;

/*13. Report the name and city of customers who don't have sales representatives*/ 
SELECT customerName,
       city
FROM customers
WHERE salesRepEmployeeNumber IS NULL;

/*14. What are the names of executives with VP or Manager in their title? Use the CONCAT function to combine the employee's first name and last name into a single field for reporting*/ 
SELECT (firstName|| ' ' ||lastName) AS fullname
FROM employees
WHERE jobTitle LIKE 'VP%'
OR    jobTitle LIKE '%Manager%';

SELECT *
FROM employees;

/*15. Which orders have a value greater than $5,000*/ 
SELECT orderNumber,
       SUM(quantityOrdered*priceEach) AS orderValue
FROM orderDetails
GROUP BY orderNumber
HAVING SUM(quantityOrdered*priceEach) > 5000;

/*ONE TO MANY RELATIONSHIPS*/ /*1. Report the account representative for each customer*/ 
SELECT c.customerName,
       (e.firstname|| ' ' ||e.lastname) AS accountrepresentative
FROM customers c
  JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber;

/*2. Report total payments for Atelier graphique*/ 
SELECT c.customername,
       SUM(p.amount)
FROM customers c
  JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
HAVING c.customerName = 'Atelier graphique';

/*3. Report the total payments by date*/ 
SELECT paymentDate,
       SUM(amount)
FROM payments
GROUP BY paymentDate;

/*4 Report the products that have not been sold.*/ 
SELECT productName
FROM products
WHERE productCode NOT IN (SELECT productCode FROM orderdetails);

/*5 List the amount paid by each customer*/ 
SELECT c.customerName,
       SUM(p.amount) AS amountPaid
FROM customers c
  JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY c.customerName;

/*6 How many orders have been placed by Herkku Gifts?*/ 
SELECT c.customerName,
       COUNT(*) AS orders
FROM customers c
  JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.customerName
HAVING c.customerName = 'Herkku Gifts';

/*7 Who are the employees in Boston?*/ 
SELECT (e.firstname|| ' ' ||e.lastname) AS employeesinboston
FROM employees e
  JOIN offices o ON e.officeCode = o.officecode
WHERE o.city = 'Boston';

/*8 Report those payments greater than $100,000. Sort the report so the customer who made the highest payment appears first.*/ 
SELECT c.customerName,
       SUM(amount) AS totalAmount
FROM customers c
  JOIN payments p ON c.customerNumber = p.customerNumber
WHERE (p.amount) > 100000
GROUP BY c.customerName;

/*9 List the value of 'On Hold' orders.*/ 
SELECT SUM(od.quantityOrdered*od.PriceEach) AS totalvalueofonholdorders
FROM customers c
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.ordernumber = od.ordernumber
WHERE o.status = 'On Hold';

/*10 Report the number of orders 'On Hold' for each customer.*/ 
SELECT c.customerName,
       COUNT(o.status) OVER (PARTITION BY c.customerName ORDER BY c.customerName) AS Numberofordersonhold
FROM customers c
  JOIN orders o ON c.customerNumber = o.customerNumber
WHERE o.status = 'On Hold';

/*MANY TO MANY RELATIONSHIP*/ /*1. List products sold by order date*/ 
SELECT p.productName,
       o.orderDate
FROM products p
  JOIN orderdetails od ON p.productCode = od.productCode
  JOIN orders o ON od.orderNumber = o.orderNumber
ORDER BY o.orderdate;

/*2 List the names of customers and the corresponding order numbers where a particular order from that customer has a value greater than $25,000?*/ 
SELECT o.orderNumber
FROM orders o
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  JOIN products p ON od.productCode = p.productCode
WHERE p.productName LIKE '1940 Ford Pickup Truck';

/*3 List the names of customers and the corresponding order numbers where a particular order from that customer has a value greater than $25,000*/ 
SELECT cd.customerName,
       tvo.orderNumber,
       tvo.totalorderedValue
FROM (SELECT orderNumber,
             SUM(quantityOrdered*priceEach) AS totalorderedValue
      FROM orderdetails
      GROUP BY ordernumber
      ORDER BY orderNumber) tvo
  JOIN (SELECT c.customerName,
               o.orderNumber
        FROM customers c
          JOIN orders o ON c.customerNumber = o.customerNumber
        ORDER BY orderNumber) cd ON tvo.orderNumber = cd.orderNumber
WHERE tvo.totalorderedValue > 25000
ORDER BY cd.customerName;

/*4 Are there any products that appear on all orders?*/ 
CREATE OR REPLACE VIEW orderCount 
AS
SELECT p.productname,
       COUNT(o.ordernumber) AS numberoforders
FROM products p
  JOIN orderdetails od ON p.productCode = od.productcode
  JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY p.productname;

CREATE OR REPLACE VIEW totalOrdersTable 
AS
SELECT COUNT(DISTINCT orderNumber) AS totalorders,
       COUNT(DISTINCT customerNumber) AS totalCustomers
FROM orders;

SELECT productname
FROM ordercount
WHERE numberoforders = (SELECT totalorders FROM totalorderstable);

/*5 List those orders containing items sold at less than the MSRP*/ 
SELECT od.orderNumber
FROM orders o
  JOIN orderdetails od ON od.ordernumber = o.ordernumber
  JOIN products p ON p.productcode = od.productcode
WHERE od.priceEach < p.MSRP
GROUP BY od.orderNumber;

/*6 Reports those products that have been sold with a markup of 100% or more (i.e.,  the priceEach is at least twice the buyPrice)*/ 
SELECT p.productName
FROM products p
  JOIN orderdetails od ON od.productCode = p.productCode
WHERE od.priceEach >= 2*(p.buyPrice)
GROUP BY p.productName;

/*7. List the products ordered on a Monday.*/ 
SELECT DISTINCT p.productName,
       (TO_CHAR(orderdate,'day')) AS orderday
FROM products p
  JOIN orderdetails od ON p.productCode = od.productCode
  JOIN orders o ON o.orderNumber = od.orderNumber
WHERE (TO_CHAR(orderdate,'d')) = 2;

/*8. What is the quantity on hand for products listed on 'On Hold' orders*/ 
SELECT p.productName,
       p.quantityInStock
FROM products p
  JOIN orderDetails od ON od.productCode = p.productCode
  JOIN orders o ON o.orderNumber = od.orderNumber
WHERE o.status = 'On Hold';

/*REGULAR EXPRESSIONS*/ /*1 Find products containing the name 'Ford'*/ 
SELECT productName
FROM products
WHERE REGEXP_LIKE (productName,'Ford');

/*2. List products ending in 'ship'*/ 
SELECT productName
FROM products
WHERE REGEXP_LIKE (productName,'Ship$');

/*3 Report the number of customers in Denmark, Norway, and Sweden*/ 
SELECT COUNT(customerName) AS numberofcustomers
FROM customers
WHERE REGEXP_LIKE (country,'(Denmark|Sweden|Norway)');

/*4 What are the products with a product code in the range S700_1000 to S700_1499?*/ 
SELECT productName,
       productCode
FROM products
WHERE REGEXP_LIKE (productCode,'S700_1[0-4][0-9][0-9]');

/*5 Which customers have a digit in their name*/ 
SELECT customerName
FROM customers
WHERE REGEXP_LIKE (customerName,'.[0-9]');

/*6 List the names of employees called Dianne or Diane*/ 
SELECT (firstName|| ' ' ||lastName) AS employeeName
FROM employees
WHERE REGEXP_LIKE ((firstName||lastName),'(Diane|Dianne)');

/*7 List the products containing ship or boat in their product name*/ 
SELECT productName
FROM products
WHERE REGEXP_LIKE (productName,'(Ship|Boat)');

/*8 List the products with a product code beginning with S700*/ 
SELECT productName,
       productCode
FROM products
WHERE REGEXP_LIKE (productCode,'^(S700)');

/*9 List the names of employees called Larry or Barry*/ 
SELECT (firstName|| ' ' ||lastName) AS employeeNameorders
FROM employees
WHERE REGEXP_LIKE ((firstName|| ' ' ||lastName),'(Larry|Barry)');

/*10 List the names of employees with non-alphabetic characters in their names*/ 
SELECT (firstName|| ' ' ||lastName) AS employeeName
FROM employees
WHERE REGEXP_LIKE ((firstName|| ' ' ||lastName),'[^a-zA-Z *]');

/*11 List the vendors whose name ends in Diecast*/ 
SELECT productVendor
FROM products
WHERE REGEXP_LIKE (productVendor,'(Diecast)$');

/*GENERAL QUERIES*/ /*1 Who is at the top of the organization (i.e.,  reports to no one).*/ 
SELECT (firstName|| ' ' ||lastName) AS employeeName
FROM employees
WHERE reportsTo IS NULL;

/*2 Who reports to William Patterson*/ 
SELECT (firstName|| ' ' ||lastName)
FROM employees
WHERE reportsTo = (SELECT employeeNumber
                   FROM employees
                   WHERE (firstName|| ' ' ||lastName) = 'William Patterson');

/*3 List all the products purchased by Herkku Gifts*/ 
SELECT p.productName
FROM products p
  JOIN orderdetails od ON p.productCode = od.productCode
  JOIN orders o ON od.orderNumber = o.orderNumber
  JOIN customers c ON o.customerNumber = c.customerNumber
WHERE c.customerName = 'Herkku Gifts';

/*4 Compute the commission for each sales representative, assuming the commission is 5% of the value of an order. Sort by employee last name and first name*/ 
SELECT (e.firstName|| ' ' || e.lastName) AS salesRepresentative,
       SUM(0.05*(od.quantityOrdered*od.PriceEach)) AS commision
FROM employees e
  JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY lastName,
         firstName;

/*5 What is the difference in days between the most recent and oldest order date in the Orders file*/ 
SELECT MAX(orderDate) -MIN(orderDate) AS differenceindays
FROM orders;

/*6 Compute the average time between order date and ship date for each customer ordered by the largest difference*/ 
SELECT c.customerName,
       AVG(TO_DATE(o.shippeddate) - TO_DATE(o.orderDate)) AS AverageDelayindays,
       ROUND(AVG(TO_DATE(o.shippeddate) - TO_DATE(o.orderDate))*24) AS averageDelayinHours
FROM customers c
  JOIN orders o ON c.customernumber = o.customernumber
GROUP BY customerName
ORDER BY AverageDelayIndays DESC;

/*7 What is the value of orders shipped in August 2004*/ 
SELECT SUM(od.quantityOrdered*od.priceEach) AS ordersshippedinAugust2004
FROM orderdetails od
  JOIN orders o ON od.orderNumber = o.orderNumber
WHERE EXTRACT(month FROM shippedDate) = '8'
AND   EXTRACT(year FROM shippedDate) = '2004';

/*8 Compute the total value ordered, total amount paid, and their difference for each customer for orders placed in 2004 and payments received in 2004 (Hint; Create views for the total paid and total ordered).*/ 
CREATE OR REPLACE VIEW totalPaidByCustomer 
AS
SELECT c.customerName,
       SUM(p.amount) AS totalPaid
FROM payments p
  JOIN customers c ON p.customerNumber = c.customerNumber
WHERE EXTRACT(year FROM p.paymentdate) = '2004'
GROUP BY c.customerName;

CREATE OR REPLACE VIEW totalOrderedByCustomer 
AS
SELECT c.customerName,
       SUM(od.quantityOrdered*od.priceEach) AS totalOrdered
FROM orderdetails od
  JOIN orders o ON od.orderNumber = o.orderNumber
  JOIN customers c ON o.customerNumber = c.customerNumber
WHERE EXTRACT(year FROM o.orderDate) = '2004'
GROUP BY c.customerName;

SELECT p.customerName,
       o.totalOrdered,
       p.totalPaid,
       ROUND(o.totalOrdered - p.totalPaid,0) AS difference
FROM totalpaidbycustomer p
  JOIN totalorderedbycustomer o ON p.customerName = o.customerName;

/*9 List the employees who report to those employees who report to Diane Murphy. Use the CONCAT function to combine the employee's first name and last name into a single field for reporting*/ 
SELECT (e3.firstName|| ' ' ||e3.lastName) AS employeeName,
       (e1.firstName|| ' ' ||e1.lastName) AS reportingManager,
       (e2.firstName|| ' ' ||e2.lastName) AS ReportingmanagerReportsto
FROM employees e1
  JOIN employees e2 ON e1.reportsTo = e2.employeeNumber
  JOIN employees e3 ON e1.employeeNumber = e3.reportsTo
WHERE e1.reportsTo IN (SELECT employeeNumber
                       FROM employees
                       WHERE (firstName|| ' ' ||lastname) = 'Diane Murphy');

/*10 What is the percentage value of each product in inventory sorted by the highest percentage first (Hint: Create a view first)*/ 
CREATE OR REPLACE VIEW totalStock 
AS
SELECT SUM(quantityInStock) AS totalQuantity
FROM products;

SELECT productName,
       (quantityInStock*100) /(SELECT totalQuantity FROM totalStock)
AS percentagevalue
FROM products
ORDER BY 2 DESC;

--using olap
SELECT productName,
       SUM(quantityinstock) OVER (PARTITION BY productcode) AS productQuantity,
       SUM(quantityinstock) OVER () AS totalQuantity,
       ((SUM(quantityinstock) OVER (PARTITION BY productcode)) /(SUM(quantityinstock) OVER ()))*100 AS percentage
FROM products
ORDER BY percentage DESC;

/*11 Write a function to convert miles per gallon to liters per 100 kilometers.*/ 
CREATE OR REPLACE FUNCTION litresper100km (input IN NUMBER) RETURN NUMBER IS output NUMBER;

BEGIN output: = 235.215 /input;

RETURN output;

END;
/

SELECT litresper100Km(3)
FROM dual;

/*12. Write a procedure to increase the price of a specified product category by a given percentage. You will need to create a product table with appropriate data to test your procedure. Alternatively, load the ClassicModels database on your personal machine so you have complete access. You have to change the DELIMITER prior to creating the procedure*/ 
CREATE OR REPLACE PROCEDURE priceHike (productcategory IN VARCHAR2,hike IN NUMBER);

BEGIN UPDATE productstest
   SET MSRP = MSRP*(1 +(hike) / 100)
WHERE productLine = ProductCategory;

END;

BEGIN priceHike ('motorcylces',5);

END;
/

SELECT *
FROM productstest;

/*13What is the value of orders shipped in August 2004?*/ 
SELECT TO_CHAR(o.shippeddate,'Month yyyy') AS shippedMonth,
       SUM(od.quantityOrdered*od.priceEach) AS totalvalue
FROM orders o
  JOIN orderdetails od ON o.ordernumber = od.ordernumber
WHERE TO_CHAR(o.shippeddate,'Month YYYY') = 'August    2004'
GROUP BY TO_CHAR(o.shippeddate,'Month yyyy');

/*14What is the ratio the value of payments made to orders received for each month of 2004. (i.e., divide the value of payments made by the orders received)?*/ 
SELECT p2004.monthname,
       p2004.paymentpermonth,
       o2004.orderpermonth,
       (p2004.paymentpermonth / o2004.orderpermonth) AS ratio
FROM (SELECT TO_CHAR(paymentdate,'month') AS monthname,
             SUM(amount) AS paymentpermonth
      FROM payments
      WHERE EXTRACT(YEAR FROM paymentDate) = '2004'
      GROUP BY TO_CHAR(paymentdate,'month')
      ORDER BY 1) p2004
  JOIN (SELECT TO_CHAR(o.orderdate,'month') AS monthname,
               SUM(quantityOrdered*priceeach) AS orderpermonth
        FROM orderdetails od
          JOIN orders o ON od.ordernumber = o.ordernumber
        WHERE EXTRACT(YEAR FROM o.orderDate) = '2004'
        GROUP BY TO_CHAR(o.orderdate,'month')
        ORDER BY 1) o2004 ON p2004.monthname = o2004.monthname;

--datwise 
SELECT d.monthname,
       dor.orderperday,
       dp.paymentperday,
       (dp.paymentperday / dor.orderperday) AS ratio
FROM (SELECT TO_CHAR(paymentdate,'month-dd') AS monthname
      FROM payments
      WHERE EXTRACT(YEAR FROM paymentdate) = 2004
      UNION
      SELECT TO_CHAR(orderdate,'month-dd') AS monthname
      FROM orders
      WHERE EXTRACT(YEAR FROM orderdate) = 2004) d
  FULL OUTER JOIN (SELECT TO_CHAR(o.orderdate,'month-dd') AS monthname,
                          SUM(quantityOrdered*priceeach) AS orderperday
                   FROM orderdetails od
                     JOIN orders o ON od.ordernumber = o.ordernumber
                   WHERE EXTRACT(YEAR FROM o.orderDate) = '2004'
                   GROUP BY TO_CHAR(o.orderdate,'month-dd')
                   ORDER BY 1) dor ON d.monthname = dor.monthname
  FULL OUTER JOIN (SELECT TO_CHAR(paymentdate,'month-dd') AS monthname,
                          SUM(amount) AS paymentperday
                   FROM payments
                   WHERE EXTRACT(YEAR FROM paymentDate) = '2004'
                   GROUP BY TO_CHAR(paymentdate,'month-dd')
                   ORDER BY 1) dp ON d.monthname = dp.monthname;

--testing
SELECT SUM(amount)
FROM payments
WHERE TO_CHAR(paymentdate,'month') || '-' ||extract(year FROM paymentDate) = 'april    -2004';

SELECT SUM(quantityOrdered*priceeach)
FROM orderdetails od
  JOIN orders o ON od.ordernumber = o.ordernumber
WHERE TO_CHAR(o.orderdate,'month') || '-' ||extract(year FROM o.orderDate) = 'april    -2004';

/*15 What is the difference in the amount received for each month of 2004 compared to 2003?*/ 
SELECT p3.month,
       p4.amountReceviedIn2004,
       p3.amountReceviedIn2003,
       (p4.amountReceviedin2004 - p3.amountReceviedIn2003) AS difference
FROM (SELECT EXTRACT(MONTH FROM paymentDate) AS MONTH,
             SUM(amount) amountReceviedIn2003
      FROM payments
      WHERE EXTRACT(YEAR FROM paymentDate) = '2003'
      GROUP BY EXTRACT(MONTH FROM paymentDate)) p3
  JOIN (SELECT EXTRACT(MONTH FROM paymentDate) AS MONTH,
               SUM(amount) AS amountReceviedIn2004
        FROM payments
        WHERE EXTRACT(YEAR FROM paymentDate) = '2004'
        GROUP BY EXTRACT(MONTH FROM paymentDate)) p4 ON p3.month = p4.month
ORDER BY month;

--using olap
SELECT EXTRACT(year FROM paymentdate) year,
       EXTRACT(month FROM paymentdate) month,
       SUM(amount) total,
       LEAD(SUM(amount),12) OVER (ORDER BY EXTRACT(year FROM paymentdate),EXTRACT(month FROM paymentdate)) AS amountreceviedyear2004
FROM payments
GROUP BY EXTRACT(year FROM paymentdate),
         EXTRACT(month FROM paymentdate)
HAVING EXTRACT(year FROM paymentdate) IN (2003,2004)
ORDER BY EXTRACT(year FROM paymentdate),
         EXTRACT(month FROM paymentdate);

/*16 Write a procedure to report the amount ordered in a specific month and year for customers containing a specified character string in their name.*/ 
CREATE OR REPLACE PROCEDURE totalorders (yearname IN VARCHAR2,monthname IN VARCHAR2,p_orderdate OUT VARCHAR2,p_totalordervalue OUT VARCHAR2)
AS
BEGIN
SELECT TO_CHAR(o.orderdate,'month-yyyy'),
       SUM(od.quantityOrdered*od.PriceEach) INTO p_orderdate,
       p_totalordervalue
FROM orders o
  JOIN orderdetails od ON o.ordernumber = od.ordernumber
GROUP BY TO_CHAR(o.orderdate,'month-yyyy')
HAVING TO_CHAR(o.orderdate,'month-yyyy') = 'january  -2003';

END;
/

DECLARE p_orderdate VARCHAR;

p_totalordervalue VARCHAR;

BEGIN totalorders ('2004','january  ',p_orderdate,p_totalordervalue);

DBMS_OUTPUT.PUT_LINE (p_orderdate || P_totalordervalue);

END;
/

/*18 A common retail analytics task is to analyze each basket or order to learn what products are often purchased together. Report the names of products that appear in the same order ten or more times.*/ 
SELECT *
FROM orders;

/*19 Compute the revenue generated by each customer based on their orders. Also, show each customer's revenue as a percentage of total revenue. Sort by customer name.*/ 
SELECT customername,
       numberoforders,
       revenue,
       SUM(revenue) OVER () AS totalrevenue,
       (revenue*100 / SUM(revenue) OVER ()) AS revenuepercent
FROM (SELECT c.customerName,
             COUNT(DISTINCT o.ordernumber) AS numberoforders,
             SUM(od.quantityordered*od.priceeach) AS revenue
      FROM customers c
        JOIN orders o ON c.customernumber = o.customernumber
        JOIN orderdetails od ON o.ordernumber = od.ordernumber
        JOIN products p ON od.productcode = p.productcode
      GROUP BY c.customerName)
ORDER BY customername;

/*20 Compute the profit generated by each customer based on their orders. Also, show each customer's profit as a percentage of total profit. Sort by profit descending*/ 
SELECT customername,
       numberoforders,
       profit,
       SUM(profit) OVER () AS totalprofit,
       (profit*100) /(SUM(profit) OVER ()) AS profitpercentage
FROM (SELECT c.customerName,
             COUNT(DISTINCT o.ordernumber) AS numberoforders,
             ((SUM(od.quantityordered*od.priceeach)) -(SUM(od.quantityordered*p.buyprice))) AS profit
      FROM customers c
        JOIN orders o ON c.customernumber = o.customernumber
        JOIN orderdetails od ON o.ordernumber = od.ordernumber
        JOIN products p ON od.productcode = p.productcode
      GROUP BY c.customerName
      ORDER BY c.customername)
ORDER BY profitpercentage DESC;

/*21 Compute the revenue generated by each sales representative based on the orders from the customers they serve*/ 
SELECT salesrepName,
       revenue
FROM (SELECT (e.firstname|| ' ' ||e.lastname) AS salesrepName,
             COUNT(DISTINCT o.ordernumber) AS numberoforders,
             SUM(od.quantityordered*od.priceeach) AS revenue
      FROM employees e
        JOIN customers c ON e.employeenumber = c.salesrepemployeenumber
        JOIN orders o ON c.customernumber = o.customernumber
        JOIN orderdetails od ON o.ordernumber = od.ordernumber
        JOIN products p ON od.productcode = p.productcode
      GROUP BY (e.firstname|| ' ' ||e.lastname))
ORDER BY salesrepName;

/*22 Compute the profit generated by each sales representative based on the orders from the customers they serve. Sort by profit generated descending.*/ 
SELECT salesrepName,
       profit
FROM (SELECT (e.firstname|| ' ' ||e.lastname) AS salesrepName,
             COUNT(DISTINCT o.ordernumber) AS numberoforders,
             ((SUM(od.quantityordered*od.priceeach)) -(SUM(od.quantityordered*p.buyprice))) AS profit
      FROM employees e
        JOIN customers c ON e.employeenumber = c.salesrepemployeenumber
        JOIN orders o ON c.customernumber = o.customernumber
        JOIN orderdetails od ON o.ordernumber = od.ordernumber
        JOIN products p ON od.productcode = p.productcode
      GROUP BY (e.firstname|| ' ' ||e.lastname))
ORDER BY profit DESC;

/*23 Compute the revenue generated by each product, sorted by product name*/ 
SELECT p.productName,
       SUM(od.quantityOrdered*od.priceEach) AS revenue
FROM products p
  JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productName
ORDER BY p.productname;

/*24 Compute the profit generated by each product line, sorted by profit descending*/ 
SELECT p.productLine,
       SUM(od.quantityOrdered*od.priceEach) AS revenue,
       SUM(p.buyPrice*od.quantityOrdered) AS investment,
       (SUM(od.quantityOrdered*od.priceEach) - SUM(p.buyPrice*od.quantityOrdered)) AS profit
FROM products p
  JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productLine
ORDER BY p.productline;

/*CORRELATED SUBQUERIES*/ 
/*1 Who reports to Mary Patterson?*/ 
SELECT firstname|| ' ' ||lastname AS employessreporttoMaryPatterson
FROM employees
WHERE reportsTo IN (SELECT employeeNumber
                    FROM employees
                    WHERE (firstname|| ' ' ||lastname) = 'Mary Patterson');

/*2 Which payments in any month and year are more than twice the average for that month and year (i.e. compare all payments in Oct 2004 with the average payment for Oct 2004)? Order the results by the date of the payment. You will need to use the date functions.*/ 
select customerNumber, checknumber, paymentDate, amount
		from payments 
		where extract(year from paymentdate)=2004 and extract(month from paymentdate)=10 and amount > 2*(select avg(amount)
		from payments where extract(year from paymentdate)=2004 and extract(month from paymentdate)=10);
		
/*3*/
