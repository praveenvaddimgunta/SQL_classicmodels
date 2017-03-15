DELIMITER //
create procedure getallProductNames()
	BEGIN
		select productName 
        from products;
	END //
    
DELIMITER ;

call getallProductNames();

DELIMITER //

create procedure priceHike(IN ProductCategory varchar(255), hike int)
BEGIN
update productstest 
	set MSRP = MSRP*(1+(hike)/100)
    where productLine=ProductCategory;
END//

DELIMITER ;

call priceHike('MotorCycles', 5);

select * from product;

DELIMITER //
create procedure report(customer varchar(255), year varchar(4), monthName varchar(25))
begin
set customer = concat("%",customer,"%");
set monthName = concat("",monthName);
select c.customerName, monthname(o.orderDate) as month, year(o.orderdate) as year, sum(od.quantityOrdered*od.priceEach) as amountOrdered
	from customers as c join orders as o on c.customerNumber = o.customerNumber
    join orderdetails as od on o.orderNumber=od.orderNumber
    where year(o.orderDate)=year and month(o.orderDate) = monthName and c.customerName like customer;
end//

DELIMITER ;
call report('Mini', 2004, 8);

drop procedure report;

select * from orderdetails;

select c.customerName, o.orderDate, sum(od.quantityOrdered*od.priceEach) as amountOrdered
	from customers as c join orders as o on c.customerNumber = o.customerNumber
    join orderdetails as od on o.orderNumber=od.orderNumber
    where year(o.orderDate)=2004 and monthname(o.orderDate)='August' and c.customerName regexp 'mini';

select avg(amount)
	from payments;

DELIMITER //
create procedure HighPayments(in year varchar(4), month varchar(10))
BEGIN
set month = concat('%',month,'%');
select customerNumber, paymentDate, amount
	from payments 
    where year(paymentDate)=year and monthname(paymentDate) like month and amount > 2*(select avg(amount)
	from payments where year(paymentDate)=year and monthname(paymentDate) like month);
END //

DELIMITER ;

call HighPayments(2003,'oct');

create view productStocks as
select p.productName, p.productLine, p.quantityInStock, sum(od.quantityOrdered) as totalQuantityOrdered, (p.quantityInStock+sum(od.quantityOrdered)) as totalProduction
	from products as p join orderdetails as od on p.productCode=od.productCode
     group by p.productName
     order by p.productLine;
create view productLineQuantityInStock as
select  productLine, sum(quantityInStock) as totalQuantityInStock from productStocks group by productLine;

select ps.productName, pq.productLine, ps.quantityInStock, pq.totalQuantityInStock, round((ps.quantityInStock*100/pq.totalQuantityInStock),2) as 'percent value with in productline'
	from productstocks as ps join productlinequantityinstock as pq on ps.productLine=pq.productLine
    order by 'percent value with in productline' desc;


select concat((select productName from Products where Products.productCode = od1.productCode), ", ", (select productName from Products where Products.productCode = od2.productCode)) 
as sets, count(*) as countInOrder
from OrderDetails as od1 join OrderDetails as od2 on od1.orderNumber = od2.orderNumber 
where od1.productCode > od2.productCode
group by sets having countInOrder >=10
order by countInOrder desc, sets;

create or replace view ProductdetailsCount  as
		select ordernumber,count(productCode) as count, sum(quantityordered*priceeach) as totalOrderedAmount 
			from orderdetails  
            group by ordernumber having count > 2;

        select p.productName, (od.quantityordered*od.priceeach) as ProductValue, pdc.TotalOrderedAmount 
			from orderdetails as od join productdetailscount as pdc on pdc.ordernumber = od.ordernumber
            join products as p on p.productCode=od.productCode
			where (quantityordered*priceeach) > (totalOrderedAmount/2) ;