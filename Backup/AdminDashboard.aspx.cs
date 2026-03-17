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
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (Session["Role"]?.ToString() != "Admin")
            {
                Response.Redirect("StudentDashboard.aspx");
                return;
            }

            lblAdminName.Text = "Welcome, " + (Session["FullName"] ?? Session["UserID"]).ToString();

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
                SqlParameter[] emptyParams = new SqlParameter[0];

                lblTotalBooks.Text = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblBooks",
                    emptyParams).Rows[0][0].ToString();

                lblTotalMembers.Text = DatabaseHelper.ExecuteQuery(@"
                    SELECT COUNT(*) FROM tblMembers m
                    INNER JOIN tblUsers u ON m.UserID = u.UserID
                    WHERE u.IsActive = 1",
                    emptyParams).Rows[0][0].ToString();

                lblActiveLoans.Text = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblTransactions WHERE Status = 'Active'",
                    emptyParams).Rows[0][0].ToString();

                lblOverdueBooks.Text = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblTransactions WHERE Status = 'Active' AND DueDate < GETDATE()",
                    emptyParams).Rows[0][0].ToString();
            }
            catch
            {
                lblTotalBooks.Text = lblTotalMembers.Text = lblActiveLoans.Text = lblOverdueBooks.Text = "N/A";
            }
        }

        private void LoadRecentLoans()
        {
            try
            {
                SqlParameter[] emptyParams = new SqlParameter[0];

                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT TOP 10
                        b.Title    AS BookTitle,
                        m.FullName AS MemberName,
                        t.BorrowDate AS LoanDate
                    FROM tblTransactions t
                    INNER JOIN tblMembers m ON t.MemberID = m.MemberID
                    INNER JOIN tblBooks   b ON t.ISBN = b.ISBN
                    WHERE t.Status = 'Active'
                    ORDER BY t.BorrowDate DESC",
                    emptyParams);

                gvRecentLoans.DataSource = dt;
                gvRecentLoans.DataBind();
            }
            catch
            {
                gvRecentLoans.DataSource = null;
                gvRecentLoans.DataBind();
            }
        }

        private void LoadPopularBooks()
        {
            try
            {
                SqlParameter[] emptyParams = new SqlParameter[0];

                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT TOP 10
                        b.Title, b.Author,
                        COUNT(t.BorrowID) AS LoanCount
                    FROM tblBooks b
                    LEFT JOIN tblTransactions t
                        ON b.ISBN = t.ISBN
                        AND t.RequestType = 'Borrow'
                        AND t.RequestStatus = 'Accepted'
                    GROUP BY b.ISBN, b.Title, b.Author
                    ORDER BY LoanCount DESC",
                    emptyParams);

                gvPopularBooks.DataSource = dt;
                gvPopularBooks.DataBind();
            }
            catch
            {
                gvPopularBooks.DataSource = null;
                gvPopularBooks.DataBind();
            }
        }

        private void LoadNotifications()
        {
            try
            {
                string query = @"
                    SELECT TOP 10 Subject, Recipient, Message, CreatedAt, Status, IsRead
                    FROM tblNotifications
                    ORDER BY CreatedAt DESC";

                DataTable dt = DatabaseHelper.ExecuteQuery(query, new SqlParameter[0]);

                if (dt.Rows.Count > 0)
                {
                    int unreadCount = 0;
                    foreach (DataRow r in dt.Rows)
                        if (!Convert.ToBoolean(r["IsRead"])) unreadCount++;

                    adminNotificationBadge.Text = unreadCount > 0 ? unreadCount.ToString() : "0";

                    string modalHtml = "";
                    foreach (DataRow row in dt.Rows)
                    {
                        string createdAt = Convert.ToDateTime(row["CreatedAt"]).ToString("MMM dd, yyyy HH:mm");
                        string subject = System.Web.HttpUtility.HtmlEncode(row["Subject"].ToString());
                        string message = System.Web.HttpUtility.HtmlEncode(row["Message"].ToString());
                        string recipient = System.Web.HttpUtility.HtmlEncode(row["Recipient"].ToString());
                        string status = row["Status"].ToString();
                        bool isRead = Convert.ToBoolean(row["IsRead"]);
                        string statusClass = status == "Sent" ? "success" : (status == "Pending" ? "warning" : "danger");
                        string unreadStyle = !isRead ? "border-left: 3px solid #ffc107;" : "";

                        modalHtml += $@"
                            <div class='card mb-2' style='{unreadStyle}'>
                                <div class='card-body'>
                                    <div class='d-flex justify-content-between align-items-start'>
                                        <div>
                                            <h6 class='mb-1'>{subject}</h6>
                                            <p class='mb-1 text-muted'>{message}</p>
                                            <small class='text-muted'>To: {recipient} &mdash; {createdAt}</small>
                                        </div>
                                        <span class='badge bg-{statusClass}'>{status}</span>
                                    </div>
                                </div>
                            </div>";
                    }

                    notificationsList.InnerHtml = modalHtml;
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