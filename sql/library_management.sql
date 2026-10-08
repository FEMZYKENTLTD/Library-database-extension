-- CS 2203 Unit 4: Library Management Database
-- SQL dialect: SQLite (the commands and constraints use standard SQL concepts).

-- Enable enforcement of foreign-key references for this SQLite session.
PRAGMA foreign_keys = ON;

-- Remove dependent tables first so that the script can be safely re-run.
DROP TABLE IF EXISTS Loans;
DROP TABLE IF EXISTS Members;
DROP TABLE IF EXISTS Books;

-- BOOKS: one row per library title/edition. ISBN is the natural primary key.
CREATE TABLE Books (
    ISBN CHAR(13) PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    Author VARCHAR(150) NOT NULL,
    Genre VARCHAR(100) NOT NULL,
    Quantity INTEGER NOT NULL CHECK (Quantity >= 0)
);

-- MEMBERS: MemberID uniquely identifies a borrower; Email must also be unique.
CREATE TABLE Members (
    MemberID VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(150) NOT NULL,
    Email VARCHAR(254) NOT NULL UNIQUE,
    Phone VARCHAR(25) NOT NULL
);

-- LOANS: records each borrowing transaction and connects a member to a book.
CREATE TABLE Loans (
    LoanID VARCHAR(10) PRIMARY KEY,
    MemberID VARCHAR(10) NOT NULL,
    ISBN CHAR(13) NOT NULL,
    LoanDate DATE NOT NULL,
    ReturnDate DATE,
    CONSTRAINT fk_loans_member
        FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE RESTRICT,
    CONSTRAINT fk_loans_book
        FOREIGN KEY (ISBN) REFERENCES Books(ISBN) ON DELETE RESTRICT,
    CONSTRAINT chk_return_date
        CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate)
);

-- Insert sample book records for the library catalogue.
INSERT INTO Books (ISBN, Title, Author, Genre, Quantity) VALUES
('9780061120084', 'To Kill a Mockingbird', 'Harper Lee', 'Fiction', 4),
('9780131103627', 'The C Programming Language', 'Kernighan and Ritchie', 'Computing', 3),
('9780439023481', 'The Hunger Games', 'Suzanne Collins', 'Dystopian', 6);

-- Insert three members. M003 has no loan and can be safely deleted later.
INSERT INTO Members (MemberID, Name, Email, Phone) VALUES
('M001', 'Amina Okafor', 'amina.okafor@example.edu', '+234-801-555-0101'),
('M002', 'David Kim', 'david.kim@example.edu', '+1-202-555-0148'),
('M003', 'Chiamaka Adeyemi', 'chiamaka.adeyemi@example.edu', '+234-802-555-0186');

-- Insert loan transactions. A NULL ReturnDate represents an active loan.
INSERT INTO Loans (LoanID, MemberID, ISBN, LoanDate, ReturnDate) VALUES
('L001', 'M001', '9780131103627', '2026-09-20', NULL),
('L002', 'M001', '9780061120084', '2026-09-10', '2026-09-17'),
('L003', 'M002', '9780439023481', '2026-09-19', NULL);

-- Verify all records in the required relations after INSERT operations.
SELECT * FROM Books ORDER BY ISBN;
SELECT * FROM Members ORDER BY MemberID;
SELECT * FROM Loans ORDER BY LoanID;

-- Retrieve all catalogue information for books borrowed by the specific member M001.
SELECT b.ISBN, b.Title, b.Author, b.Genre, b.Quantity
FROM Loans AS l
JOIN Members AS m ON m.MemberID = l.MemberID
JOIN Books AS b ON b.ISBN = l.ISBN
WHERE m.MemberID = 'M001'
ORDER BY l.LoanDate;

-- Update the number of available copies for a selected book.
UPDATE Books
SET Quantity = 5
WHERE ISBN = '9780131103627';

-- Verify the result of the quantity update.
SELECT ISBN, Title, Quantity
FROM Books
WHERE ISBN = '9780131103627';

-- Delete M003, who has no loan history. ON DELETE RESTRICT protects members with loans.
DELETE FROM Members
WHERE MemberID = 'M003';

-- Verify the member deletion and final Members table state.
SELECT * FROM Members ORDER BY MemberID;
