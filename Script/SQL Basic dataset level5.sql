--Level 5: Arithmetic + filtering (analytics style)
--Q1. Show order_id and total_revenue (qty * price) for all orders.

select order_id, qty*price as total_revenue
from sales_practice

--Q2. Show only orders where total revenue is above 600.
select *, qty*price as total_revenue 
from sales_practice
where qty*price>600 

--Q3. Show order_id and net_revenue (qty * price - discount) for orders where a discount exists.
select order_id , qty*price -discount as net_revenue
from sales_practice
where discount is not null


