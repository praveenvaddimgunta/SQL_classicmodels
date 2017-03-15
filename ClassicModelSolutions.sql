/*SINGLE ENTITY*/
/*1*/select * 
		from offices 
        order by country, state, city;

/*2*/select count(*) 
		from employees;

/*3*/select sum(amount) 
		from payments;

/*4*/select productLine 
		from productlines 
        where productLine like '%cars';
select paymentDate from payments;

/*5*/select sum(amount) 
		from payments 
        where paymentDate like '2004-10-28%';

/*6*/select * 
		from payments 
        where amount > 100000;

/*7*/select productName, productLine 
		from products 
        order by productLine;

/*8*/select productLine, count(*) as totalProducts 
		from products 
        group by productLine;

/*9*/select min(amount) as minimumPayment 
		from payments;

/*10*/select amount 
		from payments 
        where amount > 2*(select avg(amount) from payments);

select * from products;

/*11*/select avg((MSRP-buyPrice)*100/buyPrice) as 'average percentage markup' 
		from products;

/*12*/select count(distinct productName) 
		from products;

/*13*/select customerName, city 
		from customers where salesRepEmployeeNumber is NULL;

/*14*/select concat(firstName, ' ',lastName) 
		from employees 
        where jobTitle like 'VP%' or jobTitle like '%Manager%';
select * from employees;

select * from orderdetails;

/*15*/ select orderNumber 
		from orderDetails 
		where (quantityOrdered*priceEach)>5000;

/*ONE TO MANY RELATIONSHIPS*/
/*1*/select c.customerName, concat(e.firstname, ' ', e.lastname) as 'account representative'
		from customers as c join employees as e 
        on c.salesRepEmployeeNumber = e.employeeNumber;
        
/*2*/ select c.customername, sum(p.amount) 
		from customers as c join payments as p 
        on c.customerNumber = p.customerNumber
        where c.customerName='atelier graphique';
	
/*3*/ select paymentDate, amount
		from payments 
        group by paymentDate;


/*4*/ select productName 
		from products 
        where productCode not in (select productCode from orderdetails);
        
/*5*/ select c.customerName, p.amount
		from customers as c join payments as p
        where c.customerNumber = p.customerNumber group by c.customerName;
        
/*6*/select count(*) as orders
		from customers as c join orders as o 
        on c.customerNumber = o.customerNumber
        where c.customerName='Herkku Gifts';
        
/*7*/select concat(e.firstname, ' ',e.lastname) as 'employees in boston'
		from employees as e join offices as o
        on e.officeCode=o.officecode
        where o.city='boston';
        
/*8*/select customerName, (p.amount)
		from customers as c join payments as p
        on c.customerNumber = p.customerNumber
        where p.amount>100000 
        group by c.customerNumber
        order by p.amount desc;
        

/*9*/ select sum(od.quantityOrdered*od.priceEach) as 'Total value of on hold orders'
		from orderdetails as od join orders as o
        on od.orderNumber=o.orderNumber
        where o.status = 'On Hold';
        
        
/*10*/select c.customerName, count(o.status) as 'Number of orders on hold'
		from customers as c join orders as o
        on c.customerNumber=o.customerNumber
        where o.status='On Hold'
        group by c.customerName;
        
/*MANY TO MANY RELATIONSHIP*/

/*1*/select p.productName ,o.orderDate
		from products as p join orderdetails as od 
        on p.productCode = od.productCode
        join orders as o on od.orderNumber=o.orderNumber;
 
 select * FROM products where productName like '%truck%';
/*2*/select o.orderNumber
		from orders as o join orderdetails as od 
        on o.orderNumber=od.orderNumber 
        join products as p on od.productCode=p.productCode
        where p.productName like '1940 Ford Pickup Truck';
        
/*3*/select c.customerName,o.orderNumber,p.amount
		from customers as c join orders as o
        on o.customerNumber = c.customerNumber
        join payments as p on p.customerNumber=o.customerNumber
        where p.amount>25000 group by o.orderNumber;
        
select count(amount) from payments where amount>25000 group by customerNumber;

/*4*/create view orderCount as
		select p.productname, count(o.ordernumber) as 'number of orders'
			from products as p join orderdetails as od
			on p.productCode=od.productcode join orders as o
			on od.orderNumber=o.orderNumber
			group by p.productname;
      
      create view  totalOrdersTable as
		select count(distinct orderNumber) as totalorders,count(distinct customerNumber) as totalCustomers
			from orders;
select productname 
	from ordercount 
    where 'number of orders' = (select totalorders from totalorderstable);

/*5*/select od.orderNumber
		from orders as o join orderdetails as od on od.ordernumber = o.ordernumber 
        join products as p on p.productcode = od.productcode 
        where od.priceEach < p.MSRP 
        group by od.orderNumber;

