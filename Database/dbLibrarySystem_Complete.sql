-- Complete dbLibrarySystem Database Backup
-- Includes: Schema, Data, Indexes, Constraints
-- Generated: 2026-02-26

USE [master]
GO

-- Drop database if exists (for fresh restore)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'dbLibrarySystem')
BEGIN
    ALTER DATABASE [dbLibrarySystem] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [dbLibrarySystem];
END
GO

-- Create database
CREATE DATABASE [dbLibrarySystem]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'dbLibrarySystem', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\dbLibrarySystem.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'dbLibrarySystem_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\dbLibrarySystem_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

USE [dbLibrarySystem]
GO

-- Create Users table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](50) NOT NULL,
	[PasswordHash] [nvarchar](255) NOT NULL,
	[Role] [nvarchar](20) NOT NULL,
	[FullName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](100) NULL,
	[RegDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Create Books table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books](
	[ISBN] [nvarchar](20) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[Author] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](50) NULL,
	[TotalCopies] [int] NULL,
	[AvailableCopies] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ISBN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Create MembersRecord table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MembersRecord](
	[MemberID] [int] IDENTITY(1,1) NOT NULL,
	[FullName] [nvarchar](100) NOT NULL,
	[RegistrationDate] [datetime] NULL,
	[Status] [nvarchar](20) NULL,
	[RoleID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Create Transactions table
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transactions](
	[BorrowID] [int] IDENTITY(1,1) NOT NULL,
	[ISBN] [nvarchar](20) NOT NULL,
	[BorrowerFullName] [nvarchar](100) NOT NULL,
	[BookTitle] [nvarchar](200) NOT NULL,
	[BorrowDate] [datetime] NULL,
	[DueDate] [date] NOT NULL,
	[ReturnDate] [datetime] NULL,
	[Status] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[BorrowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Add indexes
CREATE NONCLUSTERED INDEX [IX_Books_Author] ON [dbo].[Books]([Author] ASC);
CREATE NONCLUSTERED INDEX [IX_Books_Title] ON [dbo].[Books]([Title] ASC);
CREATE NONCLUSTERED INDEX [IX_MembersRecord_Status] ON [dbo].[MembersRecord]([Status] ASC);
CREATE NONCLUSTERED INDEX [IX_Transactions_BorrowerFullName] ON [dbo].[Transactions]([BorrowerFullName] ASC);
CREATE NONCLUSTERED INDEX [IX_Transactions_ISBN] ON [dbo].[Transactions]([ISBN] ASC);
CREATE NONCLUSTERED INDEX [IX_Transactions_Status] ON [dbo].[Transactions]([Status] ASC);
GO

-- Add defaults
ALTER TABLE [dbo].[Books] ADD  DEFAULT ((1)) FOR [TotalCopies];
ALTER TABLE [dbo].[Books] ADD  DEFAULT ((1)) FOR [AvailableCopies];
ALTER TABLE [dbo].[Books] ADD  DEFAULT (getdate()) FOR [CreatedAt];
ALTER TABLE [dbo].[MembersRecord] ADD  DEFAULT (getdate()) FOR [RegistrationDate];
ALTER TABLE [dbo].[MembersRecord] ADD  DEFAULT ('Active') FOR [Status];
ALTER TABLE [dbo].[Transactions] ADD  DEFAULT (getdate()) FOR [BorrowDate];
ALTER TABLE [dbo].[Transactions] ADD  DEFAULT ('Borrowed') FOR [Status];
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [RegDate];
GO

-- Add foreign keys
ALTER TABLE [dbo].[MembersRecord]  WITH CHECK ADD  CONSTRAINT [FK_MembersRecord_Users] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Users] ([UserID]);
ALTER TABLE [dbo].[Transactions]  WITH CHECK ADD  CONSTRAINT [FK_Transactions_Books] FOREIGN KEY([ISBN])
REFERENCES [dbo].[Books] ([ISBN]);
GO

-- Add constraints
ALTER TABLE [dbo].[MembersRecord]  WITH CHECK ADD CHECK  (([Status]='Inactive' OR [Status]='Active'));
ALTER TABLE [dbo].[Transactions]  WITH CHECK ADD CHECK  (([Status]='Overdue' OR [Status]='Returned' OR [Status]='Borrowed'));
ALTER TABLE [dbo].[Users]  WITH CHECK ADD CHECK  (([Role]='Student' OR [Role]='Admin'));
GO

-- ========================================
-- INSERT DATA
-- ========================================

-- Insert Users
INSERT INTO Users (Username, PasswordHash, Role, FullName, Email, RegDate) VALUES
('admin', 'admin123', 'Admin', 'Administrator', 'admin@library.com', '2026-02-26'),
('student', 'password', 'Student', 'John Student', 'student@library.com', '2026-02-26');
GO

-- Insert Books
INSERT INTO Books (ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description, CreatedAt) VALUES
-- Programming Books
('9780132350884', 'Clean Code: A Handbook of Agile Software Craftsmanship', 'Robert C. Martin', 'Programming', 5, 5, 'A handbook of agile software craftsmanship covering best practices for writing clean, maintainable code.', '2026-02-26'),
('9780201616224', 'The Pragmatic Programmer', 'Andrew Hunt and David Thomas', 'Programming', 8, 7, 'From journeyman to master - practical advice for improving your programming skills and career.', '2026-02-26'),
('9780262510875', 'Structure and Interpretation of Computer Programs', 'Harold Abelson and Gerald Jay Sussman', 'Programming', 3, 3, 'A classic textbook about computer programming, focusing on fundamental concepts and abstraction.', '2026-02-26'),
-- Artificial Intelligence Books
('9780134610993', 'Artificial Intelligence: A Modern Approach', 'Stuart Russell and Peter Norvig', 'Artificial Intelligence', 6, 4, 'Comprehensive textbook on artificial intelligence covering theory and practice of AI systems.', '2026-02-26'),
('9781101970317', 'Life 3.0: Being Human in the Age of Artificial Intelligence', 'Max Tegmark', 'Artificial Intelligence', 4, 4, 'Exploring the future of AI and its impact on humanity, society, and consciousness.', '2026-02-26'),
('9780262039406', 'Deep Learning', 'Ian Goodfellow, Yoshua Bengio, Aaron Courville', 'Artificial Intelligence', 7, 6, 'Comprehensive introduction to deep learning, covering mathematical and conceptual foundations.', '2026-02-26'),
-- Data Communications Books
('9780073376226', 'Data Communications and Networking', 'Behrouz A. Forouzan', 'Data Communications', 10, 8, 'Comprehensive introduction to data communications and networking fundamentals.', '2026-02-26'),
('9781108419437', 'Computer Networking: Principles Protocols and Practice', 'Olivier Bonaventure', 'Data Communications', 5, 5, 'Modern approach to computer networking with practical examples and protocols.', '2026-02-26'),
('9781260454043', 'CompTIA Network+ Certification All-in-One Exam Guide', 'Mike Meyers', 'Data Communications', 12, 9, 'Complete study guide for CompTIA Network+ certification exam preparation.', '2026-02-26'),
-- Literature Books
('9780061120084', 'To Kill a Mockingbird', 'Harper Lee', 'Literature', 15, 12, 'Classic American novel dealing with racial injustice and childhood innocence in the American South.', '2026-02-26'),
('9780141439518', 'Pride and Prejudice', 'Jane Austen', 'Literature', 8, 6, 'Romantic novel of manners depicting the English gentry of the early 19th century.', '2026-02-26'),
('9780451524935', '1984', 'George Orwell', 'Literature', 20, 15, 'Dystopian social science fiction novel and cautionary tale about totalitarianism.', '2026-02-26'),
-- Business Books
('9780743269513', 'The 7 Habits of Highly Effective People', 'Stephen R. Covey', 'Business', 6, 4, 'Powerful lessons in personal change that have transformed millions of lives.', '2026-02-26'),
('9780066620992', 'Good to Great', 'Jim Collins', 'Business', 7, 5, 'Why some companies make the leap and others dont - based on extensive research.', '2026-02-26'),
('9780374533557', 'Thinking Fast and Slow', 'Daniel Kahneman', 'Business', 9, 7, 'Nobel laureate explores the two systems that drive the way we think and make decisions.', '2026-02-26');
GO

-- Insert Sample Members
INSERT INTO MembersRecord (FullName, RegistrationDate, Status, RoleID) VALUES
('Jane Smith', '2026-02-26', 'Active', 2),
('John Doe', '2026-02-26', 'Active', 2),
('Alice Johnson', '2026-02-26', 'Active', 2);
GO

-- Insert Sample Transactions
INSERT INTO Transactions (ISBN, BorrowerFullName, BookTitle, BorrowDate, DueDate, ReturnDate, Status) VALUES
('9780132350884', 'Jane Smith', 'Clean Code: A Handbook of Agile Software Craftsmanship', '2026-02-20', '2026-02-27', NULL, 'Borrowed'),
('9780201616224', 'John Doe', 'The Pragmatic Programmer', '2026-02-15', '2026-02-22', '2026-02-21', 'Returned'),
('9780134610993', 'Alice Johnson', 'Artificial Intelligence: A Modern Approach', '2026-02-18', '2026-02-25', NULL, 'Borrowed');
GO

-- ========================================
-- VERIFICATION QUERIES
-- ========================================

-- Verify data was inserted
SELECT 'Users' as TableName, COUNT(*) as RecordCount FROM Users
UNION ALL
SELECT 'Books', COUNT(*) FROM Books
UNION ALL
SELECT 'MembersRecord', COUNT(*) FROM MembersRecord
UNION ALL
SELECT 'Transactions', COUNT(*) FROM Transactions;
GO

-- Show sample data
SELECT TOP 5 * FROM Books ORDER BY Category, Title;
GO

PRINT 'Database dbLibrarySystem has been created and populated successfully!';
GO
