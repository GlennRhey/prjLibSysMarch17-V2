-- Check if Users table exists in dbLibrarySystem
-- Run this in SSMS to verify your database structure

USE dbLibrarySystem;
GO

-- Check if Users table exists
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'Users'
AND TABLE_TYPE = 'BASE TABLE';
GO

-- Check Users table structure if it exists
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Users')
BEGIN
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Users'
    ORDER BY ORDINAL_POSITION;
END
ELSE
BEGIN
    PRINT 'Users table does not exist in dbLibrarySystem database';
END
GO

-- Check if there are any users in the table
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Users')
BEGIN
    SELECT COUNT(*) as UserCount FROM Users;
END
GO
