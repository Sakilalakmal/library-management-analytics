# Library Management System — SQL Data Analysis Project
<img width="800" height="400" alt="git" src="https://github.com/user-attachments/assets/f0220ac4-0212-472b-b6ca-448a99518bbb" />

## Project Overview

This project presents a comprehensive **Library Management System** built entirely on **Microsoft SQL Server (T-SQL)**. It walks through the complete data lifecycle — relational schema design, bulk CSV ingestion, referential integrity enforcement, and two tiers of analytical work: **basic exploratory analysis** and **advanced analytics** leveraging CTEs, window functions, stored procedures, and time-series techniques. The end goal is to surface actionable operational insights around book inventory health, member engagement, branch-level performance, overdue risk, and cumulative revenue trends.

## Objectives

- Architect a normalized relational schema across 6 interconnected tables
- Ingest raw CSV data into SQL Server via `BULK INSERT`
- Enforce data quality through primary keys, foreign keys, and pre-load validation checks
- Execute standard CRUD operations (Create, Read, Update, Delete)
- Conduct exploratory analysis using aggregations, joins, and filtering
- Perform advanced analytics using **CTEs**, **window functions** (`DENSE_RANK`, `ROW_NUMBER`, `LAG`, cumulative `SUM`), **stored procedures**, **subquery-driven updates**, and **time-series aggregation**
- Generate derived tables (CTAS pattern) for overdue fines, active members, and branch performance reporting

## Database Schema & ERD

The database `library_management` consists of **6 core tables** with the following relationships:

```
branch (branch_id PK)
  │
  └──< employees (emp_id PK, branch_id FK → branch)
              │
              └──< issued_status (issued_id PK, issued_emp_id FK → employees,
                                  issued_member_id FK → members,
                                  issued_book_isbn FK → books)
                          │
                          └──< return_status (return_id, issued_id FK → issued_status)

members (member_id PK) ──────────────┘
books   (isbn PK) ───────────────────┘
```

### Table Details

| Table | Key Columns | Description |
|---|---|---|
| **branch** | `branch_id`, `manager_id`, `branch_address`, `contact_no` | Library branch locations |
| **employees** | `emp_id`, `emp_name`, `position`, `salary`, `branch_id` | Staff information per branch |
| **books** | `isbn`, `book_title`, `category`, `rental_price`, `status`, `author`, `publisher` | Book inventory catalogue |
| **members** | `member_id`, `member_name`, `member_address`, `reg_date` | Registered library members |
| **issued_status** | `issued_id`, `issued_member_id`, `issued_book_name`, `issued_date`, `issued_book_isbn`, `issued_emp_id` | Book issue transactions |
| **return_status** | `return_id`, `issued_id`, `return_book_name`, `return_date`, `return_book_isbn` | Book return records |

## Dataset

All source data resides in the `data-set/` directory as CSV files:

| File | Records For |
|---|---|
| `branch.csv` | Branch locations |
| `employees.csv` | Employee details |
| `books.csv` | Book catalogue |
| `members.csv` | Member registrations |
| `issued_status.csv` | Issue transactions |
| `return_status.csv` | Return transactions |

## Project Structure

```
library-management/
│
├── ddl.sql                  # Schema creation & bulk data loading (without constraints)
├── SQLQuery1.sql            # Schema with primary keys, foreign keys & constraint setup
├── basic-analytics.sql      # CRUD operations & exploratory analytical queries
├── advanced-analytics.sql   # Advanced analytics — CTEs, window functions, stored procedures
├── README.md                # Project documentation
│
└── data-set/
    ├── books.csv
    ├── branch.csv
    ├── employees.csv
    ├── issued_status.csv
    ├── members.csv
    └── return_status.csv
```

---

## Phase 1 — Basic Analytics (`basic-analytics.sql`)

### CRUD Operations
- **Insert** a new book record into the catalogue
- **Update** a member's address
- **Delete** a specific issued status record

### Exploratory Queries

| # | Analysis | Technique |
|---|---|---|
| 1 | Books issued by a specific employee (`E101`) | `WHERE` filter |
| 2 | Members who issued more than one book | `GROUP BY` + `HAVING` |
| 3 | Book issue count summary table | `SELECT INTO` (CTAS) with `JOIN` + `COUNT` |
| 4 | Book count by category | `GROUP BY` aggregation |
| 5 | Total rental revenue by category | `SUM` + `JOIN` + `ORDER BY` |
| 6 | Members registered in the last 180 days | `DATEADD` + `GETDATE` |
| 7 | Employees with their branch manager name & branch details | Self `JOIN` on employees |
| 8 | Books with rental price above a threshold (> 7) | `SELECT INTO` filtered table |
| 9 | List of books not yet returned | `LEFT JOIN` + `IS NULL` pattern |

---

## Phase 2 — Advanced Analytics (`advanced-analytics.sql`)

### Overdue & Risk Analysis

