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
