<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SuperAdminDashboard.aspx.cs" Inherits="prjLibrarySystem.SuperAdminDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Super Admin Dashboard - Library System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .main-content { padding: 20px; }
        .stat-card { transition: transform .2s; }
        .stat-card:hover { transform: translateY(-5px); }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="container-fluid">
        <div class="row">

            <%-- Blue SA sidebar, Dashboard active --%>
            <asp:Literal ID="litSidebar" runat="server"></asp:Literal>

            <main class="col-12 col-md-9 col-lg-10 px-md-4 main-content">
                <div class="d-flex flex-column pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Super Admin Dashboard</h1>
                </div>

                <div class="row">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2 stat-card">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Total Books</div>
                                        <div class="h5 mb-0 font-weight-bold"><asp:Label ID="lblTotalBooks" runat="server" Text="0"></asp:Label></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-book fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-success shadow h-100 py-2 stat-card">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Total Members</div>
                                        <div class="h5 mb-0 font-weight-bold"><asp:Label ID="lblTotalMembers" runat="server" Text="0"></asp:Label></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-users fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-info shadow h-100 py-2 stat-card">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Total Admins</div>
                                        <div class="h5 mb-0 font-weight-bold"><asp:Label ID="lblTotalAdmins" runat="server" Text="0"></asp:Label></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-user-shield fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2 stat-card">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Currently Borrowed</div>
                                        <div class="h5 mb-0 font-weight-bold"><asp:Label ID="lblActiveLoans" runat="server" Text="0"></asp:Label></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-hand-holding fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-danger shadow h-100 py-2 stat-card">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">Overdue Books</div>
                                        <div class="h5 mb-0 font-weight-bold"><asp:Label ID="lblOverdueBooks" runat="server" Text="0"></asp:Label></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-exclamation-triangle fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-secondary shadow h-100 py-2 stat-card">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-secondary text-uppercase mb-1">Audit Log Entries</div>
                                        <div class="h5 mb-0 font-weight-bold"><asp:Label ID="lblAuditCount" runat="server" Text="0"></asp:Label></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-clipboard-list fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-12 mb-4">
                        <div class="card shadow">
                            <div class="card-header py-3 d-flex justify-content-between align-items-center">
                                <h6 class="m-0 font-weight-bold" style="color:#1a237e;">
                                    <i class="fas fa-clipboard-list me-2"></i>Recent Audit Activity
                                </h6>
                                <a href="AuditLogs.aspx" class="btn btn-sm btn-outline-primary">View All Logs</a>
                            </div>
                            <div class="card-body">
                                <asp:GridView ID="gvRecentAudit" runat="server"
                                    CssClass="table table-sm table-hover"
                                    AutoGenerateColumns="false" GridLines="None">
                                    <Columns>
                                        <asp:BoundField DataField="Timestamp"     HeaderText="Time"    DataFormatString="{0:MM/dd/yyyy HH:mm}" />
                                        <asp:BoundField DataField="UserID"        HeaderText="User ID" />
                                        <asp:BoundField DataField="UserName"      HeaderText="Name" />
                                        <asp:BoundField DataField="Action"        HeaderText="Action" />
                                        <asp:BoundField DataField="AffectedTable" HeaderText="Table" />
                                        <asp:BoundField DataField="AffectedID"    HeaderText="Record" />
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="text-center p-3 text-muted">No audit activity yet.</div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>
</form>
</body>
</html>
