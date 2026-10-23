--Level 3: LIKE
--Q1. Find customers whose name starts with A.

select customer
from sales_practice
where customer like 'A%'

--Q2. Find products whose name contains the letters er.
Select *
from sales_practice
where product like '%er%'

--Q3. Find customers whose name has exactly 3 letters.
Select *
from sales_practice
where customer like '___'