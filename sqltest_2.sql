/*1*/ 
SELECT *
FROM (SELECT YEAR,
             newproductlines,
             SUM(revenue) AS sales
      FROM (SELECT EXTRACT(YEAR FROM o.orderdate) AS YEAR,
                   CASE p.productline
                     WHEN 'Vintage Cars' THEN 'RV'
                     WHEN 'Classic Cars' THEN 'RV'
                     WHEN 'Motorcycles' THEN 'RV'
                     WHEN 'Trucks and Buses' THEN 'RV'
                     ELSE p.productline
                   END AS newproductlines,
                   (od.quantityordered*od.priceeach) AS revenue
            FROM orders o
              JOIN orderdetails od ON o.ordernumber = od.ordernumber
              JOIN products p ON od.productcode = p.productcode)
      GROUP BY YEAR,
               newproductlines
      ORDER BY YEAR,
               newproductlines) PIVOT (SUM(sales) 
     FOR
     newproductlines IN ('RV','Trains','Ships','Planes'))
ORDER BY year;

/*2*/ 
SELECT year,
       metric,
       thisyear,
       LAG(thisyear,4) OVER (ORDER BY year) AS previousyear
FROM (SELECT ord.year,
             ord.customers,
             ord.orders,
             ord.sales,
             pay.payments
      FROM ((SELECT EXTRACT(YEAR FROM o.orderdate) AS YEAR,
                    COUNT(DISTINCT o.customernumber) AS customers,
                    COUNT(DISTINCT o.ordernumber) AS orders,
                    SUM(od.quantityordered*od.priceeach) AS sales
             FROM orders o
               JOIN orderdetails od ON o.ordernumber = od.ordernumber
             GROUP BY EXTRACT(YEAR FROM o.orderdate)) ord JOIN (SELECT EXTRACT(YEAR FROM paymentdate) AS YEAR,
                                                                       COUNT(DISTINCT customernumber) AS customers,
                                                                       SUM(amount) AS payments
                                                                FROM payments p
                                                                GROUP BY EXTRACT(YEAR FROM paymentdate)) pay ON ord.year = pay.year)
      ORDER BY ord.year) UNPIVOT (thisyear 
     FOR
     metric IN (customers,orders,sales,payments));

/*3*/ 
SELECT DISTINCT c.customernumber,
       fo.firstorderdate,
       fo.firstorderamount,
       so.secondorderdate,
       so.secondorderamount,
       fp.firstpaymentdate,
       fp.firstpaymentamount,
       sp.secondpaymentdate,
       sp.secondpaymentamount
FROM customers c
  FULL OUTER JOIN (SELECT customernumber,
                          orderdate AS firstorderdate,
                          orderamount AS firstorderamount
                   FROM (SELECT o.customernumber,
                                o.orderdate,
                                o.ordernumber,
                                SUM(od.quantityordered*od.priceeach) OVER (PARTITION BY o.ordernumber) AS orderamount,
                                DENSE_RANK() OVER (PARTITION BY customernumber ORDER BY o.orderdate) AS rownumber
                         FROM orders o
                           JOIN orderdetails od ON o.ordernumber = od.ordernumber
                         ORDER BY o.customernumber,
                                  o.orderdate)
                   WHERE rownumber = 1) fo ON c.customernumber = fo.customernumber
  FULL OUTER JOIN (SELECT customernumber,
                          orderdate AS secondorderdate,
                          orderamount AS secondorderamount
                   FROM (SELECT o.customernumber,
                                o.orderdate,
                                o.ordernumber,
                                SUM(od.quantityordered*od.priceeach) OVER (PARTITION BY o.ordernumber) AS orderamount,
                                DENSE_RANK() OVER (PARTITION BY customernumber ORDER BY o.orderdate) AS rownumber
                         FROM orders o
                           JOIN orderdetails od ON o.ordernumber = od.ordernumber
                         ORDER BY o.customernumber,
                                  o.orderdate)
                   WHERE rownumber = 2) so ON c.customernumber = so.customernumber
  FULL OUTER JOIN (SELECT customernumber,
                          paymentdate AS firstpaymentdate,
                          paymentamount AS firstpaymentamount
                   FROM (SELECT customernumber,
                                paymentdate,
                                checknumber,
                                SUM(amount) OVER (PARTITION BY checknumber) AS paymentamount,
                                DENSE_RANK() OVER (PARTITION BY customernumber ORDER BY paymentdate) AS rownumber
                         FROM payments
                         ORDER BY customernumber,
                                  paymentdate)
                   WHERE rownumber = 1) fp ON c.customernumber = fp.customernumber
  FULL OUTER JOIN (SELECT customernumber,
                          paymentdate AS secondpaymentdate,
                          paymentamount AS secondpaymentamount
                   FROM (SELECT customernumber,
                                paymentdate,
                                checknumber,
                                SUM(amount) OVER (PARTITION BY checknumber) AS paymentamount,
                                DENSE_RANK() OVER (PARTITION BY customernumber ORDER BY paymentdate) AS rownumber
                         FROM payments
                         ORDER BY customernumber,
                                  paymentdate)
                   WHERE rownumber = 2) sp ON c.customernumber = sp.customernumber
