# SQL Basics to Intermediate: Notes and Practice

A beginner-friendly guide to the most common SQL topics, with short examples. All examples use a small `sales` table (data included in this repo) so you can run them yourself.

## Files

| File | Description |
|------|-------------|
| `sales_practice.xlsx` | The `sales` data in Excel |
| `sales_practice.csv` | The same data as CSV, for importing into a SQL tool |
| `README.md` | This guide |

## Table of contents

1. [Sample data](#1-sample-data)
2. [SELECT basics](#2-select-basics)
3. [Filtering with WHERE and operators](#3-filtering-with-where-and-operators)
4. [Sorting and limiting](#4-sorting-and-limiting)
5. [Aggregate functions](#5-aggregate-functions)
6. [GROUP BY and HAVING](#6-group-by-and-having)
7. [Joins](#7-joins)
8. [Subqueries](#8-subqueries)
9. [Set operations](#9-set-operations)
10. [CASE expressions](#10-case-expressions)
11. [Handling NULL](#11-handling-null)
12. [Common functions](#12-common-functions)
13. [Creating and changing tables (DDL)](#13-creating-and-changing-tables-ddl)
14. [Inserting, updating, deleting (DML)](#14-inserting-updating-deleting-dml)
15. [Constraints and keys](#15-constraints-and-keys)
16. [Views](#16-views)
17. [CTEs (WITH)](#17-ctes-with)
18. [Window functions](#18-window-functions)
19. [Indexes](#19-indexes)
20. [Transactions](#20-transactions)
21. [Query order cheat sheet](#21-query-order-cheat-sheet)
22. [Practice questions](#22-practice-questions)

> Syntax is mostly standard SQL. Small differences exist between MySQL, PostgreSQL, SQL Server and SQLite (for example `LIMIT` vs `TOP`). Differences are noted where they matter.

---

## 1. Sample data

Table `sales`:

| order_id | customer | region | product | category | qty | price | order_date | discount |
|----------|----------|--------|---------|----------|-----|-------|------------|----------|
| 101 | Priya  | NSW | Laptop     | Electronics | 1 | 1200 | 2026-01-10 | 100  |
| 102 | Tom    | VIC | Mouse      | Accessories | 3 | 25   | 2026-01-15 | NULL |
| 103 | Sara   | QLD | Monitor    | Electronics | 2 | 300  | 2026-02-03 | 50   |
| 104 | Arjun  | NSW | Desk       | Furniture   | 1 | 450  | 2026-02-18 | NULL |
| 105 | Mei    | WA  | Keyboard   | Accessories | 2 | 80   | 2026-03-07 | 10   |
| 106 | Liam   | VIC | Chair      | Furniture   | 4 | 150  | 2026-03-21 | 0    |
| 107 | Aisha  | NSW | Headphones | Accessories | 1 | 200  | 2026-04-02 | NULL |
| 108 | Carlos | QLD | Laptop     | Electronics | 2 | 1200 | 2026-04-12 | 200  |

A second small table, `regions`, is used for joins:

| region_code | region_name        |
|-------------|--------------------|
| NSW | New South Wales   |
| VIC | Victoria          |
| QLD | Queensland        |
| WA  | Western Australia |
| SA  | South Australia   |

A blank or `NULL` discount means no value was recorded. A discount of `0` (order 106) is a real value.

---

## 2. SELECT basics

`SELECT` reads data from a table.

```sql
SELECT * FROM sales;                         -- all columns
SELECT customer, product FROM sales;         -- chosen columns
SELECT DISTINCT region FROM sales;           -- unique values only: NSW, VIC, QLD, WA
SELECT customer AS buyer FROM sales;         -- alias (rename in output)
SELECT order_id, qty * price AS total FROM sales;   -- calculated column
```

## 3. Filtering with WHERE and operators

`WHERE` keeps only the rows that match a condition.

| Need | Use | Example |
|------|-----|---------|
| Compare | `=` `<>` `>` `<` `>=` `<=` | `WHERE price > 500` |
| Combine | `AND` `OR` `NOT` | `WHERE region = 'NSW' AND qty = 1` |
| Range (inclusive) | `BETWEEN` | `WHERE qty BETWEEN 2 AND 3` |
| One of a list | `IN` | `WHERE region IN ('NSW', 'QLD')` |
| Text pattern | `LIKE` | `WHERE customer LIKE 'A%'` |
| Missing value | `IS NULL` | `WHERE discount IS NULL` |

`LIKE` wildcards: `%` = any number of characters, `_` = exactly one character.

```sql
SELECT * FROM sales
WHERE (region = 'NSW' OR region = 'QLD') AND price > 250;
```

Use brackets when mixing `AND` and `OR`, because `AND` is evaluated first.

## 4. Sorting and limiting

```sql
SELECT * FROM sales ORDER BY price DESC;               -- highest price first
SELECT * FROM sales ORDER BY region ASC, price DESC;   -- sort by two columns
SELECT * FROM sales ORDER BY price DESC LIMIT 3;       -- top 3 (MySQL, PostgreSQL, SQLite)
SELECT TOP 3 * FROM sales ORDER BY price DESC;         -- same in SQL Server
```

## 5. Aggregate functions

Aggregates summarise many rows into one value.

```sql
SELECT COUNT(*)      FROM sales;     -- 8 (number of rows)
SELECT COUNT(discount) FROM sales;   -- 5 (ignores NULLs)
SELECT SUM(qty)      FROM sales;     -- total quantity
SELECT AVG(price)    FROM sales;     -- average price
SELECT MIN(price), MAX(price) FROM sales;
SELECT COUNT(DISTINCT region) FROM sales;   -- 4
```

## 6. GROUP BY and HAVING

`GROUP BY` makes one summary row per group. `HAVING` filters groups (like `WHERE`, but after grouping).

```sql
SELECT region, SUM(qty * price) AS revenue
FROM sales
GROUP BY region;

SELECT category, COUNT(*) AS orders
FROM sales
GROUP BY category
HAVING COUNT(*) > 2;
```

`WHERE` filters rows before grouping. `HAVING` filters after.

## 7. Joins

Joins combine rows from two tables using a matching column.

```sql
-- INNER JOIN: only matching rows
SELECT s.order_id, s.customer, r.region_name
FROM sales s
INNER JOIN regions r ON s.region = r.region_code;

-- LEFT JOIN: all rows from the left table, matches from the right (NULL if none)
SELECT r.region_name, s.order_id
FROM regions r
LEFT JOIN sales s ON r.region_code = s.region;
-- South Australia appears with order_id NULL because it has no sales

-- RIGHT JOIN: the reverse of LEFT JOIN
-- FULL OUTER JOIN: all rows from both tables (not available in MySQL)
-- CROSS JOIN: every row paired with every row
```

| Join | Keeps |
|------|-------|
| `INNER JOIN` | Only rows that match in both tables |
| `LEFT JOIN` | All left rows, plus matches from the right |
| `RIGHT JOIN` | All right rows, plus matches from the left |
| `FULL JOIN` | All rows from both |

## 8. Subqueries

A query inside another query.

```sql
-- Orders priced above the average price
SELECT * FROM sales
WHERE price > (SELECT AVG(price) FROM sales);

-- Customers in regions that have a Laptop order
SELECT DISTINCT customer FROM sales
WHERE region IN (SELECT region FROM sales WHERE product = 'Laptop');

-- EXISTS checks whether the subquery returns any row
SELECT region_name FROM regions r
WHERE EXISTS (SELECT 1 FROM sales s WHERE s.region = r.region_code);
```

## 9. Set operations

Combine the results of two queries (same number and type of columns).

```sql
SELECT customer FROM sales WHERE region = 'NSW'
UNION
SELECT customer FROM sales WHERE category = 'Furniture';   -- removes duplicates

-- UNION ALL keeps duplicates
-- INTERSECT: rows in both results
-- EXCEPT (MINUS in Oracle): rows in the first but not the second
```

## 10. CASE expressions

If/else logic inside a query.

```sql
SELECT order_id,
       qty * price AS total,
       CASE
         WHEN qty * price >= 1000 THEN 'High'
         WHEN qty * price >= 300  THEN 'Medium'
         ELSE 'Low'
       END AS order_size
FROM sales;
```

## 11. Handling NULL

`NULL` means unknown or missing. It is not zero and not an empty string.

```sql
SELECT * FROM sales WHERE discount IS NULL;        -- correct
SELECT * FROM sales WHERE discount = NULL;         -- WRONG: never matches

SELECT order_id, COALESCE(discount, 0) AS discount_clean FROM sales;   -- replace NULL with 0
```

Comparisons with `NULL` are never true, so `WHERE discount < 100` drops the NULL rows. Add `OR discount IS NULL` to keep them.

## 12. Common functions

Function names vary slightly by database.

```sql
-- Text
SELECT UPPER(customer), LOWER(customer), LENGTH(customer) FROM sales;
SELECT CONCAT(customer, ' - ', product) FROM sales;
SELECT SUBSTRING(customer, 1, 3) FROM sales;     -- first 3 letters
SELECT TRIM('  hello  ');

-- Numbers
SELECT ROUND(qty * price * 0.1, 2) FROM sales;   -- also CEIL, FLOOR, ABS

-- Dates
SELECT EXTRACT(MONTH FROM order_date) FROM sales;     -- PostgreSQL/MySQL
SELECT YEAR(order_date), MONTH(order_date) FROM sales;  -- MySQL/SQL Server
SELECT CURRENT_DATE;
```

## 13. Creating and changing tables (DDL)

DDL (Data Definition Language) defines structure.

```sql
CREATE TABLE sales (
  order_id   INT PRIMARY KEY,
  customer   VARCHAR(50) NOT NULL,
  region     VARCHAR(3),
  product    VARCHAR(50),
  category   VARCHAR(30),
  qty        INT,
  price      DECIMAL(10,2),
  order_date DATE,
  discount   DECIMAL(10,2)
);

ALTER TABLE sales ADD COLUMN notes VARCHAR(100);   -- add a column
ALTER TABLE sales DROP COLUMN notes;               -- remove a column
DROP TABLE sales;                                  -- delete the whole table
TRUNCATE TABLE sales;                              -- remove all rows, keep the table
```

Common data types: `INT`, `DECIMAL(p,s)`, `VARCHAR(n)`, `TEXT`, `DATE`, `TIMESTAMP`, `BOOLEAN`.

## 14. Inserting, updating, deleting (DML)

DML (Data Manipulation Language) changes data.

```sql
INSERT INTO sales (order_id, customer, region, product, category, qty, price, order_date, discount)
VALUES (109, 'Eva', 'SA', 'Desk', 'Furniture', 1, 450, '2026-05-01', NULL);

UPDATE sales SET discount = 25 WHERE order_id = 102;

DELETE FROM sales WHERE order_id = 109;
```

Always include `WHERE` with `UPDATE` and `DELETE`. Without it, every row is changed or removed.

## 15. Constraints and keys

Rules that keep data valid.

| Constraint | Purpose |
|------------|---------|
| `PRIMARY KEY` | Uniquely identifies each row (not null, unique) |
| `FOREIGN KEY` | Links to a primary key in another table |
| `UNIQUE` | No duplicate values in the column |
| `NOT NULL` | Value is required |
| `CHECK` | Value must satisfy a condition |
| `DEFAULT` | Value used when none is given |

```sql
CREATE TABLE regions (
  region_code VARCHAR(3) PRIMARY KEY,
  region_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE sales (
  order_id INT PRIMARY KEY,
  region   VARCHAR(3),
  qty      INT CHECK (qty > 0),
  status   VARCHAR(10) DEFAULT 'new',
  FOREIGN KEY (region) REFERENCES regions(region_code)
);
```

## 16. Views

A saved query that behaves like a table.

```sql
CREATE VIEW high_value_orders AS
SELECT order_id, customer, qty * price AS total
FROM sales
WHERE qty * price > 600;

SELECT * FROM high_value_orders;
DROP VIEW high_value_orders;
```

## 17. CTEs (WITH)

A Common Table Expression is a named temporary result that makes long queries easier to read.

```sql
WITH region_totals AS (
  SELECT region, SUM(qty * price) AS revenue
  FROM sales
  GROUP BY region
)
SELECT * FROM region_totals
WHERE revenue > 1000
ORDER BY revenue DESC;
```

## 18. Window functions

Calculate across related rows without collapsing them into one row (unlike `GROUP BY`).

```sql
-- Rank orders by revenue within each region
SELECT order_id, region, qty * price AS total,
       RANK() OVER (PARTITION BY region ORDER BY qty * price DESC) AS rank_in_region
FROM sales;

-- Running total by date
SELECT order_id, order_date, qty * price AS total,
       SUM(qty * price) OVER (ORDER BY order_date) AS running_total
FROM sales;

-- Previous row's value
SELECT order_id, qty * price AS total,
       LAG(qty * price) OVER (ORDER BY order_date) AS previous_total
FROM sales;
```

Other useful ones: `ROW_NUMBER()`, `DENSE_RANK()`, `LEAD()`, `AVG() OVER (...)`.

## 19. Indexes

An index speeds up searches on a column, at the cost of slightly slower writes.

```sql
CREATE INDEX idx_sales_region ON sales(region);
DROP INDEX idx_sales_region;        -- exact syntax varies by database
```

Index columns you often use in `WHERE`, `JOIN` and `ORDER BY`.

## 20. Transactions

A transaction groups statements so they all succeed or all fail.

```sql
BEGIN;                                           -- START TRANSACTION in MySQL
UPDATE sales SET qty = qty - 1 WHERE order_id = 101;
UPDATE sales SET qty = qty + 1 WHERE order_id = 108;
COMMIT;                                          -- save both changes
-- ROLLBACK;                                     -- or undo both
```

Transactions follow the ACID properties: Atomicity, Consistency, Isolation, Durability.

## 21. Query order cheat sheet

You write a query in this order:

```
SELECT -> FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> ORDER BY -> LIMIT
```

The database runs it in this order:

```
FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT
```

That is why a column alias created in `SELECT` cannot be used in `WHERE`.

## 22. Practice questions

Load `sales_practice.csv` into a SQL tool as a table named `sales`, then try these. Answers are below.

1. List all orders where the price is more than 500.
2. Find orders from NSW with quantity of 1.
3. Find orders placed between 1 February 2026 and 31 March 2026.
4. List orders from NSW, QLD, or WA using `IN`.
5. Find customers whose name starts with `A`.
6. List orders that have no discount recorded.
7. Show total revenue (`qty * price`) per region, highest first.
8. Show categories with more than 2 orders.
9. Show each order's customer and region name (join with `regions`).
10. Find orders priced above the average price.
11. Label each order High, Medium or Low by total revenue.
12. Rank orders by revenue within each region.

<details>
<summary>Answers</summary>

```sql
-- 1  (101, 108)
SELECT * FROM sales WHERE price > 500;

-- 2  (101, 104, 107)
SELECT * FROM sales WHERE region = 'NSW' AND qty = 1;

-- 3  (103, 104, 105, 106)
SELECT * FROM sales WHERE order_date BETWEEN '2026-02-01' AND '2026-03-31';

-- 4  (101, 103, 104, 105, 107, 108)
SELECT * FROM sales WHERE region IN ('NSW', 'QLD', 'WA');

-- 5  (Arjun, Aisha)
SELECT customer FROM sales WHERE customer LIKE 'A%';

-- 6  (102, 104, 107)
SELECT * FROM sales WHERE discount IS NULL;

-- 7
SELECT region, SUM(qty * price) AS revenue
FROM sales
GROUP BY region
ORDER BY revenue DESC;

-- 8  (Electronics 3, Accessories 3)
SELECT category, COUNT(*) AS orders
FROM sales
GROUP BY category
HAVING COUNT(*) > 2;

-- 9
SELECT s.customer, r.region_name
FROM sales s
JOIN regions r ON s.region = r.region_code;

-- 10  (101, 108)  average price is about 450.63, so order 104 (450) is not above it
SELECT * FROM sales
WHERE price > (SELECT AVG(price) FROM sales);

-- 11
SELECT order_id,
       CASE
         WHEN qty * price >= 1000 THEN 'High'
         WHEN qty * price >= 300  THEN 'Medium'
         ELSE 'Low'
       END AS order_size
FROM sales;

-- 12
SELECT order_id, region, qty * price AS total,
       RANK() OVER (PARTITION BY region ORDER BY qty * price DESC) AS rank_in_region
FROM sales;
```

</details>

## Key takeaways

- Use `IS NULL`, never `= NULL`.
- `AND` runs before `OR`, so use brackets.
- `WHERE` filters rows, `HAVING` filters groups.
- Always add `WHERE` to `UPDATE` and `DELETE`.
- Pick the join type by which unmatched rows you want to keep.

