using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class MemberDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["Role"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (Session["Role"].ToString() != "Member")
            {
                Response.Redirect("AdminDashboard.aspx");
                return;
            }

            lblStudentName.Text = "Welcome, " + (Session["FullName"] ?? Session["UserID"]).ToString();

            if (!IsPostBack)
            {
                LoadMemberStatistics();
                LoadRecommendations();
                LoadMemberNotifications();
            }
        }

        private void LoadMemberStatistics()
        {
            // Always load Available Books first — needs no MemberID
            try
            {
                lblAvailableBooks.Text = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblBooks WHERE AvailableCopies > 0",
                    new SqlParameter[0]).Rows[0][0].ToString();
            }
            catch { lblAvailableBooks.Text = "0"; }

            // Resolve MemberID directly from UserID — do not rely on session alone
            string userId = Session["UserID"]?.ToString();
            if (string.IsNullOrEmpty(userId))
            {
                lblBorrowedBooks.Text = lblOverdueBooks.Text = lblTotalBorrowed.Text = "0";
                return;
            }

            int memberId = 0;

            DataTable dtMember = DatabaseHelper.ExecuteQuery(
                "SELECT MemberID FROM tblMembers WHERE UserID = @UserID",
                new SqlParameter[] { new SqlParameter("@UserID", userId) });

            if (dtMember.Rows.Count > 0)
            {
                memberId = Convert.ToInt32(dtMember.Rows[0]["MemberID"]);
                Session["MemberID"] = memberId.ToString();
            }

            if (memberId <= 0)
            {
                lblBorrowedBooks.Text = lblOverdueBooks.Text = lblTotalBorrowed.Text = "N/A - MemberID not found for UserID: " + userId;
                return;
            }

            lblBorrowedBooks.Text = DatabaseHelper.ExecuteQuery(
                "SELECT COUNT(*) FROM tblTransactions WHERE MemberID = @MemberID AND Status = 'Active' AND RequestStatus = 'Accepted' AND RequestType = 'Borrow'",
                new SqlParameter[] { new SqlParameter("@MemberID", memberId) }).Rows[0][0].ToString();

            lblOverdueBooks.Text = DatabaseHelper.ExecuteQuery(
                "SELECT COUNT(*) FROM tblTransactions WHERE MemberID = @MemberID AND Status = 'Active' AND RequestStatus = 'Accepted' AND RequestType = 'Borrow' AND DueDate < GETDATE()",
                new SqlParameter[] { new SqlParameter("@MemberID", memberId) }).Rows[0][0].ToString();

            lblTotalBorrowed.Text = DatabaseHelper.ExecuteQuery(
                "SELECT COUNT(DISTINCT BorrowID) FROM tblTransactions WHERE MemberID = @MemberID AND RequestStatus IN ('Accepted', 'Pending') AND Status IN ('Active', 'Returned', 'Overdue')",
                new SqlParameter[] { new SqlParameter("@MemberID", memberId) }).Rows[0][0].ToString();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadMemberStatistics();
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string currentPassword = txtCurrentPassword.Text.Trim();
            string newPassword = txtNewPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            HidePasswordMessages();

            if (string.IsNullOrEmpty(currentPassword) || string.IsNullOrEmpty(newPassword) || string.IsNullOrEmpty(confirmPassword))
            { ShowPasswordError("All fields are required."); KeepModalOpen(); return; }

            if (newPassword.Length < 6)
            { ShowPasswordError("New password must be at least 6 characters long."); KeepModalOpen(); return; }

            if (newPassword != confirmPassword)
            { ShowPasswordError("New password and confirmation do not match."); KeepModalOpen(); return; }

            if (currentPassword == newPassword)
            { ShowPasswordError("New password must be different from current password."); KeepModalOpen(); return; }

            try
            {
                bool success = DatabaseHelper.ChangePassword(
                    Session["UserID"].ToString(), currentPassword, newPassword);

                if (success)
                {
                    ShowPasswordSuccess("Password changed successfully!");
                    txtCurrentPassword.Text = txtNewPassword.Text = txtConfirmPassword.Text = "";
                }
                else
                {
                    ShowPasswordError("Current password is incorrect.");
                }
                KeepModalOpen();
            }
            catch (Exception ex)
            {
                ShowPasswordError("An error occurred: " + ex.Message);
                KeepModalOpen();
            }
        }

        private void KeepModalOpen()
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "keepModalOpen",
                "setTimeout(function(){ new bootstrap.Modal(document.getElementById('changePasswordModal')).show(); }, 100);", true);
        }

        private void ShowPasswordError(string message)
        {
            lblPasswordError.Text = message;
            passwordError.Style["display"] = "block";
            passwordSuccess.Style["display"] = "none";
        }

        private void ShowPasswordSuccess(string message)
        {
            lblPasswordSuccess.Text = message;
            passwordSuccess.Style["display"] = "block";
            passwordError.Style["display"] = "none";
        }

        private void HidePasswordMessages()
        {
            passwordError.Style["display"] = "none";
            passwordSuccess.Style["display"] = "none";
        }

        private void LoadRecommendations()
        {
            try
            {
                string memberId = Session["MemberID"]?.ToString();
                if (string.IsNullOrEmpty(memberId))
                {
                    gvRecommendations.Visible = false;
                    noRecommendations.Visible = true;
                    return;
                }

                int memberIdInt = Convert.ToInt32(memberId);
                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT TOP 5
                        b.ISBN, b.Title, b.Author, b.Category,
                        b.AvailableCopies,
                        COUNT(t.BorrowID) AS Popularity
                    FROM tblBooks b
                    INNER JOIN tblTransactions t ON b.ISBN = t.ISBN
                    WHERE t.MemberID IN (
                        SELECT MemberID FROM tblTransactions
                        WHERE ISBN IN (
                            SELECT ISBN FROM tblTransactions WHERE MemberID = @MemberID
                        )
                        AND MemberID <> @MemberID
                    )
                    AND b.ISBN NOT IN (
                        SELECT ISBN FROM tblTransactions WHERE MemberID = @MemberID
                    )
                    AND b.AvailableCopies > 0
                    GROUP BY b.ISBN, b.Title, b.Author, b.Category, b.AvailableCopies
                    ORDER BY Popularity DESC",
                    new SqlParameter[] { new SqlParameter("@MemberID", memberIdInt) });

                if (dt.Rows.Count > 0)
                {
                    gvRecommendations.DataSource = dt;
                    gvRecommendations.DataBind();
                    gvRecommendations.Visible = true;
                    noRecommendations.Visible = false;
                }
                else
                {
                    gvRecommendations.Visible = false;
                    noRecommendations.Visible = true;
                }
            }
            catch
            {
                gvRecommendations.Visible = false;
                noRecommendations.Visible = true;
            }
        }

        private void LoadMemberNotifications()
        {
            try
            {
                string memberEmail = Session["Email"]?.ToString();
                if (string.IsNullOrEmpty(memberEmail)) { SetEmptyNotificationState(); return; }

                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT TOP 10 Subject, Message, CreatedAt, Status, IsRead
                    FROM tblNotifications
                    WHERE Recipient = @Email
                    ORDER BY CreatedAt DESC",
                    new SqlParameter[] { new SqlParameter("@Email", memberEmail) });

                if (dt.Rows.Count > 0)
                {
                    int unreadCount = 0;
                    foreach (DataRow r in dt.Rows)
                        if (!Convert.ToBoolean(r["IsRead"])) unreadCount++;

                    studentNotificationBadge.Text = unreadCount > 0 ? unreadCount.ToString() : "0";
                    studentNotificationList.Visible = true;
                    noStudentNotifications.Visible = false;

                    string dropdownHtml = "";
                    int dropdownCount = Math.Min(5, dt.Rows.Count);
                    for (int i = 0; i < dropdownCount; i++)
                    {
                        DataRow row = dt.Rows[i];
                        string date = Convert.ToDateTime(row["CreatedAt"]).ToString("MMM dd");
                        string subj = System.Web.HttpUtility.HtmlEncode(row["Subject"].ToString());
                        string msg = System.Web.HttpUtility.HtmlEncode(row["Message"].ToString());
                        bool isRead = Convert.ToBoolean(row["IsRead"]);
                        string bold = !isRead ? "font-weight:600;" : "";

                        dropdownHtml += $@"
                            <li><a class='dropdown-item' style='{bold}'>
                                <small class='text-muted'>{date}</small><br>
                                <strong>{subj}</strong><br>
                                <small>{msg}</small>
                            </a></li>";
                    }
                    studentNotificationList.InnerHtml = dropdownHtml;

                    string modalHtml = "";
                    foreach (DataRow row in dt.Rows)
                    {
                        string createdAt = Convert.ToDateTime(row["CreatedAt"]).ToString("MMM dd, yyyy HH:mm");
                        string subject = System.Web.HttpUtility.HtmlEncode(row["Subject"].ToString());
                        string message = System.Web.HttpUtility.HtmlEncode(row["Message"].ToString());
                        string status = row["Status"].ToString();
                        bool isRead = Convert.ToBoolean(row["IsRead"]);
                        string statusClass = status == "Sent" ? "success" : (status == "Pending" ? "warning" : "danger");
                        string unreadStyle = !isRead ? "border-left: 3px solid #dc3545;" : "";

                        modalHtml += $@"
                            <div class='card mb-2' style='{unreadStyle}'>
                                <div class='card-body'>
                                    <div class='d-flex justify-content-between align-items-start'>
                                        <div>
                                            <h6 class='mb-1'>{subject}</h6>
                                            <p class='mb-1 text-muted'>{message}</p>
                                            <small class='text-muted'>{createdAt}</small>
                                        </div>
                                        <span class='badge bg-{statusClass}'>{status}</span>
                                    </div>
                                </div>
                            </div>";
                    }
                    notificationsList.InnerHtml = modalHtml;
                    noNotificationsModal.Visible = false;
                }
                else
                {
                    SetEmptyNotificationState();
                }
            }
            catch
            {
                SetEmptyNotificationState();
            }
        }

        private void SetEmptyNotificationState()
        {
            studentNotificationBadge.Text = "0";
            studentNotificationList.Visible = false;
            noStudentNotifications.Visible = true;
            notificationsList.InnerHtml = "";
            noNotificationsModal.Visible = true;
        }
    }
}