| # | Analysis | Technique |
|---|---|---|
| 1 | Identify members with overdue books (30-day return policy) | `CASE`, `DATEDIFF`, `DATEADD`, multi-table `LEFT JOIN` |
| 2 | Update book status to unavailable for unreturned books | Subquery-driven `UPDATE` with `LEFT JOIN` + `IS NULL` |
| 3 | Members issuing high-risk (damaged) books more than twice | `GROUP BY` + `HAVING` with status filter |

### Branch & Employee Performance

| # | Analysis | Technique |
|---|---|---|
| 4 | Branch performance report — books issued, returned, and revenue | Multi-level **CTE** (Common Table Expressions) |
| 5 | Top 3 employees by book issues processed | `TOP(3)` + `GROUP BY` + `ORDER BY DESC` |

### Derived Tables (CTAS Pattern)

| # | Analysis | Technique |
|---|---|---|
| 6 | Active members who issued at least one book in the last 2 months | `SELECT INTO` with `DATEADD` + `HAVING` |
| 7 | Overdue books with fine calculation ($0.50/day) | **CTE** + `DATEDIFF` + calculated columns |

### Stored Procedure

| # | Analysis | Technique |
|---|---|---|
| 8 | Book issuance management — check availability, issue book, update status | `CREATE PROCEDURE` with `IF/ELSE` control flow, parameterized inputs |

### Window Functions & Time-Series

| # | Analysis | Technique |
|---|---|---|
| 9 | Monthly book issue count (time-series) | `DATETRUNC` + `COUNT` aggregation |
| 10 | Rank book categories by issue frequency | `DENSE_RANK()` window function |
| 11 | Sequential ordering of each member's book issues | `ROW_NUMBER()` with `PARTITION BY` |
| 12 | Days between consecutive book issues per member | `LAG()` window function + `DATEDIFF` |
| 13 | Cumulative rental revenue over time | `SUM() OVER(ORDER BY ...)` running total |

---

## Key Insights

- **Revenue by Category**: Identified the highest revenue-generating book categories by joining issue records with book rental prices; enables data-driven collection development decisions.
- **Overdue Detection**: Flagged all members exceeding the 30-day return policy with calculated overdue days — critical for library operations and follow-up workflows.
- **Fine Estimation**: Computed per-member overdue fines at $0.50/day using CTEs, producing a ready-to-use fines summary table.
- **Branch Performance**: Built a branch-level KPI report covering issue volume, return rate, and total rental revenue — useful for comparing branch efficiency.
- **Top Performers**: Surfaced the top 3 employees by books processed, supporting performance reviews and workload balancing.
- **Active vs. Inactive Members**: Segmented members by recent activity (last 2 months) into a derived table, enabling targeted engagement campaigns.
- **Damaged Book Risk**: Identified repeat offenders issuing damaged books, flagging potential policy enforcement needs.
- **Cumulative Revenue Trend**: Used a running `SUM` window function to visualize revenue accumulation over time — a foundational metric for financial reporting.
- **Issue Frequency Patterns**: Applied `LAG` to measure gaps between consecutive member issues, revealing borrowing behavior patterns.
- **Monthly Trends**: Time-series aggregation via `DATETRUNC` uncovered seasonal or monthly spikes in book issuance volume.

## SQL Techniques Used

| Category | Techniques |
|---|---|
| **DDL** | `CREATE DATABASE`, `CREATE TABLE`, `DROP TABLE`, `ALTER TABLE`, `ADD CONSTRAINT` |
| **DML** | `INSERT`, `UPDATE`, `DELETE`, `BULK INSERT` |
| **Joins** | `LEFT JOIN`, Self `JOIN`, multi-table joins |
| **Aggregation** | `GROUP BY`, `HAVING`, `COUNT`, `SUM` |
| **Filtering** | `WHERE`, `IN`, `IS NULL`, `TOP` |
| **Date Functions** | `DATEADD`, `DATEDIFF`, `DATETRUNC`, `GETDATE`, `CAST` |
| **CTEs** | Single and multi-level Common Table Expressions |
| **Window Functions** | `ROW_NUMBER()`, `DENSE_RANK()`, `LAG()`, `SUM() OVER()` |
| **Stored Procedures** | Parameterized procedure with `IF/ELSE` control flow |
| **CTAS** | `SELECT INTO` for derived/summary tables |
| **Subqueries** | Correlated subqueries in `UPDATE` and `WHERE IN` |

## Tech Stack

| Component | Technology |
|---|---|
| Database | Microsoft SQL Server |
| Language | T-SQL |
| Data Format | CSV |
| Data Loading | `BULK INSERT` |

## How to Run

1. Open **SQL Server Management Studio (SSMS)** or any compatible SQL Server client.
2. Execute `ddl.sql` to create the database, tables, and load data from CSV files **without** constraints.
   - Alternatively, execute `SQLQuery1.sql` for the full version **with** primary keys, foreign keys, and referential integrity constraints.
   > **Note**: Update the file paths inside `BULK INSERT` statements to match your local directory.
3. Execute `basic-analytics.sql` to run CRUD operations and exploratory queries.
4. Execute `advanced-analytics.sql` to run advanced analytics — CTEs, window functions, stored procedures, and time-series analysis.

## Author

**Sakila Lakmal**

---

*This project is part of a data engineering & data analytics learning portfolio.*
