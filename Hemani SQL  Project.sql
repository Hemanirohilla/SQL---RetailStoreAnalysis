-- SQL Project  

-- Question 1 - 1. Write a query to display customer full name with their title (Mr/Ms), both first name and last name are in upper case, customer email id, 
-- customer creation date and display customer’s category after applying below categorization rules: i) IF customer creation date Year <2005 Then Category A ii) 
-- IF customer creation date Year >=2005 and <2011 Then Category B iii)IF customer creation date Year>= 2011 Then Category C Hint: Use CASE statement, no permanent 
-- change in table required 

select* from online_customer;
select case when customer_gender='f' then upper(concat('Ms ',customer_fname,' ',customer_lname))
when customer_gender='m' then upper(concat('Mr ',customer_fname,' ',customer_lname)) end as full_name, customer_email,customer_creation_date,
CASE
    when  Year(customer_creation_date) <2005 Then 'Category A'
    when  Year(customer_creation_date) >=2005 and Year(customer_creation_date) < 2011 Then 'Category B'
    when  Year(customer_creation_date) >= 2011 Then 'Category C'
END customer_category
    from online_customer
    ORDER BY CUSTOMER_CATEGORY;
    
    -- Question 2 -- Write a query to display the following information for the products, which have not been sold: product_id, product_desc, product_quantity_avail,
  --   product_price, inventory values (product_quantity_avail*product_price), New_Price after applying discount as per below criteria. Sort the output with respect to 
--     decreasing value of Inventory_Value. i) IF Product Price > 200,000 then apply 20% discount ii) IF Product Price > 100,000 then apply 15% discount iii) 
--      IF Product Price =< 100,000 then apply 10% discount 

select*from product;
select*from order_items;

select p.product_id,product_desc,product_quantity_avail,product_price,product_quantity_avail*product_price as inventory_value, o.*, 
CASE
	when product_price>200000 then product_price*0.80
    when product_price>100000 then product_price*0.85
    when product_price<=100000 then product_price*0.90
end as new_price
from product p
left join order_items o
on p.product_id=o.product_id
where o.order_id is null
order by inventory_value desc;


-- Question 3-  Write a query to display Product_class_code, Product_class_description, Count of Product type in each productclass, Inventory Value
--  (p.product_quantity_avail*p.product_price). Information should be displayed for only those product_class_code which have more than 1,00,000. Inventory Value. 
--  Sort the output with respect to decreasing value of Inventory_Value. 

select * from product;
select* from product_class;
select * from product;

select p.product_class_code,count(*),product_class_desc,sum(p.product_quantity_avail*p.product_price) as inventory_value
from product p
inner join product_class as ps
on p.product_class_code=ps.product_class_code 
group by product_class_code,product_class_desc
having inventory_value >100000;

-- Question 4 - Write a query to display customer_id, full name, customer_email, customer_phone and country of customers who have cancelled all the orders placed by them
 select * from online_customer;
 select* from address;
 select*from order_header;
 
 -- By using Multiple Table Joins 
 select oh.customer_id, concat(customer_fname, ' ' , customer_lname) as full_name, customer_email,customer_phone,oh.order_status,ads.country from online_customer as oc
 inner join address as ads on oc.address_id=ads.address_id inner join order_header as oh on oh.customer_id=oc.customer_id
 where order_status='cancelled';
 
 -- By using Sub query
 select distinct customer_id from order_header
 where order_status='cancelled';
 
select oc.customer_id, concat(customer_fname, ' ' , customer_lname) as full_name, customer_email,customer_phone,ads.country from online_customer as oc
inner join address as ads on oc.address_id=ads.address_id
and oc.customer_id in ( select distinct customer_id from order_header
 where order_status='cancelled');
 
 -- Question no. 5 - Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city and number of 
 -- consignments delivered to that city for Shipper DHL 
 
 select * from online_customer;
 select* from address;
 select*from order_header;
 SELECT * FROM shipper;
 
 select S.SHIPPER_NAME,
 A.CITY,COUNT(distinct oc.CUSTOMER_ID)  CUSTOMERS_CATERED,
 COUNT(OH.ORDER_ID)  ORDERS_DELIVERED from shipper S 
 INNER JOIN order_header OH 
 ON OH.SHIPPER_ID=S.SHIPPER_ID
 INNER JOIN online_customer OC
 ON OC.CUSTOMER_ID=OH.CUSTOMER_ID
 INNER JOIN  ADDRESS A 
 ON A.ADDRESS_ID=OC.ADDRESS_ID
 WHERE S.SHIPPER_NAME='DHL'
 GROUP BY S.SHIPPER_NAME,A.CITY
 ORDER BY S.SHIPPER_NAME,A.CITY;
 
 
  select * from online_customer;
 select* from address;
 select*from order_header;
 SELECT * FROM shipper;
 
select shipper_name,ads.city,count(distinct oc.customer_id) as customer_catered ,count(oh.order_id) as number_consignment from shipper as sh
inner join order_header as oh on sh.shipper_id=oh.shipper_id
inner join online_customer oc on oh.customer_id=oc.customer_id
inner join address as ads on oc.address_id=ads.address_id
where shipper_name='DHL'
group by shipper_name,city
ORDER BY SHIPPER_NAME,Ads.
CITY;

-- Question no. 6 -  Write a query to display product_id, product_desc, product_quantity_avail, quantity sold, quantity available and show inventory Status of products as 
-- below as per below condition: a. For Electronics and Computer categories, if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
-- if inventory quantity is less than 10% of quantity sold,show 'Low inventory, need to add inventory', if inventory quantity is less than 50% of quantity sold, show 
-- 'Medium inventory, need to add some inventory', if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' b. For Mobiles and Watches 
-- categories, if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', if inventory quantity is less than 20% of quantity sold, show 
-- 'Low inventory, need to add inventory', if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
-- if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' c. Rest of the categories, if sales till date is Zero then show
--  'No Sales in past, give discount to reduce inventory', if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
--  if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory', if inventory quantity is more or equal to 70% of
--  quantity sold, show 'Sufficient inventory'

