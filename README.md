# Library Management System — Data Analysis Project

## Project Overview

This project demonstrates a complete **Library Management System** built using **Microsoft SQL Server**. It covers the full data lifecycle — from database schema design and CSV data ingestion to exploratory data analysis using SQL queries. The goal is to analyze library operations including book inventory, member activity, employee management, branch details, and rental revenue insights.

## Objectives

- Design and implement a relational database schema for a library system
- Load raw CSV data into SQL Server tables using `BULK INSERT`
- Establish referential integrity through primary keys and foreign key constraints
- Perform CRUD operations (Create, Read, Update, Delete)
- Derive meaningful business insights through analytical SQL queries

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
├── ddl.sql              # Schema creation & bulk data loading (without constraints)
├── SQLQuery1.sql        # Schema with primary keys, foreign keys & constraint setup
├── analytics.sql        # Analytical & exploratory SQL queries
├── read-me.md           # Project documentation
│
└── data-set/
    ├── books.csv
    ├── branch.csv
    ├── employees.csv
    ├── issued_status.csv
    ├── members.csv
    └── return_status.csv
```

## Analysis & Findings

The following key analyses were performed in `analytics.sql`:

### CRUD Operations
- **Insert** a new book record into the catalogue
- **Update** a member's address
- **Delete** a specific issued status record

### Analytical Queries

| # | Analysis | Technique |
|---|---|---|
| 1 | Books issued by a specific employee (`E101`) | `WHERE` filter |
| 2 | Members who issued more than one book | `GROUP BY` + `HAVING` |
| 3 | Book issue count summary table | `CTAS` (SELECT INTO) with `JOIN` + `COUNT` |
| 4 | Book count by category | `GROUP BY` aggregation |
| 5 | Total rental revenue by category | `SUM` + `JOIN` + `ORDER BY` |
| 6 | Members registered in the last 180 days | `DATEADD` + `GETDATE` |
| 7 | Employees with their branch manager name & branch details | Self `JOIN` on employees |
| 8 | Books with rental price above threshold (> 7) | `SELECT INTO` filtered table |
| 9 | List of books not yet returned | `LEFT JOIN` + `IS NULL` pattern |

### Key Insights

- **Revenue by Category**: Identified the highest revenue-generating book categories by joining issue records with book rental prices.
- **Unreturned Books**: Detected all books that have been issued but not yet returned, helping track overdue inventory.
- **Active Members**: Flagged members with multiple book issues, indicating high engagement.
- **Employee-Branch Mapping**: Mapped each employee to their branch and respective manager for organizational visibility.
- **High-Value Books**: Isolated premium books (rental price > 7) into a separate summary table for pricing analysis.

## Tech Stack

| Component | Technology |
|---|---|
| Database | Microsoft SQL Server |
| Language | T-SQL |
| Data Format | CSV |
| Data Loading | `BULK INSERT` |

## How to Run

1. Open **SQL Server Management Studio (SSMS)** or any SQL Server client.
2. Execute `ddl.sql` (or `SQLQuery1.sql` for the version with constraints) to create the database, tables, and load data from CSV files.
   > **Note**: Update the file paths inside `BULK INSERT` statements to match your local directory.
3. Execute `analytics.sql` to run the analytical queries and explore the results.

## Author

**Sakila Lakmal**

---

*This project is part of a data engineering & data analytics learning portfolio.*
