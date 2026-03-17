<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="reports.aspx.cs" Inherits="prjLibrarySystem.reports" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Borrowing Transaction - Library System</title>
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
        .summary-card .card-body {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <nav class="col-12 col-md-3 col-lg-2 d-block sidebar">
                    <div class="position-sticky pt-3">
                        <h4 class="text-white text-center mb-4">Library System</h4>
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link" href="AdminDashboard.aspx">
                                    <i class="fas fa-tachometer-alt me-2"></i> Dashboard
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="Books.aspx">
                                    <i class="fas fa-book me-2"></i> Books
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="Members.aspx">
                                    <i class="fas fa-users me-2"></i> Members
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="borrowtransac.aspx">
                                    <i class="fas fa-hand-holding me-2"></i> Borrow Transaction
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link active" href="reports.aspx">
                                    <i class="fas fa-chart-bar me-2"></i> Reports
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
                        <h1 class="h2">Library Reports</h1>
                    </div>

                    <h2 class="mb-4">Library Summary Reports</h2>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="card summary-card border-info">
                                <div class="card-body">
                                    <span>Total Books</span>
                                    <asp:Label ID="lblTotalBooks" runat="server" Text="0" class="badge bg-dark"></asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card summary-card border-success">
                                <div class="card-body">
                                    <span>Total Members</span>
                                    <asp:Label ID="lblTotalMembers" runat="server" Text="0" class="badge bg-dark"></asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card summary-card border-warning">
                                <div class="card-body">
                                    <span>Books Currently Issued</span>
                                    <asp:Label ID="lblIssuedBooks" runat="server" Text="0" class="badge bg-dark"></asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card summary-card border-danger">
                                <div class="card-body">
                                    <span>Books Overdue</span>
                                    <asp:Label ID="lblOverdueBooks" runat="server" Text="0" class="badge bg-dark"></asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="card summary-card border-primary">
                                <div class="card-body">
                                    <span>Most Borrowed Book</span>
                                    <asp:Label ID="lblMostBorrowed" runat="server" Text="N/A" class="badge bg-dark"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-4">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh Report" CssClass="btn btn-primary me-2" OnClick="btnRefresh_Click" />
                        <asp:Button ID="btnExport" runat="server" Text="Export Report" CssClass="btn btn-success" OnClick="btnExport_Click" />
                    </div>
                </main>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
