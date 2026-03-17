using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class reports : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null) { Response.Redirect("Login.aspx"); return; }

            string role = Session["Role"]?.ToString();
            if (role != "Admin" && role != "Super Admin")
            {
                Response.Redirect("MemberDashboard.aspx");
                return;
            }

            // Render correct sidebar — blue for Super Admin, red for Admin
            litSidebar.Text = SidebarHelper.GetSidebar(role, "reports");

            if (!IsPostBack) LoadReportData();
        }

        protected void btnRefresh_Click(object sender, EventArgs e) { LoadReportData(); }
        protected void btnExport_Click(object sender, EventArgs e) { ExportReportToCSV(); }

        private void LoadReportData()
        {
            try
            {
                lblTotalBooks.Text = GetCount("SELECT COUNT(*) FROM tblBooks");
                lblTotalMembers.Text = GetCount(@"
                    SELECT COUNT(*) FROM tblMembers m
                    INNER JOIN tblUsers u ON m.UserID=u.UserID
                    WHERE u.IsActive=1");
                lblIssuedBooks.Text = GetCount("SELECT COUNT(*) FROM tblTransactions WHERE Status IN ('Active','Overdue') AND RequestStatus='Accepted'");
                lblOverdueBooks.Text = GetCount("SELECT COUNT(*) FROM tblTransactions WHERE Status='Overdue'");
                lblMostBorrowed.Text = GetMostBorrowedBook();
            }
            catch (Exception ex)
            {
                ShowError("Error loading report: " + ex.Message);
                lblTotalBooks.Text = lblTotalMembers.Text =
                    lblIssuedBooks.Text = lblOverdueBooks.Text = "0";
                lblMostBorrowed.Text = "N/A";
            }
        }

        private string GetCount(string query) =>
            DatabaseHelper.ExecuteQuery(query, new SqlParameter[0]).Rows[0][0].ToString();

        private string GetMostBorrowedBook()
        {
            DataTable dt = DatabaseHelper.ExecuteQuery(@"
                SELECT TOP 1 b.Title
                FROM   tblBooks b
                INNER JOIN tblTransactions t ON b.ISBN=t.ISBN
                WHERE  t.RequestType='Borrow' AND t.RequestStatus='Accepted'
                GROUP BY b.ISBN, b.Title
                ORDER BY COUNT(t.BorrowID) DESC",
                new SqlParameter[0]);
            return dt.Rows.Count > 0 ? dt.Rows[0][0].ToString() : "N/A";
        }

        private void ExportReportToCSV()
        {
            try
            {
                var csv = new StringBuilder();
                csv.AppendLine("Library Summary Report");
                csv.AppendLine("Generated on," + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                csv.AppendLine();
                csv.AppendLine("Metric,Value");
                csv.AppendLine("Total Books," + GetCount("SELECT COUNT(*) FROM tblBooks"));
                csv.AppendLine("Total Active Members," + GetCount(@"SELECT COUNT(*) FROM tblMembers m INNER JOIN tblUsers u ON m.UserID=u.UserID WHERE u.IsActive=1"));
                csv.AppendLine("Books Currently on Loan," + GetCount("SELECT COUNT(*) FROM tblTransactions WHERE Status IN ('Active','Overdue') AND RequestStatus='Accepted'"));
                csv.AppendLine("Books Overdue," + GetCount("SELECT COUNT(*) FROM tblTransactions WHERE Status='Overdue'"));
                csv.AppendLine("Most Borrowed Book,\"" + GetMostBorrowedBook() + "\"");
                csv.AppendLine();
                csv.AppendLine("Database,dbLibrarySystem");
                csv.AppendLine("Export Date," + DateTime.Now.ToString("yyyy-MM-dd"));

                byte[] bytes = Encoding.UTF8.GetBytes(csv.ToString());
                Response.Clear();
                Response.ContentType = "text/csv";
                Response.AppendHeader("Content-Disposition",
                    "attachment; filename=LibraryReport_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv");
                Response.BinaryWrite(bytes);
                Response.End();
            }
            catch (Exception ex) { ShowError("Export error: " + ex.Message); }
        }

        private void ShowError(string message)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "error",
                "alert('" + message.Replace("'", "\\'") + "');", true);
        }
    }
}