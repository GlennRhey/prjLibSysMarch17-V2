using System;

namespace prjLibrarySystem.Models
{
    // Mirrors tblUsers:
    // UserID (PK), PasswordHash, Role, FullName (admins only), Email, IsActive, CreatedAt
    public class User
    {
        public string UserID { get; set; }   // e.g. EMP-001 or 2023-0001
        public string Password { get; set; }   // maps to PasswordHash in tblUsers
        public string Role { get; set; }   // 'Admin' or 'Student'
        public string FullName { get; set; }   // populated for Admins; null for Students
        public string Email { get; set; }
        public bool IsActive { get; set; }
        public DateTime? CreatedAt { get; set; }

        public User()
        {
            IsActive = true;
            CreatedAt = DateTime.Now;
            Role = "Student";
        }

        public User(string userId, string password, string role, string fullName, string email)
        {
            UserID = userId;
            Password = password;
            Role = role;
            FullName = fullName;
            Email = email;
            IsActive = true;
            CreatedAt = DateTime.Now;
        }

        public bool IsAdmin => Role == "Admin";
        public bool IsStudent => Role == "Student";
    }
}