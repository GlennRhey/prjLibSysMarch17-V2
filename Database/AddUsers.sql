-- Add Sample Users to dbLibrarySystem
-- Execute this script in SSMS

-- First, create Users table if it doesn't exist (based on your SQLQuery.sql structure)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' AND xtype='U')
BEGIN
    CREATE TABLE Users (
        UserID INT IDENTITY(1,1) PRIMARY KEY,
        Username NVARCHAR(50) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(255) NOT NULL,
        Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Admin', 'Student')),
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) UNIQUE,
        RegDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- Clear existing users (optional)
DELETE FROM Users WHERE Username IN ('admin', 'student');

-- Admin User (password: admin123)
INSERT INTO Users (Username, PasswordHash, Role, FullName, Email) 
VALUES ('admin', 
        'Y6uqxB8H7z5N8Q5w6k9M2p3L4s5T6u7v8w9x0y1z2', 
        'Admin', 
        'Administrator', 
        'admin@library.com');

-- Student User (password: password)
INSERT INTO Users (Username, PasswordHash, Role, FullName, Email) 
VALUES ('student', 
        'X7v9yC8z6A5b4c3d2e1f0g9h8i7j6k5l4m3n2o1', 
        'Student', 
        'John Student', 
        'student@library.com');

-- Insert Sample Books (ISBN is primary key)
INSERT INTO Books (ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description) 
VALUES 
('978-1234567890', 'C# Programming', 'John Smith', 'Programming', 5, 5, 'Learn C# programming from scratch'),
('978-0987654321', 'Database Design', 'Jane Doe', 'Database', 3, 3, 'Complete guide to database design'),
('978-5678901234', 'Web Development', 'Mike Johnson', 'Web', 4, 4, 'Modern web development techniques');

-- Insert Sample Members
INSERT INTO MembersRecord (FullName, Status) 
VALUES 
('Alice Brown', 'Active'),
('Bob Wilson', 'Active');

GO
