namespace prjLibrarySystem.Models
{
    public class Member
    {
        public int MemberID { get; set; }
        public string UserID { get; set; }
        public string FullName { get; set; }
        public string MemberType { get; set; }  // 'Student' or 'Teacher'
        public string Course { get; set; }  // NULL for Teachers
        public int? YearLevel { get; set; }  // NULL for Teachers
        public string Email { get; set; }
        public bool IsActive { get; set; }

        public bool IsStudent => MemberType == "Student";
        public bool IsTeacher => MemberType == "Teacher";
    }
}