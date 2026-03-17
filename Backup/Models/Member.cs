using System;

namespace prjLibrarySystem.Models
{
    // Mirrors tblMembers:
    // MemberID (PK, identity), UserID (FK → tblUsers), FullName, Course, YearLevel
    public class Member
    {
        public int MemberID { get; set; }
        public string UserID { get; set; }   // FK to tblUsers.UserID e.g. 2023-0001
        public string FullName { get; set; }
        public string Course { get; set; }   // e.g. BSIT, BSCS
        public int YearLevel { get; set; }   // 1–4

        // Joined from tblUsers when needed
        public string Email { get; set; }
        public bool IsActive { get; set; }
        public DateTime? CreatedAt { get; set; }

        public Member()
        {
            IsActive = true;
            CreatedAt = DateTime.Now;
        }

        public Member(string userId, string fullName, string course, int yearLevel)
        {
            UserID = userId;
            FullName = fullName;
            Course = course;
            YearLevel = yearLevel;
            IsActive = true;
            CreatedAt = DateTime.Now;
        }
    }
}