/*6*/select p.productName
		from products as p join orderdetails as od on od.productCode = p.productCode
        where od.priceEach >= 2*(p.buyPrice)
        group by p.productName;
        
/*7*/select distinct p.productName 
		from products  as p join orderdetails as od on p.productCode = od.productCode
		join orders as o on o.orderNumber = od.orderNumber
		where dayname(orderDate) ='Monday';
        
/*8*/select p.productName, p.quantityInStock 
		from products as p join orderDetails as od on od.productCode = p.productCode 
		join orders as o on o.orderNumber = od.orderNumber
		where o.status ='On Hold';
        
        
/*REGULAR EXPRESSIONS*/
/*1*/select productName 
		from products 
        where productName REGEXP 'Ford';

/*2*/select productName
		from products
        where productName regexp 'ship$';

/*3*/select count(customerName) as 'number of customers'
		from customers
        where country regexp "(denmark|sweden|Norway)";

/*4*/select productName, productCode 
		from products
        where productCode regexp "s700_1[0-4][0-9][0-9]";

/*5*/select customerName 
		from customers
        where customerName regexp ".[0-9]";
        
/*6*/select concat(firstName, ' ', lastName) as employeeName
		from employees
        where concat(firstName, lastName) regexp "(Diane|Dianne)";

/*7*/select productName
		from products
        where productName regexp "(ship|boat)";

/*8*/select productName, productCode
		from products
        where productCode regexp "^(s700)";

/*9*/select concat(firstName, ' ', lastName) as employeeNameorders
		from employees
        where concat(firstName, lastName) regexp "(larry|barry)";

/*10*/select concat(firstName, ' ', lastName) as employeeName
		from employees
        where concat(firstName, lastName) regexp "[^a-zA-Z *]";
        
/*11*/select productVendor 
		from products
        where productVendor regexp "(Diecast)$";
        
/*GENERAL QUERIES*/

/*1*/select concat(firstName, ' ', lastName) 
		from employees
        where reportsTo is NULL;
        
/*2*/select concat(firstName, ' ', lastName) 
		from employees
        where reportsTo =(
        select employeeNumber 
			from employees 
            where concat(firstName, ' ', lastName)='William Patterson'
		);
        
/*3*/select p.productName 
		from products as p join orderdetails as od on p.productCode=od.productCode 
        join orders as o on od.orderNumber=o.orderNumber
        join customers as c on o.customerNumber=c.customerNumber
        where c.customerName = 'Herkku Gifts';

/*4*/select concat(e.firstName, ' ', e.lastName) as salesRepresentative,sum(0.05*(od.quantityOrdered*od.PriceEach)) as commision
		from employees as e join customers as c on e.employeeNumber=c.salesRepEmployeeNumber
        join orders as o on c.customerNumber=o.customerNumber 
        join orderdetails as od on o.orderNumber=od.orderNumber
        group by  lastName, firstName ;
        
/*5*/select datediff(max(orderDate), min(orderDate)) as 'difference in days between the most recent and oldest order' 
		from orders;
        
/*6*/select concat(floor(avg(datediff(shippedDate, orderDate))),'days ',24*mod(avg(datediff(shippedDate, orderDate)),1),'hours') as 'average time between order date and ship date' 
		from orders;
        
/*7*/select sum(od.quantityOrdered*od.priceEach) as 'Total value of orders shipped in August 2004'
		from orderdetails as od join orders as o on od.orderNumber=o.orderNumber
        where monthname(o.shippedDate) = 'August' and year(o.shippedDate)='2004';
        
/*8*/create view totalPaidByCustomer as
		select c.customerName, sum(p.amount)  as totalPaid
			from payments as p join customers as c on p.customerNumber=c.customerNumber 
            where year(p.paymentDate)='2004'
            group by c.customerNumber;


	create view totalOrderedByCustomer as 
		select c.customerName, sum(od.quantityOrdered*od.priceEach) as totalOrdered
			from orderdetails as od join orders as o on od.orderNumber=o.orderNumber
            join customers as c on o.customerNumber=c.customerNumber 
            where year(o.orderDate)='2004'
            group by c.customerNumber;
            
	select p.customerName, o.totalOrdered, p.totalPaid, round(o.totalOrdered-p.totalPaid,0) as difference
			from totalpaidbycustomer as p join totalorderedbycustomer as o
            on p.customerName=o.customerName;
            
/*9*/ select concat(e3.firstName,' ',e3.lastName) as employeeName
			from employees as e1 join employees as e2 on e1.reportsTo=e2.employeeNumber
            join employees as e3 on e1.employeeNumber=e3.reportsTo
            where e1.reportsTo in(select employeeNumber from employees where concat(firstName,' ',lastname)='Diane Murphy');

