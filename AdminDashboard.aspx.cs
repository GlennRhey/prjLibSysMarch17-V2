using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null) { Response.Redirect("Login.aspx"); return; }

            string role = Session["Role"]?.ToString();

            // Super Admin must never land on the Admin dashboard
            if (role == "Super Admin") { Response.Redirect("SuperAdminDashboard.aspx"); return; }
            if (role != "Admin") { Response.Redirect("MemberDashboard.aspx"); return; }

            litSidebar.Text = SidebarHelper.GetSidebar("Admin", "dashboard",
                "Welcome, " + (Session["FullName"] ?? Session["UserID"]).ToString());

            if (!IsPostBack)
            {
                LoadDashboardStatistics();
                LoadRecentLoans();
                LoadPopularBooks();
                LoadNotifications();
            }
        }

        private void LoadDashboardStatistics()
        {
            try
            {
                var p = new SqlParameter[0];
                lblTotalBooks.Text = DatabaseHelper.ExecuteQuery("SELECT COUNT(*) FROM tblBooks", p).Rows[0][0].ToString();
                lblTotalMembers.Text = DatabaseHelper.ExecuteQuery(@"
                    SELECT COUNT(*) FROM tblMembers m
                    INNER JOIN tblUsers u ON m.UserID = u.UserID WHERE u.IsActive = 1", p).Rows[0][0].ToString();
                lblActiveLoans.Text = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblTransactions WHERE Status IN ('Active','Overdue') AND RequestStatus='Accepted'", p).Rows[0][0].ToString();
                lblOverdueBooks.Text = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblTransactions WHERE Status='Overdue'", p).Rows[0][0].ToString();
            }
            catch
            {
                lblTotalBooks.Text = lblTotalMembers.Text =
                lblActiveLoans.Text = lblOverdueBooks.Text = "N/A";
            }
        }

        private void LoadRecentLoans()
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT TOP 10 b.Title AS BookTitle, m.FullName AS MemberName, t.BorrowDate AS LoanDate
                    FROM tblTransactions t
                    INNER JOIN tblMembers m ON t.MemberID = m.MemberID
                    INNER JOIN tblBooks   b ON t.ISBN     = b.ISBN
                    WHERE t.Status IN ('Active','Overdue') AND t.RequestStatus='Accepted' ORDER BY t.BorrowDate DESC", new SqlParameter[0]);
                gvRecentLoans.DataSource = dt;
                gvRecentLoans.DataBind();
            }
            catch { gvRecentLoans.DataSource = null; gvRecentLoans.DataBind(); }
        }

        private void LoadPopularBooks()
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT TOP 10 b.Title, b.Author, COUNT(t.BorrowID) AS LoanCount
                    FROM tblBooks b
                    LEFT JOIN tblTransactions t ON b.ISBN = t.ISBN
                        AND t.RequestType = 'Borrow' AND t.RequestStatus = 'Accepted'
                    GROUP BY b.ISBN, b.Title, b.Author ORDER BY LoanCount DESC", new SqlParameter[0]);
                gvPopularBooks.DataSource = dt;
                gvPopularBooks.DataBind();
            }
            catch { gvPopularBooks.DataSource = null; gvPopularBooks.DataBind(); }
        }

        private void LoadNotifications()
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT TOP 10 Subject, Recipient, Message, CreatedAt, Status, IsRead
                    FROM tblNotifications ORDER BY CreatedAt DESC", new SqlParameter[0]);

                if (dt.Rows.Count > 0)
                {
                    int unread = 0;
                    foreach (DataRow r in dt.Rows)
                        if (!Convert.ToBoolean(r["IsRead"])) unread++;

                    adminNotificationBadge.Text = unread > 0 ? unread.ToString() : "0";

                    string html = "";
                    foreach (DataRow row in dt.Rows)
                    {
                        string date = Convert.ToDateTime(row["CreatedAt"]).ToString("MMM dd, yyyy HH:mm");
                        string subject = System.Web.HttpUtility.HtmlEncode(row["Subject"].ToString());
                        string message = System.Web.HttpUtility.HtmlEncode(row["Message"].ToString());
                        string recipient = System.Web.HttpUtility.HtmlEncode(row["Recipient"].ToString());
                        string status = row["Status"].ToString();
                        bool isRead = Convert.ToBoolean(row["IsRead"]);
                        string sc = status == "Sent" ? "success" : (status == "Pending" ? "warning" : "danger");
                        string border = !isRead ? "border-left:3px solid #ffc107;" : "";
                        html += $@"<div class='card mb-2' style='{border}'>
                            <div class='card-body'>
                                <div class='d-flex justify-content-between align-items-start'>
                                    <div>
                                        <h6 class='mb-1'>{subject}</h6>
                                        <p class='mb-1 text-muted'>{message}</p>
                                        <small class='text-muted'>To: {recipient} &mdash; {date}</small>
                                    </div>
                                    <span class='badge bg-{sc}'>{status}</span>
                                </div>
                            </div>
                        </div>";
                    }
                    notificationsList.InnerHtml = html;
                    noNotificationsModal.Visible = false;
                    gvNotifications.DataSource = dt;
                    gvNotifications.DataBind();
                }
                else
                {
                    adminNotificationBadge.Text = "0";
                    notificationsList.InnerHtml = "";
                    noNotificationsModal.Visible = true;
                    gvNotifications.DataSource = null;
                    gvNotifications.DataBind();
                }
            }
            catch
            {
                adminNotificationBadge.Text = "0";
                notificationsList.InnerHtml = "";
                noNotificationsModal.Visible = true;
                gvNotifications.DataSource = null;
                gvNotifications.DataBind();
            }
        }

        protected void btnSendReminders_Click(object sender, EventArgs e)
        {
            try
            {
                DatabaseHelper.SendDueDateReminders();
                LoadNotifications();
                ScriptManager.RegisterStartupScript(this, GetType(), "reminderSuccess",
                    "alert('Due date reminders sent successfully!');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "reminderError",
                    $"alert('Failed to send reminders: {ex.Message.Replace("'", "\\'")}');", true);
            }
        }
    }
}