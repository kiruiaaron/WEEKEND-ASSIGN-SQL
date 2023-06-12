
--library management system database
CREATE DATABASE library_management_system;

use library_management_system;

--books table

CREATE TABLE Books(
BookID INT PRIMARY KEY NOT NULL,
Title VARCHAR(100) NOT NULL,
Athor VARCHAR(100) NOT NULL,
PublicationYear INT,
Status VARCHAR(100));

--inserting values into books table

INSERT INTO Books (BookID,Title,Athor,PublicationYear,Status)
VALUES(101,'COMPUTER SCIENCE','PEREZ',2010,'AVAILABLE'),
       (102,'IT','JANE',2015,'AVAILABLE'),
	   (103,'BBIT','JOHN',2017,'AVAILABLE'),
	   (104,'MMM','ELI',2007,'AVAILABLE'),
	   (105,'EEE','ANNE',2009,'AVAILABLE'),
	   (106,'TIE','PETER',2011,'AVAILABLE'),
	   (107,'MIT','IAN',2020,'AVAILABLE'),
	   (108,'BCOM','DOE',2016,'AVAILABLE'),
	   (109,'ACTUARAL','MISANDEI',2005,'AVAILABLE'),
	   (110,'COMPTER FORENSIC','MARK',2019,'AVAILABLE');

SELECT * FROM Books;

--members table

CREATE TABLE Members(
MemberID INT PRIMARY KEY NOT NULL,
Name VARCHAR(100),
Address VARCHAR(100),
ContactNumber INT);

--inserting values into members table

INSERT INTO Members(MemberID,Name,Address,ContactNumber)
VALUES(1001,'ARTHUR','746 EMBU ST',0118950),
       (1002,'OSCAR','200 TYW ST',0836782),
	   (1003,'SANTOS','220 CYTUM ST',094678),
	   (1004,'WILLIAM','520 AINE ST',0783945),
	   (1005,'JERRY','734 HIOME ST',0145783),
	   (1006,'KARIM','534 COMP ST',045627),
	   (1007,'HAWTY','435 AMBT ST',0819045),
	   (1008,'JAMES','2256 WILL ST',03456677),
	   (1009,'JUNE','178 TURKST',0111355566),
	   (1010,'APRG','930 GUTY ST',09035672);

SELECT * FROM Members;

--loan books table

CREATE TABLE Loans(
LoanID INT PRIMARY KEY NOT NULL,
BookID INT FOREIGN KEY REFERENCES Books(BookID),
MemberID INT FOREIGN KEY REFERENCES Members(MemberID),
LoanDate DATE,
ReturnDate DATE);

--inserting values into loans table

INSERT INTO Loans(LoanID,BookID,MemberID,LoanDate,ReturnDate)
VALUES(300,101,1001,'2023-05-03','2023-05-06'),
      (301,102,1002,'2023-06-03','2023-06-06'),
	  (302,103,1003,'2023-05-03','2023-05-06'),
	  (303,104,1004,'2023-06-03','2023-06-06'),
	  (304,105,1005,'2023-06-03','2023-05-06'),
	  (305,106,1006,'2023-06-03','2023-06-06'),
	  (306,107,1007,'2023-05-03','2023-05-06'),
	  (307,108,1008,'2023-06-03','2023-06-06'),
	  (308,109,1009,'2023-05-03','2023-05-06'),
	  (309,110,1010,'2023-06-01','2023-06-06');


SELECT * FROM Loans;
GO

--QUE1
CREATE TRIGGER StatusUpdate
ON Loans
AFTER UPDATE,INSERT,DELETE
AS
BEGIN
 UPDATE Books
    SET Status = 'Loaned' WHERE BookID IN (SELECT BookID FROM inserted);
      
    UPDATE Books
    SET Status = 'Available' WHERE BookID IN (SELECT BookID FROM deleted);
 
END;



--QUE2

WITH highetsBorrowed AS (
    SELECT MemberID, COUNT(*) AS times
    FROM Loans
    GROUP BY MemberID
    HAVING COUNT(*) >= 3
)
SELECT M.name
FROM Members M
JOIN highetsBorrowed h ON M.MemberID= h.MemberID;
GO

--que3

CREATE FUNCTION OverdueDays(@LoanID INT) RETURNS INT
AS
BEGIN
    DECLARE @DueDate DATE;
    DECLARE @ReturnDate DATE;
    DECLARE @OverdueDays INT;

    -- Get the due date and return date for the loan
    SELECT @DueDate = 10, @ReturnDate = ReturnDate
    FROM Loans
    WHERE LoanID = @LoanID;

    -- Calculate the overdue days
    SET @OverdueDays = DATEDIFF(DAY, @DueDate, @ReturnDate);

    -- If the loan is not returned yet, set overdue days to 0
    IF @ReturnDate IS NULL
        SET @OverdueDays = 0;

    -- Return the overdue days
    RETURN @OverdueDays;
END;
GO

--que4
CREATE VIEW OverdueLoansView AS
SELECT l.LoanID AS LoanID, b.title AS BookTitle, m.name AS MemberName,
       DATEDIFF(DAY, l.LoanDate, GETDATE()) AS OverdueDays
FROM Loans l
JOIN Books b ON l.BookID = b.BookID
JOIN Members m ON l.LoanID = m.MemberID
WHERE l.ReturnDate IS NULL AND l.LoanDate < GETDATE();

GO

--que 5
CREATE TRIGGER PreventExcessiveBorrowing
ON Loans
FOR INSERT
AS
BEGIN
    DECLARE @MemberID INT;
    DECLARE @TotalLoans INT;

    SELECT @MemberID = MemberID
    FROM inserted;

    SELECT @TotalLoans = COUNT(*)
    FROM Loans
    WHERE MemberID = @MemberID;

    IF @TotalLoans >= 3
    BEGIN
        RAISERROR('Cannot borrow more than three books at a time.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;





