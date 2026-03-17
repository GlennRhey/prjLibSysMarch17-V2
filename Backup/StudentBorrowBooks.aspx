<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentBorrowBooks.aspx.cs" Inherits="prjLibrarySystem.StudentBorrowBooks" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Borrow Books - Library System</title>
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
        .sidebar .nav-link:hover  { background-color: rgba(255,255,255,0.1); color: white; }
        .sidebar .nav-link.active { background: rgba(255,255,255,0.2); border-left: 4px solid white; }
        .main-content { padding: 20px; }
        .action-buttons .btn { margin-right: 5px; }
        .book-cover {
            width: 50px; height: 70px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 5px;
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 1.3rem;
        }
        .borrow-btn { border-radius: 20px; font-size: 0.85rem; }
        .card-body {
            padding: 0;
        }
        .table {
            table-layout: fixed;
            width: 100%;
            margin-bottom: 0;
        }
        .table th,
        .table td {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            vertical-align: middle;
            padding-left: 12px;
        }
        .table th {
            height: 52px;
        }
        .table td {
            height: 66px;
        }
        .table th:nth-child(1), .table td:nth-child(1) { width: 80px; }
        .table th:nth-child(2), .table td:nth-child(2) { width: 25%; }
        .table th:nth-child(3), .table td:nth-child(3) { width: 20%; }
        .table th:nth-child(4), .table td:nth-child(4) { width: 15%; }
        .table th:nth-child(5), .table td:nth-child(5) { width: 120px; }
        .table th:nth-child(6), .table td:nth-child(6) { width: 100px; }
        tr.pagination { display: none !important; }
        .pagination-bar {
            display: flex;
            align-items: center;
            justify-content: flex-start;
            padding: 0 12px;
            height: 54px;
            border-top: 1px solid #f0f0f0;
            background: #fff;
            border-radius: 0 0 4px 4px;
        }
        .pagination-bar a,
        .pagination-bar span {
            color: #555;
            display: inline-block;
            padding: 6px 12px;
            text-decoration: none !important;
            border: 1px solid #ddd;
            margin: 0 2px;
            border-radius: 6px;
            font-weight: 500;
            font-size: 13px;
            transition: all 0.25s ease;
        }
        .pagination-bar a:hover {
            border-color: #8b0000 !important;
            color: #8b0000 !important;
            transform: translateY(-2px);
            background-color: transparent !important;
            text-decoration: none !important;
            box-shadow: none !important;
        }
        .pagination-bar span {
            background-color: #8b0000;
            color: white !important;
            border-color: #8b0000;
            cursor: default;
        }
        .pagination-bar a.disabled-link {
            color: #aaa !important;
            background-color: #f5f5f5 !important;
            border-color: #ddd !important;
            pointer-events: none;
            transform: none !important;
        }
    </style>
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
                        <i class="fas fa-book-open fa-3x text-white mb-2"></i>
                        <h5 class="text-white mt-2">Student Portal</h5>
                        <small class="text-white-50">
                            <asp:Label ID="lblStudentName" runat="server" Text="Student"></asp:Label>
                        </small>
                    </div>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link" href="StudentDashboard.aspx">
                                <i class="fas fa-tachometer-alt me-2"></i> Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="StudentBorrowBooks.aspx">
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
                    <h1 class="h2"><i class="fas fa-book me-2"></i>Borrow Books</h1>
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh"
                        CssClass="btn btn-outline-secondary btn-sm" OnClick="btnRefresh_Click" />
                </div>

                <!-- Status message panel (success / error feedback) -->
                <asp:Panel ID="pnlStatus" runat="server" Visible="false" CssClass="alert alert-dismissible fade show">
                    <asp:Label ID="lblStatusMessage" runat="server"></asp:Label>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </asp:Panel>

                <!-- Info banner -->
                <div class="alert alert-info d-flex align-items-center mb-3" role="alert">
                    <i class="fas fa-info-circle me-2"></i>
                    <span>You may borrow up to <strong>3 books</strong> and have up to <strong>3 pending requests</strong> at a time. All requests require librarian approval.</span>
                </div>

                <!-- Search & Filter -->
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="input-group">
                            <asp:TextBox ID="txtSearchBooks" runat="server" CssClass="form-control"
                                placeholder="Search by title or author..."
                                AutoPostBack="true" OnTextChanged="txtSearchBooks_TextChanged" />
                            <asp:Button ID="btnSearchBooks" runat="server" Text="Search"
                                CssClass="btn btn-outline-secondary" OnClick="btnSearchBooks_Click" />
                        </div>
                    </div>
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                            <asp:ListItem Value="">All Categories</asp:ListItem>
                            <asp:ListItem Value="Programming">Programming</asp:ListItem>
                            <asp:ListItem Value="Artificial Intelligence">Artificial Intelligence</asp:ListItem>
                            <asp:ListItem Value="Data Communications">Data Communications</asp:ListItem>
                            <asp:ListItem Value="Literature">Literature</asp:ListItem>
                            <asp:ListItem Value="Business">Business</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <!-- Available Books -->
                <div class="card shadow mb-4">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Available Books</h6>
                    </div>
                    <div class="card-body">

                        <!-- Books Grid -->
                        <asp:GridView ID="gvAvailableBooks" runat="server"
                            CssClass="table table-hover align-middle"
                            AutoGenerateColumns="false" GridLines="None"
                            AllowPaging="true" PageSize="5"
                            OnPageIndexChanging="gvAvailableBooks_PageIndexChanging"
                            OnRowCommand="gvAvailableBooks_RowCommand">
                            <Columns>
                                <asp:TemplateField HeaderText="">
                                    <ItemTemplate>
                                        <div class="book-cover"><i class="fas fa-book"></i></div>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:BoundField DataField="Title"    HeaderText="Title"    />
                                <asp:BoundField DataField="Author"   HeaderText="Author"   />
                                <asp:BoundField DataField="Category" HeaderText="Category" />

                                <asp:TemplateField HeaderText="Copies Available">
                                    <ItemTemplate>
                                        <span class='badge <%# Convert.ToInt32(Eval("AvailableCopies")) > 0 ? "bg-success" : "bg-danger" %>'>
                                            <%# Eval("AvailableCopies") %> available
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <%-- No OnClientClick — confirm() breaks GridView RowCommand in WebForms --%>
                                        <asp:Button ID="btnBorrow" runat="server"
                                            Text="Request Borrow"
                                            CssClass="btn btn-success borrow-btn btn-sm"
                                            CommandName="BorrowBook"
                                            CommandArgument='<%# Eval("ISBN") %>'
                                            Enabled='<%# Convert.ToInt32(Eval("AvailableCopies")) > 0 %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center p-4">
                                    <i class="fas fa-search fa-3x text-muted mb-3"></i>
                                    <p class="text-muted mb-0">No available books match your search.</p>
                                </div>
                            </EmptyDataTemplate>
                            <PagerStyle CssClass="pagination" />
                        </asp:GridView>
                        <div class="pagination-bar" id="customPagerBooks"></div>

                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Change Password Modal -->
    <div class="modal fade" id="changePasswordModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-key me-2"></i>Change Password</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Current Password</label>
                        <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password"
                            CssClass="form-control" placeholder="Enter current password" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">New Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password"
                            CssClass="form-control" placeholder="Minimum 6 characters" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Confirm New Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                            CssClass="form-control" placeholder="Re-enter new password" />
                    </div>
                    <div id="passwordError" class="alert alert-danger" style="display:none;" runat="server">
                        <asp:Label ID="lblPasswordError" runat="server"></asp:Label>
                    </div>
                    <div id="passwordSuccess" class="alert alert-success" style="display:none;" runat="server">
                        <asp:Label ID="lblPasswordSuccess" runat="server"></asp:Label>
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

</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    window.addEventListener('DOMContentLoaded', function () {
        var builtInPager = document.querySelector('tr.pagination td');
        var customPager = document.getElementById('customPagerBooks');
        if (builtInPager && customPager) {
            customPager.innerHTML = builtInPager.innerHTML;
        }
    });
</script>
</body>
</html>
