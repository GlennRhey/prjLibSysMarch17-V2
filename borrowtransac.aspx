<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="borrowtransac.aspx.cs" Inherits="prjLibrarySystem.Loans" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Borrowing Transaction - Library System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css?v=2.0" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css?v=2.0" rel="stylesheet">
    <style>
        .main-content { padding: 20px; }
        .action-buttons .btn { margin-right: 5px; }
        .card-body { padding: 0; }
        .table { table-layout: fixed; width: 100%; margin-bottom: 0; }
        .table th, .table td { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; vertical-align: middle; padding-left: 12px; }
        .table th { height: 52px; } .table td { height: 66px; }
        .table th:nth-child(1),  .table td:nth-child(1)  { width: 100px; }
        .table th:nth-child(2),  .table td:nth-child(2)  { width: 20%; }
        .table th:nth-child(3),  .table td:nth-child(3)  { width: 100px; }
        .table th:nth-child(4),  .table td:nth-child(4)  { width: 15%; }
        .table th:nth-child(5),  .table td:nth-child(5)  { width: 100px; }
        .table th:nth-child(6),  .table td:nth-child(6)  { width: 100px; }
        .table th:nth-child(7),  .table td:nth-child(7)  { width: 100px; }
        .table th:nth-child(8),  .table td:nth-child(8)  { width: 100px; }
        .table th:nth-child(9),  .table td:nth-child(9)  { width: 100px; }
        .table th:nth-child(10), .table td:nth-child(10) { width: 120px; }
        tr.pagination { display: none !important; }
        .pagination-bar { display: flex; align-items: center; justify-content: flex-start; padding: 0 12px; height: 54px; border-top: 1px solid #f0f0f0; background: #fff; border-radius: 0 0 4px 4px; }
        .pagination-bar a, .pagination-bar span { color: #555; display: inline-block; padding: 6px 12px; text-decoration: none !important; border: 1px solid #ddd; margin: 0 2px; border-radius: 6px; font-weight: 500; font-size: 13px; transition: all .25s ease; }
        .pagination-bar a:hover { border-color: #8b0000 !important; color: #8b0000 !important; transform: translateY(-2px); background-color: transparent !important; }
        .pagination-bar span { background-color: #8b0000; color: white !important; border-color: #8b0000; cursor: default; }
        .pagination-bar a.disabled-link { color: #aaa !important; background-color: #f5f5f5 !important; border-color: #ddd !important; pointer-events: none; }
        .btn-icon-eye { width: 32px; height: 32px; padding: 0; display: inline-flex; align-items: center; justify-content: center; font-size: 0; border-radius: 6px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="container-fluid">
            <div class="row">

                <%-- Dynamic sidebar — set by code-behind based on session role --%>
                <asp:Literal ID="litSidebar" runat="server"></asp:Literal>

                <main class="col-12 col-md-9 col-lg-10 px-md-4 main-content">
                    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                        <h1 class="h2">Borrow Transaction</h1>
                    </div>

                    <div class="row mb-3 g-2 align-items-center">
                        <div class="col-md-4">
                            <div class="input-group">
                                <asp:TextBox ID="txtSearchLoan" runat="server" CssClass="form-control"
                                    placeholder="Search title, member, or Borrow ID..."></asp:TextBox>
                                <asp:Button ID="btnSearchLoan" runat="server" Text="Search"
                                    CssClass="btn btn-outline-secondary" OnClick="btnSearchLoan_Click" UseSubmitBehavior="false" />
                            </div>
                        </div>
                        <div class="col-md-2">
                            <asp:DropDownList ID="ddlLoanStatus" runat="server" CssClass="form-select"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlLoanStatus_SelectedIndexChanged">
                                <asp:ListItem Value="">All Status</asp:ListItem>
                                <asp:ListItem Value="Active">Active</asp:ListItem>
                                <asp:ListItem Value="Overdue">Overdue</asp:ListItem>
                                <asp:ListItem Value="Returned">Returned</asp:ListItem>
                                <asp:ListItem Value="Cancelled">Cancelled</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <asp:DropDownList ID="ddlTransactionType" runat="server" CssClass="form-select"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlTransactionType_SelectedIndexChanged">
                                <asp:ListItem Value="">All Transactions</asp:ListItem>
                                <asp:ListItem Value="PendingBorrow">Pending Borrow Requests</asp:ListItem>
                                <asp:ListItem Value="PendingReturn">Pending Return Requests</asp:ListItem>
                                <asp:ListItem Value="Borrow">All Borrow Records</asp:ListItem>
                                <asp:ListItem Value="Return">All Return Records</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <asp:DropDownList ID="ddlDateRange" runat="server" CssClass="form-select"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlDateRange_SelectedIndexChanged">
                                <asp:ListItem Value="">All Time</asp:ListItem>
                                <asp:ListItem Value="Today">Today</asp:ListItem>
                                <asp:ListItem Value="ThisWeek">This Week</asp:ListItem>
                                <asp:ListItem Value="ThisMonth">This Month</asp:ListItem>
                                <asp:ListItem Value="ThisYear">This Year</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>



                    <div class="card shadow">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">Transaction Records</h6>
                        </div>
                        <div class="card-body">
                            <asp:GridView ID="gvLoans" runat="server" CssClass="table table-hover"
                                AutoGenerateColumns="false" GridLines="None" AllowPaging="true"
                                PageSize="10" OnPageIndexChanging="gvLoans_PageIndexChanging"
                                OnRowCommand="gvLoans_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="BorrowID"      HeaderText="Borrow ID" />
                                    <asp:BoundField DataField="BookTitle"     HeaderText="Book Title" />
                                    <asp:BoundField DataField="StudentID"     HeaderText="Student ID" />
                                    <asp:BoundField DataField="StudentName"   HeaderText="Student" />
                                    <asp:BoundField DataField="RequestType"   HeaderText="Request Type" />
                                    <asp:BoundField DataField="RequestStatus" HeaderText="Request Status" />
                                    <asp:BoundField DataField="BorrowDate"    HeaderText="Borrow Date"  DataFormatString="{0:MM/dd/yyyy}" />
                                    <asp:BoundField DataField="DueDate"       HeaderText="Due Date"     DataFormatString="{0:MM/dd/yyyy}" />
                                    <asp:BoundField DataField="ReturnDate"    HeaderText="Return Date"  DataFormatString="{0:MM/dd/yyyy}" />
                                    <asp:BoundField DataField="DisplayStatus"    HeaderText="Status" />
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <div class="action-buttons">
                                                <asp:LinkButton ID="btnAccept" runat="server" CommandName="AcceptRequest"
                                                    CommandArgument='<%# Eval("BorrowID") %>' CssClass="btn btn-sm btn-success"
                                                    CausesValidation="false"
                                                    Visible='<%# Eval("RequestStatus").ToString() == "Pending" %>'>
                                                    <i class="fas fa-check"></i> Accept
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnReject" runat="server" CommandName="RejectRequest"
                                                    CommandArgument='<%# Eval("BorrowID") %>' CssClass="btn btn-sm btn-danger"
                                                    CausesValidation="false"
                                                    Visible='<%# Eval("RequestStatus").ToString() == "Pending" %>'>
                                                    <i class="fas fa-times"></i> Reject
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnRenew" runat="server" CommandName="RenewLoan"
                                                    CommandArgument='<%# Eval("BorrowID") %>' CssClass="btn btn-sm btn-warning"
                                                    CausesValidation="false"
                                                    Visible='<%# !Convert.ToBoolean(Eval("IsReturned")) && Eval("RequestStatus").ToString() != "Rejected" %>'>
                                                    <i class="fas fa-clock"></i> Renew
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnDetails" runat="server" CommandName="ViewDetails"
                                                    CommandArgument='<%# Eval("BorrowID") %>' CssClass="btn btn-sm btn-info"
                                                    CausesValidation="false" ToolTip="View Details">
                                                    <i class="fas fa-eye"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="text-center p-4">
                                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                        <p class="text-muted">No transactions found.</p>
                                    </div>
                                </EmptyDataTemplate>
                                <PagerStyle CssClass="pagination" />
                            </asp:GridView>
                            <div class="pagination-bar" id="customPagerLoans"></div>
                        </div>
                    </div>
                </main>
            </div>
        </div>

        <%-- New Loan Modal --%>
        <div class="modal fade" id="loanModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">New Loan</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Select Member</label>
                                <asp:DropDownList ID="ddlMember" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="">-- Select Member --</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Select Book</label>
                                <asp:DropDownList ID="ddlBook" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="">-- Select Book --</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Loan Date</label>
                                <asp:TextBox ID="txtLoanDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Due Date</label>
                                <asp:TextBox ID="txtDueDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12 mb-3">
                                <label class="form-label">Notes</label>
                                <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnSaveLoan" runat="server" Text="Create Loan" CssClass="btn btn-primary" OnClick="btnSaveLoan_Click" />
                    </div>
                </div>
            </div>
        </div>

        <%-- Return Book Modal --%>
        <div class="modal fade" id="returnModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Return Book</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Return Date</label>
                            <asp:TextBox ID="txtReturnDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Fine Amount (if any)</label>
                            <asp:TextBox ID="txtFineAmount" runat="server" CssClass="form-control" TextMode="Number" step="0.01" min="0"></asp:TextBox>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Return Notes</label>
                            <asp:TextBox ID="txtReturnNotes" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
                        </div>
                        <asp:HiddenField ID="hfLoanId" runat="server" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnProcessReturn" runat="server" Text="Process Return" CssClass="btn btn-success" OnClick="btnProcessReturn_Click" />
                    </div>
                </div>
            </div>
        </div>

        <%-- Transaction Details Modal --%>
        <div class="modal fade" id="detailsModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header" style="background:linear-gradient(135deg,#8b0000,#b11226);color:white;">
                        <h5 class="modal-title"><i class="fas fa-info-circle me-2"></i>Transaction Details</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-12"><h6 class="text-muted text-uppercase fw-bold" style="font-size:.75rem;letter-spacing:1px;"><i class="fas fa-book me-1"></i> Book Information</h6><hr class="mt-1 mb-2"/></div>
                            <div class="col-md-6"><label class="form-label text-muted small mb-0">Title</label><div class="fw-semibold" id="dtlBookTitle"></div></div>
                            <div class="col-md-3"><label class="form-label text-muted small mb-0">ISBN</label><div class="fw-semibold" id="dtlISBN"></div></div>
                            <div class="col-md-3"><label class="form-label text-muted small mb-0">Author</label><div class="fw-semibold" id="dtlAuthor"></div></div>
                            <div class="col-12 mt-2"><h6 class="text-muted text-uppercase fw-bold" style="font-size:.75rem;letter-spacing:1px;"><i class="fas fa-user-graduate me-1"></i> Student Information</h6><hr class="mt-1 mb-2"/></div>
                            <div class="col-md-4"><label class="form-label text-muted small mb-0">Student ID</label><div class="fw-semibold" id="dtlStudentID"></div></div>
                            <div class="col-md-4"><label class="form-label text-muted small mb-0">Full Name</label><div class="fw-semibold" id="dtlStudentName"></div></div>
                            <div class="col-md-4"><label class="form-label text-muted small mb-0">Course / Year</label><div class="fw-semibold" id="dtlCourse"></div></div>
                            <div class="col-12 mt-2"><h6 class="text-muted text-uppercase fw-bold" style="font-size:.75rem;letter-spacing:1px;"><i class="fas fa-exchange-alt me-1"></i> Transaction Information</h6><hr class="mt-1 mb-2"/></div>
                            <div class="col-md-3"><label class="form-label text-muted small mb-0">Borrow ID</label><div class="fw-semibold" id="dtlBorrowID"></div></div>
                            <div class="col-md-3"><label class="form-label text-muted small mb-0">Request Type</label><div id="dtlRequestType"></div></div>
                            <div class="col-md-3"><label class="form-label text-muted small mb-0">Request Status</label><div id="dtlRequestStatus"></div></div>
                            <div class="col-md-3"><label class="form-label text-muted small mb-0">Status</label><div id="dtlStatus"></div></div>
                            <div class="col-md-4"><label class="form-label text-muted small mb-0">Borrow Date</label><div class="fw-semibold" id="dtlBorrowDate"></div></div>
                            <div class="col-md-4"><label class="form-label text-muted small mb-0">Due Date</label><div class="fw-semibold" id="dtlDueDate"></div></div>
                            <div class="col-md-4"><label class="form-label text-muted small mb-0">Return Date</label><div class="fw-semibold" id="dtlReturnDate"></div></div>
                            <div class="col-12 mt-2"><h6 class="text-muted text-uppercase fw-bold" style="font-size:.75rem;letter-spacing:1px;"><i class="fas fa-user-shield me-1"></i> Handled By</h6><hr class="mt-1 mb-2"/></div>
                            <div class="col-md-4"><label class="form-label text-muted small mb-0">Admin ID</label><div class="fw-semibold" id="dtlAdminID"></div></div>
                            <div class="col-md-4"><label class="form-label text-muted small mb-0">Admin Name</label><div class="fw-semibold" id="dtlAdminName"></div></div>
                            <div class="col-md-4"><label class="form-label text-muted small mb-0">Admin Email</label><div class="fw-semibold" id="dtlAdminEmail"></div></div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            window.addEventListener('DOMContentLoaded', function () {
                var builtInPager = document.querySelector('tr.pagination td');
                var customPager = document.getElementById('customPagerLoans');
                if (builtInPager && customPager) customPager.innerHTML = builtInPager.innerHTML;
            });
            function showLoanModal() { new bootstrap.Modal(document.getElementById('loanModal')).show(); }
            function hideLoanModal() { var m = bootstrap.Modal.getInstance(document.getElementById('loanModal')); if (m) m.hide(); }
            function showReturnModal() { new bootstrap.Modal(document.getElementById('returnModal')).show(); }
            function hideReturnModal() { var m = bootstrap.Modal.getInstance(document.getElementById('returnModal')); if (m) m.hide(); }
            function showDetailsModal(data) {
                var statusColors = { 'Active': 'bg-success', 'Overdue': 'bg-danger', 'Returned': 'bg-secondary', 'Cancelled': 'bg-dark' };
                var reqStatusColors = { 'Pending': 'bg-warning text-dark', 'Accepted': 'bg-success', 'Rejected': 'bg-danger' };
                document.getElementById('dtlBorrowID').innerText = data.borrowID;
                document.getElementById('dtlBookTitle').innerText = data.bookTitle;
                document.getElementById('dtlISBN').innerText = data.isbn;
                document.getElementById('dtlAuthor').innerText = data.author;
                document.getElementById('dtlStudentID').innerText = data.studentID;
                document.getElementById('dtlStudentName').innerText = data.studentName;
                document.getElementById('dtlCourse').innerText = data.course;
                document.getElementById('dtlBorrowDate').innerText = data.borrowDate;
                document.getElementById('dtlDueDate').innerText = data.dueDate;
                document.getElementById('dtlReturnDate').innerText = data.returnDate || '';
                document.getElementById('dtlAdminID').innerText = data.adminID || '';
                document.getElementById('dtlAdminName').innerText = data.adminName || '';
                document.getElementById('dtlAdminEmail').innerText = data.adminEmail || '';
                document.getElementById('dtlRequestType').innerHTML = '<span class="badge bg-primary">' + (data.requestType) + '</span>';
                document.getElementById('dtlRequestStatus').innerHTML = '<span class="badge ' + (reqStatusColors[data.requestStatus] || 'bg-secondary') + '">' + (data.requestStatus) + '</span>';
                document.getElementById('dtlStatus').innerHTML = '<span class="badge ' + (statusColors[data.status] || 'bg-secondary') + '">' + (data.status) + '</span>';
                new bootstrap.Modal(document.getElementById('detailsModal')).show();
            }
        </script>
    </form>
</body>
</html>
