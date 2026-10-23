--Level 1: Comparison & logical operators
--Q1. List all orders where the price is more than 500.

Select *
from sales_practice
where price>500

--Q2. Find orders from NSW with quantity of 1.

Select *
From sales_practice
where region ='NSW' and qty=1

--Q3. Find orders that are in either the Furniture category or have a price above 1000.

Select *
from sales_practice
where category='Furniture' or price >1000

--Q4. List all orders not from VIC.

Select *
from sales_practice
where region <> 'VIC'