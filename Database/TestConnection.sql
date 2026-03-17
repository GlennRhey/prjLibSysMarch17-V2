-- Test connection to MSI/SQLEXPRESS and dbLibrarySystem
-- Run this in SSMS to verify everything is working

USE dbLibrarySystem;
GO

-- Test basic connection
SELECT 'Connected to dbLibrarySystem on MSI/SQLEXPRESS' AS ConnectionTest;
GO

-- Check if Users table exists
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'Users';
GO

-- If Users table exists, show its structure
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Users')
BEGIN
    SELECT 
        COLUMN_NAME, 
        DATA_TYPE, 
        CHARACTER_MAXIMUM_LENGTH,
        IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Users'
    ORDER BY ORDINAL_POSITION;
END
GO

-- Show current users if table exists
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Users')
BEGIN
    SELECT 
        UserID,
        Username,
        Role,
        FullName,
        Email,
        RegDate
    FROM Users;
END
ELSE
BEGIN
    PRINT 'Users table does not exist. Please run CreateUsers.sql';
END
GO
