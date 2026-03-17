using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] != null && Session["UserID"] != null)
            {
                Response.Redirect(Session["Role"].ToString() == "Admin"
                    ? "AdminDashboard.aspx" : "StudentDashboard.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // txtUsername on the form accepts UserID (e.g. EMP-001 or 2023-0001)
            string userId = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();
            string role = hfSelectedRole.Value;

            if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(password))
            {
                ShowError("Please enter both User ID and password.");
                return;
            }

            try
            {
                // Uses DatabaseHelper.AuthenticateUser which queries tblUsers
                User user = DatabaseHelper.AuthenticateUser(userId, password);

                if (user == null)
                {
                    ShowError("Invalid User ID or password, or account is inactive.");
                    return;
                }

                if (user.Role != role)
                {
                    ShowError($"Wrong role selected. This account is registered as '{user.Role}'.");
                    return;
                }

                Session["UserID"] = user.UserID;
                Session["Role"] = user.Role;      // dashboards check Session["Role"]
                Session["UserRole"] = user.Role;      // kept for any other pages still using UserRole
                Session["Email"] = user.Email;
                Session["LoginTime"] = DateTime.Now;

                if (user.Role == "Admin")
                {
                    // Admins store FullName in tblUsers
                    Session["FullName"] = user.FullName;
                    Response.Redirect("AdminDashboard.aspx");
                }
                else
                {
                    // Students store FullName and MemberID in tblMembers
                    DataTable memberDt = DatabaseHelper.ExecuteQuery(
                        "SELECT MemberID, FullName FROM tblMembers WHERE UserID = @UserID",
                        new SqlParameter[] { new SqlParameter("@UserID", userId) });

                    if (memberDt.Rows.Count > 0)
                    {
                        Session["MemberID"] = memberDt.Rows[0]["MemberID"].ToString();
                        Session["FullName"] = memberDt.Rows[0]["FullName"].ToString();
                    }
                    else
                    {
                        Session["MemberID"] = "";
                        Session["FullName"] = userId;
                    }

                    Response.Redirect("StudentDashboard.aspx");
                }
            }
            catch (Exception ex)
            {
                ShowError("Login failed: " + ex.Message);
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            divError.Visible = true;
        }
    }
}