/*10*/create view totalStock as
		select sum(quantityInStock) as totalQuantity
			from products;

	select productName, (quantityInStock*100)/(select totalQuantity from totalStock) as 'percentage value of each product in inventory '
			from products order by 2 desc;
            
/*11*/DELIMITER //
		create function litresper100Km (input int) returns float(10,2)
			begin
				return  235.215/input;
			end;
        //
	select litresper100Km(3);
    DELIMITER ;

/*12*/DELIMITER //

create procedure priceHike(IN ProductCategory varchar(255), hike int)
BEGIN
update productstest 
	set MSRP = MSRP*(1+(hike)/100)
    where productLine=ProductCategory;
END//

DELIMITER ;

call priceHike('MotorCycles', 5);

select * from productstest;

/*13*/select sum(od.quantityOrdered*od.priceEach) as 'Total value of orders shipped in August 2004'
		from orderdetails as od join orders as o on od.orderNumber=o.orderNumber
        where monthname(o.shippedDate) = 'August' and year(o.shippedDate)='2004';
        
/*14*/create view  dayWisePaymentsRatio as;
		select o.orderDate as date, sum(p.amount) as paymentAmount, sum(od.priceEach*od.quantityordered) as orderedAmount, (sum(p.amount)/sum(od.priceEach*od.quantityordered)) as ratio
			from payments as p join customers as c on p.customerNumber=c.customerNumber
            join orders as o on c.customerNumber=o.customerNumber
            join orderdetails as od on o.orderNumber=od.orderNumber
            where year(o.orderDate)='2004' group by o.orderDate;
            
	create view  monthWisePaymentsRatio as;
		select monthname(o.orderDate) as month, sum(p.amount) as paymentAmount, sum(od.priceEach*od.quantityordered) as orderedAmount, (sum(p.amount)/sum(od.priceEach*od.quantityordered)) as ratio
			from payments as p join customers as c on p.customerNumber=c.customerNumber
            join orders as o on c.customerNumber=o.customerNumber
            join orderdetails as od on o.orderNumber=od.orderNumber
            where year(o.orderDate)='2004' group by month(o.orderDate);
        
        select * from daywisePaymentsRatio;
        select * from monthWisePaymentsRatio;
		select sum(paymentamount), sum(orderedAmount) from daywisepaymentsratio;
        select sum(paymentamount), sum(orderedAmount) from monthwisepaymentsratio;

/*15*/create view paymentsIn2003 as
		select monthname(paymentDate) as month, sum(amount) as amountReceviedIn2003
			from payments
            where year(paymentDate)='2003'
            group by month(paymentDate);
	  create view paymentsIn2004 as
		select monthname(paymentDate) as month, sum(amount) as amountReceviedIn2004
			from payments
            where year(paymentDate)='2004'
            group by month(paymentDate);
            
	select p3.month, p4.amountReceviedIn2004, p3.amountReceviedIn2003, (p4.amountReceviedin2004-p3.amountReceviedIn2003) as difference
		from paymentsin2003 as p3 join paymentsin2004 as p4 on p3.month=p4.month;

/*16*/DELIMITER //
create procedure report(customer varchar(255), year varchar(4), monthName varchar(25))
begin
set customer = concat("%",customer,"%");
set monthName = concat("%",monthName);
select c.customerName, monthname(o.orderDate) as month, year(o.orderdate) as year, sum(od.quantityOrdered*od.priceEach) as amountOrdered
	from customers as c join orders as o on c.customerNumber = o.customerNumber
    join orderdetails as od on o.orderNumber=od.orderNumber
    where year(o.orderDate)=year and monthname(o.orderDate) like monthName and c.customerName like customer;
end//

DELIMITER ;
call report('mini', 2004, 'august');

drop procedure report;
/*17*/DELIMITER //
create procedure creditLimit(IN countryName varchar(255), percent int)
BEGIN
update customers 
	set creditLimit = creditLimit*(1+(percent)/100)
    where country = countryName;
END//

DELIMITER ;
call creditLimit('France', 10);
select * from customers;

/*18*/select concat((select productName from Products where Products.productCode = od1.productCode), ", ", (select productName from Products where Products.productCode = od2.productCode)) as sets, count(*) as countInOrder
			from OrderDetails as od1 join OrderDetails as od2 on od1.orderNumber = od2.orderNumber 
			where od1.productCode > od2.productCode
			group by sets having countInOrder >=10
			order by countInOrder desc, sets;

