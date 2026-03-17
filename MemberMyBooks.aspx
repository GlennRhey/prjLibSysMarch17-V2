<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MemberMyBooks.aspx.cs" Inherits="prjLibrarySystem.MemberMyBooks" EnableEventValidation="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My Books - Library System</title>
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
        .return-btn {
            background: #ffc107;
            color: #212529;
            border: none;
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
        }
        .btn-icon-eye {
            width: 32px;
            height: 32px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0;
            border-radius: 6px;
        }
        .btn-icon-eye::before {
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            content: "\f06e";
            font-size: 14px;
        }
        .return-btn:hover {
            background: #e0a800;
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
                            <div class="library-icon">
                                <i class="fas fa-book-open"></i>
                            </div>
                            <h4 class="text-white">Member Portal</h4>
                    </div>
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link" href="MemberDashboard.aspx">
                                    <i class="fas fa-tachometer-alt me-2"></i> Dashboard
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="MemberBorrowBooks.aspx">
                                    <i class="fas fa-book me-2"></i> Borrow Books
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link active" href="MemberMyBooks.aspx">
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
                        <h1 class="h2">My Borrowed Books</h1>
                        <div class="btn-toolbar mb-2 mb-md-0">
                            <div class="btn-group me-2">
                                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" 
                                    CssClass="btn btn-outline-secondary" OnClick="btnRefresh_Click" />
                            </div>
                        </div>
                    </div>

                    <!-- Status feedback panel -->
                    <asp:Panel ID="pnlStatus" runat="server" Visible="false" CssClass="alert alert-dismissible fade show">
                        <asp:Label ID="lblStatusMessage" runat="server"></asp:Label>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </asp:Panel>

                    <!-- My Books Section -->
                    <div class="card shadow mb-4">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">My Borrowed Books</h6>
                        </div>
                        <div class="card-body">
                            <asp:GridView ID="gvMyBooks" runat="server" CssClass="table table-hover" 
                                AutoGenerateColumns="false" GridLines="None" AllowPaging="true" 
                                PageSize="10" OnPageIndexChanging="gvMyBooks_PageIndexChanging"
                                OnRowCommand="gvMyBooks_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="Title" HeaderText="Book Title" />
                                    <asp:BoundField DataField="Author" HeaderText="Author" />
                                    <asp:BoundField DataField="BorrowDate" HeaderText="Borrow Date" DataFormatString="{0:MM/dd/yyyy}" />
                                    <asp:BoundField DataField="DueDate" HeaderText="Due Date" DataFormatString="{0:MM/dd/yyyy}" />
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <span class='badge <%# GetStatusBadgeClass(Eval("DisplayStatus")) %>'>
                                                <%# GetBookStatus(Eval("DisplayStatus")) %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Action">
                                        <ItemTemplate>
                                            <asp:Button ID="btnReturn" runat="server" Text="Request Return"
                                                CssClass="btn return-btn btn-sm"
                                                CommandName="ReturnBook"
                                                CommandArgument='<%# Eval("BorrowID") %>'
                                                CausesValidation="false"
                                                Visible='<%# Eval("DisplayStatus").ToString() == "Active" || Eval("DisplayStatus").ToString() == "Overdue" %>' />
                                            <asp:LinkButton ID="btnViewDetail" runat="server"
                                                CommandName="ViewDetail"
                                                CommandArgument='<%# Eval("BorrowID") %>'
                                                CssClass="btn btn-sm btn-info ms-1"
                                                CausesValidation="false"
                                                ToolTip="View Details">
                                                <i class="fas fa-eye"></i>
                                            </asp:LinkButton>
                                            <span class="text-muted small">
                                                <%# (Eval("DisplayStatus").ToString() == "Return Pending"    ? "Awaiting approval"        :
                                                     Eval("DisplayStatus").ToString() == "Pending Approval"  ? "Awaiting borrow approval"  : "") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </main>
            </div>
        </div>

        <!-- Book Details Modal -->
        <div class="modal fade" id="bookDetailModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header" style="background: linear-gradient(135deg, #8b0000, #b11226); color: white;">
                        <h5 class="modal-title">
                            <i class="fas fa-info-circle me-2"></i>Borrow Details
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row g-3">
                            <!-- Book Info -->
                            <div class="col-12">
                                <h6 class="text-muted text-uppercase fw-bold" style="font-size:0.75rem; letter-spacing:1px;">
                                    <i class="fas fa-book me-1"></i> Book Information
                                </h6>
                                <hr class="mt-1 mb-2" />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label text-muted small mb-0">Title</label>
                                <div class="fw-semibold" id="sdtlTitle"></div>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label text-muted small mb-0">Author</label>
                                <div class="fw-semibold" id="sdtlAuthor"></div>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label text-muted small mb-0">ISBN</label>
                                <div class="fw-semibold" id="sdtlISBN"></div>
                            </div>

                            <!-- Transaction Info -->
                            <div class="col-12 mt-2">
                                <h6 class="text-muted text-uppercase fw-bold" style="font-size:0.75rem; letter-spacing:1px;">
                                    <i class="fas fa-exchange-alt me-1"></i> Transaction Information
                                </h6>
                                <hr class="mt-1 mb-2" />
                            </div>
                            <div class="col-md-3">
                                <label class="form-label text-muted small mb-0">Status</label>
                                <div id="sdtlStatus"></div>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label text-muted small mb-0">Borrow Date</label>
                                <div class="fw-semibold" id="sdtlBorrowDate"></div>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label text-muted small mb-0">Due Date</label>
                                <div class="fw-semibold" id="sdtlDueDate"></div>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label text-muted small mb-0">Return Date</label>
                                <div class="fw-semibold" id="sdtlReturnDate"></div>
                            </div>

                            <!-- Admin Info -->
                            <div class="col-12 mt-2">
                                <h6 class="text-muted text-uppercase fw-bold" style="font-size:0.75rem; letter-spacing:1px;">
                                    <i class="fas fa-user-shield me-1"></i> Handled By
                                </h6>
                                <hr class="mt-1 mb-2" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label text-muted small mb-0">Admin ID</label>
                                <div class="fw-semibold" id="sdtlAdminID"></div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label text-muted small mb-0">Admin Name</label>
                                <div class="fw-semibold" id="sdtlAdminName"></div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label text-muted small mb-0">Admin Email</label>
                                <div class="fw-semibold" id="sdtlAdminEmail"></div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
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

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            function showBookDetailModal(data) {
                var statusColors = {
                    'Active': 'bg-success',
                    'Overdue': 'bg-danger',
                    'Returned': 'bg-secondary',
                    'Pending Approval': 'bg-warning text-dark',
                    'Return Pending': 'bg-info text-dark',
                    'Cancelled': 'bg-dark'
                };
                document.getElementById('sdtlTitle').innerText = data.title;
                document.getElementById('sdtlAuthor').innerText = data.author;
                document.getElementById('sdtlISBN').innerText = data.isbn;
                document.getElementById('sdtlBorrowDate').innerText = data.borrowDate;
                document.getElementById('sdtlDueDate').innerText = data.dueDate;
                document.getElementById('sdtlReturnDate').innerText = data.returnDate || '';
                document.getElementById('sdtlAdminID').innerText = data.adminID || '';
                document.getElementById('sdtlAdminName').innerText = data.adminName || '';
                document.getElementById('sdtlAdminEmail').innerText = data.adminEmail || '';

                var stEl = document.getElementById('sdtlStatus');
                stEl.innerHTML = '<span class="badge ' + (statusColors[data.displayStatus] || 'bg-secondary') + '">' + data.displayStatus + '</span>';

                new bootstrap.Modal(document.getElementById('bookDetailModal')).show();
            }
        </script>
    </form>
</body>
</html>
