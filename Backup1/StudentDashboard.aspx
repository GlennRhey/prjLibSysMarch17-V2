<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentDashboard.aspx.cs" Inherits="prjLibrarySystem.StudentDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Student Dashboard - Library System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css?v=2.0" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css?v=2.0" rel="stylesheet">
    <style>
        .sidebar {
            min-height: 100vh;
            background: linear-gradient(135deg, #8b0000 0%, #b11226 100%);
        }
        .sidebar .nav-link {
            color: white;
            padding: 15px 20px;
            border-radius: 0;
        }
        .sidebar .nav-link:hover {
            background-color: rgba(255, 255, 255, 0.1);
            color: white;
        }
        .sidebar .nav-link.active {
            background: rgba(255, 255, 255, 0.2);
            border-left: 4px solid white;
        }
        .main-content {
            padding: 20px;
        }
        .stat-card {
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
    </style>
    <script>
        function sendDueDateReminders() {
            // This function will be called from the admin dropdown
            // For now, we'll just show an alert
            alert('Due date reminders would be sent from the Admin Dashboard');
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <nav class="col-12 col-md-3 col-lg-2 d-block sidebar">
                    <div class="position-sticky pt-3">
                        <div class="text-center mb-4">
                            <div class="library-icon">
                                <i class="fas fa-book-open"></i>
                            </div>
                            <h4 class="text-white">Student Portal</h4>
                            <small class="text-white-50">
                                <asp:Label ID="lblStudentName" runat="server" Text="Student"></asp:Label>
                            </small>
                        </div>
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link active" href="StudentDashboard.aspx">
                                    <i class="fas fa-tachometer-alt me-2"></i> Dashboard
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="StudentBorrowBooks.aspx">
                                    <i class="fas fa-book me-2"></i> Borrow Books
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="StudentMyBooks.aspx">
                                    <i class="fas fa-book-reader me-2"></i> My Books
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="#" data-bs-toggle="modal" data-bs-target="#changePasswordModal">
                                    <i class="fas fa-key me-2"></i> Change Password
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="Logout.aspx">
                                    <i class="fas fa-sign-out-alt me-2"></i> Logout
                                </a>
                            </li>
                        </ul>
                    </div>
                </nav>

                <!-- Main Content -->
                <main class="col-12 col-md-9 col-lg-10 px-md-4 main-content">
                    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                        <h1 class="h2">Student Dashboard</h1>
                        <div class="btn-toolbar mb-2 mb-md-0">
                            <div class="btn-group me-2">
                                <div class="dropdown position-relative">
                                    <button class="btn btn-outline-secondary dropdown-toggle" type="button" 
                                            id="studentNotificationDropdown" data-bs-toggle="dropdown" 
                                            aria-expanded="false">
                                        <i class="fas fa-bell"></i>
                                        <asp:Label ID="studentNotificationBadge" runat="server" 
                                            CssClass="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">0</asp:Label>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="studentNotificationDropdown">
                                        <li><h6 class="dropdown-header">Notifications</h6></li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li id="noStudentNotifications" runat="server">
                                            <a class="dropdown-item text-muted">No new notifications</a>
                                        </li>
                                        <li id="studentNotificationList" runat="server" visible="false">
                                            <!-- Notifications will be loaded here -->
                                        </li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#notificationsModal">View All Notifications</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Statistics Cards -->
                    <div class="row mb-4">
                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-primary shadow h-100 py-2 stat-card">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                                Available Books</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">
                                                <asp:Label ID="lblAvailableBooks" runat="server" Text="0"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-book fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-success shadow h-100 py-2 stat-card">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                                Borrowed Books</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">
                                                <asp:Label ID="lblBorrowedBooks" runat="server" Text="0"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-hand-holding fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-info shadow h-100 py-2 stat-card">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                                Overdue Books</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">
                                                <asp:Label ID="lblOverdueBooks" runat="server" Text="0"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-exclamation-triangle fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-xl-3 col-md-6 mb-4">
                            <div class="card border-left-warning shadow h-100 py-2 stat-card">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                                Total Borrowed</div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">
                                                <asp:Label ID="lblTotalBorrowed" runat="server" Text="0"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fas fa-chart-line fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Book Recommendations -->
                    <div class="row">
                        <div class="col-12 mb-4">
                            <div class="card shadow">
                                <div class="card-header py-3 d-flex justify-content-between align-items-center">
                                    <h6 class="m-0 font-weight-bold text-primary">
                                        <i class="fas fa-lightbulb me-2"></i>Recommended for You
                                    </h6>
                                    <small class="text-muted">Based on your reading history</small>
                                </div>
                                <div class="card-body">
                                    <asp:GridView ID="gvRecommendations" runat="server" 
                                        AutoGenerateColumns="false" CssClass="table table-hover">
                                        <Columns>
                                            <asp:BoundField DataField="Title" HeaderText="Title" />
                                            <asp:BoundField DataField="Author" HeaderText="Author" />
                                            <asp:BoundField DataField="Category" HeaderText="Category" />
                                            <asp:BoundField DataField="AvailableCopies" HeaderText="Available" />
                                            <asp:TemplateField HeaderText="Action">
                                                <ItemTemplate>
                                                    <a href='StudentBorrowBooks.aspx?isbn=<%# Eval("ISBN") %>' 
                                                       class="btn btn-sm btn-outline-primary">
                                                        <i class="fas fa-plus"></i> Borrow
                                                    </a>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    
                                    <!-- Empty state -->
                                    <div id="noRecommendations" runat="server" class="text-center py-4" visible="false">
                                        <i class="fas fa-book-open fa-3x text-muted mb-3"></i>
                                        <p class="text-muted">Start borrowing books to get personalized recommendations!</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Quick Links -->
                    <div class="row">
                        <div class="col-12">
                            <div class="card shadow">
                                <div class="card-header py-3">
                                    <h6 class="m-0 font-weight-bold text-primary">Quick Actions</h6>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <a href="StudentBorrowBooks.aspx" class="btn btn-primary btn-lg mb-2 w-100">
                                                <i class="fas fa-book me-2"></i> Browse Available Books
                                            </a>
                                        </div>
                                        <div class="col-md-6">
                                            <a href="StudentMyBooks.aspx" class="btn btn-success btn-lg mb-2 w-100">
                                                <i class="fas fa-book-reader me-2"></i> View My Books
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        </div>

        <!-- Password Change Modal -->
        <div class="modal fade" id="changePasswordModal" tabindex="-1" aria-labelledby="changePasswordModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="changePasswordModalLabel">
                            <i class="fas fa-key me-2"></i>Change Password
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="txtCurrentPassword" class="form-label">Current Password</label>
                            <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" 
                                CssClass="form-control" placeholder="Enter current password" />
                        </div>
                        <div class="mb-3">
                            <label for="txtNewPassword" class="form-label">New Password</label>
                            <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" 
                                CssClass="form-control" placeholder="Enter new password" />
                        </div>
                        <div class="mb-3">
                            <label for="txtConfirmPassword" class="form-label">Confirm New Password</label>
                            <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" 
                                CssClass="form-control" placeholder="Confirm new password" />
                        </div>
                        <div id="passwordError" class="alert alert-danger" style="display: none;" runat="server">
                            <asp:Label ID="lblPasswordError" runat="server" Text=""></asp:Label>
                        </div>
                        <div id="passwordSuccess" class="alert alert-success" style="display: none;" runat="server">
                            <asp:Label ID="lblPasswordSuccess" runat="server" Text=""></asp:Label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnChangePassword" runat="server" Text="Change Password" 
                            CssClass="btn btn-primary" OnClick="btnChangePassword_Click" />
                    </div>
                </div>
            </div>
        </div>
        <!-- Notifications Modal -->
        <div class="modal fade" id="notificationsModal" tabindex="-1" aria-labelledby="notificationsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="notificationsModalLabel">
                            <i class="fas fa-bell me-2"></i>Notifications
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div id="notificationsList" runat="server">
                            <!-- Notifications will be loaded here -->
                        </div>
                        <div id="noNotificationsModal" runat="server" class="text-center py-4" visible="false">
                            <i class="fas fa-bell-slash fa-3x text-muted mb-3"></i>
                            <p class="text-muted">No notifications yet</p>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
