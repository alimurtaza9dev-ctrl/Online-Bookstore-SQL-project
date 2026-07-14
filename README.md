# Online Bookstore SQL Project

A relational database project built around an online bookstore — schema
design, data import, and a set of SQL queries ranging from basic filtering
to window functions, CTEs, and subqueries.

**Engine:** MySQL 8.0 (built and tested in MySQL Workbench)

## Overview

The database models three core entities in a bookstore's operations:
books in the catalog, customers, and the orders that connect them. On top
of the schema, this project answers a set of analytical questions that
go beyond basic `SELECT`/`WHERE` — running totals, per-category rankings,
month-over-month trends, and anti-joins for finding "missing" records.

## Schema

```
Books                    Customers                 Orders
---------------           ---------------           ---------------
Book_ID (PK)              Customer_ID (PK)          Order_ID (PK)
Title                      Name                       Customer_ID (FK)
Author                     Email                      Book_ID (FK)
Genre                      Phone                      Order_Date
Published_Year             City                       Quantity
Price                      Country                    Total_Amount
Stock
```

`Orders.Customer_ID` and `Orders.Book_ID` are foreign keys referencing
`Customers` and `Books` respectively — every order must point to a real
customer and a real book.

## Project structure

```
Online-Bookstore-SQL-project/
├── Online Bookstore SQL project.sql   # Full schema + all queries
├── data/
│   ├── Books.csv
│   ├── Customers.csv
│   └── Orders.csv
└── README.md
```

## Setup

1. Run the schema section at the top of the `.sql` file to create the
   database and tables (`CREATE DATABASE`, `CREATE TABLE` statements).
2. Import the three CSVs from `data/` into their matching tables. In MySQL
   Workbench: right-click each table → **Table Data Import Wizard** →
   select the corresponding CSV → import into the existing table.
   Import order matters — load `Books.csv` and `Customers.csv` before
   `Orders.csv`, since Orders has foreign keys pointing at both.
3. Run `SHOW TABLES;` and a `SELECT COUNT(*)` on each table to confirm
   the import (500 rows each).

## Query highlights

- **Running total of revenue** — `SUM(Total_Amount) OVER (ORDER BY Order_Date, Order_ID)`
  to track cumulative revenue order by order.
- **Books ranked by price within genre** — `RANK() OVER (PARTITION BY Genre ORDER BY Price DESC)`.
- **Customers with zero orders** — anti-join written with `NOT EXISTS`
  rather than `LEFT JOIN ... IS NULL`.
- **Customers spending above the average customer spend** — a subquery
  that first aggregates total spend per customer, then averages *those*
  totals (not the same as averaging raw order amounts).
- **Month-over-month revenue change** — `LAG()` inside a CTE to compare
  each month's revenue to the previous month.
- **Second-most-expensive book per genre** — `DENSE_RANK()` instead of
  `RANK()`, so tied prices don't cause a genre to skip having a "second place."
- **Email domain breakdown** — `SUBSTRING_INDEX(Email, '@', -1)` to split
  out and group by domain (e.g. Gmail vs. everything else).
- **Books that were never ordered** — a `LEFT JOIN` from `Books` to
  `Orders` filtered on `IS NULL`, to catch catalog items with zero sales.

## Data source

Sample data (500 books, 500 customers, 500 orders) is synthetic,
generated for practice purposes — not real customer or sales data.

---
Built by Ali Murtaza — [GitHub](https://github.com/alimurtaza9dev-ctrl) · [Portfolio](https://alimurtaza9dev-ctrl.github.io)
