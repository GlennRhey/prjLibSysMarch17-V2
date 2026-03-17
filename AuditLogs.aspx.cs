using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using prjLibrarySystem.Models;

namespace prjLibrarySystem
{
    public partial class AuditLogs : System.Web.UI.Page
    {
        private string SearchTerm
        {
            get { return ViewState["AuditSearch"] as string ?? ""; }
            set { ViewState["AuditSearch"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null) { Response.Redirect("Login.aspx"); return; }
            if (Session["Role"]?.ToString() != "Super Admin") { Response.Redirect("SuperAdminDashboard.aspx"); return; }

            litSidebar.Text = SidebarHelper.GetSidebar("Super Admin", "auditlogs");

            if (!IsPostBack) LoadAuditLogs();
        }

        private void LoadAuditLogs()
        {
            try
            {
                string query = @"
                    SELECT LogID, Timestamp, UserID, UserName, Action,
                           AffectedTable, AffectedID, OldValue, NewValue
                    FROM   tblAuditLogs WHERE 1 = 1";

                var parameters = new List<SqlParameter>();

                if (!string.IsNullOrEmpty(SearchTerm))
                {
                    query += " AND (UserID LIKE @Search OR UserName LIKE @Search OR Action LIKE @Search OR AffectedTable LIKE @Search OR AffectedID LIKE @Search)";
                    parameters.Add(new SqlParameter("@Search", "%" + SearchTerm + "%"));
                }
                if (!string.IsNullOrEmpty(ddlAction.SelectedValue))
                {
                    query += " AND Action = @Action";
                    parameters.Add(new SqlParameter("@Action", ddlAction.SelectedValue));
                }
                if (!string.IsNullOrEmpty(ddlDateRange.SelectedValue))
                {
                    switch (ddlDateRange.SelectedValue)
                    {
                        case "Today": query += " AND CAST(Timestamp AS DATE) = CAST(GETDATE() AS DATE)"; break;
                        case "ThisWeek": query += " AND Timestamp >= DATEADD(DAY,-7,GETDATE())"; break;
                        case "ThisMonth": query += " AND MONTH(Timestamp)=MONTH(GETDATE()) AND YEAR(Timestamp)=YEAR(GETDATE())"; break;
                    }
                }

                query += " ORDER BY Timestamp DESC";

                DataTable dt = DatabaseHelper.ExecuteQuery(query, parameters.ToArray());
                lblCount.Text = $"{dt.Rows.Count} record{(dt.Rows.Count == 1 ? "" : "s")}";
                gvAuditLogs.DataSource = dt;
                gvAuditLogs.DataBind();
                txtSearch.Text = SearchTerm;
            }
            catch (Exception ex)
            {
                gvAuditLogs.DataSource = null;
                gvAuditLogs.DataBind();
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    $"alert('Error loading audit logs: {ex.Message}');", true);
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e) { SearchTerm = ""; LoadAuditLogs(); }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            SearchTerm = txtSearch.Text.Trim();
            gvAuditLogs.PageIndex = 0;
            LoadAuditLogs();
        }

        protected void ddlAction_SelectedIndexChanged(object sender, EventArgs e) { gvAuditLogs.PageIndex = 0; LoadAuditLogs(); }
        protected void ddlDateRange_SelectedIndexChanged(object sender, EventArgs e) { gvAuditLogs.PageIndex = 0; LoadAuditLogs(); }

        protected void gvAuditLogs_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvAuditLogs.PageIndex = e.NewPageIndex;
            LoadAuditLogs();
        }

        protected string FormatChange(object oldVal, object newVal)
        {
            string old = (oldVal == null || oldVal == DBNull.Value) ? "" : oldVal.ToString();
            string nw = (newVal == null || newVal == DBNull.Value) ? "" : newVal.ToString();
            if (string.IsNullOrEmpty(old) && string.IsNullOrEmpty(nw)) return "—";
            if (string.IsNullOrEmpty(old)) return "→ " + Truncate(nw, 60);
            if (string.IsNullOrEmpty(nw)) return Truncate(old, 60);
            return Truncate(old, 40) + " → " + Truncate(nw, 40);
        }

        private static string Truncate(string s, int max) =>
            s.Length <= max ? s : s.Substring(0, max) + "…";
    }
}