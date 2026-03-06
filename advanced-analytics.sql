USE library_management

-- Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue. 

SELECT * FROM issued_status

SELECT * FROM return_status

SELECT * FROM members

SELECT
mem.member_id,
mem.member_name,
bks.book_title,
stats.issued_date AS issue_date,
DATEADD(day,30,stats.issued_date) AS return_date,
rtn.return_date AS returned_date,
CASE 
    WHEN rtn.return_date IS NOT NULL 
        THEN DATEDIFF(day, DATEADD(day,30,stats.issued_date), rtn.return_date)
    ELSE 
        DATEDIFF(day, DATEADD(day,30,stats.issued_date), GETDATE())
END AS overdue_days    
FROM issued_status AS stats
LEFT JOIN return_status AS rtn
ON stats.issued_id = rtn.issued_id
LEFT JOIN members AS mem
ON mem.member_id = stats.issued_member_id
LEFT JOIN books AS bks
ON stats.issued_book_isbn = bks.isbn
WHERE rtn.return_date > DATEADD(day,30,stats.issued_date) OR rtn.issued_id IS NULL
ORDER BY member_id


-- Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
--(yes is already exists so change status to no where books still doesnt returned)
UPDATE books
SET status = 'no'
WHERE books.isbn IN (
    SELECT 
sts.issued_book_isbn
FROM issued_status AS sts
LEFT JOIN return_status AS rtn
ON sts.issued_id = rtn.issued_id
WHERE rtn.issued_id IS NULL
)

-- Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals

WITH CTE_based AS (
SELECT
    sts.issued_id as issued_id,
    sts.issued_book_isbn as books_isbn,
    emp.emp_id AS emp_id,
    bks.rental_price AS rental_price,
    bra.branch_id as branch_id
FROM issued_status AS sts
LEFT JOIN employees AS emp
ON sts.issued_emp_id = emp.emp_id
LEFT JOIN books AS bks
ON sts.issued_book_isbn = bks.isbn
LEFT JOIN branch AS bra
ON emp.branch_id = bra.branch_id
),
CTE_second AS (
SELECT
    ctb.branch_id as sec_branch_id,
    COUNT(rts.issued_id) as returned_count,
    SUM(rental_price) AS revenue,
    COUNT(ctb.issued_id) as nr_of_books_issued
FROM CTE_based AS ctb
LEFT JOIN return_status AS rts
ON ctb.issued_id = rts.issued_id
GROUP BY ctb.branch_id
)
SELECT
    ct1.branch_id,
    returned_count,
    revenue,
    nr_of_books_issued
FROM CTE_based AS ct1
LEFT JOIN CTE_second AS ct2
ON ct1.branch_id = ct2.sec_branch_id
GROUP BY ct1.branch_id , 
        returned_count , 
        revenue , 
        nr_of_books_issued

-- Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months

SELECT 
    mem.member_id AS issued_member_id
INTO active_members
FROM issued_status AS stats
LEFT JOIN members AS mem
ON stats.issued_member_id =  mem.member_id
WHERE mem.member_id IS NOT NULL AND stats.issued_date >= DATEADD(MONTH,-2,CAST(GETDATE() AS DATE))
GROUP BY mem.member_id
HAVING COUNT(*) >= 1

SELECT DATEADD(MONTH,-2,CAST(GETDATE() AS DATE))

-- count how many books issued every month
SELECT
DATETRUNC(MONTH,issued_date) as month,
COUNT(*) issue_count
FROM issued_status
GROUP BY DATETRUNC(MONTH,issued_date)

-- Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch


SELECT TOP(3)
emp.emp_name AS employee_name,
sts.issued_emp_id,
COUNT(issued_book_isbn) AS nr_of_books,
emp.branch_id AS branch
FROM issued_status AS sts
LEFT JOIN employees AS emp
ON sts.issued_emp_id = emp.emp_id
GROUP BY sts.issued_emp_id , emp.emp_name , emp.branch_id
ORDER BY COUNT(issued_book_isbn)  DESC

-- Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

SELECT 
sts.issued_member_id,
COUNT(sts.issued_book_isbn) AS count
FROM issued_status AS sts
LEFT JOIN members AS mem
ON sts.issued_member_id = mem.member_id
LEFT JOIN books AS bks
ON sts.issued_book_isbn = bks.isbn
WHERE bks.status = 'damaged'
GROUP BY issued_member_id
HAVING COUNT(sts.issued_book_isbn) > 2

-- Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
--The procedure should first check if the book is available (status = 'yes'). 
--If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
--If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.


CREATE PROCEDURE issued_books
    @book_id NVARCHAR(30),
    @issued_id NVARCHAR(20),
    @issued_member_id NVARCHAR(20),
    @issued_book_name NVARCHAR(100),
    @issued_date DATE,
    @issued_emp_id NVARCHAR(25)
AS 
BEGIN
     DECLARE @book_status NVARCHAR(20)
     SELECT
     @book_status = status
     FROM books
     WHERE isbn = @book_id

     -- check status
     IF @book_status = NULL
         BEGIN
         PRINT('This book isnt exists...')
         END;
     ELSE IF @book_status = 'yes'
         BEGIN 
         INSERT INTO issued_status (
             issued_id,
             issued_member_id,
             issued_book_name,
             issued_date,
             issued_book_isbn,
             issued_emp_id)
         VALUES (
             @issued_id,
             @issued_member_id,
             @issued_book_name,
             @issued_date,
             @book_id,
             @issued_emp_id)
     
         -- update book status
         UPDATE books
         set status = 'no'
         WHERE isbn = @book_id

         PRINT('book added successfully')
         END;
      ELSE BEGIN 
      PRINT('This book currently unavailable')
      END;

END;

-- Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
-- The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
-- The number of books issued by each member. 
-- The resulting table should show: Member ID Number of overdue books Total fines
WITH CTE_first_cte AS (
SELECT
issued_member_id,
DATEDIFF(DAY, DATEADD(DAY,30,issued_date),GETDATE()) AS over_due_days,
DATEDIFF(DAY, DATEADD(DAY,30,issued_date),GETDATE()) * 0.50 AS fined,
sts.issued_book_isbn AS nr_of_books
FROM issued_status AS sts
LEFT JOIN return_status AS rtn
ON sts.issued_id = rtn.issued_id
WHERE return_date > DATEADD(DAY,30,issued_date) OR return_date IS NULL
)
,
second_cte AS (
SELECT 
issued_member_id,
SUM(fined) AS fined,
COUNT(ct1.nr_of_books) AS nr_of_nrtn
FROM CTE_first_cte AS ct1
GROUP BY issued_member_id
)
SELECT * FROM second_cte


 -- time series analysis

SELECT
DATETRUNC(MONTH,issued_date) AS month,
COUNT(issued_book_isbn) AS book_month
FROM issued_status
GROUP BY DATETRUNC(MONTH,issued_date)
PRINT('03 month has most issued book count')

-- For each book category, rank books based on the number of times they have been issued.

SELECT 
    bks.category AS category,
    DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank
FROM books AS bks
LEFT JOIN issued_status AS sts
ON bks.isbn = sts.issued_book_isbn
GROUP BY bks.category

            ----------------------------- testing ---------------------------
            SELECT
            bks.category AS category,
            COUNT(*) bks_count
            FROM books AS bks
            LEFT JOIN issued_status AS stats
            ON bks.isbn = stats.issued_book_isbn
            GROUP BY bks.category
            ORDER BY bks_count DESC


-- For each member, list all books they have issued and assign a sequential order based on the issue date.
SELECT
issued_member_id,
issued_date,
ROW_NUMBER() OVER(PARTITION BY issued_member_id ORDER BY issued_date ASC) as orders,
issued_book_name
FROM issued_status 

-- Calculate the number of days between consecutive book issues for each member.

SELECT 
*,
DATEDIFF(DAY,prev_date,issued_date) AS date_differ
FROM (
SELECT
issued_id,
issued_member_id,
issued_book_name,
issued_date,
LAG(issued_date) OVER(PARTITION BY issued_member_id ORDER BY issued_date ASC) AS prev_date
FROM issued_status 
) t

-- Calculate cumulative rental revenue over time based on issued books.
SELECT 
issued_id,
issued_book_isbn,
issued_book_name,
issued_date,
bks.isbn,
bks.rental_price,
SUM(bks.rental_price) OVER(ORDER BY issued_date ASC ) total_rental_revenue
FROM issued_status sts
LEFT JOIN books AS bks
ON sts.issued_book_isbn = bks.isbn
