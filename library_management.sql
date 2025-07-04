use library_db;

-- Project TASK


-- ### 2. CRUD Operations


-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title,category,rental_price,status,author,publisher)
Values 
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

select * from books;

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
SELECT * FROM issued_status
WHERE issued_id = 'IS121';

DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT ist.issued_emp_id, e.emp_id from issued_status as ist 
Join employees as e 
on e.emp_id = ist.issued_emp_id
group by 1,2
Having count(ist.issued_emp_id) > 1;


-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE book_cnts
AS    
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;


SELECT * FROM
book_cnts;


-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:
SELECT b.category, SUM(b.rental_price), COUNT(*) FROM books as b
JOIN issued_status as ist 
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;


-- Task 9. **List Members Who Registered in the Last 180 Days**:
SELECT * FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:
SELECT e1.*, b.manager_id, e2.emp_name as manager
FROM employees as e1
JOIN   branch as b
ON b.branch_id = e1.branch_id
JOIN employees as e2
ON b.manager_id = e2.emp_id;


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
CREATE TABLE books_price_greater_than_seven
AS    
SELECT * FROM Books
WHERE rental_price > 7;

SELECT * FROM 
books_price_greater_than_seven;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;
    
SELECT * FROM return_status;
    
/*
### Advanced SQL Operations

/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30 

SELECT CURRENT_DATE;
SELECT ist.issued_member_id, m.member_name, bk.book_title, ist.issued_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN members as m
    ON m.member_id = ist.issued_member_id
JOIN books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;


-- 
/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/


SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-330-25864-8';
-- IS104

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM return_status
WHERE issued_id = 'IS130';

-- 
INSERT INTO return_status(return_id, issued_id, return_date)
VALUES
('RS125', 'IS130', CURRENT_DATE);
SELECT * FROM return_status
WHERE issued_id = 'IS130';

-- stored procedure
DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10), 
    IN p_issued_id VARCHAR(10), 
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert record into return_status table
    INSERT INTO return_status(return_id, issued_id, return_date, return_book_isbn)
    SELECT 
        p_return_id, 
        p_issued_id, 
        CURRENT_DATE, 
        issued_book_isbn
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Get book ISBN and book name
    SELECT 
        issued_book_isbn, 
        issued_book_name
    INTO 
        v_isbn, 
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Optional: Display a message (won’t be seen in most client apps, but works in some like MySQL CLI)
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
    
END$$

DELIMITER ;
 
-- Testing FUNCTION add_return_records

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

SELECT * FROM branch;

SELECT * FROM issued_status;

SELECT * FROM employees;

SELECT * FROM books;

SELECT * FROM return_status;

CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

CREATE TABLE active_members AS
SELECT * 
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
);

SELECT * FROM active_members;

-- 
-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2;


/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

SELECT * FROM books;

SELECT * FROM issued_status;

DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10), 
    IN p_issued_member_id VARCHAR(30), 
    IN p_issued_book_isbn VARCHAR(30), 
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Get book status
    SELECT status INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        -- Insert issued book record
        INSERT INTO issued_status(
            issued_id, 
            issued_member_id, 
            issued_date, 
            issued_book_isbn, 
            issued_emp_id
        ) VALUES (
            p_issued_id, 
            p_issued_member_id, 
            CURDATE(), 
            p_issued_book_isbn, 
            p_issued_emp_id
        );

        -- Update book status to 'no'
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        SELECT CONCAT('Book record added successfully for book ISBN: ', p_issued_book_isbn) AS message;
    ELSE
        SELECT CONCAT('Sorry, the book is unavailable. ISBN: ', p_issued_book_isbn) AS message;
    END IF;
END$$

DELIMITER ;


SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;


CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');



CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');


SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'
/* Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/