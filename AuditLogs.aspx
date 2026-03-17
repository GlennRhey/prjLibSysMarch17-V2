<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AuditLogs.aspx.cs" Inherits="prjLibrarySystem.AuditLogs" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Audit Logs - Library System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .main-content { padding: 20px; }
        .audit-row-hover:hover { background: #f0f4ff; }
        .badge-action { font-size: .72rem; }
        tr.pagination { display: none !important; }
        .pagination-bar { display: flex; align-items: center; justify-content: flex-start; padding: 0 12px; height: 54px; border-top: 1px solid #f0f0f0; background: #fff; border-radius: 0 0 4px 4px; }
        .pagination-bar a, .pagination-bar span { color: #555; display: inline-block; padding: 6px 12px; text-decoration: none !important; border: 1px solid #ddd; margin: 0 2px; border-radius: 6px; font-weight: 500; font-size: 13px; transition: all .25s ease; }
        .pagination-bar a:hover { border-color: #1a237e !important; color: #1a237e !important; transform: translateY(-2px); background-color: transparent !important; }
        .pagination-bar span { background-color: #1a237e; color: white !important; border-color: #1a237e; cursor: default; }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="container-fluid">
        <div class="row">

            <asp:Literal ID="litSidebar" runat="server"></asp:Literal>

            <main class="col-12 col-md-9 col-lg-10 px-md-4 main-content">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2"><i class="fas fa-clipboard-list me-2"></i>Audit Logs</h1>
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh"
                        CssClass="btn btn-outline-secondary btn-sm" OnClick="btnRefresh_Click" CausesValidation="false" />
                </div>

                <div class="row mb-3">
                    <div class="col-md-5">
                        <div class="input-group">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control"
                                placeholder="Search by user, action, or table..."></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" Text="Search"
                                CssClass="btn btn-outline-secondary" OnClick="btnSearch_Click" CausesValidation="false" />
                        </div>
                    </div>
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlAction" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlAction_SelectedIndexChanged">
                            <asp:ListItem Value="">All Actions</asp:ListItem>
                            <asp:ListItem Value="ADD_BOOK">Add Book</asp:ListItem>
                            <asp:ListItem Value="EDIT_BOOK">Edit Book</asp:ListItem>
                            <asp:ListItem Value="DELETE_BOOK">Delete Book</asp:ListItem>
                            <asp:ListItem Value="ADD_MEMBER">Add Member</asp:ListItem>
                            <asp:ListItem Value="EDIT_MEMBER">Edit Member</asp:ListItem>
                            <asp:ListItem Value="DELETE_MEMBER">Delete Member</asp:ListItem>
                            <asp:ListItem Value="ADD_ADMIN">Add Admin</asp:ListItem>
                            <asp:ListItem Value="EDIT_ADMIN">Edit Admin</asp:ListItem>
                            <asp:ListItem Value="DELETE_ADMIN">Delete Admin</asp:ListItem>
                            <asp:ListItem Value="ACCEPT_BORROW">Accept Borrow</asp:ListItem>
                            <asp:ListItem Value="ACCEPT_RETURN">Accept Return</asp:ListItem>
                            <asp:ListItem Value="REJECT_REQUEST">Reject Request</asp:ListItem>
                            <asp:ListItem Value="EDIT_BORROW_SETTINGS">Edit Borrow Settings</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-4">
                        <asp:DropDownList ID="ddlDateRange" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlDateRange_SelectedIndexChanged">
                            <asp:ListItem Value="">All Time</asp:ListItem>
                            <asp:ListItem Value="Today">Today</asp:ListItem>
                            <asp:ListItem Value="ThisWeek">This Week</asp:ListItem>
                            <asp:ListItem Value="ThisMonth">This Month</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="card shadow">
                    <div class="card-header py-3 d-flex justify-content-between align-items-center">
                        <h6 class="m-0 font-weight-bold" style="color:#1a237e;">
                            <i class="fas fa-shield-alt me-2"></i>System Audit Trail
                        </h6>
                        <asp:Label ID="lblCount" runat="server" CssClass="text-muted" Text=""></asp:Label>
                    </div>
                    <div class="card-body p-0" style="position:relative; min-height:400px;">
                        <asp:GridView ID="gvAuditLogs" runat="server" CssClass="table table-hover mb-0"
                            AutoGenerateColumns="false" GridLines="None" AllowPaging="true"
                            PageSize="15" OnPageIndexChanging="gvAuditLogs_PageIndexChanging">
                            <PagerStyle CssClass="pagination" HorizontalAlign="Left" />
                            <PagerSettings Mode="NumericFirstLast" Position="Bottom" PageButtonCount="5" FirstPageText="«" LastPageText="»" />
                            <RowStyle CssClass="audit-row-hover" />
                            <Columns>
                                <asp:BoundField DataField="LogID"         HeaderText="#"              ItemStyle-Width="50px" />
                                <asp:BoundField DataField="Timestamp"     HeaderText="Date &amp; Time" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" ItemStyle-Width="160px" />
                                <asp:BoundField DataField="UserID"        HeaderText="User ID"         ItemStyle-Width="110px" />
                                <asp:BoundField DataField="UserName"      HeaderText="User Name"       ItemStyle-Width="130px" />
                                <asp:TemplateField HeaderText="Action" ItemStyle-Width="180px">
                                    <ItemTemplate>
                                        <span class="badge bg-primary badge-action"><%# Eval("Action") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="AffectedTable" HeaderText="Table"           ItemStyle-Width="130px" />
                                <asp:BoundField DataField="AffectedID"    HeaderText="Record ID"       ItemStyle-Width="100px" />
                                <asp:TemplateField HeaderText="Changes">
                                    <ItemTemplate>
                                        <%-- Inline expression — no code-behind method call needed --%>
                                        <small class="text-muted">
                                            <%# (Eval("OldValue") == DBNull.Value || Eval("OldValue") == null) &&
                                                (Eval("NewValue") == DBNull.Value || Eval("NewValue") == null)
                                                ? "—"
                                                : (Eval("OldValue") == DBNull.Value || Eval("OldValue") == null)
                                                    ? "→ " + Eval("NewValue").ToString()
                                                    : (Eval("NewValue") == DBNull.Value || Eval("NewValue") == null)
                                                        ? Eval("OldValue").ToString()
                                                        : Eval("OldValue").ToString() + " → " + Eval("NewValue").ToString()
                                            %>
                                        </small>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center p-4">
                                    <i class="fas fa-clipboard fa-3x text-muted mb-3"></i>
                                    <p class="text-muted">No audit log entries found.</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <div class="pagination-bar" id="customPager"></div>
                    </div>
                </div>
            </main>
        </div>
    </div>
</form>
<script>
    window.addEventListener('DOMContentLoaded', function () {
        var builtIn = document.querySelector('tr.pagination td');
        var custom = document.getElementById('customPager');
        if (builtIn && custom) custom.innerHTML = builtIn.innerHTML;
    });
</script>
</body>
</html>
