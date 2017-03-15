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

/*2*/ 
SELECT v1.ManagerFullName,
       v1.ReportIn,
       v2.reportInDifferentLocation
FROM (SELECT (e1.firstName|| ' ' ||e1.lastName) AS ManagerFullName,
             COUNT(e2.reportsTo) AS ReportIn
      FROM employees e1
        JOIN employees e2 ON e1.employeeNumber = e2.reportsTo
      GROUP BY e1.firstName|| ' ' ||e1.lastName) v1
  FULL OUTER JOIN (SELECT (e1.firstName|| ' ' ||e1.lastName) AS ManagerFullName,
                          COUNT(e2.reportsTo) AS ReportIndifferentLocation
                   FROM employees e1
                     JOIN employees e2 ON e1.employeeNumber = e2.reportsTo
                   WHERE e1.officeCode != e2.officeCode
                   GROUP BY e1.firstName|| ' ' ||e1.lastName) v2 ON v1.ManagerFullName = v2.ManagerFullName;

--second method
SELECT (e1.firstName|| ' ' ||e1.lastName) AS ManagerFullName,
       COUNT(e2.reportsto) AS ReportIn,
       COUNT(CASE WHEN e1.officecode <> e2.officecode THEN e2.reportsto END) AS reportindifferentlocation
FROM employees e1
  JOIN employees e2 ON e1.employeeNumber = e2.reportsTo
GROUP BY (e1.firstName|| ' ' ||e1.lastName);

/*3*/ 
SELECT productname,
       soldin2004notin2005,
       soldin2005notin2004
FROM (SELECT DISTINCT p.productname,
             CASE soldin2004
               WHEN 'YES' THEN 'YES'
               ELSE 'NO'
             END AS soldin2004notin2005,
             CASE soldin2005
               WHEN 'YES' THEN 'YES'
               ELSE 'NO'
             END AS soldin2005notin2004
      FROM products p
        FULL OUTER JOIN (SELECT p.productName,
                                TO_CHAR(o.orderdate,'mm-yyyy') AS orderyear,
                                'YES' AS soldin2004
                         FROM products p
                           JOIN orderdetails od ON p.productCode = od.productCode
                           JOIN orders o ON od.orderNumber = o.orderNumber
                         WHERE TO_CHAR(o.orderdate,'mm-yyyy') = '03-2004') v1 ON p.productname = v1.productname
        FULL OUTER JOIN (SELECT p.productName,
                                TO_CHAR(o.orderdate,'mm-yyyy') AS orderyear,
                                'YES' AS soldin2005
                         FROM products p
                           JOIN orderdetails od ON p.productCode = od.productCode
                           JOIN orders o ON od.orderNumber = o.orderNumber
                         WHERE TO_CHAR(o.orderdate,'mm-yyyy') = '03-2005') v2 ON p.productname = v2.productname)
WHERE soldin2004notin2005 != soldin2005notin2004
ORDER BY productname;

/*4*/ 
SELECT TO_DATE(monthdate,'mm-yyyy') AS monthdate,
       firstname,
       employeenumber,
       sales,
       SUM(sales) OVER (PARTITION BY TO_DATE(monthdate,'mm-yyyy')) AS totalmonthsales,
       LAG(sales,1) OVER (PARTITION BY employeenumber ORDER BY employeenumber,TO_DATE(monthdate,'mm-yyyy')) AS previousmonthsales,
       (sales*100 / SUM(sales) OVER (PARTITION BY TO_DATE(monthdate,'mm-yyyy'))) AS percentofsalestocurrentmonth
FROM (SELECT v2.monthdate,
             v2.salesrepemployeenumber AS employeenumber,
             v2.firstname,
             SUM(v1.priceeach*v1.quantityordered) AS sales
      FROM (SELECT TO_CHAR(DAY,'mm-yyyy') AS monthdate,
                   salesrepemployeenumber,
                   firstname
            FROM (SELECT (TO_DATE('01-01-2003','DD-MM-YYYY') + LEVEL -1) AS DAY
                  FROM dual
                  CONNECT BY LEVEL <= (TO_DATE('31-05-2005','DD-MM-YYYY') - TO_DATE('01-01-2003','DD-MM-YYYY') +1))
              CROSS JOIN (SELECT c.salesrepemployeenumber,
                                 e.firstname
                          FROM customers c
                            JOIN employees e ON c.salesrepemployeenumber = e.employeenumber
                          GROUP BY c.salesrepemployeenumber,
                                   e.firstname)
            GROUP BY TO_CHAR(DAY,'mm-yyyy'),
                     salesrepemployeenumber,
                     firstname
            ORDER BY 1,
                     2) v2
        LEFT OUTER JOIN (SELECT TO_CHAR(o.orderdate,'mm-yyyy') AS monthdate,
                                e.firstname,
                                e.employeenumber,
                                od.quantityordered,
                                od.priceeach,
                                od.quantityordered*od.priceeach AS orderamont,
                                SUM(od.quantityordered*od.priceeach) OVER (PARTITION BY TO_CHAR(o.orderdate,'mm-yyyy'),firstname ORDER BY firstname) AS sales
                         FROM employees e
                           JOIN customers c ON e.employeenumber = c.salesrepemployeenumber
                           JOIN orders o ON c.customernumber = o.customernumber
                           JOIN orderdetails od ON o.ordernumber = od.ordernumber
                         ORDER BY 1) v1
                     ON v2.monthdate = v1.monthdate
                    AND v2.salesrepemployeenumber = v1.employeenumber
      GROUP BY v2.monthdate,
               v2.salesrepemployeenumber,
               v2.firstname
      ORDER BY v2.monthdate)
GROUP BY TO_DATE(monthdate,'mm-yyyy'),
         firstname,
         employeenumber,
         sales
ORDER BY employeenumber,
         monthdate;


--testing
SELECT TO_CHAR(orderdate,'mm-yyyy'),
       employeenumber,
       e.firstname,
       SUM(od.quantityordered*od.priceeach)
FROM employees e
  JOIN customers c ON e.employeenumber = c.salesrepemployeenumber
  JOIN orders o ON c.customernumber = o.customernumber
  JOIN orderdetails od ON o.ordernumber = od.ordernumber
WHERE e.employeenumber = 1165
GROUP BY TO_CHAR(orderdate,'mm-yyyy'),
         employeenumber,
         e.firstname
ORDER BY 1;

/*5*/ 
SELECT orderdate,
       productcount,
       COUNT(ordernumber) AS ordercount,
       SUM(orderamount) AS totoalorderamount
FROM (SELECT o.orderdate,
             o.ordernumber,
             COUNT(p.productcode) AS productcount,
             SUM(od.quantityordered*od.priceeach) AS orderamount
      FROM orders o
        JOIN orderdetails od ON o.orderNumber = od.orderNumber
        JOIN products p ON od.productCode = p.productCode
      GROUP BY o.orderdate,
               o.ordernumber
      ORDER BY 1)
GROUP BY orderdate,
         productcount
ORDER BY orderdate,
         productcount;

