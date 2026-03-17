namespace prjLibrarySystem
{
    /// <summary>
    /// Generates the correct sidebar HTML for admin-area pages.
    /// 
    /// Super Admin gets: blue sidebar, SA nav links, Audit Logs item
    /// Admin gets:       red sidebar,  Admin nav links, no Audit Logs
    ///
    /// Usage in any shared page's Page_Load:
    ///     litSidebar.Text = SidebarHelper.GetSidebar(Session["Role"]?.ToString(), "books");
    ///
    /// activePage values:
    ///     "dashboard" | "books" | "members" | "borrow" | "reports" | "auditlogs"
    /// </summary>
    public static class SidebarHelper
    {
        public static string GetSidebar(string role, string activePage)
        {
            bool isSA = (role == "Super Admin");

            string bg = isSA ? "linear-gradient(135deg,#1a237e 0%,#283593 100%)"
                                 : "linear-gradient(135deg,#8b0000 0%,#b11226 100%)";
            string accent = isSA ? "#ffd54f" : "white";

            string title = isSA
                ? "Super Admin <span style='background:#ffd54f;color:#1a237e;font-size:.7rem;" +
                  "font-weight:700;padding:2px 8px;border-radius:20px;margin-left:6px;'>SA</span>"
                : "Admin Portal";

            string dashUrl = isSA ? "SuperAdminDashboard.aspx" : "AdminDashboard.aspx";
            string memUrl = isSA ? "SuperAdminMembers.aspx" : "Members.aspx";
            string memIcon = isSA ? "fas fa-users-cog" : "fas fa-users";

            string auditItem = isSA
                ? NavItem("fas fa-clipboard-list", "Audit Logs",
                          "AuditLogs.aspx", activePage == "auditlogs", accent)
                : "";

            return $@"
<nav class='col-12 col-md-3 col-lg-2 d-block'
     style='min-height:100vh;background:{bg};'>
  <div class='position-sticky pt-3'>
    <div style='text-align:center;margin-bottom:1.5rem;padding:0 10px;'>
      <h4 style='color:white;margin:0;'>{title}</h4>
    </div>
    <ul class='nav flex-column' style='padding:0;list-style:none;margin:0;'>
      {NavItem("fas fa-tachometer-alt", "Dashboard", dashUrl, activePage == "dashboard", accent)}
      {NavItem("fas fa-book", "Books", "Books.aspx", activePage == "books", accent)}
      {NavItem(memIcon, "Members", memUrl, activePage == "members", accent)}
      {NavItem("fas fa-hand-holding", "Borrow Transaction", "borrowtransac.aspx", activePage == "borrow", accent)}
      {NavItem("fas fa-chart-bar", "Reports", "reports.aspx", activePage == "reports", accent)}
      {auditItem}
      {NavItem("fas fa-sign-out-alt", "Logout", "Logout.aspx", false, accent)}
    </ul>
  </div>
</nav>";
        }

        private static string NavItem(string icon, string label, string url,
                                       bool isActive, string accent)
        {
            string bg = isActive ? "rgba(255,255,255,0.2)" : "transparent";
            string border = isActive ? $"border-left:4px solid {accent};"
                                     : "border-left:4px solid transparent;";

            return $@"<li style='list-style:none;'>
  <a href='{url}' style='color:white;padding:15px 20px;display:block;
     text-decoration:none;background:{bg};{border}transition:background .2s;'
     onmouseover=""this.style.background='rgba(255,255,255,0.1)'""
     onmouseout=""this.style.background='{bg}'"">
    <i class='{icon}' style='margin-right:8px;width:16px;text-align:center;'></i>{label}
  </a>
</li>";
        }
    }
}