select* from product;
select*from product_class;
select*from order_header;
select *from order_items;

with a as
(select distinct pd.product_id,pd.product_desc,pd.product_quantity_avail,sum(product_quantity) over(partition by product_id) 
as quantity_sold,product_class_desc
from product pd
left join order_items as oi on pd.product_id=oi.product_id
inner join product_class as pc on pd.product_class_code=pc.product_class_code)
select product_id,product_desc,product_quantity_avail,case when quantity_sold is null then 0 else quantity_sold end as quantity_sold,product_class_desc,
CASE
when product_class_desc in ('Electronics','Computer') and quantity_sold is null then 'No Sales in past, give discount to reduce inventory'
when product_class_desc in ('Electronics','Computer') and product_quantity_avail<(0.10*quantity_sold) then 'Low inventory, need to add inventory'
when product_class_desc in ('Electronics','Computer') and product_quantity_avail<(0.50*quantity_sold) then 'Medium inventory, need to add some inventory'
when product_class_desc in ('Electronics','Computer') and product_quantity_avail>=(0.50*quantity_sold) then 'Sufficient inventory'

when product_class_desc in ('Mobiles','Watches') and quantity_sold is null then 'No Sales in past, give discount to reduce inventory'
when product_class_desc in ('Mobiles','Watches') and product_quantity_avail<(0.20*quantity_sold) then 'Low inventory, need to add inventory'
when product_class_desc in ('Mobiles','Watches') and product_quantity_avail<(0.60*quantity_sold) then 'Medium inventory, need to add some inventory'
when product_class_desc in ('Mobiles','Watches') and product_quantity_avail>=(0.60*quantity_sold) then 'Sufficient inventory'

when product_class_desc not in ('Electronics','Computer','Mobiles','Watches') and quantity_sold is null then 'No Sales in past, give discount to reduce inventory'
when product_class_desc not in ('Electronics','Computer','Mobiles','Watches') and product_quantity_avail<(0.30*quantity_sold) then 'Low inventory, need to add inventory'
when product_class_desc not in ('Electronics','Computer','Mobiles','Watches') and product_quantity_avail<(0.70*quantity_sold) then 'Medium inventory, need to add some inventory'
when product_class_desc not in ('Electronics','Computer','Mobiles','Watches') and product_quantity_avail>=(0.70*quantity_sold) then 'Sufficient inventory'
end as inventory_status
from a;

-- Question 7 Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 

select*from product;
select (len*width*height) as volume_of_carton_10 from carton
where carton_id=10;
select *from order_items;

select distinct order_id,volume_orderid_wise from (select order_id,p.product_id,product_quantity,len,width,height,
(len*width*(case when height is null then 1 else height end))*product_quantity as volume,
sum((len*width*(case when height is null then 1 else height end))*product_quantity)
over(partition by order_id)as volume_orderid_wise from product as p
inner join order_items as oi on p.product_id=oi.product_id) as ab
where volume_orderid_wise<=(select (len*width*height) as volume_of_carton_10 from carton
where carton_id=10)
order by volume_orderid_wise desc
limit 1;

-- Question 8- Write a query to display customer id, customer full name, total quantity and
--  total value (quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G' 

select * from online_customer;
select * from order_items;
select*from product;
select*from order_header;

select  oc.customer_id,concat(customer_fname, ' ' , customer_lname) as full_name,
sum(product_quantity) as product_quantity,sum(product_quantity*product_price) as total_value,payment_mode from online_customer as oc
inner join order_header as oh on oc.customer_id=oh.customer_id
inner join order_items as oi on oh.order_id=oi.order_id
inner join product as p on p.product_id=oi.product_id
where payment_mode='Cash' and customer_lname like 'G%'
group by customer_id,full_name;
 
-- Question no. 9 Write a query to display product_id, product_desc and total quantity of products which are sold together with
--  product id 201 and are not shipped to city Bangalore and New Delhi. Display the output in descending order with respect to the tot_qty. 
 select*from order_items;
 select*from product;
 select*from order_header;
 select* from online_customer;
 select* from address;
 
 select order_id,product_id,product_quantity from  order_items where order_id in(select order_Id from order_items where 
 product_id=201);
 -- Using sub query 
 select p.product_id,product_desc,sum(product_quantity) as Overall_product_quantity from  
 (select order_id,product_id,product_quantity from  order_items where order_id in(select order_Id from order_items where 
 product_id=201)) oi 
 inner join product as p on oi.product_id=p.product_id
 inner join order_header as oh on oi.order_id=oh.order_id
 inner join online_customer as oc on oc.customer_id=oh.customer_id
 inner join address as ads on ads.address_id=oc.address_id
 where city not in ('Bangalore','New Delhi') and p.product_id != 201
 group  by product_id,product_desc
 order by overall_product_quantity desc;
 
 -- Question-10 Write a query to display the order_id,customer_id and customer fullname,
 -- total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
 select*from order_items;
 select*from order_header;
 select* from online_customer;
 select* from address;
 
 select oi.order_id,oc.customer_id,concat(customer_fname, ' ' , customer_lname) as full_name,sum(product_quantity) as Total_quantity from order_items as oi
 inner join order_header as oh on oh.order_id=oi.order_id
 inner join online_customer as oc on oc.customer_id=oh.customer_id
 inner join address as ads on ads.address_id=oc.address_id
 where oi.order_id%2=0 and pincode not like '5%'
 group by oi.order_id,customer_id,full_name;
 
 
 
 