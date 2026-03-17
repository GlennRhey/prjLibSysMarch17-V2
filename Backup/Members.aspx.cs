using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class Members : System.Web.UI.Page
    {
        private string SearchTerm
        {
            get { return ViewState["SearchTerm"] as string ?? ""; }
            set { ViewState["SearchTerm"] = value; }
        }

        // ddlYearLevel in Members.aspx uses Text values: "1st Year","2nd Year","3rd Year","4th Year"
        // These map to int YearLevel in tblMembers: 1,2,3,4
        private int ParseYearLevel(string text)
        {
            switch (text)
            {
                case "1st Year": return 1;
                case "2nd Year": return 2;
                case "3rd Year": return 3;
                case "4th Year": return 4;
                default:
                    // fallback: try parsing the first character
                    if (text.Length > 0 && char.IsDigit(text[0]))
                        return int.Parse(text[0].ToString());
                    return 1;
            }
        }

        private string YearLevelToText(int yearLevel)
        {
            switch (yearLevel)
            {
                case 1: return "1st Year";
                case 2: return "2nd Year";
                case 3: return "3rd Year";
                case 4: return "4th Year";
                default: return "1st Year";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                LoadMembers();
        }

        private void LoadMembers()
        {
            try
            {
                string currentSearch = SearchTerm;

                // Query to get both students (from tblMembers) and admins (from tblUsers only)
                string query = @"
                    SELECT 
                        u.UserID AS MemberID,
                        m.FullName,
                        u.UserID AS Username,
                        u.Email,
                        m.Course,
                        m.YearLevel,
                        'Student' AS Role,
                        u.CreatedAt AS RegistrationDate,
                        CASE WHEN u.IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS Status
                    FROM tblMembers m
                    INNER JOIN tblUsers u ON m.UserID = u.UserID
                    WHERE u.Role = 'Student'
                    
                    UNION ALL
                    
                    SELECT 
                        u.UserID AS MemberID,
                        u.FullName,
                        u.UserID AS Username,
                        u.Email,
                        NULL AS Course,
                        NULL AS YearLevel,
                        'Admin' AS Role,
                        u.CreatedAt AS RegistrationDate,
                        CASE WHEN u.IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS Status
                    FROM tblUsers u
                    WHERE u.Role = 'Admin'";

                var parameters = new List<SqlParameter>();

                if (!string.IsNullOrEmpty(currentSearch))
                {
                    query += " AND (FullName LIKE @Search OR Email LIKE @Search OR Username LIKE @Search)";
                    parameters.Add(new SqlParameter("@Search", "%" + currentSearch + "%"));
                }

                // Apply role filter if selected
                if (!string.IsNullOrEmpty(ddlMembershipType.SelectedValue))
                {
                    if (ddlMembershipType.SelectedValue == "Student")
                    {
                        query = @"
                            SELECT 
                                u.UserID AS MemberID,
                                m.FullName,
                                u.UserID AS Username,
                                u.Email,
                                m.Course,
                                m.YearLevel,
                                'Student' AS Role,
                                u.CreatedAt AS RegistrationDate,
                                CASE WHEN u.IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS Status
                            FROM tblMembers m
                            INNER JOIN tblUsers u ON m.UserID = u.UserID
                            WHERE u.Role = 'Student'";
                    }
                    else if (ddlMembershipType.SelectedValue == "Admin")
                    {
                        query = @"
                            SELECT 
                                u.UserID AS MemberID,
                                u.FullName,
                                u.UserID AS Username,
                                u.Email,
                                NULL AS Course,
                                NULL AS YearLevel,
                                'Admin' AS Role,
                                u.CreatedAt AS RegistrationDate,
                                CASE WHEN u.IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS Status
                            FROM tblUsers u
                            WHERE u.Role = 'Admin'";
                    }
                }

                // Apply search filter again if role filter was applied
                if (!string.IsNullOrEmpty(currentSearch) && !string.IsNullOrEmpty(ddlMembershipType.SelectedValue))
                {
                    query += " AND (FullName LIKE @Search OR Email LIKE @Search OR Username LIKE @Search)";
                    parameters.Add(new SqlParameter("@Search", "%" + currentSearch + "%"));
                }

                // Apply status filter
                if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
                {
                    query += " AND (CASE WHEN IsActive = 1 THEN 'Active' ELSE 'Inactive' END) = @Status";
                    parameters.Add(new SqlParameter("@Status", ddlStatus.SelectedValue));
                }

                query += " ORDER BY Role ASC, Username ASC";

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters.ToArray());
                gvMembers.DataSource = dt;
                gvMembers.DataBind();
                txtSearchMember.Text = currentSearch;
            }
            catch (Exception ex)
            {
                gvMembers.DataSource = null;
                gvMembers.DataBind();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                    $"alert('Error loading members: {ex.Message}');", true);
            }
        }

        // All control IDs below verified against Members.aspx:
        // txtUserId, txtFullName, txtEmail, txtCourse, ddlYearLevel, txtPassword
        // hfSelectedRole, hfEditingMemberId, lblRegisterTitle

        protected void btnSaveMember_Click(object sender, EventArgs e)
        {
            try
            {
                string selectedRole = hfSelectedRole.Value; // "Student" or "Admin"

                if (!string.IsNullOrEmpty(hfEditingMemberId.Value))
                {
                    // ── EDIT STUDENT ───────────────────────────────────────────
                    int memberId = int.Parse(hfEditingMemberId.Value);

                    DataTable userDt = DatabaseHelper.ExecuteQuery(
                        "SELECT UserID FROM tblMembers WHERE MemberID = @MemberID",
                        new SqlParameter[] { new SqlParameter("@MemberID", memberId) });

                    if (userDt.Rows.Count == 0) throw new Exception("Member not found.");
                    string userId = userDt.Rows[0]["UserID"].ToString();

                    // Update email in tblUsers
                    DatabaseHelper.ExecuteQuery(
                        "UPDATE tblUsers SET Email = @Email WHERE UserID = @UserID",
                        new SqlParameter[]
                        {
                            new SqlParameter("@Email",  txtEmail.Text),
                            new SqlParameter("@UserID", userId)
                        });

                    // Update password only if filled in
                    if (!string.IsNullOrEmpty(txtPassword.Text))
                        DatabaseHelper.ExecuteQuery(
                            "UPDATE tblUsers SET PasswordHash = @PasswordHash WHERE UserID = @UserID",
                            new SqlParameter[]
                            {
                                new SqlParameter("@PasswordHash", DatabaseHelper.HashPassword(txtPassword.Text)),
                                new SqlParameter("@UserID",       userId)
                            });

                    // Update member profile
                    DatabaseHelper.ExecuteQuery(
                        "UPDATE tblMembers SET FullName=@FullName, Course=@Course, YearLevel=@YearLevel WHERE MemberID=@MemberID",
                        new SqlParameter[]
                        {
                            new SqlParameter("@FullName",  txtFullName.Text),
                            new SqlParameter("@Course",    txtCourse.Text),
                            new SqlParameter("@YearLevel", ParseYearLevel(ddlYearLevel.SelectedValue)),
                            new SqlParameter("@MemberID",  memberId)
                        });
                }
                else if (selectedRole == "Admin" && !string.IsNullOrEmpty(txtUserId.Text))
                {
                    // ── EDIT ADMIN (when hfEditingMemberId is empty but role is Admin) ──
                    string userId = txtUserId.Text.Trim();

                    // Check if admin exists
                    DataTable checkDt = DatabaseHelper.ExecuteQuery(
                        "SELECT COUNT(*) FROM tblUsers WHERE UserID = @UserID AND Role = 'Admin'",
                        new SqlParameter[] { new SqlParameter("@UserID", userId) });

                    if (Convert.ToInt32(checkDt.Rows[0][0]) > 0)
                    {
                        // Update existing admin
                        string updateQuery = "UPDATE tblUsers SET Email = @Email";
                        var updateParams = new List<SqlParameter>
                        {
                            new SqlParameter("@Email", txtEmail.Text),
                            new SqlParameter("@UserID", userId)
                        };

                        if (!string.IsNullOrEmpty(txtPassword.Text))
                        {
                            updateQuery += ", PasswordHash = @PasswordHash";
                            updateParams.Add(new SqlParameter("@PasswordHash", DatabaseHelper.HashPassword(txtPassword.Text)));
                        }

                        if (!string.IsNullOrEmpty(txtFullName.Text))
                        {
                            updateQuery += ", FullName = @FullName";
                            updateParams.Add(new SqlParameter("@FullName", txtFullName.Text));
                        }

                        updateQuery += " WHERE UserID = @UserID";

                        DatabaseHelper.ExecuteQuery(updateQuery, updateParams.ToArray());
                    }
                    else
                    {
                        // Create new admin
                        DatabaseHelper.ExecuteQuery(
                            "INSERT INTO tblUsers (UserID, PasswordHash, Role, FullName, Email, IsActive) VALUES (@UserID, @PasswordHash, 'Admin', @FullName, @Email, 1)",
                            new SqlParameter[]
                            {
                                new SqlParameter("@UserID",       userId),
                                new SqlParameter("@PasswordHash", DatabaseHelper.HashPassword(txtPassword.Text)),
                                new SqlParameter("@FullName",     txtFullName.Text),
                                new SqlParameter("@Email",        txtEmail.Text)
                            });
                    }
                }
                else
                {
                    // ── ADD NEW ──────────────────────────────────────────────
                    string newUserId = txtUserId.Text.Trim();

                    if (selectedRole == "Student")
                    {
                        // Insert login record first (FK constraint)
                        DatabaseHelper.ExecuteQuery(
                            "INSERT INTO tblUsers (UserID, PasswordHash, Role, Email, IsActive) VALUES (@UserID, @PasswordHash, 'Student', @Email, 1)",
                            new SqlParameter[]
                            {
                                new SqlParameter("@UserID",       newUserId),
                                new SqlParameter("@PasswordHash", DatabaseHelper.HashPassword(txtPassword.Text)),
                                new SqlParameter("@Email",        txtEmail.Text)
                            });

                        // Insert student profile
                        DatabaseHelper.ExecuteQuery(
                            "INSERT INTO tblMembers (UserID, FullName, Course, YearLevel) VALUES (@UserID, @FullName, @Course, @YearLevel)",
                            new SqlParameter[]
                            {
                                new SqlParameter("@UserID",    newUserId),
                                new SqlParameter("@FullName",  txtFullName.Text),
                                new SqlParameter("@Course",    txtCourse.Text),
                                new SqlParameter("@YearLevel", ParseYearLevel(ddlYearLevel.SelectedValue))
                            });
                    }
                    else
                    {
                        // Admin — FullName lives in tblUsers, no tblMembers row
                        DatabaseHelper.ExecuteQuery(
                            "INSERT INTO tblUsers (UserID, PasswordHash, Role, FullName, Email, IsActive) VALUES (@UserID, @PasswordHash, 'Admin', @FullName, @Email, 1)",
                            new SqlParameter[]
                            {
                                new SqlParameter("@UserID",       newUserId),
                                new SqlParameter("@PasswordHash", DatabaseHelper.HashPassword(txtPassword.Text)),
                                new SqlParameter("@FullName",     txtFullName.Text),
                                new SqlParameter("@Email",        txtEmail.Text)
                            });
                    }
                }

                ClearMemberForm();
                hfEditingMemberId.Value = "";
                LoadMembers();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop",
                    "var myModal = bootstrap.Modal.getInstance(document.getElementById('memberModal')); myModal.hide();", true);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "success",
                    "alert('Member saved successfully.');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                    $"alert('Error saving member: {ex.Message}');", true);
            }
        }

        private void ClearMemberForm()
        {
            txtUserId.Text = "";
            txtFullName.Text = "";
            txtEmail.Text = "";
            txtCourse.Text = "";
            ddlYearLevel.SelectedIndex = 0;
            txtPassword.Text = "";
        }

        protected void gvMembers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMembers.PageIndex = e.NewPageIndex;
            LoadMembers();
        }

        protected void gvMembers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            try
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument.ToString());
                string memberId = gvMembers.DataKeys[rowIndex]["MemberID"].ToString();
                string role = gvMembers.DataKeys[rowIndex]["Role"].ToString();

                // ── TOGGLE Active/Inactive ─────────────────────────────────
                if (e.CommandName == "ToggleStatus")
                {
                    if (role == "Student")
                    {
                        // For students, get the actual MemberID from tblMembers
                        DataTable memberDt = DatabaseHelper.ExecuteQuery(
                            "SELECT MemberID FROM tblMembers WHERE UserID = @UserID",
                            new SqlParameter[] { new SqlParameter("@UserID", memberId) });

                        if (memberDt.Rows.Count > 0)
                        {
                            string actualMemberId = memberDt.Rows[0]["MemberID"].ToString();
                            DataTable userDt = DatabaseHelper.ExecuteQuery(@"
                                SELECT u.UserID, u.IsActive
                                FROM tblUsers u
                                INNER JOIN tblMembers m ON u.UserID = m.UserID
                                WHERE m.MemberID = @MemberID",
                                new SqlParameter[] { new SqlParameter("@MemberID", actualMemberId) });

                            if (userDt.Rows.Count > 0)
                            {
                                string userId = userDt.Rows[0]["UserID"].ToString();
                                int newActive = Convert.ToInt32(userDt.Rows[0]["IsActive"]) == 1 ? 0 : 1;

                                DatabaseHelper.ExecuteQuery(
                                    "UPDATE tblUsers SET IsActive = @IsActive WHERE UserID = @UserID",
                                    new SqlParameter[]
                                    {
                                        new SqlParameter("@IsActive", newActive),
                                        new SqlParameter("@UserID",   userId)
                                    });
                            }
                        }
                    }
                    else if (role == "Admin")
                    {
                        // For admins, use UserID directly
                        DataTable userDt = DatabaseHelper.ExecuteQuery(@"
                            SELECT UserID, IsActive FROM tblUsers WHERE UserID = @UserID",
                            new SqlParameter[] { new SqlParameter("@UserID", memberId) });

                        if (userDt.Rows.Count > 0)
                        {
                            int newActive = Convert.ToInt32(userDt.Rows[0]["IsActive"]) == 1 ? 0 : 1;

                            DatabaseHelper.ExecuteQuery(
                                "UPDATE tblUsers SET IsActive = @IsActive WHERE UserID = @UserID",
                                new SqlParameter[]
                                {
                                    new SqlParameter("@IsActive", newActive),
                                    new SqlParameter("@UserID",   memberId)
                                });
                        }
                    }
                    LoadMembers();
                    return;
                }

                // ── DELETE ────────────────────────────────────────────────
                if (e.CommandName == "DeleteMember")
                {
                    if (role == "Student")
                    {
                        // For students, get the actual MemberID from tblMembers
                        DataTable memberDt = DatabaseHelper.ExecuteQuery(
                            "SELECT MemberID FROM tblMembers WHERE UserID = @UserID",
                            new SqlParameter[] { new SqlParameter("@UserID", memberId) });

                        if (memberDt.Rows.Count > 0)
                        {
                            string actualMemberId = memberDt.Rows[0]["MemberID"].ToString();
                            DataTable checkDt = DatabaseHelper.ExecuteQuery(
                                "SELECT COUNT(*) FROM tblTransactions WHERE MemberID = @MemberID AND Status = 'Active'",
                                new SqlParameter[] { new SqlParameter("@MemberID", actualMemberId) });

                            if (Convert.ToInt32(checkDt.Rows[0][0]) > 0)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                                    "alert('Cannot delete a member with active borrow transactions.');", true);
                                return;
                            }

                            DataTable userDt = DatabaseHelper.ExecuteQuery(
                                "SELECT UserID FROM tblMembers WHERE MemberID = @MemberID",
                                new SqlParameter[] { new SqlParameter("@MemberID", actualMemberId) });

                            if (userDt.Rows.Count > 0)
                                // ON DELETE CASCADE removes tblMembers row automatically
                                DatabaseHelper.ExecuteQuery(
                                    "DELETE FROM tblUsers WHERE UserID = @UserID",
                                    new SqlParameter[] { new SqlParameter("@UserID", userDt.Rows[0]["UserID"].ToString()) });
                        }
                    }
                    else if (role == "Admin")
                    {
                        // For admins, just delete from tblUsers — admins don't have borrow records
                        DatabaseHelper.ExecuteQuery(
                            "DELETE FROM tblUsers WHERE UserID = @UserID AND Role = 'Admin'",
                            new SqlParameter[] { new SqlParameter("@UserID", memberId) });
                    }

                    LoadMembers();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "success",
                        "alert('Member deleted successfully.');", true);
                    return;
                }

                // ── EDIT ──────────────────────────────────────────────────
                if (e.CommandName == "EditMember")
                {
                    if (role == "Student")
                    {
                        // For students, get the actual MemberID from tblMembers
                        DataTable memberDt = DatabaseHelper.ExecuteQuery(
                            "SELECT MemberID FROM tblMembers WHERE UserID = @UserID",
                            new SqlParameter[] { new SqlParameter("@UserID", memberId) });

                        if (memberDt.Rows.Count > 0)
                        {
                            string actualMemberId = memberDt.Rows[0]["MemberID"].ToString();
                            DataTable dt = DatabaseHelper.ExecuteQuery(@"
                                SELECT m.MemberID, m.FullName, m.Course, m.YearLevel,
                                       u.UserID, u.Email, u.IsActive
                                FROM tblMembers m
                                INNER JOIN tblUsers u ON m.UserID = u.UserID
                                WHERE m.MemberID = @MemberID",
                                new SqlParameter[] { new SqlParameter("@MemberID", actualMemberId) });

                            if (dt.Rows.Count > 0)
                            {
                                DataRow row = dt.Rows[0];

                                txtUserId.Text = row["UserID"].ToString();
                                txtFullName.Text = row["FullName"].ToString();
                                txtEmail.Text = row["Email"].ToString();
                                txtCourse.Text = row["Course"].ToString();

                                // Convert int YearLevel back to text for ddlYearLevel
                                ddlYearLevel.SelectedValue = YearLevelToText(Convert.ToInt32(row["YearLevel"]));
                                txtPassword.Text = "";

                                hfEditingMemberId.Value = row["MemberID"].ToString();
                                lblRegisterTitle.Text = "Edit Member";

                                ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop",
                                    "var myModal = new bootstrap.Modal(document.getElementById('memberModal')); myModal.show();", true);
                            }
                        }
                    }
                    else if (role == "Admin")
                    {
                        // For admins, load from tblUsers only
                        DataTable dt = DatabaseHelper.ExecuteQuery(@"
                            SELECT UserID, FullName, Email, IsActive
                            FROM tblUsers
                            WHERE UserID = @UserID AND Role = 'Admin'",
                            new SqlParameter[] { new SqlParameter("@UserID", memberId) });

                        if (dt.Rows.Count > 0)
                        {
                            DataRow row = dt.Rows[0];

                            txtUserId.Text = row["UserID"].ToString();
                            txtFullName.Text = row["FullName"].ToString();
                            txtEmail.Text = row["Email"].ToString();
                            txtCourse.Text = ""; // Admins don't have course
                            ddlYearLevel.SelectedIndex = 0; // Admins don't have year level
                            txtPassword.Text = "";

                            hfEditingMemberId.Value = ""; // Admins don't have MemberID
                            lblRegisterTitle.Text = "Edit Admin Member";

                            // Select admin role in the modal
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "setAdminRole",
                                "selectRole('Admin');", true);
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop",
                                "var myModal = new bootstrap.Modal(document.getElementById('memberModal')); myModal.show();", true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "error",
                    $"alert('Error: {ex.Message}');", true);
            }
        }

        // Called from .aspx TemplateField: GetStatusBadgeClass(Eval("Status"))
        protected string GetStatusBadgeClass(object statusObj)
        {
            if (statusObj == null) return "status-inactive";
            return statusObj.ToString() == "Active" ? "status-active" : "status-inactive";
        }

        protected string GetMemberStatus(object statusObj)
        {
            if (statusObj == null) return "Inactive";
            return statusObj.ToString() == "Active" ? "Active" : "Inactive";
        }

        protected void btnSearchMember_Click(object sender, EventArgs e)
        {
            SearchTerm = txtSearchMember.Text.Trim();
            gvMembers.PageIndex = 0;
            LoadMembers();
        }

        protected void ddlMembershipType_SelectedIndexChanged(object sender, EventArgs e)
        {
            gvMembers.PageIndex = 0;
            LoadMembers();
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            gvMembers.PageIndex = 0;
            LoadMembers();
        }
    }
}