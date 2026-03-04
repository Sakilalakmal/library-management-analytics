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
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.