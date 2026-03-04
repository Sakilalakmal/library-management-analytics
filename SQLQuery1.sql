CREATE DATABASE library_management

USE library_management

-- create branch table
IF OBJECT_ID('branch','U') IS NOT NULL
DROP TABLE branch
CREATE TABLE branch (
	branch_id NVARCHAR(25) NOT NULL PRIMARY KEY,
	manager_id	NVARCHAR(25) NOT NULL,
	branch_address NVARCHAR(100),
	contact_no NVARCHAR(50)
)
PRINT 'Truncating table before load data again into table'
TRUNCATE TABLE branch
PRINT '>> Inserting Data Into: branch-table';
BULK INSERT branch
FROM 'D:\DE-DA\library-management\data-set\branch.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
);

-- test branch table
SELECT * FROM branch

-- Employee Table

-- create employees table
IF OBJECT_ID('employees','U') IS NOT NULL
DROP TABLE employees
CREATE TABLE employees (
	emp_id	NVARCHAR(25) NOT NULL PRIMARY KEY,
	emp_name NVARCHAR(25),
	position NVARCHAR(25),
	salary INT,
	branch_id NVARCHAR(25) NOT NULL
)

PRINT 'Truncating table before load data again into table'
TRUNCATE TABLE employees
PRINT '>> Inserting Data Into: employees-table';
BULK INSERT employees
FROM 'D:\DE-DA\library-management\data-set\employees.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
);

-- test employees table
SELECT * FROM employees

-- books table

-- create book table
IF OBJECT_ID('books','U') IS NOT NULL
DROP TABLE books
CREATE TABLE books (
	isbn NVARCHAR(30) PRIMARY KEY,
	book_title	NVARCHAR(200),
	category NVARCHAR(20)	,
	rental_price INT,
	status	NVARCHAR(10),
	author	NVARCHAR(30),
	publisher NVARCHAR(25)
)

PRINT 'Truncating table before load data again into table'
TRUNCATE TABLE books
PRINT '>> Inserting Data Into: books-table';
BULK INSERT books
FROM 'D:\DE-DA\library-management\data-set\books.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
);

-- test books table
SELECT * FROM books


-- members table

-- create members table
IF OBJECT_ID('members','U') IS NOT NULL
DROP TABLE members
CREATE TABLE members (
	member_id NVARCHAR(20) NOT NULL PRIMARY KEY,
	member_name	NVARCHAR(20),
	member_address	NVARCHAR(50),
	reg_date DATE
)

PRINT 'Truncating table before load data again into table'
TRUNCATE TABLE members
PRINT '>> Inserting Data Into: members-table';
BULK INSERT members
FROM 'D:\DE-DA\library-management\data-set\members.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
);

-- test books table
SELECT * FROM members


-- issued_status table

-- create issued_status table
IF OBJECT_ID('issued_status','U') IS NOT NULL
DROP TABLE issued_status;
GO
CREATE TABLE issued_status (
	issued_id	NVARCHAR(20) NOT NULL PRIMARY KEY,
	issued_member_id NVARCHAR(20) NOT NULL,	
	issued_book_name  NVARCHAR(100),
	issued_date	DATE,
	issued_book_isbn NVARCHAR(30),	
	issued_emp_id NVARCHAR(25) NOT NULL
)

PRINT 'Truncating table before load data again into table'
TRUNCATE TABLE issued_status
PRINT '>> Inserting Data Into: issued_status-table';
BULK INSERT issued_status
FROM 'D:\DE-DA\library-management\data-set\issued_status.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
);

-- test issued_status table
SELECT * FROM issued_status

-- return_status table

-- create return_status table
IF OBJECT_ID('return_status','U') IS NOT NULL
DROP TABLE return_status;
GO
CREATE TABLE return_status (
	return_id NVARCHAR(20) NOT NULL,	
	issued_id NVARCHAR(20) NOT NULL,	
	return_book_name NVARCHAR(100),
	return_date	DATE,
	return_book_isbn NVARCHAR(20)
)

PRINT 'Truncating table before load data again into table'
TRUNCATE TABLE return_status
PRINT '>> Inserting Data Into: return_status-table';
BULK INSERT return_status
FROM 'D:\DE-DA\library-management\data-set\return_status.csv'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
);

-- test issued_status table
SELECT * FROM return_status

--Adding foreign keys
ALTER TABLE issued_status
ADD CONSTRAINT FK_issued_status_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id)

--check is there any member id doesnt exists in pk table appear in issued_status table (before set foreign keys)
SELECT
issued_member_id
FROM issued_status
WHERE issued_member_id NOT IN (
SELECT
member_id
FROM members
)

ALTER TABLE issued_status
ADD CONSTRAINT FK_books_isbn_number
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn)

ALTER TABLE issued_status
ADD CONSTRAINT FK_employee_id
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id)

ALTER TABLE employees
ADD CONSTRAINT FK_branch_id_for_employee
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id)

ALTER TABLE return_status
ADD CONSTRAINT FK_return_book_issued_id
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id)