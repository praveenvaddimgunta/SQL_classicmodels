--Q1
SELECT PRODUCTLINE,
       PRODUCTNAME,
       PRODUCTVENDOR,
       QUANTITYINSTOCK,
       CASE
         WHEN QUANTITYINSTOCK < 10 THEN 'Y'
         ELSE 'N'
       END AS TOBEPROCURED
FROM PRODUCTS;

--Q2
SELECT M.LASTNAME,
       COUNT(1) NO_OF_EMPLOYEES,
       COUNT(CASE WHEN M.OFFICECODE <> E.OFFICECODE THEN e.employeenumber END) DIFF_LOCATION
       FROM EMPLOYEES E,
     EMPLOYEES M
WHERE E.REPORTSTO = M.EMPLOYEENUMBER
GROUP BY M.LASTNAME;

--Q3 using productcount
SELECT a.PRODUCTNAME,
       CASE
         WHEN a.a2004_count > 0 AND a.a2005_count = 0 THEN 'Y'
         ELSE 'N'
       END ordered_in_2004_not_2005,
       CASE
         WHEN a.a2004_count = 0 AND a.a2005_count > 0 THEN 'Y'
         ELSE 'N'
       END ordered_in_2005_not_2004
FROM (SELECT P.PRODUCTNAME,
             COUNT(CASE WHEN orderdate BETWEEN '01 mar 04' AND '31 mar 04' THEN O.ordernumber END) a2004_count,
             COUNT(CASE WHEN orderdate BETWEEN '01 mar 05' AND '31 mar 05' THEN O.ordernumber END) a2005_count
      FROM ORDERS O,
           ORDERDETAILS OD,
           PRODUCTS P
      WHERE O.ORDERNUMBER = OD.ORDERNUMBER
	  AND OD.PRODUCTCODE = P.PRODUCTCODE
      AND   (o.orderdate BETWEEN '01 mar 04' AND '31 mar 04' OR o.orderdate BETWEEN '01 mar 05' AND '31 mar 05') 
      GROUP BY P.PRODUCTNAME) a
WHERE (a2004_count = 0 AND a2005_count > 0)
OR    (a2004_count > 0 AND a2005_count = 0)
ORDER BY 1,
         2,
         3;

--Q3 using flags
SELECT a.productname,
       a.sold_in_2004,
       a.sold_in_2005
FROM (SELECT p.productName,
             MAX(CASE WHEN EXTRACT(YEAR FROM o.orderdate) = 2005 THEN 'Y' ELSE 'N' END) Sold_in_2005,
             MAX(CASE WHEN EXTRACT(YEAR FROM o.orderdate) = 2004 THEN 'Y' ELSE 'N' END) Sold_in_2004
      FROM orderdetails od
        JOIN orders o ON od.orderNumber = o.orderNumber
        JOIN products p ON od.productCode = p.productCode
      WHERE (o.orderdate BETWEEN '01 mar 04' AND '31 mar 04' OR o.orderdate BETWEEN '01 mar 05' AND '31 mar 05')
      GROUP BY productname) a
WHERE a.sold_in_2005 <> a.sold_in_2004
ORDER BY 1,
         2,
         3;

--Q4 Method using OLAP Functions
SELECT A2.ORDER_MONTH ORDER_MONTH,
       A2.EMP,
       A2.ORDER_AMT,
       A2.TOTAL_ORDER_AMT,
       CASE
         WHEN A2.PREV_CAL_MONTH = A2.PREV_MONTH THEN A2.PREV_MONTH_ORDER_AMT
         ELSE 0
       END PREV_MONTH_ORDER_AMT,
       (A2.ORDER_AMT / A2.TOTAL_ORDER_AMT)*100 ORDER_PCT,
       CASE
         WHEN COALESCE(A2.PREV_MONTH_ORDER_AMT,0) <> 0 AND A2.PREV_CAL_MONTH = A2.PREV_MONTH THEN ((A2.ORDER_AMT - A2.PREV_MONTH_ORDER_AMT) / A2.PREV_MONTH_ORDER_AMT)*100
       END MoM_Sales_Increase
FROM (SELECT A1.EMP,
             A1.ORDER_MONTH,
             A1.ORDER_AMT,
             SUM(A1.ORDER_AMT) OVER (PARTITION BY A1.ORDER_MONTH) TOTAL_ORDER_AMT,
             LAG(A1.ORDER_AMT,1) OVER (PARTITION BY A1.EMP ORDER BY A1.ORDER_MONTH) PREV_MONTH_ORDER_AMT,
             LAG(A1.ORDER_MONTH,1) OVER (PARTITION BY A1.EMP ORDER BY A1.ORDER_MONTH) PREV_MONTH,
             ADD_MONTHS(A1.ORDER_MONTH,-1) PREV_CAL_MONTH
      FROM (SELECT COALESCE(C.SALESREPEMPLOYEENUMBER,-1) EMP,
                   TRUNC(O.ORDERDATE,'mm') ORDER_MONTH,
                   SUM(OD.QUANTITYORDERED*OD.PRICEEACH) ORDER_AMT
                   FROM ORDERS O,
                 ORDERDETAILS OD,
                 CUSTOMERS C
            WHERE O.ORDERNUMBER = OD.ORDERNUMBER
            GROUP BY COALESCE(C.SALESREPEMPLOYEENUMBER,-1),
                    TRUNC(O.ORDERDATE,'mm')
			) A1
			) A2
ORDER BY A2.EMP,
         A2.ORDER_MONTH;

-- Q5. 

SELECT A1.ORDERDATE,
       A1.PRODUCT_CNT,
       COUNT(A1.ORDERNUMBER) ORDER_CNT,
       SUM(A1.ORDER_AMT) ORDER_AMT
FROM (SELECT O.ORDERDATE,
             O.ORDERNUMBER,
             COUNT(1) PRODUCT_CNT,
             SUM(OD.QUANTITYORDERED*OD.PRICEEACH) ORDER_AMT
      FROM ORDERS O,
           ORDERDETAILS OD
      WHERE O.ORDERNUMBER = OD.ORDERNUMBER
      GROUP BY O.ORDERDATE,
               O.ORDERNUMBER) A1
GROUP BY A1.ORDERDATE,
         A1.PRODUCT_CNT
ORDER BY 1,
         2
;
