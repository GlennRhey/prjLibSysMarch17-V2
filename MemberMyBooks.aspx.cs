using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class MemberMyBooks : System.Web.UI.Page
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

            if (!IsPostBack)
            {
                HideStatusMessage();
                LoadMyBooks();
            }
        }

        private void LoadMyBooks()
        {
            string memberIdStr = Session["MemberID"]?.ToString() ?? "";
            if (string.IsNullOrEmpty(memberIdStr)) { ShowError("Session expired. Please log in again."); return; }

            int memberId = Convert.ToInt32(memberIdStr);

            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT
                        t.BorrowID,
                        b.Title,
                        b.Author,
                        t.BorrowDate,
                        t.DueDate,
                        t.ReturnDate,
                        t.RequestType,
                        t.RequestStatus,
                        t.Status,
                        CASE
                            WHEN t.RequestType   = 'Return'
                             AND t.RequestStatus = 'Pending'  THEN 'Return Pending'
                            WHEN t.RequestStatus = 'Pending'  THEN 'Pending Approval'
                            WHEN t.Status        = 'Active'
                             AND t.DueDate < GETDATE()        THEN 'Overdue'
                            WHEN t.Status        = 'Active'   THEN 'Active'
                            WHEN t.Status        = 'Overdue'  THEN 'Overdue'
                            WHEN t.Status        = 'Returned' THEN 'Returned'
                            ELSE t.Status
                        END AS DisplayStatus
                    FROM  tblTransactions t
                    INNER JOIN tblBooks b ON b.ISBN = t.ISBN
                    WHERE t.MemberID      = @MemberID
                      AND t.RequestStatus != 'Rejected'
                    ORDER BY t.BorrowDate DESC",
                    new SqlParameter[] { new SqlParameter("@MemberID", memberId) });

                gvMyBooks.DataSource = dt;
                gvMyBooks.DataBind();
            }
            catch (Exception ex)
            {
                gvMyBooks.DataSource = null;
                gvMyBooks.DataBind();
                ShowError("Error loading books: " + ex.Message);
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e) { HideStatusMessage(); LoadMyBooks(); }

        protected void gvMyBooks_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMyBooks.PageIndex = e.NewPageIndex;
            LoadMyBooks();
        }

        protected void gvMyBooks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page" || e.CommandName == "Sort") return;
            if (string.IsNullOrEmpty(e.CommandArgument?.ToString())) return;

            int borrowId;
            if (!int.TryParse(e.CommandArgument.ToString(), out borrowId)) return;

            if (e.CommandName == "ReturnBook")
            { HideStatusMessage(); HandleReturn(borrowId); }
            else if (e.CommandName == "ViewDetail")
            { ShowDetailModal(borrowId); }
        }

        private void ShowDetailModal(int borrowId)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT
                        b.Title, b.Author, b.ISBN,
                        t.BorrowDate, t.DueDate, t.ReturnDate,
                        t.RequestType, t.RequestStatus, t.Status,
                        t.AdminID,
                        u.FullName AS AdminName,
                        u.Email    AS AdminEmail,
                        CASE
                            WHEN t.RequestType   = 'Return'
                             AND t.RequestStatus = 'Pending'  THEN 'Return Pending'
                            WHEN t.RequestStatus = 'Pending'  THEN 'Pending Approval'
                            WHEN t.Status        = 'Active'
                             AND t.DueDate < GETDATE()        THEN 'Overdue'
                            WHEN t.Status        = 'Active'   THEN 'Active'
                            WHEN t.Status        = 'Overdue'  THEN 'Overdue'
                            WHEN t.Status        = 'Returned' THEN 'Returned'
                            ELSE t.Status
                        END AS DisplayStatus
                    FROM  tblTransactions t
                    INNER JOIN tblBooks b ON b.ISBN    = t.ISBN
                    LEFT  JOIN tblUsers u ON u.UserID  = t.AdminID
                    WHERE t.BorrowID = @BorrowID",
                    new SqlParameter[] { new SqlParameter("@BorrowID", borrowId) });

                if (dt.Rows.Count == 0) { ShowError("Details not found."); return; }

                DataRow r = dt.Rows[0];
                string Esc(string v) => (v ?? "").Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ");

                string script = string.Format(@"showBookDetailModal({{
                    title:         '{0}',
                    author:        '{1}',
                    isbn:          '{2}',
                    borrowDate:    '{3}',
                    dueDate:       '{4}',
                    returnDate:    '{5}',
                    displayStatus: '{6}',
                    adminID:       '{7}',
                    adminName:     '{8}',
                    adminEmail:    '{9}'
                }});",
                    Esc(r["Title"].ToString()),
                    Esc(r["Author"].ToString()),
                    Esc(r["ISBN"].ToString()),
                    r["BorrowDate"] != DBNull.Value ? Convert.ToDateTime(r["BorrowDate"]).ToString("MM/dd/yyyy") : "",
                    r["DueDate"] != DBNull.Value ? Convert.ToDateTime(r["DueDate"]).ToString("MM/dd/yyyy") : "",
                    r["ReturnDate"] != DBNull.Value ? Convert.ToDateTime(r["ReturnDate"]).ToString("MM/dd/yyyy") : "",
                    Esc(r["DisplayStatus"].ToString()),
                    Esc(r["AdminID"]?.ToString() ?? ""),
                    Esc(r["AdminName"]?.ToString() ?? ""),
                    Esc(r["AdminEmail"]?.ToString() ?? "")
                );

                ScriptManager.RegisterStartupScript(this, GetType(), "showDetail", script, true);
            }
            catch (Exception ex) { ShowError("Error loading details: " + ex.Message); }
        }

        private void HandleReturn(int borrowId)
        {
            try
            {
                string memberIdStr = Session["MemberID"]?.ToString() ?? "";
                if (string.IsNullOrEmpty(memberIdStr)) { ShowError("Session expired."); return; }

                int memberId = Convert.ToInt32(memberIdStr);

                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT BorrowID, ISBN, RequestType, RequestStatus, Status
                    FROM   tblTransactions
                    WHERE  BorrowID = @BorrowID AND MemberID = @MemberID",
                    new SqlParameter[]
                    {
                        new SqlParameter("@BorrowID", borrowId),
                        new SqlParameter("@MemberID", memberId)
                    });

                if (dt.Rows.Count == 0) { ShowError("Transaction not found."); return; }

                string requestType = dt.Rows[0]["RequestType"].ToString();
                string requestStatus = dt.Rows[0]["RequestStatus"].ToString();
                string status = dt.Rows[0]["Status"].ToString();
                string isbn = dt.Rows[0]["ISBN"].ToString();

                if (requestStatus != "Accepted" || status != "Active")
                {
                    if (requestType == "Return" && requestStatus == "Pending")
                        ShowError("A return request for this book is already pending admin approval.");
                    else
                        ShowError("This book cannot be returned in its current state.");
                    return;
                }

                int existingReturn = Convert.ToInt32(DatabaseHelper.ExecuteScalar(@"
                    SELECT COUNT(*) FROM tblTransactions
                    WHERE  MemberID = @MemberID AND ISBN = @ISBN
                      AND  RequestType = 'Return' AND RequestStatus = 'Pending'",
                    new SqlParameter[]
                    {
                        new SqlParameter("@MemberID", memberId),
                        new SqlParameter("@ISBN",     isbn)
                    }));

                if (existingReturn > 0)
                { ShowError("A return request for this book is already pending admin approval."); return; }

                DatabaseHelper.ExecuteNonQuery(@"
                    UPDATE tblTransactions
                    SET    RequestType = 'Return', RequestStatus = 'Pending'
                    WHERE  BorrowID = @BorrowID",
                    new SqlParameter[] { new SqlParameter("@BorrowID", borrowId) });

                ShowSuccess("Return request submitted. Please wait for librarian approval.");
                LoadMyBooks();
            }
            catch (Exception ex) { ShowError("Error submitting return request: " + ex.Message); }
        }

        protected string GetStatusBadgeClass(object displayStatus)
        {
            if (displayStatus == null) return "bg-secondary";
            switch (displayStatus.ToString())
            {
                case "Active": return "bg-success";
                case "Overdue": return "bg-danger";
                case "Returned": return "bg-secondary";
                case "Pending Approval": return "bg-warning text-dark";
                case "Return Pending": return "bg-info text-dark";
                default: return "bg-secondary";
            }
        }

        protected string GetBookStatus(object displayStatus) => displayStatus?.ToString() ?? "Unknown";

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string current = txtCurrentPassword.Text.Trim();
            string newPass = txtNewPassword.Text.Trim();
            string confirm = txtConfirmPassword.Text.Trim();

            HidePasswordMessages();

            if (string.IsNullOrEmpty(current) || string.IsNullOrEmpty(newPass) || string.IsNullOrEmpty(confirm))
            { ShowPasswordError("All fields are required."); KeepModalOpen(); return; }

            if (newPass.Length < 6)
            { ShowPasswordError("New password must be at least 6 characters."); KeepModalOpen(); return; }

            if (newPass != confirm)
            { ShowPasswordError("New password and confirmation do not match."); KeepModalOpen(); return; }

            if (current == newPass)
            { ShowPasswordError("New password must be different from current password."); KeepModalOpen(); return; }

            try
            {
                bool success = DatabaseHelper.ChangePassword(Session["UserID"].ToString(), current, newPass);
                if (success)
                { txtCurrentPassword.Text = txtNewPassword.Text = txtConfirmPassword.Text = ""; ShowPasswordSuccess("Password changed successfully!"); }
                else
                { ShowPasswordError("Current password is incorrect."); }
                KeepModalOpen();
            }
            catch (Exception ex) { ShowPasswordError("An error occurred: " + ex.Message); KeepModalOpen(); }
        }

        private void ShowSuccess(string message)
        {
            pnlStatus.Visible = true;
            pnlStatus.CssClass = "alert alert-success alert-dismissible fade show";
            lblStatusMessage.Text = "<strong><i class=\"fas fa-check-circle me-2\"></i>Success!</strong> " + message;
        }

        private void ShowError(string message)
        {
            pnlStatus.Visible = true;
            pnlStatus.CssClass = "alert alert-danger alert-dismissible fade show";
            lblStatusMessage.Text = "<strong><i class=\"fas fa-exclamation-circle me-2\"></i>Error:</strong> " + message;
        }

        private void HideStatusMessage() { pnlStatus.Visible = false; }

        private void KeepModalOpen()
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "keepModal",
                "setTimeout(function(){ new bootstrap.Modal(document.getElementById('changePasswordModal')).show(); }, 100);", true);
        }

        private void ShowPasswordError(string msg)
        { lblPasswordError.Text = msg; passwordError.Style["display"] = "block"; passwordSuccess.Style["display"] = "none"; }

        private void ShowPasswordSuccess(string msg)
        { lblPasswordSuccess.Text = msg; passwordSuccess.Style["display"] = "block"; passwordError.Style["display"] = "none"; }

        private void HidePasswordMessages()
        { passwordError.Style["display"] = "none"; passwordSuccess.Style["display"] = "none"; }
    }
}