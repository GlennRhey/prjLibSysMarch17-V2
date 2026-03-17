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
                switch (Session["Role"].ToString())
                {
                    case "Super Admin": Response.Redirect("SuperAdminDashboard.aspx"); break;
                    case "Admin": Response.Redirect("AdminDashboard.aspx"); break;
                    default: Response.Redirect("MemberDashboard.aspx"); break;
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string userId = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();
            string roleBtn = Request.Form["hfSelectedRole"] ?? "Member";

            if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(password))
            { ShowError("Please enter both User ID and password."); return; }

            try
            {
                User user = DatabaseHelper.AuthenticateUser(userId, password);

                if (user == null)
                { ShowError("Invalid User ID or password, or account is inactive."); return; }

                if (roleBtn == "Member" && (user.Role == "Admin" || user.Role == "Super Admin"))
                { ShowError("Wrong role selected. This account is registered as 'Admin'."); return; }

                if (roleBtn == "Admin" && user.Role == "Member")
                { ShowError("Wrong role selected. This account is registered as 'Member'."); return; }

                Session["UserID"] = user.UserID;
                Session["Role"] = user.Role;
                Session["Email"] = user.Email;
                Session["LoginTime"] = DateTime.Now;

                switch (user.Role)
                {
                    case "Super Admin":
                        Session["FullName"] = user.FullName;
                        Response.Redirect("SuperAdminDashboard.aspx");
                        break;

                    case "Admin":
                        Session["FullName"] = user.FullName;
                        Response.Redirect("AdminDashboard.aspx");
                        break;

                    default:
                        DataTable dt = DatabaseHelper.ExecuteQuery(
                            "SELECT MemberID, FullName, MemberType FROM tblMembers WHERE UserID = @UserID",
                            new SqlParameter[] { new SqlParameter("@UserID", userId) });

                        if (dt.Rows.Count > 0)
                        {
                            Session["MemberID"] = dt.Rows[0]["MemberID"].ToString();
                            Session["FullName"] = dt.Rows[0]["FullName"].ToString();
                            Session["MemberType"] = dt.Rows[0]["MemberType"].ToString();
                        }
                        else
                        {
                            Session["MemberID"] = "";
                            Session["FullName"] = userId;
                            Session["MemberType"] = "Student";
                        }
                        Response.Redirect("MemberDashboard.aspx");
                        break;
                }
            }
            catch (Exception ex) { ShowError("Login failed: " + ex.Message); }
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            divError.Visible = true;
        }
    }
}