<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="prjLibrarySystem.AdminDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Library Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .main-content { padding: 20px; }
        .stat-card { transition: transform 0.2s; }
        .stat-card:hover { transform: translateY(-5px); }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function sendDueDateReminders() { __doPostBack('btnSendReminders', ''); }
    </script>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="container-fluid">
        <div class="row">

            <asp:Literal ID="litSidebar" runat="server"></asp:Literal>

            <main class="col-12 col-md-9 col-lg-10 px-md-4 main-content">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Library Dashboard</h1>
                    <div class="btn-toolbar mb-2 mb-md-0 align-items-center gap-3">
                        <div class="btn-group me-2">
                            <div class="dropdown position-relative">
                                <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button"
                                        id="adminNotificationDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                    <i class="fas fa-bell"></i>
                                    <asp:Label ID="adminNotificationBadge" runat="server"
                                        CssClass="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-warning">0</asp:Label>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <li><h6 class="dropdown-header">System Notifications</h6></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="#" onclick="sendDueDateReminders()"><i class="fas fa-envelope me-2"></i>Send Due Date Reminders</a></li>
                                    <li><a class="dropdown-item" href="#"><i class="fas fa-book me-2"></i>Low Stock Alerts</a></li>
                                    <li><a class="dropdown-item" href="#"><i class="fas fa-chart-line me-2"></i>Usage Report</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#notificationsModal">View All Notifications</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-primary shadow h-100 py-2 stat-card">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Total Books</div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Label ID="lblTotalBooks" runat="server" Text="0"></asp:Label></div>
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
                                        <div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Label ID="lblTotalMembers" runat="server" Text="0"></asp:Label></div>
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
                                        <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Currently Borrowed</div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Label ID="lblActiveLoans" runat="server" Text="0"></asp:Label></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-hand-holding fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card border-left-warning shadow h-100 py-2 stat-card">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center">
                                    <div class="col mr-2">
                                        <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">Overdue Books</div>
                                        <div class="h5 mb-0 font-weight-bold text-gray-800"><asp:Label ID="lblOverdueBooks" runat="server" Text="0"></asp:Label></div>
                                    </div>
                                    <div class="col-auto"><i class="fas fa-exclamation-triangle fa-2x text-gray-300"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-6 mb-4">
                        <div class="card shadow">
                            <div class="card-header py-3 d-flex justify-content-between align-items-center">
                                <h6 class="m-0 font-weight-bold text-warning"><i class="fas fa-bell me-2"></i>Recent Notifications</h6>
                                <asp:Button ID="btnSendReminders" runat="server" Text="Send Due Date Reminders"
                                    CssClass="btn btn-sm btn-outline-warning" OnClick="btnSendReminders_Click" />
                            </div>
                            <div class="card-body">
                                <asp:GridView ID="gvNotifications" runat="server" AutoGenerateColumns="false" CssClass="table table-sm">
                                    <Columns>
                                        <asp:BoundField DataField="Subject"   HeaderText="Subject" />
                                        <asp:BoundField DataField="Recipient" HeaderText="To" />
                                        <asp:BoundField DataField="CreatedAt" HeaderText="Sent" DataFormatString="{0:MMM dd, HH:mm}" />
                                        <asp:BoundField DataField="Status"    HeaderText="Status" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card shadow">
                            <div class="card-header py-3"><h6 class="m-0 font-weight-bold text-primary">Recent Loans</h6></div>
                            <div class="card-body">
                                <asp:GridView ID="gvRecentLoans" runat="server" CssClass="table table-sm" AutoGenerateColumns="false" GridLines="None">
                                    <Columns>
                                        <asp:BoundField DataField="BookTitle"  HeaderText="Book" />
                                        <asp:BoundField DataField="MemberName" HeaderText="Member" />
                                        <asp:BoundField DataField="LoanDate"   HeaderText="Date" DataFormatString="{0:MM/dd/yyyy}" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-4">
                        <div class="card shadow">
                            <div class="card-header py-3"><h6 class="m-0 font-weight-bold text-primary">Popular Books</h6></div>
                            <div class="card-body">
                                <asp:GridView ID="gvPopularBooks" runat="server" CssClass="table table-sm" AutoGenerateColumns="false" GridLines="None">
                                    <Columns>
                                        <asp:BoundField DataField="Title"     HeaderText="Title" />
                                        <asp:BoundField DataField="Author"    HeaderText="Author" />
                                        <asp:BoundField DataField="LoanCount" HeaderText="Times Borrowed" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>
</form>

<div class="modal fade" id="notificationsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-bell me-2"></i>System Notifications</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="notificationsList" runat="server"></div>
                <div id="noNotificationsModal" runat="server" class="text-center py-4" visible="false">
                    <i class="fas fa-bell-slash fa-3x text-muted mb-3"></i>
                    <p class="text-muted">No system notifications yet</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
</body>
</html>
