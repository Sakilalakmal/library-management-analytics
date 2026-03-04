USE library_management

-- Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
SELECT * FROM books

-- Update an Existing Member's Address
SELECT * FROM members
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101'

-- Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM  issued_status
WHERE issued_id = 'IS121'

SELECT * FROM issued_status

-- Select all books issued by the employee with emp_id = 'E101'
SELECT
issued_book_name
FROM issued_status
WHERE issued_emp_id = 'E101'

--Use GROUP BY to find members who have issued more than one book
SELECT
issued_member_id
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1

-- Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
SELECT
bk.isbn,
bk.book_title,
bk.author,
COUNT(*) as count
INTO book_issued_count
FROM books AS bk
LEFT JOIN issued_status
ON bk.isbn = issued_status.issued_book_isbn
GROUP BY bk.isbn , bk.book_title,
bk.author

-- Retrieve All Books in a Specific Category
SELECT
books.category,
COUNT(*) count
FROM books
GROUP BY books.category

-- Find Total Rental Income by Category
SELECT
bks.category AS category,
SUM(bks.rental_price) AS total_revenue
FROM issued_status as stats
LEFT JOIN books AS bks
ON stats.issued_book_isbn = bks.isbn
GROUP BY bks.category
ORDER BY total_revenue DESC

-- List Members Who Registered in the Last 180 Days
SELECT * FROM members
WHERE reg_date >= DATEADD(day , -180 , GETDATE())


--List Employees with Their Branch Manager's Name and their branch details
SELECT 
	*,
brch.branch_address,
brch.contact_no,
emp2.emp_name as manager_name
FROM employees AS emp
LEFT JOIN branch AS brch
ON emp.branch_id = brch.branch_id
LEFT JOIN employees AS emp2
ON emp2.emp_id = brch.manager_id

-- Create a Table of Books with Rental Price Above a Certain Threshold

SELECT * INTO high_rental_books FROM books WHERE rental_price > 7

    ------------------------------ check that table ---------------------
	SELECT * FROM high_rental_books

-- Retrieve the List of Books Not Yet Returned
 
SELECT * FROM issued_status stats
LEFT JOIN return_status AS rs
ON stats.issued_id = rs.issued_id
WHERE rs.issued_id IS  NULL