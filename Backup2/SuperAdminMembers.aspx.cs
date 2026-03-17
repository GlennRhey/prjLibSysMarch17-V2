using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class SuperAdminMembers : System.Web.UI.Page
    {
        private string SearchTerm
        {
            get { return ViewState["SAMSearch"] as string ?? ""; }
            set { ViewState["SAMSearch"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null) { Response.Redirect("Login.aspx"); return; }
            if (Session["Role"]?.ToString() != "Super Admin") { Response.Redirect("AdminDashboard.aspx"); return; }

            // Render blue SA sidebar with Members active
            litSidebar.Text = SidebarHelper.GetSidebar("Super Admin", "members");

            if (!IsPostBack) LoadAdmins();
        }

        private void LoadAdmins()
        {
            try
            {
                string query = @"
                    SELECT u.UserID, u.FullName, u.Email,
                           u.CreatedAt AS RegistrationDate,
                           CASE WHEN u.IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS Status
                    FROM tblUsers u
                    WHERE u.Role = 'Admin'";

                var parameters = new List<SqlParameter>();

                if (!string.IsNullOrEmpty(SearchTerm))
                {
                    query += " AND (u.FullName LIKE @Search OR u.Email LIKE @Search OR u.UserID LIKE @Search)";
                    parameters.Add(new SqlParameter("@Search", "%" + SearchTerm + "%"));
                }
                if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
                {
                    query += " AND (CASE WHEN u.IsActive = 1 THEN 'Active' ELSE 'Inactive' END) = @Status";
                    parameters.Add(new SqlParameter("@Status", ddlStatus.SelectedValue));
                }

                query += " ORDER BY u.UserID ASC";

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters.ToArray());
                gvAdmins.DataSource = dt;
                gvAdmins.DataBind();
                txtSearch.Text = SearchTerm;
            }
            catch (Exception ex)
            {
                gvAdmins.DataSource = null;
                gvAdmins.DataBind();
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    $"alert('Error loading admins: {ex.Message}');", true);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            SearchTerm = txtSearch.Text.Trim();
            gvAdmins.PageIndex = 0;
            LoadAdmins();
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e) { gvAdmins.PageIndex = 0; LoadAdmins(); }

        protected void gvAdmins_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvAdmins.PageIndex = e.NewPageIndex;
            LoadAdmins();
        }

        protected void btnSaveAdmin_Click(object sender, EventArgs e)
        {
            try
            {
                string saId = Session["UserID"]?.ToString() ?? "";
                string saName = Session["FullName"]?.ToString() ?? "";

                if (!string.IsNullOrEmpty(hfEditingAdminId.Value))
                {
                    // Edit existing admin
                    string userId = hfEditingAdminId.Value;

                    string updateQuery = "UPDATE tblUsers SET Email = @Email";
                    var updateParams = new List<SqlParameter>
                    {
                        new SqlParameter("@Email",  txtEmail.Text),
                        new SqlParameter("@UserID", userId)
                    };

                    if (!string.IsNullOrEmpty(txtPassword.Text))
                    {
                        updateQuery += ", PasswordHash = @PasswordHash";
                        updateParams.Add(new SqlParameter("@PasswordHash",
                            DatabaseHelper.HashPassword(txtPassword.Text)));
                    }
                    if (!string.IsNullOrEmpty(txtFullName.Text))
                    {
                        updateQuery += ", FullName = @FullName";
                        updateParams.Add(new SqlParameter("@FullName", txtFullName.Text));
                    }

                    updateQuery += " WHERE UserID = @UserID AND Role = 'Admin'";
                    DatabaseHelper.ExecuteNonQuery(updateQuery, updateParams.ToArray());
                    DatabaseHelper.WriteAuditLog(saId, saName, "EDIT_ADMIN", "tblUsers", userId);
                }
                else
                {
                    // Add new admin
                    string newUserId = txtUserId.Text.Trim();

                    if (string.IsNullOrEmpty(newUserId) || string.IsNullOrEmpty(txtPassword.Text))
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "validation",
                            "alert('User ID and Password are required for new admins.');", true);
                        return;
                    }

                    int exists = Convert.ToInt32(DatabaseHelper.ExecuteScalar(
                        "SELECT COUNT(*) FROM tblUsers WHERE UserID = @UserID",
                        new SqlParameter[] { new SqlParameter("@UserID", newUserId) }));

                    if (exists > 0)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "dupError",
                            "alert('User ID already exists. Please choose a different one.');", true);
                        return;
                    }

                    DatabaseHelper.ExecuteNonQuery(
                        "INSERT INTO tblUsers (UserID,PasswordHash,Role,FullName,Email,IsActive) VALUES (@UserID,@PasswordHash,'Admin',@FullName,@Email,1)",
                        new SqlParameter[]
                        {
                            new SqlParameter("@UserID",       newUserId),
                            new SqlParameter("@PasswordHash", DatabaseHelper.HashPassword(txtPassword.Text)),
                            new SqlParameter("@FullName",     txtFullName.Text),
                            new SqlParameter("@Email",        txtEmail.Text)
                        });

                    DatabaseHelper.WriteAuditLog(saId, saName, "ADD_ADMIN", "tblUsers", newUserId);
                }

                hfEditingAdminId.Value = "";
                LoadAdmins();

                ScriptManager.RegisterStartupScript(this, GetType(), "closeModal",
                    "var m=bootstrap.Modal.getInstance(document.getElementById('adminModal'));if(m)m.hide();", true);
                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                    "alert('Admin saved successfully.');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    $"alert('Error saving admin: {ex.Message}');", true);
            }
        }

        protected void gvAdmins_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            try
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument.ToString());
                string userId = gvAdmins.DataKeys[rowIndex]["UserID"].ToString();
                string saId = Session["UserID"]?.ToString() ?? "";
                string saName = Session["FullName"]?.ToString() ?? "";

                if (e.CommandName == "ToggleStatus")
                {
                    DataTable dt = DatabaseHelper.ExecuteQuery(
                        "SELECT IsActive FROM tblUsers WHERE UserID = @UserID AND Role = 'Admin'",
                        new SqlParameter[] { new SqlParameter("@UserID", userId) });

                    if (dt.Rows.Count > 0)
                    {
                        int newActive = Convert.ToInt32(dt.Rows[0]["IsActive"]) == 1 ? 0 : 1;
                        DatabaseHelper.ExecuteNonQuery(
                            "UPDATE tblUsers SET IsActive = @IsActive WHERE UserID = @UserID",
                            new SqlParameter[]
                            {
                                new SqlParameter("@IsActive", newActive),
                                new SqlParameter("@UserID",   userId)
                            });
                        DatabaseHelper.WriteAuditLog(saId, saName,
                            newActive == 1 ? "ACTIVATE_ADMIN" : "DEACTIVATE_ADMIN", "tblUsers", userId);
                    }
                    LoadAdmins();
                    return;
                }

                if (e.CommandName == "DeleteAdmin")
                {
                    int active = Convert.ToInt32(DatabaseHelper.ExecuteScalar(
                        "SELECT COUNT(*) FROM tblTransactions WHERE AdminID = @UserID AND Status = 'Active'",
                        new SqlParameter[] { new SqlParameter("@UserID", userId) }));

                    if (active > 0)
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                            "alert('Cannot delete an admin with active borrow transactions.');", true);
                        return;
                    }

                    DatabaseHelper.WriteAuditLog(saId, saName, "DELETE_ADMIN", "tblUsers", userId);
                    DatabaseHelper.ExecuteNonQuery(
                        "DELETE FROM tblUsers WHERE UserID = @UserID AND Role = 'Admin'",
                        new SqlParameter[] { new SqlParameter("@UserID", userId) });

                    LoadAdmins();
                    ScriptManager.RegisterStartupScript(this, GetType(), "success",
                        "alert('Admin deleted successfully.');", true);
                    return;
                }

                if (e.CommandName == "EditAdmin")
                {
                    DataTable dt = DatabaseHelper.ExecuteQuery(
                        "SELECT UserID, FullName, Email FROM tblUsers WHERE UserID = @UserID AND Role = 'Admin'",
                        new SqlParameter[] { new SqlParameter("@UserID", userId) });

                    if (dt.Rows.Count > 0)
                    {
                        DataRow row = dt.Rows[0];
                        txtUserId.Text = row["UserID"].ToString();
                        txtUserId.Enabled = false;
                        txtFullName.Text = row["FullName"]?.ToString() ?? "";
                        txtEmail.Text = row["Email"]?.ToString() ?? "";
                        txtPassword.Text = "";
                        hfEditingAdminId.Value = row["UserID"].ToString();
                        lblModalTitle.Text = "Edit Admin";

                        ScriptManager.RegisterStartupScript(this, GetType(), "openModal",
                            "new bootstrap.Modal(document.getElementById('adminModal')).show();", true);
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    $"alert('Error: {ex.Message}');", true);
            }
        }
    }
}