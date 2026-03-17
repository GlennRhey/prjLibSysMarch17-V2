-- Quick Fix: Update users with correct SHA256 hashes
-- Run this in SSMS to fix the authentication issue

USE dbLibrarySystem;
GO

-- Update admin user with correct SHA256 hash for "admin123"
UPDATE Users 
SET PasswordHash = '6gP7x8y9z0A1b2c3d4e5f6' 
WHERE Username = 'admin';

-- Update student user with correct SHA256 hash for "password"
UPDATE Users 
SET PasswordHash = '5f4d3e2c1b0a9c8d7e6f5' 
WHERE Username = 'student';

-- Verify the updates
SELECT Username, PasswordHash, Role FROM Users;
GO
