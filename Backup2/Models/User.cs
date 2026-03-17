namespace prjLibrarySystem.Models
{
    public class User
    {
        public string UserID { get; set; }
        public string Role { get; set; }  // 'Super Admin', 'Admin', or 'Member'
        public string FullName { get; set; }
        public string Email { get; set; }

        public bool IsSuperAdmin => Role == "Super Admin";
        public bool IsAdmin => Role == "Admin";
        public bool IsMember => Role == "Member";
    }
}