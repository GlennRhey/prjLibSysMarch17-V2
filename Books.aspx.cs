using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class Books : System.Web.UI.Page
    {
        private string SearchTerm
        {
            get { return ViewState["SearchTerm"] as string ?? ""; }
            set { ViewState["SearchTerm"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null) { Response.Redirect("Login.aspx"); return; }

            string role = Session["Role"]?.ToString();
            if (role != "Admin" && role != "Super Admin")
            {
                Response.Redirect("MemberDashboard.aspx");
                return;
            }

            // Render the correct sidebar (red for Admin, blue for Super Admin)
            litSidebar.Text = SidebarHelper.GetSidebar(role, "books");

            if (!IsPostBack) LoadBooks();
        }

        private void LoadBooks()
        {
            try
            {
                string query = @"
                    SELECT ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description
                    FROM tblBooks WHERE 1=1";

                var parameters = new List<SqlParameter>();

                if (!string.IsNullOrEmpty(SearchTerm))
                {
                    query += " AND (Title LIKE @Search OR Author LIKE @Search OR ISBN LIKE @Search OR Description LIKE @Search)";
                    parameters.Add(new SqlParameter("@Search", "%" + SearchTerm + "%"));
                }
                if (!string.IsNullOrEmpty(ddlCategory.SelectedValue))
                {
                    query += " AND Category = @Category";
                    parameters.Add(new SqlParameter("@Category", ddlCategory.SelectedValue));
                }
                if (!string.IsNullOrEmpty(ddlAvailability.SelectedValue))
                {
                    if (ddlAvailability.SelectedValue == "Available")
                        query += " AND AvailableCopies > 0";
                    else if (ddlAvailability.SelectedValue == "Borrowed")
                        query += " AND AvailableCopies < TotalCopies";
                }

                query += " ORDER BY Title";
                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters.ToArray());
                gvBooks.DataSource = dt;
                gvBooks.DataBind();
                txtSearch.Text = SearchTerm;
            }
            catch (Exception ex)
            {
                gvBooks.DataSource = null;
                gvBooks.DataBind();
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    $"alert('Error loading books: {ex.Message}');", true);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { SearchTerm = txtSearch.Text.Trim(); gvBooks.PageIndex = 0; LoadBooks(); }
        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e) { gvBooks.PageIndex = 0; LoadBooks(); }
        protected void ddlAvailability_SelectedIndexChanged(object sender, EventArgs e) { gvBooks.PageIndex = 0; LoadBooks(); }
        protected void gvBooks_PageIndexChanging(object sender, GridViewPageEventArgs e) { gvBooks.PageIndex = e.NewPageIndex; LoadBooks(); }

        protected void gvBooks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string isbn = e.CommandArgument.ToString();
            switch (e.CommandName)
            {
                case "EditBook": LoadBookForEdit(isbn); break;
                case "DeleteBook": DeleteBook(isbn); break;
                case "ViewDetails": ViewBookDetails(isbn); break;
            }
        }

        private void LoadBookForEdit(string isbn)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT ISBN,Title,Author,Category,TotalCopies,AvailableCopies,Description FROM tblBooks WHERE ISBN=@ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    hfBookId.Value = row["ISBN"].ToString();
                    txtISBN.Text = row["ISBN"].ToString();
                    txtISBN.Enabled = false;
                    txtTitle.Text = row["Title"].ToString();
                    txtAuthor.Text = row["Author"].ToString();
                    ddlBookCategory.SelectedValue = row["Category"].ToString();
                    txtTotalCopies.Text = row["TotalCopies"].ToString();
                    txtAvailableCopies.Text = row["AvailableCopies"].ToString();
                    txtDescription.Text = row["Description"]?.ToString() ?? "";
                    lblModalTitle.Text = "Edit Book";
                    ClientScript.RegisterStartupScript(GetType(), "showModal", "<script>showBookModal();</script>");
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                    $"alert('Error loading book: {ex.Message}');", true);
            }
        }

        private void DeleteBook(string isbn)
        {
            try
            {
                int active = Convert.ToInt32(DatabaseHelper.ExecuteScalar(
                    "SELECT COUNT(*) FROM tblTransactions WHERE ISBN=@ISBN AND Status='Active'",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) }));

                if (active > 0)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                        "alert('Cannot delete a book that is currently borrowed.');", true);
                    return;
                }

                DatabaseHelper.ExecuteNonQuery("DELETE FROM tblBooks WHERE ISBN=@ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });
                DatabaseHelper.WriteAuditLog(Session["UserID"]?.ToString(), Session["FullName"]?.ToString(),
                    "DELETE_BOOK", "tblBooks", isbn);

                LoadBooks();
                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                    "alert('Book deleted successfully.');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                    $"alert('Error deleting book: {ex.Message}');", true);
            }
        }

        private void ViewBookDetails(string isbn)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT ISBN,Title,Author,Category,TotalCopies,AvailableCopies,Description FROM tblBooks WHERE ISBN=@ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    string Esc(string f) => row[f].ToString().Replace("'", "\\'");
                    string script = $@"
                        document.getElementById('viewISBN').innerText='{Esc("ISBN")}';
                        document.getElementById('viewTitle').innerText='{Esc("Title")}';
                        document.getElementById('viewAuthor').innerText='{Esc("Author")}';
                        document.getElementById('viewCategory').innerText='{Esc("Category")}';
                        document.getElementById('viewTotalCopies').innerText='{row["TotalCopies"]}';
                        document.getElementById('viewAvailableCopies').innerText='{row["AvailableCopies"]}';
                        document.getElementById('viewDescription').innerText='{(row["Description"] ?? "").ToString().Replace("'", "\\'").Replace("\r\n", "\\n")}';
                        showViewBookModal();";
                    ClientScript.RegisterStartupScript(GetType(), "showViewModal", "<script>" + script + "</script>");
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                    $"alert('Error loading book details: {ex.Message}');", true);
            }
        }

        protected void btnSaveBook_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrEmpty(txtISBN.Text) || string.IsNullOrEmpty(txtTitle.Text) ||
                    string.IsNullOrEmpty(txtAuthor.Text) || string.IsNullOrEmpty(ddlBookCategory.SelectedValue) ||
                    string.IsNullOrEmpty(txtTotalCopies.Text) || string.IsNullOrEmpty(txtAvailableCopies.Text))
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "validation",
                        "alert('Please fill in all required fields.');", true);
                    return;
                }

                SqlParameter[] bookParams = {
                    new SqlParameter("@ISBN",            txtISBN.Text),
                    new SqlParameter("@Title",           txtTitle.Text),
                    new SqlParameter("@Author",          txtAuthor.Text),
                    new SqlParameter("@Category",        ddlBookCategory.SelectedValue),
                    new SqlParameter("@TotalCopies",     Convert.ToInt32(txtTotalCopies.Text)),
                    new SqlParameter("@AvailableCopies", Convert.ToInt32(txtAvailableCopies.Text)),
                    new SqlParameter("@Description",     txtDescription.Text)
                };

                string adminId = Session["UserID"]?.ToString() ?? "";
                string adminName = Session["FullName"]?.ToString() ?? "";

                if (string.IsNullOrEmpty(hfBookId.Value))
                {
                    DatabaseHelper.ExecuteNonQuery(@"
                        INSERT INTO tblBooks (ISBN,Title,Author,Category,TotalCopies,AvailableCopies,Description)
                        VALUES (@ISBN,@Title,@Author,@Category,@TotalCopies,@AvailableCopies,@Description)",
                        bookParams);
                    DatabaseHelper.WriteAuditLog(adminId, adminName, "ADD_BOOK", "tblBooks", txtISBN.Text);
                    ScriptManager.RegisterStartupScript(this, GetType(), "success", "alert('Book added successfully.');", true);
                }
                else
                {
                    DatabaseHelper.ExecuteNonQuery(@"
                        UPDATE tblBooks SET Title=@Title,Author=@Author,Category=@Category,
                            TotalCopies=@TotalCopies,AvailableCopies=@AvailableCopies,Description=@Description
                        WHERE ISBN=@ISBN", bookParams);
                    DatabaseHelper.WriteAuditLog(adminId, adminName, "EDIT_BOOK", "tblBooks", hfBookId.Value);
                    ScriptManager.RegisterStartupScript(this, GetType(), "success", "alert('Book updated successfully.');", true);
                }

                SearchTerm = "";
                LoadBooks();
                ScriptManager.RegisterStartupScript(this, GetType(), "hideModal", "hideBookModal();", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                    $"alert('Error saving book: {ex.Message}');", true);
            }
        }

        [WebMethod]
        public static object GetBorrowSettings()
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT MemberType,SettingKey,SettingValue FROM tblSystemSettings", new SqlParameter[0]);
                int stuMax = 3, stuDays = 7, tchMax = 10, tchDays = 30;
                foreach (DataRow row in dt.Rows)
                {
                    string mt = row["MemberType"].ToString(), key = row["SettingKey"].ToString();
                    int val = Convert.ToInt32(row["SettingValue"]);
                    if (mt == "Student") { if (key == "MaxBorrowedBooks") stuMax = val; if (key == "BorrowDuration") stuDays = val; }
                    if (mt == "Teacher") { if (key == "MaxBorrowedBooks") tchMax = val; if (key == "BorrowDuration") tchDays = val; }
                }
                return new { StudentMaxBooks = stuMax, StudentBorrowDays = stuDays, TeacherMaxBooks = tchMax, TeacherBorrowDays = tchDays };
            }
            catch { return null; }
        }

        [WebMethod]
        public static string SaveBorrowSettings(int studentMaxBooks, int studentBorrowDays,
                                                 int teacherMaxBooks, int teacherBorrowDays)
        {
            try
            {
                if (studentMaxBooks < 1 || studentBorrowDays < 1 || teacherMaxBooks < 1 || teacherBorrowDays < 1)
                    return "All values must be positive numbers.";

                DataTable oldDt = DatabaseHelper.ExecuteQuery(
                    "SELECT MemberType,SettingKey,SettingValue FROM tblSystemSettings", new SqlParameter[0]);
                string oldValues = "";
                foreach (DataRow r in oldDt.Rows)
                    oldValues += $"{r["MemberType"]}.{r["SettingKey"]}={r["SettingValue"]}; ";
                string newValues =
                    $"Student.MaxBorrowedBooks={studentMaxBooks};Student.BorrowDuration={studentBorrowDays};" +
                    $"Teacher.MaxBorrowedBooks={teacherMaxBooks};Teacher.BorrowDuration={teacherBorrowDays};";

                ExecUpdateSetting("Student", "MaxBorrowedBooks", studentMaxBooks);
                ExecUpdateSetting("Student", "BorrowDuration", studentBorrowDays);
                ExecUpdateSetting("Teacher", "MaxBorrowedBooks", teacherMaxBooks);
                ExecUpdateSetting("Teacher", "BorrowDuration", teacherBorrowDays);

                DatabaseHelper.WriteAuditLog("System", "Admin", "EDIT_BORROW_SETTINGS", "tblSystemSettings",
                    null, oldValues.TrimEnd(), newValues.TrimEnd());
                return "OK";
            }
            catch (Exception ex) { return "Error: " + ex.Message; }
        }

        private static void ExecUpdateSetting(string memberType, string settingKey, int value)
        {
            DatabaseHelper.ExecuteNonQuery(@"
                UPDATE tblSystemSettings SET SettingValue=@Value,LastUpdatedAt=GETDATE()
                WHERE MemberType=@MemberType AND SettingKey=@SettingKey",
                new SqlParameter[]
                {
                    new SqlParameter("@Value",      value),
                    new SqlParameter("@MemberType", memberType),
                    new SqlParameter("@SettingKey", settingKey)
                });
        }

        [WebMethod]
        public static object GetBookData(string isbn)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT ISBN,Title,Author,Category,TotalCopies,AvailableCopies,Description FROM tblBooks WHERE ISBN=@ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });
                if (dt.Rows.Count == 0) return null;
                DataRow r = dt.Rows[0];
                return new
                {
                    ISBN = r["ISBN"].ToString(),
                    Title = r["Title"].ToString(),
                    Author = r["Author"].ToString(),
                    Category = r["Category"].ToString(),
                    TotalCopies = Convert.ToInt32(r["TotalCopies"]),
                    AvailableCopies = Convert.ToInt32(r["AvailableCopies"]),
                    Description = r["Description"]?.ToString() ?? ""
                };
            }
            catch { return null; }
        }

        private void ClearBookForm()
        {
            txtISBN.Text = ""; txtISBN.Enabled = true; txtTitle.Text = ""; txtAuthor.Text = "";
            ddlBookCategory.SelectedIndex = 0; txtTotalCopies.Text = ""; txtAvailableCopies.Text = ""; txtDescription.Text = "";
        }
    }
}