/*19*/create view totalrevenueView as
	select sum(quantityOrdered*priceEach) as totalRevenue
		from orderdetails;
        
	select * from totalrevenueView;

	select c.customerName, sum(od.quantityOrdered*od.priceEach) as revenue, (select totalRevenue from totalrevenueview) as totalRevenue, (sum(od.quantityOrdered*od.priceEach)*100)/(select totalRevenue from totalrevenueview) as percentageOfTotalRevenue
		from customers as c join orders as o on c.customerNumber=o.customerNumber
		join orderdetails as od on o.orderNumber=od.orderNumber 
		group by c.customerName;

/*20*/create view profitTable as;
		select c.customerName, od.quantityOrdered, od.priceEach, (od.quantityOrdered*od.priceEach) as sp , (p.buyPrice*od.quantityOrdered) as cp, ((od.quantityOrdered*od.priceEach)-(p.buyPrice*od.quantityOrdered)) as profit
			from customers as c join orders as o on c.customerNumber=o.customerNumber
			join orderdetails as od on o.orderNumber=od.orderNumber
			join products as p on od.productCode=p.productCode;
	create view totalProfit as 
		select sum(profit) as total 
			from profittable;

select customerName, sum(profit) as profit, sum(profit)*100/(select total from totalprofit) as profitPercent
	from profittable 
    group by customerName 
    order by 2 desc;
    
/*21*/ create or replace view salesRepProfit as
select concat(e.firstname,' ',e.lastname) as SalesRepName, c.customerName, od.quantityOrdered, od.priceEach, (od.quantityOrdered*od.priceEach) as revenue , (p.buyPrice*od.quantityOrdered) as investment, ((od.quantityOrdered*od.priceEach)-(p.buyPrice*od.quantityOrdered)) as profit
	from employees as e join customers as c on e.employeeNumber=c.salesRepEmployeeNumber
    join orders as o on c.customerNumber=o.customerNumber
    join orderdetails as od on o.orderNumber=od.orderNumber
    join products as p on od.productCode=p.productCode;

select SalesRepName, sum(revenue) as totalRevenue 
	from salesrepprofit 
    group by SalesRepName;
    
/*22*/select salesRepName, sum(revenue-investment) as profit 
		from salesrepprofit 
        group by SalesRepName 
        order by 2 desc;
select * from employees;
/*23*/select p.productName,sum(od.quantityOrdered*od.priceEach) as revenue
		from products as p join orderdetails as od on p.productCode=od.productCode 
		group by p.productName;

/*24*/select p.productLine, sum(od.quantityOrdered*od.priceEach) as revenue, sum(p.buyPrice*od.quantityOrdered) as investment, (sum(od.quantityOrdered*od.priceEach)-sum(p.buyPrice*od.quantityOrdered)) as profit
		from products as p join orderdetails as od on p.productCode=od.productCode 
		group by p.productLine;

/*CORRELATED SUBQUERIES*/

/*1*/select concat(firstName,' ',lastName) as 'employess report to Mary Patterson' 
		from employees
		where reportsTo in (
			select employeeNumber 
				from employees 
                where concat(firstName,' ',lastName) = 'Mary Patterson'
		);

/*2*/DELIMITER //
	create procedure HighPayments(in year varchar(4), month varchar(10))
	BEGIN
	set month = concat('%',month,'%');
	select customerNumber, paymentDate, amount
		from payments 
		where year(paymentDate)=year and monthname(paymentDate) like month and amount > 2*(select avg(amount)
		from payments where year(paymentDate)=year and monthname(paymentDate) like month);
	END //
DELIMITER ;

call HighPayments(2004,'oct');

/*3*/create view productStocks as
		select p.productName, p.productLine, p.quantityInStock, sum(od.quantityOrdered) as totalQuantityOrdered, (p.quantityInStock+sum(od.quantityOrdered)) as totalProduction
			from products as p join orderdetails as od on p.productCode=od.productCode
			 group by p.productName
			 order by p.productLine;
             
		create view productLineQuantityInStock as
		select  productLine, sum(quantityInStock) as totalQuantityInStock from productStocks group by productLine;

		select ps.productName, pq.productLine, ps.quantityInStock, pq.totalQuantityInStock, round((ps.quantityInStock*100/pq.totalQuantityInStock),2) as 'percent value with in productline'
			from productstocks as ps join productlinequantityinstock as pq on ps.productLine=pq.productLine
			order by pq.productLine, 5 desc;

/*4*/create or replace view ProductdetailsCount  as
		select ordernumber,count(productCode) as count, sum(quantityordered*priceeach) as totalOrderedAmount 
			from orderdetails  
            group by ordernumber having count > 2;
            
		select p.productName, (od.quantityordered*od.priceeach) as ProductValue, pdc.TotalOrderedAmount 
			from orderdetails as od join productdetailscount as pdc on pdc.ordernumber = od.ordernumber
            join products as p on p.productCode=od.productCode
			where (quantityordered*priceeach) > (totalOrderedAmount/2) ;
