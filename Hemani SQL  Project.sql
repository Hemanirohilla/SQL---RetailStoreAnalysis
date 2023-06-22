-- SQL Project  

-- Looking at customer full name along with title in upper case, customer email id, customer creation date 
-- and cateogorizing customers according to customer creation date in
-- IF customer creation date Year <2005 Then Category A 
-- If customer creation date Year >=2005 and <2011 Then Category B 
-- IF customer creation date Year>= 2011 Then Category C Hint: Use CASE statement, no permanent 

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


-- Looking at product_id, product_desc, product_quantity, product_price, inventory values (product_quantity_avail*product_price), New_Price after applying discount.

-- Sort the output with respect to decreasing value of Inventory_Value. 
-- cateogorizing customers according to product price-
-- IF Product Price > 200,000 then apply 20% discount 
-- IF Product Price > 100,000 then apply 15% discount iii) 
-- IF Product Price =< 100,000 then apply 10% discount 



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


--  Display  Product_class_code, Product_class_description, Count of Product type in each productclass, Inventory Value.
--  (p.product_quantity_avail*p.product_price)
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

-- Display customer_id, full name, customer_email, customer_phone and country of customers who have cancelled all the orders placed by them
 select * from online_customer;
 select* from address;
 select*from order_header;
 
 -- By using Multiple Table Joins 
 select oh.customer_id, concat(customer_fname, ' ' , customer_lname) as full_name, customer_email,customer_phone,oh.order_status,ads.country from online_customer as oc
 inner join address as ads on oc.address_id=ads.address_id inner join order_header as oh on oh.customer_id=oc.customer_id
 where order_status='cancelled';


-- Display customer id, customer full name, total quantity and
--  total value (quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G' 

select * from online_customer;
select * from order_items;
select*from product;
select*from order_header;

select  oc.customer_id,concat(customer_fname, ' ' , customer_lname) as full_name,
sum(product_quantity) as product_quantity,sum(product_quantity*product_price) as total_value,payment_mode 
from online_customer as oc
inner join order_header as oh on oc.customer_id=oh.customer_id
inner join order_items as oi on oh.order_id=oi.order_id
inner join product as p on p.product_id=oi.product_id
where payment_mode='Cash' and customer_lname like 'G%'
group by customer_id,full_name;
 


 
 
 
 
