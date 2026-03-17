using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class MemberBorrowBooks : System.Web.UI.Page
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
                LoadAvailableBooks();
                HideStatusMessage();
            }

            // Always refresh the info banner (even on postback) so it
            // reflects the latest tblSystemSettings values.
            LoadBorrowInfoBanner();
        }

        // ── Populate the info banner from tblSystemSettings ───────────────────

        private void LoadBorrowInfoBanner()
        {
            try
            {
                string memberIdStr = Session["MemberID"]?.ToString() ?? "";
                string memberType = Session["MemberType"]?.ToString() ?? "Student";

                int maxBooks = 3; // fallback

                if (!string.IsNullOrEmpty(memberIdStr))
                {
                    int memberId = Convert.ToInt32(memberIdStr);
                    var (max, _) = DatabaseHelper.GetBorrowLimits(memberId);
                    maxBooks = max;
                }
                else
                {
                    // Fallback: read directly for the member type from session
                    DataTable dt = DatabaseHelper.ExecuteQuery(
                        "SELECT SettingValue FROM tblSystemSettings WHERE MemberType = @MT AND SettingKey = 'MaxBorrowedBooks'",
                        new SqlParameter[] { new SqlParameter("@MT", memberType) });

                    if (dt.Rows.Count > 0)
                        maxBooks = Convert.ToInt32(dt.Rows[0]["SettingValue"]);
                }

                lblBorrowInfo.Text =
                    $"You may borrow up to <strong>{maxBooks} book{(maxBooks == 1 ? "" : "s")}</strong> " +
                    $"and have up to <strong>{maxBooks} pending request{(maxBooks == 1 ? "" : "s")}</strong> " +
                    $"at a time. All requests require librarian approval.";
            }
            catch
            {
                lblBorrowInfo.Text =
                    "You may borrow books up to your account limit. All requests require librarian approval.";
            }
        }

        // ── Load available books grid ─────────────────────────────────────────

        private void LoadAvailableBooks()
        {
            try
            {
                string query = @"
                    SELECT ISBN, Title, Author, Category, AvailableCopies
                    FROM   tblBooks
                    WHERE  AvailableCopies > 0";

                var parameters = new System.Collections.Generic.List<SqlParameter>();

                if (!string.IsNullOrWhiteSpace(txtSearchBooks.Text))
                {
                    query += " AND (Title LIKE @Search OR Author LIKE @Search)";
                    parameters.Add(new SqlParameter("@Search", "%" + txtSearchBooks.Text.Trim() + "%"));
                }
                if (!string.IsNullOrEmpty(ddlCategory.SelectedValue))
                {
                    query += " AND Category = @Category";
                    parameters.Add(new SqlParameter("@Category", ddlCategory.SelectedValue));
                }

                query += " ORDER BY Title";

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters.ToArray());
                gvAvailableBooks.DataSource = dt;
                gvAvailableBooks.DataBind();
            }
            catch (Exception ex)
            {
                gvAvailableBooks.DataSource = null;
                gvAvailableBooks.DataBind();
                ShowError("Error loading books: " + ex.Message);
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            txtSearchBooks.Text = "";
            ddlCategory.SelectedIndex = 0;
            HideStatusMessage();
            LoadAvailableBooks();
        }

        protected void txtSearchBooks_TextChanged(object sender, EventArgs e) { LoadAvailableBooks(); }
        protected void btnSearchBooks_Click(object sender, EventArgs e) { LoadAvailableBooks(); }
        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e) { LoadAvailableBooks(); }

        protected void gvAvailableBooks_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvAvailableBooks.PageIndex = e.NewPageIndex;
            LoadAvailableBooks();
        }

        protected void gvAvailableBooks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "BorrowBook") return;

            HideStatusMessage();

            string isbn = e.CommandArgument.ToString();
            string memberIdStr = Session["MemberID"]?.ToString() ?? "";

            if (string.IsNullOrEmpty(memberIdStr)) { ShowError("Session expired. Please log in again."); return; }

            int memberId = Convert.ToInt32(memberIdStr);

            try
            {
                // Get limits live from tblSystemSettings
                var (maxBooks, borrowDays) = DatabaseHelper.GetBorrowLimits(memberId);

                // 1. Check active borrows against limit
                int activeBorrows = Convert.ToInt32(DatabaseHelper.ExecuteScalar(@"
                    SELECT COUNT(*) FROM tblTransactions
                    WHERE  MemberID = @MemberID AND Status = 'Active' AND RequestStatus = 'Accepted'",
                    new SqlParameter[] { new SqlParameter("@MemberID", memberId) }));

                if (activeBorrows >= maxBooks)
                {
                    ShowError($"You already have {maxBooks} borrowed book{(maxBooks == 1 ? "" : "s")}. Please return a book before borrowing another.");
                    return;
                }

                // 2. Check pending requests against limit
                int pendingBorrows = Convert.ToInt32(DatabaseHelper.ExecuteScalar(@"
                    SELECT COUNT(*) FROM tblTransactions
                    WHERE  MemberID = @MemberID AND RequestType = 'Borrow' AND RequestStatus = 'Pending'",
                    new SqlParameter[] { new SqlParameter("@MemberID", memberId) }));

                if (pendingBorrows >= maxBooks)
                {
                    ShowError($"You already have {maxBooks} pending borrow request{(maxBooks == 1 ? "" : "s")}. Please wait for librarian approval.");
                    return;
                }

                // 3. Check duplicate
                int duplicate = Convert.ToInt32(DatabaseHelper.ExecuteScalar(@"
                    SELECT COUNT(*) FROM tblTransactions
                    WHERE  MemberID = @MemberID AND ISBN = @ISBN
                      AND  RequestStatus != 'Rejected'
                      AND  Status        != 'Returned'
                      AND  Status        != 'Cancelled'",
                    new SqlParameter[]
                    {
                        new SqlParameter("@MemberID", memberId),
                        new SqlParameter("@ISBN",     isbn)
                    }));

                if (duplicate > 0) { ShowError("You already have an active or pending request for this book."); return; }

                // 4. Get book title
                DataTable bookDt = DatabaseHelper.ExecuteQuery(
                    "SELECT Title FROM tblBooks WHERE ISBN = @ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                if (bookDt.Rows.Count == 0) { ShowError("Book not found."); return; }
                string bookTitle = bookDt.Rows[0]["Title"].ToString();

                // 5. Insert borrow request with dynamic due date
                DatabaseHelper.ExecuteNonQuery(@"
                    INSERT INTO tblTransactions
                        (MemberID, ISBN, RequestType, RequestStatus, BorrowDate, DueDate, Status)
                    VALUES
                        (@MemberID, @ISBN, 'Borrow', 'Pending', GETDATE(), DATEADD(DAY, @BorrowDays, GETDATE()), 'Active')",
                    new SqlParameter[]
                    {
                        new SqlParameter("@MemberID",  memberId),
                        new SqlParameter("@ISBN",       isbn),
                        new SqlParameter("@BorrowDays", borrowDays)
                    });

                ShowSuccess($"Borrow request submitted for \"{bookTitle}\". Please wait for librarian approval.");
                LoadAvailableBooks();
            }
            catch (Exception ex) { ShowError("Error submitting request: " + ex.Message); }
        }

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
            { ShowPasswordError("New password must be different from the current password."); KeepModalOpen(); return; }

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