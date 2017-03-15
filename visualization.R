library(ggvis)
library(DBI)
conn <- dbConnect(RMySQL::MySQL(), "C:/Users/BizAct/Downloads/classicModels.sql", dbname="ClassicModels", user="root",password="praveen1993", host="127.0.0.1")
#1
ans <- dbGetQuery(conn,"select productscale from products")
ans %>% ggvis(~productscale) %>% layer_bars(fill:='blue') %>%
  add_axis('x',title='productscale')%>%
  add_axis('y',title='frequency')

#2
ans <- dbGetQuery(conn,"select monthname(paymentdate) as months ,amount from payments where paymentDate regexp '^(2004)' group by monthname(paymentdate);")
ans %>% ggvis(x=~months,y=~amount) %>% layer_bars(fill:='red') %>%
  add_axis('x',title='monthname(paymentdate)')%>%
  add_axis('y',title='amount')

#3
ans <- dbGetQuery(conn,"select country, sum(quantityOrdered*priceEach) as orders from Orders, 
                OrderDetails, Customers where Orders.orderNumber = OrderDetails.orderNumber 
                and Customers.customerNumber = Orders.customerNumber 
                AND country IN ('Denmark','Finland', 'Norway','Sweden') GROUP BY country")
ans %>% ggvis(~country,~orders) %>% layer_bars(fill:='yellow') %>% 
  add_axis('x',title='Country') %>% 
  add_axis('y',title='Orders',title_offset = 60)