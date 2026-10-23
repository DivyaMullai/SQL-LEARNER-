--Level 6: Business scenarios (combine everything)

--Q16. The manager wants high-value Electronics or Furniture orders (total revenue above 500) from NSW or QLD, with a discount recorded. Write one query.
select qty*price as total_revenue
from sales_practice
where category in ('Electronics', 'Furniture') 
and qty*price >500 and region in ('NSW', 'QLD')
AND discount is not null




--Q17. Find Accessories orders placed in 2026 Q1 (Jan to Mar), where the customer name does not start with M.
Select *
from sales_practice 
where category='Accessories' and   order_date between '2026-01-01' and '2026-03-31' and customer not like 'M%'