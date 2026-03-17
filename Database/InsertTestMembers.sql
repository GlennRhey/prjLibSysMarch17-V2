-- Insert 10 Test Members for Pagination Testing
-- Run this script in SQL Server Management Studio (SSMS) against dbLibrarySystem database

USE dbLibrarySystem;
GO

-- Insert 10 test members with different roles
INSERT INTO Users (Username, PasswordHash, Role, FullName, Email, RegDate) VALUES
('student001', 'password123', 'Student', 'Alice Johnson', 'alice.johnson@email.com', GETDATE()),
('student002', 'password123', 'Student', 'Bob Smith', 'bob.smith@email.com', GETDATE()),
('student003', 'password123', 'Student', 'Carol Williams', 'carol.williams@email.com', GETDATE()),
('student004', 'password123', 'Student', 'David Brown', 'david.brown@email.com', GETDATE()),
('student005', 'password123', 'Student', 'Emma Davis', 'emma.davis@email.com', GETDATE()),
('student006', 'password123', 'Student', 'Frank Miller', 'frank.miller@email.com', GETDATE()),
('student007', 'password123', 'Student', 'Grace Wilson', 'grace.wilson@email.com', GETDATE()),
('student008', 'password123', 'Student', 'Henry Moore', 'henry.moore@email.com', GETDATE()),
('student009', 'password123', 'Student', 'Ivy Taylor', 'ivy.taylor@email.com', GETDATE()),
('student010', 'password123', 'Student', 'Jack Anderson', 'jack.anderson@email.com', GETDATE());

GO

-- Verify the insert
SELECT COUNT(*) as TotalMembers FROM Users WHERE Role = 'Student';
GO

-- Show the first 5 members
SELECT TOP 5 UserID, Username, FullName, Email, Role, RegDate 
FROM Users 
WHERE Role = 'Student' 
ORDER BY UserID;
GO

PRINT 'Successfully inserted 10 test members for pagination testing!';
PRINT 'Total student members: ' + CAST((SELECT COUNT(*) FROM Users WHERE Role = 'Student') AS VARCHAR(10));
GO
