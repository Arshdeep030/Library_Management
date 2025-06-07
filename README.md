# Library System Management – SQL Project

## Project Overview
This project is a relational database design and management system for a Library. It includes various entities such as books, members, employees, branches, issue/return statuses, and integrates several SQL operations such as CRUD, CTAS, data analysis, and stored procedures. The system simulates real-world library functions, such as issuing and returning books, tracking overdue records, and reporting on library performance.

---

## Database Design

The project consists of the following main tables:

- **branch**: Stores details of library branches.
- **employees**: Holds information about library employees.
- **members**: Contains member registration details.
- **books**: Catalog of books in the library with rental info.
- **issued_status**: Tracks book issues including date, book, employee, and member.
- **return_status**: Records returned books and return details.

---

## 🛠️ Tasks Breakdown

### 1. Database Creation & Schema Setup
- Creation of necessary tables and constraints.
- Establishment of primary and foreign key relationships.

---

### 2. CRUD Operations

- **Task 1**: Add a new book to the catalog.
- **Task 2**: Update an existing member’s address.
- **Task 3**: Delete an entry from the `issued_status` table.
- **Task 4**: Retrieve all books issued by a specific employee (`emp_id = 'E101'`).
- **Task 5**: List members who have issued more than one book.

---

### 3. CTAS (Create Table As Select)

- **Task 6**: Create a summary table showing each book and how many times it has been issued.

---

### 4. Data Analysis & Findings

- **Task 7**: Retrieve all books under a specific category (e.g., 'Science Fiction').
- **Task 8**: Calculate total rental income grouped by category.
- **Task 9**: List members who registered in the last 180 days.
- **Task 10**: Show employees along with their branch manager and branch details.
- **Task 11**: Create a table of books with rental price above a defined threshold.
- **Task 12**: Retrieve a list of books that have not yet been returned.

---

### 5. Advanced SQL Operations

- **Task 13**: Identify members with overdue books (based on a 30-day return policy). Display member name, book title, issue date, and days overdue.
- **Task 14**: Update book status to `'available'` in the `books` table once returned.
- **Task 15**: Generate a branch performance report showing:
  - Total books issued
  - Total books returned
  - Revenue from rentals
- **Task 16**: CTAS to create `active_members` table with members who issued books in the last 6 months.
- **Task 17**: Find top 3 employees who processed the most book issues along with their branch.
- **Task 18**: Identify members who issued damaged books more than twice.
- **Task 19**: Create a **Stored Procedure** to update book status:
  - On issuance → status = `'no'`
  - On return → status = `'yes'`
- **Task 20**: CTAS to create a table listing members with overdue books:
  - Number of overdue books
  - Total fines ($0.50/day)
  - Total books issued
  - Member ID

