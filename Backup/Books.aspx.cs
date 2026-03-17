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
            if (!IsPostBack)
                LoadBooks();
        }

        private void LoadBooks()
        {
            try
            {
                string currentSearch = SearchTerm;
                string query = "SELECT ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description FROM tblBooks WHERE 1=1";
                var parameters = new List<SqlParameter>();

                if (!string.IsNullOrEmpty(currentSearch))
                {
                    query += " AND (Title LIKE @Search OR Author LIKE @Search OR ISBN LIKE @Search OR Description LIKE @Search)";
                    parameters.Add(new SqlParameter("@Search", "%" + currentSearch + "%"));
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
                txtSearch.Text = currentSearch;
            }
            catch (Exception ex)
            {
                gvBooks.DataSource = null;
                gvBooks.DataBind();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                    $"alert('Error loading books: {ex.Message}');", true);
            }
        }

        protected void btnAddBook_Click(object sender, EventArgs e)
        {
            ClearBookForm();
            lblModalTitle.Text = "Add New Book";
            hfBookId.Value = "";
            ClientScript.RegisterStartupScript(this.GetType(), "showModal", "showBookModal();", true);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            SearchTerm = txtSearch.Text.Trim();
            gvBooks.PageIndex = 0;
            LoadBooks();
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            gvBooks.PageIndex = 0;
            LoadBooks();
        }

        protected void ddlAvailability_SelectedIndexChanged(object sender, EventArgs e)
        {
            gvBooks.PageIndex = 0;
            LoadBooks();
        }

        protected void gvBooks_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvBooks.PageIndex = e.NewPageIndex;
            LoadBooks();
        }

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
                    "SELECT ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description FROM tblBooks WHERE ISBN = @ISBN",
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
                    ClientScript.RegisterStartupScript(this.GetType(), "showModal", "<script>showBookModal();</script>");
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    $"alert('Error loading book: {ex.Message}');", true);
            }
        }

        private void DeleteBook(string isbn)
        {
            try
            {
                DataTable checkDt = DatabaseHelper.ExecuteQuery(
                    "SELECT COUNT(*) FROM tblTransactions WHERE ISBN = @ISBN AND Status = 'Borrowed'",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                if (Convert.ToInt32(checkDt.Rows[0][0]) > 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                        "alert('Cannot delete a book that is currently borrowed.');", true);
                    return;
                }

                DatabaseHelper.ExecuteQuery("DELETE FROM tblBooks WHERE ISBN = @ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                LoadBooks();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "success",
                    "alert('Book deleted successfully.');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    $"alert('Error deleting book: {ex.Message}');", true);
            }
        }

        private void ViewBookDetails(string isbn)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description FROM tblBooks WHERE ISBN = @ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    string Esc(string f) => row[f].ToString().Replace("'", "\\'");

                    string script = $@"
                        document.getElementById('viewISBN').innerText            = '{Esc("ISBN")}';
                        document.getElementById('viewTitle').innerText           = '{Esc("Title")}';
                        document.getElementById('viewAuthor').innerText          = '{Esc("Author")}';
                        document.getElementById('viewCategory').innerText        = '{Esc("Category")}';
                        document.getElementById('viewTotalCopies').innerText     = '{row["TotalCopies"]}';
                        document.getElementById('viewAvailableCopies').innerText = '{row["AvailableCopies"]}';
                        document.getElementById('viewDescription').innerText     = '{(row["Description"] ?? "").ToString().Replace("'", "\\'").Replace("\r\n", "\\n")}';
                        showViewBookModal();";

                    ClientScript.RegisterStartupScript(this.GetType(), "showViewModal", "<script>" + script + "</script>");
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
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
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "validation",
                        "alert('Please fill in all required fields.');", true);
                    return;
                }

                if (string.IsNullOrEmpty(hfBookId.Value))
                {
                    DatabaseHelper.ExecuteQuery(@"
                        INSERT INTO tblBooks (ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description)
                        VALUES (@ISBN, @Title, @Author, @Category, @TotalCopies, @AvailableCopies, @Description)",
                        new SqlParameter[]
                        {
                            new SqlParameter("@ISBN",            txtISBN.Text),
                            new SqlParameter("@Title",           txtTitle.Text),
                            new SqlParameter("@Author",          txtAuthor.Text),
                            new SqlParameter("@Category",        ddlBookCategory.SelectedValue),
                            new SqlParameter("@TotalCopies",     Convert.ToInt32(txtTotalCopies.Text)),
                            new SqlParameter("@AvailableCopies", Convert.ToInt32(txtAvailableCopies.Text)),
                            new SqlParameter("@Description",     txtDescription.Text)
                        });
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "success",
                        "alert('Book added successfully.');", true);
                }
                else
                {
                    DatabaseHelper.ExecuteQuery(@"
                        UPDATE tblBooks SET
                            Title = @Title, Author = @Author, Category = @Category,
                            TotalCopies = @TotalCopies, AvailableCopies = @AvailableCopies, Description = @Description
                        WHERE ISBN = @ISBN",
                        new SqlParameter[]
                        {
                            new SqlParameter("@ISBN",            hfBookId.Value),
                            new SqlParameter("@Title",           txtTitle.Text),
                            new SqlParameter("@Author",          txtAuthor.Text),
                            new SqlParameter("@Category",        ddlBookCategory.SelectedValue),
                            new SqlParameter("@TotalCopies",     Convert.ToInt32(txtTotalCopies.Text)),
                            new SqlParameter("@AvailableCopies", Convert.ToInt32(txtAvailableCopies.Text)),
                            new SqlParameter("@Description",     txtDescription.Text)
                        });
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "success",
                        "alert('Book updated successfully.');", true);
                }

                SearchTerm = "";
                LoadBooks();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "hideModal", "hideBookModal();", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    $"alert('Error saving book: {ex.Message}');", true);
            }
        }

        private void ClearBookForm()
        {
            txtISBN.Text = ""; txtISBN.Enabled = true;
            txtTitle.Text = ""; txtAuthor.Text = "";
            ddlBookCategory.SelectedIndex = 0;
            txtTotalCopies.Text = ""; txtAvailableCopies.Text = "";
            txtDescription.Text = "";
        }

        [WebMethod]
        public static BookData GetBookData(string isbn)
        {
            try
            {
                DataTable dt = DatabaseHelper.ExecuteQuery(
                    "SELECT ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description FROM tblBooks WHERE ISBN = @ISBN",
                    new SqlParameter[] { new SqlParameter("@ISBN", isbn) });

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    return new BookData
                    {
                        ISBN = row["ISBN"].ToString(),
                        Title = row["Title"].ToString(),
                        Author = row["Author"].ToString(),
                        Category = row["Category"].ToString(),
                        TotalCopies = Convert.ToInt32(row["TotalCopies"]),
                        AvailableCopies = Convert.ToInt32(row["AvailableCopies"]),
                        Description = row["Description"]?.ToString() ?? ""
                    };
                }
                return null;
            }
            catch { return null; }
        }
    }

    public class BookData
    {
        public string ISBN { get; set; }
        public string Title { get; set; }
        public string Author { get; set; }
        public string Category { get; set; }
        public int TotalCopies { get; set; }
        public int AvailableCopies { get; set; }
        public string Description { get; set; }
    }
}