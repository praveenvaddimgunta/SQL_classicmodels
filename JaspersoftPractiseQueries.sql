/*Revenue under productLine*/ 
SELECT DISTINCT p.productName,
       p.productLine,
       SUM(od.quantityOrdered*od.priceEach) OVER (PARTITION BY productName ORDER BY productLine) AS revenue
FROM products p
  JOIN orderdetails od ON p.productcode = od.productcode
ORDER BY p.productLine;

/*Revenue per Year*/ 
SELECT DISTINCT p.productName,
       o.orderdate,
       p.productLine,
       SUM(od.quantityOrdered*od.priceEach) OVER (PARTITION BY productName ORDER BY productLine) AS revenue
FROM products p
  JOIN orderdetails od ON p.productcode = od.productcode
  JOIN orders o ON od.orderNumber = o.orderNumber
WHERE EXTRACT(year FROM o.orderdate) = 2003
ORDER BY p.productLine;

/*Revenue per year, productLine*/ 
SELECT p.productLine,
       EXTRACT(year FROM o.orderdate) AS orderyear,
       EXTRACT(month FROM o.orderdate) ordermonth,
       SUM(od.quantityOrdered*od.priceEach) AS Revenue
FROM products p
  JOIN orderdetails od ON p.productcode = od.productcode
  JOIN orders o ON od.orderNumber = o.orderNumber
WHERE EXTRACT(year FROM o.orderdate) = 2003
GROUP BY p.productLine,
         EXTRACT(year FROM o.orderdate),
         EXTRACT(month FROM o.orderdate)
ORDER BY p.productLine;

DECODE(TRUNC EXTRACT(month FROM o.orderdate),1,'Jan',2,'Feb',3,'Mar',4,'Apr',5,'May',6,'Jun',7,'Jul',8,'Aug',9,'Sep',10,'Oct',11,'Nov',12,'Dec')
SELECT p.productLine,
       EXTRACT(year FROM o.orderdate) AS orderyear,
       DECODE( EXTRACT(month FROM o.orderdate),
             1,'Jan',
             2,'Feb',
             3,'Mar',
             4,'Apr',
             5,'May',
             6,'Jun',
             7,'Jul',
             8,'Aug',
             9,'Sep',
             10,'Oct',
             11,'Nov',
             12,'Dec'
       ) ordermonth,
       SUM(od.quantityOrdered*od.priceEach) AS Revenue
FROM products p
  JOIN orderdetails od ON p.productcode = od.productcode
  JOIN orders o ON od.orderNumber = o.orderNumber
WHERE EXTRACT(year FROM o.orderdate) = 2003
GROUP BY p.productLine,
         EXTRACT(year FROM o.orderdate),
         EXTRACT(month FROM o.orderdate)
ORDER BY p.productLine;

/*TASK-5*/ 
SELECT DISTINCT productLine
FROM productLines
WHERE productLine IN ('Vintage Cars','Classic Cars');

/*TASK-2*/ 
SELECT DISTINCT p.productName,
       EXTRACT(year FROM o.orderdate) AS orderyear,
       p.productLine,
       SUM(od.quantityOrdered*od.priceEach) AS revenue
FROM products p
  JOIN orderdetails od ON p.productcode = od.productcode
  JOIN orders o ON od.orderNumber = o.orderNumber
WHERE EXTRACT(year FROM o.orderdate) = 2003
GROUP BY EXTRACT(year FROM o.orderdate),
         p.productLine,
         p.productname
ORDER BY orderyear,
         p.productline,
         p.productname;

