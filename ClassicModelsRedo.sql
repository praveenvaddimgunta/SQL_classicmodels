/*SINGLE ENTITY*/ /*12*/ 
SELECT COUNT(productCode) AS NumberOfProductsToSell
FROM products;

/*15*/ 
SELECT orderNumber,
       SUM(quantityOrdered*priceEach) AS orderValue
FROM orderDetails
GROUP BY orderNumber
HAVING SUM(quantityOrdered*priceEach) > 5000;

/*ONE TO MANY */ /*4*/ 
SELECT productName
FROM products
WHERE productCode NOT IN (SELECT productCode FROM orderdetails);

/*5*/ 
SELECT c.customerName,
       SUM(p.amount) AS amountPaid
FROM customers c
  JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName
ORDER BY c.customerName;

/*8*/ 
SELECT c.customerName,
       SUM(amount) AS totalAmount
FROM customers c
  JOIN payments p ON c.customerNumber = p.customerNumber
WHERE (p.amount) > 100000
GROUP BY c.customerName;

/*9*/ 
SELECT COUNT(*) AS NumberOfOrderdsOnHold
FROM customers c
  JOIN orders o ON c.customerNumber = o.customerNumber
WHERE o.status = 'On Hold';

/*MANY TO MANY*/ /*3*/ 
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

/*General Queries*/ /*6*/ 
SELECT c.customerName,
       AVG(TO_DATE(o.shippeddate) - TO_DATE(o.orderDate)) AS AverageDelayindays,
       ROUND(AVG(TO_DATE(o.shippeddate) - TO_DATE(o.orderDate))*24) AS averageDelayinHours
FROM customers c
  JOIN orders o ON c.customernumber = o.customernumber
GROUP BY customerName
ORDER BY AverageDelayIndays DESC;

/*9*/ 
SELECT (e3.firstName|| ' ' ||e3.lastName) AS employeeName,
       e3.reportsTo
FROM employees e1
  JOIN employees e2 ON e1.reportsTo = e2.employeeNumber
  JOIN employees e3 ON e1.employeeNumber = e3.reportsTo
WHERE e1.reportsTo IN (SELECT employeeNumber
                       FROM employees
                       WHERE (firstName|| ' ' ||lastname) = 'Diane Murphy');

/*15*/ 
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

/*19*/ 
SELECT c.customerName,
       SUM(od.quantityOrdered*od.priceEach) AS revenue,
       (SELECT totalRevenue
        FROM (SELECT SUM(quantityOrdered*priceEach) AS totalRevenue
              FROM orderdetails)) AS totalRevenue,
       (SUM(od.quantityOrdered*od.priceEach)*100) /(SELECT totalRevenue
                                                    FROM (SELECT SUM(quantityOrdered*priceEach) AS totalRevenue
                                                          FROM orderdetails))
AS percentageOfTotalRevenue
FROM customers c
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerName
ORDER BY c.customerName;

/*21*/ 
CREATE OR REPLACE VIEW salesRepProfit 
AS
SELECT (e.firstname|| ' ' ||e.lastname) AS SalesRepName,
       c.customerName,
       p.productline,
       o.orderdate,
       od.quantityOrdered,
       od.priceEach,
       (od.quantityOrdered*od.priceEach) AS revenue,
       (p.buyPrice*od.quantityOrdered) AS investment,
       ((od.quantityOrdered*od.priceEach) -(p.buyPrice*od.quantityOrdered)) AS profit
FROM employees e
  JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  JOIN products p ON od.productCode = p.productCode;

SELECT SalesRepName,
       productline,
       EXTRACT(year FROM orderdate),
       EXTRACT(month FROM orderdate),
       SUM(revenue) AS totalRevenue
FROM salesrepprofit
GROUP BY SalesRepName,
         productline,
         EXTRACT(year FROM orderdate),
         EXTRACT(month FROM orderdate);

/*15 using OLAP*/ 
SELECT EXTRACT(year FROM paymentdate) year,
       EXTRACT(month FROM paymentdate) month,
       SUM(amount) total,
       LEAD(SUM(amount),12) OVER (ORDER BY EXTRACT(year FROM paymentdate),EXTRACT(month FROM paymentdate)) AS year2004
FROM payments
GROUP BY EXTRACT(year FROM paymentdate),
         EXTRACT(month FROM paymentdate)
HAVING EXTRACT(year FROM paymentdate) IN (2003,2004)
ORDER BY EXTRACT(year FROM paymentdate),
         EXTRACT(month FROM paymentdate);

/*coreeelated Queries*/ /*2.*/ 
SELECT checknumber,
       amount,
       TO_CHAR(paymentdate,'yyyy-mm-dd') pay_date,
       2 *AVG(amount) OVER (PARTITION BY EXTRACT(month FROM paymentdate)) AS month_avg,
       2 *AVG(amount) OVER (PARTITION BY EXTRACT(year FROM paymentdate)) AS year_avg
FROM payments where amount>50000
ORDER BY EXTRACT(year FROM paymentdate),
         EXTRACT(month FROM paymentdate);

select customerNumber, paymentDate, amount
		from payments 
		where year(paymentDate)=year and monthname(paymentDate) like month and amount > 2*(select avg(amount)
		from payments where year(paymentDate)=year and monthname(paymentDate) =);


SELECT d.monthname,
       dor.orderperday,
       dp.paymentperday,
FROM (SELECT monthname
      FROM daywiseorders
      UNION
      SELECT monthname
      FROM daywisepayments) d
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
                   

SELECT p.customernumber,
       c.customername,
       SUM(amount) as revenue,v1.total_payments,
       100 *(SUM(amount) / v1.total_payments) AS percentage
FROM payments p
  JOIN customers c ON c.customernumber = p.customernumber, (SELECT SUM(amount) AS total_payments FROM payments) v1
GROUP BY p.customernumber,
         c.customername,
         v1.total_payments
ORDER BY c.customername;


/*20 Compute the profit generated by each customer based on their orders. Also, show each customer's profit as a percentage of total profit. Sort by profit descending*/
SELECT customername,
       numberoforders,
       profit,
       SUM(profit) OVER () AS totalprofit,
       (profit*100) /(SUM(profit) OVER ()) AS percentage
FROM (SELECT c.customerName,
             COUNT(DISTINCT o.ordernumber) AS numberoforders,
             ((SUM(od.quantityordered*od.priceeach)) -(SUM(od.quantityordered*p.buyprice))) AS profit
      FROM customers c join orders o on c.customernumber=o.customernumber
        JOIN orderdetails od ON o.ordernumber = od.ordernumber
        JOIN products p ON od.productcode = p.productcode
      GROUP BY c.customerName
      ORDER BY c.customername)
  order by percentage desc;
