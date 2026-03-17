using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class Loans : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadMembersDropdown();
                LoadAvailableBooksDropdown();
                txtLoanDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txtDueDate.Text = DateTime.Now.AddDays(14).ToString("yyyy-MM-dd");
                txtReturnDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadTransactions();
            }
            // For postbacks, LoadTransactions is called by specific event handlers
        }

        // ── Load transaction grid ─────────────────────────────────────────────

        private void LoadTransactions()
        {
            try
            {
                string query = @"
                    SELECT
                        t.BorrowID,
                        b.Title                                        AS BookTitle,
                        t.MemberID                                     AS StudentID,
                        mem.FullName                                   AS StudentName,
                        t.ISBN,
                        t.RequestType,
                        t.RequestStatus,
                        t.BorrowDate,
                        t.DueDate,
                        t.ReturnDate,
                        t.Status,
                        CASE WHEN t.Status = 'Returned' THEN 1 ELSE 0 END AS IsReturned,
                        -- Display status: what the student sees
                        CASE
                            WHEN t.RequestStatus = 'Pending'  THEN 'Pending Approval'
                            WHEN t.RequestStatus = 'Rejected' THEN 'Cancelled'
                            WHEN t.Status = 'Active'          THEN 'Active'
                            WHEN t.Status = 'Returned'        THEN 'Returned'
                            WHEN t.Status = 'Overdue'         THEN 'Overdue'
                            ELSE t.Status
                        END AS DisplayStatus
                    FROM  tblTransactions t
                    INNER JOIN tblBooks   b   ON b.ISBN       = t.ISBN
                    INNER JOIN tblMembers mem ON mem.MemberID = t.MemberID
                    WHERE 1 = 1";

                var parameters = new System.Collections.Generic.List<SqlParameter>();

                if (!string.IsNullOrWhiteSpace(txtSearchLoan.Text))
                {
                    string searchTerm = txtSearchLoan.Text.Trim();
                    query += @" AND (b.Title LIKE @Search 
                                  OR mem.FullName LIKE @Search 
                                  OR t.BorrowID LIKE @Search)";
                    parameters.Add(new SqlParameter("@Search", "%" + searchTerm + "%"));
                }

                if (!string.IsNullOrEmpty(ddlLoanStatus.SelectedValue))
                {
                    switch (ddlLoanStatus.SelectedValue)
                    {
                        case "Active":
                            query += " AND t.Status = 'Active' AND t.RequestStatus = 'Accepted'";
                            break;
                        case "Returned":
                            query += " AND t.Status = 'Returned'";
                            break;
                        case "Overdue":
                            query += " AND t.Status = 'Overdue'";
                            break;
                        case "Pending":
                            query += " AND t.RequestStatus = 'Pending'";
                            break;
                        case "Cancelled":
                            query += " AND t.RequestStatus = 'Rejected'";
                            break;
                    }
                }

                if (!string.IsNullOrEmpty(ddlDateRange.SelectedValue))
                {
                    switch (ddlDateRange.SelectedValue)
                    {
                        case "Today":
                            query += " AND CAST(t.BorrowDate AS DATE) = CAST(GETDATE() AS DATE)";
                            break;
                        case "ThisWeek":
                            query += " AND t.BorrowDate >= DATEADD(DAY, -7, GETDATE())";
                            break;
                        case "ThisMonth":
                            query += " AND MONTH(t.BorrowDate) = MONTH(GETDATE()) AND YEAR(t.BorrowDate) = YEAR(GETDATE())";
                            break;
                        case "ThisYear":
                            query += " AND YEAR(t.BorrowDate) = YEAR(GETDATE())";
                            break;
                    }
                }

                query += " ORDER BY t.BorrowDate DESC";

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters.ToArray());
                gvLoans.DataSource = dt;
                gvLoans.DataBind();
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading transactions: " + ex.Message);
                gvLoans.DataSource = null;
                gvLoans.DataBind();
            }
        }

        // ── Dropdown loaders ──────────────────────────────────────────────────

        private void LoadMembersDropdown()
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT MemberID, FullName FROM tblMembers ORDER BY FullName",
                    null);
                ddlMember.DataSource = dt;
                ddlMember.DataTextField = "FullName";
                ddlMember.DataValueField = "MemberID";
                ddlMember.DataBind();
                ddlMember.Items.Insert(0, new ListItem("-- Select Member --", ""));
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading members: " + ex.Message);
            }
        }

        private void LoadAvailableBooksDropdown()
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT ISBN, Title FROM tblBooks WHERE AvailableCopies > 0 ORDER BY Title",
                    null);
                ddlBook.DataSource = dt;
                ddlBook.DataTextField = "Title";
                ddlBook.DataValueField = "ISBN";
                ddlBook.DataBind();
                ddlBook.Items.Insert(0, new ListItem("-- Select Book --", ""));
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading books: " + ex.Message);
            }
        }

        // ── Search / filter / paging events ──────────────────────────────────

        protected void btnSearchLoan_Click(object sender, EventArgs e)
        {
            try
            {
                LoadTransactions();
            }
            catch (Exception ex)
            {
                ShowAlert("Search error: " + ex.Message);
            }
        }

        protected void ddlLoanStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTransactions();
        }

        protected void ddlDateRange_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTransactions();
        }

        protected void gvLoans_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLoans.PageIndex = e.NewPageIndex;
            LoadTransactions();
        }

        // ── GridView row commands ─────────────────────────────────────────────

        protected void gvLoans_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Ignore built-in GridView commands (Page, Sort etc.)
            if (e.CommandName == "Page" || e.CommandName == "Sort") return;
            if (string.IsNullOrEmpty(e.CommandArgument != null ? e.CommandArgument.ToString() : "")) return;

            int borrowId;
            if (!int.TryParse(e.CommandArgument.ToString(), out borrowId)) return;

            switch (e.CommandName)
            {
                case "AcceptRequest": AcceptRequest(borrowId); break;
                case "RejectRequest": RejectRequest(borrowId); break;
                case "RenewLoan": RenewLoan(borrowId); break;
                case "ReturnBook": ShowReturnModal(borrowId); break;
                case "ViewDetails": ShowDetailsModal(borrowId); break;
            }
        }

        // ── Accept ────────────────────────────────────────────────────────────

        private void AcceptRequest(int borrowId)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT RequestType, RequestStatus, ISBN
                    FROM   tblTransactions
                    WHERE  BorrowID = @BorrowID",
                    new SqlParameter[] { new SqlParameter("@BorrowID", borrowId) });

                if (dt.Rows.Count == 0) { ShowAlert("Transaction not found."); return; }

                string requestType = dt.Rows[0]["RequestType"].ToString();
                string requestStatus = dt.Rows[0]["RequestStatus"].ToString();
                string isbn = dt.Rows[0]["ISBN"].ToString();

                if (requestStatus != "Pending")
                {
                    ShowAlert("This request has already been processed.");
                    LoadTransactions();
                    return;
                }

                string adminId = Session["UserID"] != null ? Session["UserID"].ToString() : "";

                if (requestType == "Borrow")
                {
                    int copies = Convert.ToInt32(DatabaseHelper.ExecuteScalar(
                        "SELECT AvailableCopies FROM tblBooks WHERE ISBN = @ISBN",
                        new SqlParameter[] { new SqlParameter("@ISBN", isbn) }));

                    if (copies <= 0)
                    {
                        ShowAlert("Cannot accept: no copies of this book are currently available.");
                        return;
                    }

                    // Accept borrow — Status stays 'Active', RequestStatus = 'Accepted'
                    DatabaseHelper.ExecuteNonQuery(@"
                        UPDATE tblTransactions
                        SET    RequestStatus = 'Accepted',
                               Status       = 'Active',
                               AdminID      = @AdminID
                        WHERE  BorrowID = @BorrowID",
                        new SqlParameter[]
                        {
                            new SqlParameter("@AdminID",  string.IsNullOrEmpty(adminId) ? (object)DBNull.Value : adminId),
                            new SqlParameter("@BorrowID", borrowId)
                        });

                    DatabaseHelper.ExecuteNonQuery(
                        "UPDATE tblBooks SET AvailableCopies = AvailableCopies - 1 WHERE ISBN = @ISBN",
                        new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                    // Send borrow confirmation notification
                    try
                    {
                        // Get member details for notification
                        DataTable memberDt = DatabaseHelper.ExecuteQuery(@"
                            SELECT u.Email, m.FullName, b.Title, t.DueDate
                            FROM tblTransactions t
                            INNER JOIN tblMembers m ON t.MemberID = m.MemberID
                            INNER JOIN tblUsers u ON m.UserID = u.UserID
                            INNER JOIN tblBooks b ON t.ISBN = b.ISBN
                            WHERE t.BorrowID = @BorrowID",
                            new SqlParameter[] { new SqlParameter("@BorrowID", borrowId) });

                        if (memberDt.Rows.Count > 0)
                        {
                            DataRow row = memberDt.Rows[0];
                            DatabaseHelper.SendBorrowConfirmation(
                                row["Email"].ToString(),
                                row["FullName"].ToString(),
                                row["Title"].ToString(),
                                Convert.ToDateTime(row["DueDate"])
                            );
                        }
                    }
                    catch
                    {
                        // Notification error shouldn't break the main functionality
                    }

                    ShowAlert("Borrow request accepted. Book has been issued.");
                }
                else if (requestType == "Return")
                {
                    // Accept return — Status = 'Returned', increment copies
                    DatabaseHelper.ExecuteNonQuery(@"
                        UPDATE tblTransactions
                        SET    RequestStatus = 'Accepted',
                               Status       = 'Returned',
                               ReturnDate   = GETDATE(),
                               AdminID      = @AdminID
                        WHERE  BorrowID = @BorrowID",
                        new SqlParameter[]
                        {
                            new SqlParameter("@AdminID",  string.IsNullOrEmpty(adminId) ? (object)DBNull.Value : adminId),
                            new SqlParameter("@BorrowID", borrowId)
                        });

                    DatabaseHelper.ExecuteNonQuery(
                        "UPDATE tblBooks SET AvailableCopies = AvailableCopies + 1 WHERE ISBN = @ISBN",
                        new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                    ShowAlert("Return request accepted. Book returned to inventory.");
                }

                LoadTransactions();
            }
            catch (Exception ex)
            {
                ShowAlert("Error accepting request: " + ex.Message);
            }
        }

        // ── Reject ────────────────────────────────────────────────────────────

        private void RejectRequest(int borrowId)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT RequestStatus FROM tblTransactions WHERE BorrowID = @BorrowID",
                    new SqlParameter[] { new SqlParameter("@BorrowID", borrowId) });

                if (dt.Rows.Count == 0) { ShowAlert("Transaction not found."); return; }

                if (dt.Rows[0]["RequestStatus"].ToString() != "Pending")
                {
                    ShowAlert("This request has already been processed.");
                    LoadTransactions();
                    return;
                }

                string adminId = Session["UserID"] != null ? Session["UserID"].ToString() : "";

                // Reject — Status = 'Cancelled', RequestStatus = 'Rejected'
                DatabaseHelper.ExecuteNonQuery(@"
                    UPDATE tblTransactions
                    SET    RequestStatus = 'Rejected',
                           Status       = 'Cancelled',
                           AdminID      = @AdminID
                    WHERE  BorrowID = @BorrowID",
                    new SqlParameter[]
                    {
                        new SqlParameter("@AdminID",  string.IsNullOrEmpty(adminId) ? (object)DBNull.Value : adminId),
                        new SqlParameter("@BorrowID", borrowId)
                    });

                ShowAlert("Request rejected.");
                LoadTransactions();
            }
            catch (Exception ex)
            {
                ShowAlert("Error rejecting request: " + ex.Message);
            }
        }

        // ── Renew ─────────────────────────────────────────────────────────────

        private void RenewLoan(int borrowId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery(
                    "UPDATE tblTransactions SET DueDate = DATEADD(DAY, 14, DueDate) WHERE BorrowID = @BorrowID",
                    new SqlParameter[] { new SqlParameter("@BorrowID", borrowId) });

                ShowAlert("Loan renewed. Due date extended by 14 days.");
                LoadTransactions();
            }
            catch (Exception ex)
            {
                ShowAlert("Error renewing loan: " + ex.Message);
            }
        }

        // ── Admin creates loan directly ───────────────────────────────────────

        protected void btnSaveLoan_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlMember.SelectedValue) || string.IsNullOrEmpty(ddlBook.SelectedValue))
            {
                ShowAlert("Please select both a member and a book.");
                return;
            }

            try
            {
                string isbn = ddlBook.SelectedValue;
                int memberId = Convert.ToInt32(ddlMember.SelectedValue);
                string adminId = Session["UserID"] != null ? Session["UserID"].ToString() : "";

                DateTime borrowDate = DateTime.Parse(txtLoanDate.Text);
                DateTime dueDate = DateTime.Parse(txtDueDate.Text);

                DataTable bookDt = DatabaseHelper.ExecuteQuery(
                    "SELECT Title, AvailableCopies FROM tblBooks WHERE ISBN = @ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                if (bookDt.Rows.Count == 0) { ShowAlert("Book not found."); return; }

                int copies = Convert.ToInt32(bookDt.Rows[0]["AvailableCopies"]);
                if (copies <= 0) { ShowAlert("No available copies for this book."); return; }

                // Admin-created loans are immediately Active + Accepted
                DatabaseHelper.ExecuteNonQuery(@"
                    INSERT INTO tblTransactions
                        (MemberID, ISBN, AdminID, RequestType, RequestStatus,
                         BorrowDate, DueDate, Status)
                    VALUES
                        (@MemberID, @ISBN, @AdminID, 'Borrow', 'Accepted',
                         @BorrowDate, @DueDate, 'Active')",
                    new SqlParameter[]
                    {
                        new SqlParameter("@MemberID",   memberId),
                        new SqlParameter("@ISBN",       isbn),
                        new SqlParameter("@AdminID",    string.IsNullOrEmpty(adminId) ? (object)DBNull.Value : adminId),
                        new SqlParameter("@BorrowDate", borrowDate),
                        new SqlParameter("@DueDate",    dueDate)
                    });

                DatabaseHelper.ExecuteNonQuery(
                    "UPDATE tblBooks SET AvailableCopies = AvailableCopies - 1 WHERE ISBN = @ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                LoadTransactions();
                ScriptManager.RegisterStartupScript(this, GetType(), "hideModal", "hideLoanModal();", true);
                ShowAlert("Loan created successfully.");
            }
            catch (Exception ex)
            {
                ShowAlert("Error creating loan: " + ex.Message);
            }
        }

        // ── Return modal ──────────────────────────────────────────────────────

        private void ShowReturnModal(int borrowId)
        {
            hfLoanId.Value = borrowId.ToString();
            txtReturnDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtReturnNotes.Text = "";
            ScriptManager.RegisterStartupScript(this, GetType(), "showReturn", "showReturnModal();", true);
        }

        protected void btnProcessReturn_Click(object sender, EventArgs e)
        {
            try
            {
                int borrowId = Convert.ToInt32(hfLoanId.Value);
                DateTime returnDate = DateTime.Parse(txtReturnDate.Text);
                string adminId = Session["UserID"] != null ? Session["UserID"].ToString() : "";

                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT ISBN FROM tblTransactions WHERE BorrowID = @BorrowID",
                    new SqlParameter[] { new SqlParameter("@BorrowID", borrowId) });

                if (dt.Rows.Count == 0) { ShowAlert("Transaction not found."); return; }

                string isbn = dt.Rows[0]["ISBN"].ToString();

                DatabaseHelper.ExecuteNonQuery(@"
                    UPDATE tblTransactions
                    SET    ReturnDate     = @ReturnDate,
                           Status        = 'Returned',
                           RequestType   = 'Return',
                           RequestStatus = 'Accepted',
                           AdminID       = @AdminID
                    WHERE  BorrowID = @BorrowID",
                    new SqlParameter[]
                    {
                        new SqlParameter("@ReturnDate", returnDate),
                        new SqlParameter("@AdminID",    string.IsNullOrEmpty(adminId) ? (object)DBNull.Value : adminId),
                        new SqlParameter("@BorrowID",   borrowId)
                    });

                DatabaseHelper.ExecuteNonQuery(
                    "UPDATE tblBooks SET AvailableCopies = AvailableCopies + 1 WHERE ISBN = @ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                LoadTransactions();
                ScriptManager.RegisterStartupScript(this, GetType(), "hideReturn", "hideReturnModal();", true);
                ShowAlert("Book returned successfully.");
            }
            catch (Exception ex)
            {
                ShowAlert("Error processing return: " + ex.Message);
            }
        }

        // ── View Details ──────────────────────────────────────────────────────

        private void ShowDetailsModal(int borrowId)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(@"
                    SELECT
                        t.BorrowID,
                        b.Title      AS BookTitle,
                        b.ISBN,
                        b.Author,
                        mem.UserID   AS StudentID,
                        mem.FullName AS StudentName,
                        mem.Course,
                        mem.YearLevel,
                        t.RequestType,
                        t.RequestStatus,
                        t.Status,
                        t.BorrowDate,
                        t.DueDate,
                        t.ReturnDate,
                        t.AdminID,
                        u.FullName   AS AdminName,
                        u.Email      AS AdminEmail
                    FROM  tblTransactions t
                    INNER JOIN tblBooks   b   ON b.ISBN       = t.ISBN
                    INNER JOIN tblMembers mem ON mem.MemberID = t.MemberID
                    LEFT  JOIN tblUsers   u   ON u.UserID     = t.AdminID
                    WHERE t.BorrowID = @BorrowID",
                    new SqlParameter[] { new SqlParameter("@BorrowID", borrowId) });

                if (dt.Rows.Count == 0) { ShowAlert("Transaction not found."); return; }

                DataRow r = dt.Rows[0];
                string course = (r["Course"] != null ? r["Course"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : "") + " — Year " + r["YearLevel"].ToString();

                string script = string.Format(@"showDetailsModal({{
                    borrowID:      '{0}',
                    bookTitle:     '{1}',
                    isbn:          '{2}',
                    author:        '{3}',
                    studentID:     '{4}',
                    studentName:   '{5}',
                    course:        '{6}',
                    requestType:   '{7}',
                    requestStatus: '{8}',
                    status:        '{9}',
                    borrowDate:    '{10}',
                    dueDate:       '{11}',
                    returnDate:    '{12}',
                    adminID:       '{13}',
                    adminName:     '{14}',
                    adminEmail:    '{15}'
                }});",
                    r["BorrowID"],
                    (r["BookTitle"] != null ? r["BookTitle"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : ""),
                    (r["ISBN"] != null ? r["ISBN"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : ""),
                    (r["Author"] != null ? r["Author"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : ""),
                    r["StudentID"],
                    (r["StudentName"] != null ? r["StudentName"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : ""),
                    course,
                    (r["RequestType"] != null ? r["RequestType"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : ""),
                    (r["RequestStatus"] != null ? r["RequestStatus"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : ""),
                    (r["Status"] != null ? r["Status"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : ""),
                    r["BorrowDate"] != DBNull.Value ? Convert.ToDateTime(r["BorrowDate"]).ToString("MM/dd/yyyy") : "",
                    r["DueDate"] != DBNull.Value ? Convert.ToDateTime(r["DueDate"]).ToString("MM/dd/yyyy") : "",
                    r["ReturnDate"] != DBNull.Value ? Convert.ToDateTime(r["ReturnDate"]).ToString("MM/dd/yyyy") : "",
                    (r["AdminID"] != null ? r["AdminID"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : ""),
                    (r["AdminName"] != null ? r["AdminName"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : ""),
                    (r["AdminEmail"] != null ? r["AdminEmail"].ToString().Replace("'", "\\'").Replace("\r\n", " ").Replace("\n", " ") : "")
                );

                ScriptManager.RegisterStartupScript(this, GetType(), "showDetails", script, true);
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading details: " + ex.Message);
            }
        }

        // ── Helper ────────────────────────────────────────────────────────────

        private static int _alertCounter = 0;
        private void ShowAlert(string message)
        {
            string safe = message.Replace("'", "\\'").Replace("\n", "\\n");
            string key = "alert_" + System.Threading.Interlocked.Increment(ref _alertCounter).ToString();
            ScriptManager.RegisterStartupScript(this, GetType(), key,
                "alert('" + safe + "');", true);
        }
    }
}