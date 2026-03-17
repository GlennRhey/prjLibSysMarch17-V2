-- Create Notifications Table for Library System
-- This table stores all email notifications sent by the system

USE [dbLibrarySystem]
GO

-- Create Notifications table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tblNotifications' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[tblNotifications](
        [NotificationID] [int] IDENTITY(1,1) NOT NULL,
        [NotificationType] [nvarchar](50) NOT NULL,
        [Recipient] [nvarchar](100) NOT NULL,
        [Subject] [nvarchar](200) NOT NULL,
        [Message] [nvarchar](MAX) NOT NULL,
        [Status] [nvarchar](20) NOT NULL DEFAULT 'Pending',
        [CreatedAt] [datetime] NOT NULL DEFAULT GETDATE(),
        [SentAt] [datetime] NULL,
        PRIMARY KEY CLUSTERED ([NotificationID] ASC)
    ) ON [PRIMARY]
    
    PRINT 'Notifications table created successfully.'
END
ELSE
BEGIN
    PRINT 'Notifications table already exists.'
END
GO

-- Add DueDateReminderSent column to tblTransactions (for tracking reminder emails)
IF NOT EXISTS (SELECT * FROM syscolumns WHERE id=OBJECT_ID('tblTransactions') AND name='DueDateReminderSent')
BEGIN
    ALTER TABLE tblTransactions ADD DueDateReminderSent bit DEFAULT 0
    PRINT 'DueDateReminderSent column added to tblTransactions.'
END
ELSE
BEGIN
    PRINT 'DueDateReminderSent column already exists in tblTransactions.'
END
GO

-- Insert sample notification records for testing
IF NOT EXISTS (SELECT * FROM tblNotifications)
BEGIN
    INSERT INTO tblNotifications (NotificationType, Recipient, Subject, Message, Status) VALUES
    ('EMAIL', 'student@example.com', 'Welcome to Library System', 'Dear Student, Welcome to our Library Management System!', 'Sent'),
    ('EMAIL', 'admin@library.com', 'System Update', 'Library system has been updated with new features.', 'Sent'),
    ('EMAIL', 'student2@example.com', 'Book Due Date Reminder', 'Your book is due in 2 days. Please return it on time.', 'Pending');
    
    PRINT 'Sample notification records inserted.'
END
ELSE
BEGIN
    PRINT 'Sample notifications already exist.'
END
GO

-- Create index for better performance on notification queries
IF NOT EXISTS (SELECT * FROM sysindexes WHERE name='IX_Notifications_CreatedAt' AND id=OBJECT_ID('tblNotifications'))
BEGIN
    CREATE INDEX IX_Notifications_CreatedAt ON tblNotifications(CreatedAt DESC)
    PRINT 'Index IX_Notifications_CreatedAt created.'
END
ELSE
BEGIN
    PRINT 'Index IX_Notifications_CreatedAt already exists.'
END
GO

PRINT 'Notifications table setup completed successfully!'
GO
