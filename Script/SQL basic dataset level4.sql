--Level 4: NULL handling
--Q1. List orders that have no discount recorded.

select *
from sales_practice
where discount is NULL

--Q2.List orders where discount is less than 100. Which rows come back, and why is order 102 missing?
Select *
from sales_practice
where discount<100
