-- Populate MembersRecord Table with Test Data
-- Run this script in SQL Server Management Studio (SSMS) against dbLibrarySystem database

USE dbLibrarySystem;
GO

-- Clear existing data from MembersRecord (if any)
DELETE FROM MembersRecord;
GO

-- Insert 15 test members into MembersRecord table
INSERT INTO MembersRecord (FullName, RegistrationDate, Status, RoleID, Course, YearLevel) VALUES
('Alice Johnson', GETDATE(), 'Active', 1, 'Computer Science', '1st Year'),
('Bob Smith', GETDATE(), 'Active', 2, 'Information Technology', '2nd Year'),
('Carol Williams', GETDATE(), 'Active', 3, 'Computer Science', '3rd Year'),
('David Brown', GETDATE(), 'Active', 1, 'Information Technology', '1st Year'),
('Emma Davis', GETDATE(), 'Active', 2, 'Computer Science', '2nd Year'),
('Frank Miller', GETDATE(), 'Active', 3, 'Information Technology', '3rd Year'),
('Grace Wilson', GETDATE(), 'Active', 1, 'Computer Science', '4th Year'),
('Henry Moore', GETDATE(), 'Active', 2, 'Information Technology', '1st Year'),
('Ivy Taylor', GETDATE(), 'Active', 3, 'Computer Science', '2nd Year'),
('Jack Anderson', GETDATE(), 'Active', 1, 'Information Technology', '3rd Year'),
('Karen Thomas', GETDATE(), 'Active', 2, 'Computer Science', '4th Year'),
('Liam Jackson', GETDATE(), 'Active', 3, 'Information Technology', '1st Year'),
('Mia White', GETDATE(), 'Active', 1, 'Computer Science', '2nd Year'),
('Noah Harris', GETDATE(), 'Active', 2, 'Information Technology', '3rd Year'),
('Olivia Martin', GETDATE(), 'Active', 3, 'Computer Science', '4th Year');

GO

-- Verify the insert
SELECT COUNT(*) as TotalMembers FROM MembersRecord;
GO

-- Show the first 5 members with user info
SELECT TOP 5 
    m.MemberID, 
    m.FullName, 
    m.Course, 
    m.YearLevel, 
    m.Status,
    u.Username,
    u.Email,
    u.Role
FROM MembersRecord m
LEFT JOIN Users u ON m.RoleID = u.UserID
ORDER BY m.MemberID;
GO

PRINT 'Successfully inserted 15 test members into MembersRecord table!';
PRINT 'Total members in MembersRecord: ' + CAST((SELECT COUNT(*) FROM MembersRecord) AS VARCHAR(10));
GO
