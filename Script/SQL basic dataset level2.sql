--Level 2: BETWEEN and IN
--Q1. Find orders placed between 1 February 2026 and 31 March 2026.

Select *
from sales_practice
where order_date between '2026-02-01' and '2026-03-31'

--Q2. List orders from NSW, QLD, or WA using IN.

Select *
from sales_practice
where region in ('NSW','QLD','WA')

--Q3. Find orders where quantity is between 2 and 3 and the category is Accessories.

Select *
from sales_practice
where qty between 2 and 3 and category='Accessories'