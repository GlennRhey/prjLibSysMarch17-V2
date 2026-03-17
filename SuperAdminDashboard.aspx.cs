using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class SuperAdminDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null) { Response.Redirect("Login.aspx"); return; }
            if (Session["Role"]?.ToString() != "Super Admin") { Response.Redirect("AdminDashboard.aspx"); return; }

            litSidebar.Text = SidebarHelper.GetSidebar("Super Admin", "dashboard",
                "Welcome, " + (Session["FullName"] ?? Session["UserID"]).ToString());

            if (!IsPostBack) LoadStats();
        }

        private void LoadStats()
        {
            try
            {
                var p = new SqlParameter[0];
                lblTotalBooks.Text = DatabaseHelper.ExecuteQuery("SELECT COUNT(*) FROM tblBooks", p).Rows[0][0].ToString();
                lblTotalMembers.Text = DatabaseHelper.ExecuteQuery(@"
                    SELECT COUNT(*) FROM tblMembers m
                    INNER JOIN tblUsers u ON m.UserID = u.UserID
                    WHERE u.IsActive = 1", p).Rows[0][0].ToString();
                lblTotalAdmins.Text = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblUsers WHERE Role = 'Admin' AND IsActive = 1", p).Rows[0][0].ToString();
                lblActiveLoans.Text = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblTransactions WHERE Status IN ('Active','Overdue') AND RequestStatus='Accepted'", p).Rows[0][0].ToString();
                lblOverdueBooks.Text = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblTransactions WHERE Status='Overdue'", p).Rows[0][0].ToString();
                lblAuditCount.Text = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblAuditLogs", p).Rows[0][0].ToString();
            }
            catch
            {
                lblTotalBooks.Text = lblTotalMembers.Text = lblTotalAdmins.Text =
                lblActiveLoans.Text = lblOverdueBooks.Text = lblAuditCount.Text = "N/A";
            }

            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT TOP 10 Timestamp, UserID, UserName, Action, AffectedTable, AffectedID
                    FROM tblAuditLogs ORDER BY Timestamp DESC", new SqlParameter[0]);
                gvRecentAudit.DataSource = dt;
                gvRecentAudit.DataBind();
            }
            catch { gvRecentAudit.DataSource = null; gvRecentAudit.DataBind(); }
        }
    }
}