ORDER BY c.customernumber;

/*4*/ 
SELECT day,
       orderamountoftheday,
       previousdayorderamount,
       previousmonthorderamount,
       previousyearorderamount,
       monthtodate,
       (orderamountoftheday*100 / monthtordervalue) AS orderamountaspermonthsales
FROM (SELECT TO_CHAR(dates,'dd-mon-yyyy') AS DAY,
             orderamountoftheday,
             LAG(orderamountoftheday,1) OVER (ORDER BY rownumber) AS previousdayorderamount,
             LAG(orderamountoftheday,31) OVER (ORDER BY rownumber) previousmonthorderamount,
             LAG(orderamountoftheday,366) OVER (ORDER BY rownumber) previousyearorderamount,
             SUM(orderamountoftheday) OVER (PARTITION BY EXTRACT(MONTH FROM dates) || '-' ||EXTRACT (YEAR FROM dates) ORDER BY dates) AS monthtodate,
             SUM(orderamountoftheday) OVER (PARTITION BY EXTRACT(MONTH FROM dates) || '-' ||EXTRACT (YEAR FROM dates)) AS monthtordervalue
      FROM (SELECT d.dates AS dates,
                   o.orderamount AS orderamountoftheday,
                   d.rownumber AS rownumber
            FROM (SELECT (TO_DATE('01-01-2003','DD-MM-YYYY') + LEVEL -1) AS dates,
                         LEVEL AS rownumber
                  FROM dual
                  CONNECT BY LEVEL <= (TO_DATE('31-05-2005','DD-MM-YYYY') - TO_DATE('01-01-2003','DD-MM-YYYY') +1)) d
              FULL OUTER JOIN (SELECT o.orderdate,
                                      SUM(od.quantityordered*od.priceeach) AS orderamount
                               FROM orders o
                                 JOIN orderdetails od ON o.ordernumber = od.ordernumber
                               GROUP BY o.orderdate
                               ORDER BY o.orderdate) o ON d.dates = o.orderdate
            ORDER BY d.rownumber)
      ORDER BY dates)
WHERE TO_DATE(day,'dd-mm-yyyy') BETWEEN TO_DATE('01-06-2004','dd-mm-yyyy') AND TO_DATE('30-06-2004','dd-mm-yyyy');

/*5*/ 
SELECT p.ordermonth AS month,
       p.productname AS bestperfomingproduct,
       p.productrevenue AS bestperfomingproductordervalue,
       pl.productline AS bestperfomingproductline,
       pl.productlinerevenue AS bestproductlineordervalue,
       t.totalorderamount AS totalorderamount
FROM (SELECT *
      FROM (SELECT TO_CHAR(o.orderdate,'month-yyyy') AS ordermonth,
                   p.productline,
                   SUM(od.quantityordered*od.priceeach) AS productlinerevenue,
                   RANK() OVER (PARTITION BY TO_CHAR(o.orderdate,'month-yyyy') ORDER BY SUM(od.quantityordered*od.priceeach) DESC) AS productlinerank
            FROM products p
              JOIN orderdetails od ON p.productcode = od.productcode
              JOIN orders o ON od.ordernumber = o.ordernumber
            GROUP BY TO_CHAR(o.orderdate,'month-yyyy'),
                     productline)
      WHERE productlinerank = 1) pl
  JOIN (SELECT *
        FROM (SELECT TO_CHAR(o.orderdate,'month-yyyy') AS ordermonth,
                     p.productname,
                     SUM(od.quantityordered*od.priceeach) AS productrevenue,
                     RANK() OVER (PARTITION BY TO_CHAR(o.orderdate,'month-yyyy') ORDER BY SUM(od.quantityordered*od.priceeach) DESC) AS productrank
              FROM products p
                JOIN orderdetails od ON p.productcode = od.productcode
                JOIN orders o ON od.ordernumber = o.ordernumber
              GROUP BY TO_CHAR(o.orderdate,'month-yyyy'),
                       productname)
        WHERE productrank = 1) p ON pl.ordermonth = p.ordermonth
  JOIN (SELECT TO_CHAR(o.orderdate,'month-yyyy') AS ordermonth,
               SUM(od.quantityordered*od.priceeach) AS totalorderamount
        FROM orders o
          JOIN orderdetails od ON o.ordernumber = od.ordernumber
        GROUP BY TO_CHAR(o.orderdate,'month-yyyy')
        ORDER BY TO_CHAR(o.orderdate,'month-yyyy')) t ON p.ordermonth = t.ordermonth;

