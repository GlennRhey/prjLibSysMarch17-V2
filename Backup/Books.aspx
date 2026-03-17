<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Books.aspx.cs" Inherits="prjLibrarySystem.Books" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Book Management - Library System</title>
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
        .main-content { padding: 20px; }
        .action-buttons .btn { margin-right: 5px; }
        .card-body {
            height: 436px;
            padding: 0;
            position: relative;
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
        .table th:nth-child(1), .table td:nth-child(1) { width: 130px; }
        .table th:nth-child(2), .table td:nth-child(2) { width: 22%; }
        .table th:nth-child(3), .table td:nth-child(3) { width: 15%; }
        .table th:nth-child(4), .table td:nth-child(4) { width: 14%; }
        .table th:nth-child(5), .table td:nth-child(5) { width: 100px; }
        .table th:nth-child(6), .table td:nth-child(6) { width: 90px; }
        .table th:nth-child(7), .table td:nth-child(7) { width: 100px; }
        .table th:nth-child(8), .table td:nth-child(8) { width: 120px; }
        tr.pagination { display: none !important; }
        .pagination-bar {
            position: absolute;
            bottom: 0; left: 0; right: 0;
            height: 54px;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            padding: 0 12px;
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
        .modal-dialog {
            position: fixed;
            top: 15vh;
            left: 50%;
            transform: translateX(-50%);
            margin: 0;
            max-width: 90vw;
            width: 800px;
        }
        .modal.show .modal-dialog {
            transform: translateX(-50%) !important;
        }
        .modal input[type="text"], .modal input[type="number"] {
            pointer-events: auto !important;
            user-select: text !important;
            -webkit-user-select: text !important;
            -moz-user-select: text !important;
            -ms-user-select: text !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="container-fluid">
            <div class="row">
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
                                <a class="nav-link active" href="Books.aspx">
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
                                <a class="nav-link" href="reports.aspx">
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

                <main class="col-12 col-md-9 col-lg-10 px-md-4 main-content">
                    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                        <h1 class="h2">Book Management</h1>
                        <div class="btn-toolbar mb-2 mb-md-0">
                            <div class="btn-group me-2">
                                <asp:Button ID="btnAddBook" runat="server" Text="Add New Book"
                                    CssClass="btn btn-primary" OnClientClick="showBookModal(); return false;"
                                    CausesValidation="false" />
                            </div>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="input-group">
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control"
                                    placeholder="Search by title, author, or ISBN..."></asp:TextBox>
                                <asp:Button ID="btnSearch" runat="server" Text="Search"
                                    CssClass="btn btn-outline-secondary" OnClick="btnSearch_Click"
                                    CausesValidation="false" />
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
                        <div class="col-md-3">
                            <asp:DropDownList ID="ddlAvailability" runat="server" CssClass="form-select"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlAvailability_SelectedIndexChanged">
                                <asp:ListItem Value="">All Books</asp:ListItem>
                                <asp:ListItem Value="Available">Available</asp:ListItem>
                                <asp:ListItem Value="Borrowed">Borrowed</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="card shadow">
                        <div class="card-header py-3">
                            <h6 class="m-0 font-weight-bold text-primary">Books Inventory</h6>
                        </div>
                        <div class="card-body">
                            <asp:GridView ID="gvBooks" runat="server" CssClass="table table-hover"
                                AutoGenerateColumns="false" GridLines="None" AllowPaging="true"
                                PageSize="5" OnPageIndexChanging="gvBooks_PageIndexChanging"
                                OnRowCommand="gvBooks_RowCommand" DataKeyNames="ISBN">
                                <PagerStyle CssClass="pagination" HorizontalAlign="Left" />
                                <PagerSettings Mode="NumericFirstLast" Position="Bottom" PageButtonCount="5" FirstPageText="&laquo;" LastPageText="&raquo;" />
                                <Columns>
                                    <asp:BoundField DataField="ISBN" HeaderText="ISBN" />
                                    <asp:BoundField DataField="Title" HeaderText="Title" />
                                    <asp:BoundField DataField="Author" HeaderText="Author" />
                                    <asp:BoundField DataField="Category" HeaderText="Category" />
                                    <asp:BoundField DataField="TotalCopies" HeaderText="Total Copies" />
                                    <asp:BoundField DataField="AvailableCopies" HeaderText="Available" />
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <span class='badge <%# Eval("AvailableCopies").ToString() == "0" ? "bg-danger" : "bg-success" %>'>
                                                <%# Eval("AvailableCopies").ToString() == "0" ? "Out of Stock" : "Available" %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <div class="action-buttons">
                                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditBook"
                                                    CommandArgument='<%# Eval("ISBN") %>' CssClass="btn btn-sm btn-warning"
                                                    CausesValidation="false" data-isbn='<%# Eval("ISBN") %>'
                                                    OnClientClick="return editBook(this);">
                                                    <i class="fas fa-edit"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteBook"
                                                    CommandArgument='<%# Eval("ISBN") %>' CssClass="btn btn-sm btn-danger"
                                                    CausesValidation="false"
                                                    OnClientClick="return confirm('Are you sure you want to delete this book?');">
                                                    <i class="fas fa-trash"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnDetails" runat="server" CommandName="ViewDetails"
                                                    CommandArgument='<%# Eval("ISBN") %>' CssClass="btn btn-sm btn-info"
                                                    CausesValidation="false" data-isbn='<%# Eval("ISBN") %>'
                                                    OnClientClick="return viewBook(this);">
                                                    <i class="fas fa-eye"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <PagerStyle CssClass="pagination" />
                            </asp:GridView>

                            <div class="pagination-bar" id="customPager"></div>
                        </div>
                    </div>
                </main>
            </div>
        </div>

        <div class="modal fade" id="bookModal" tabindex="-1" aria-labelledby="bookModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="bookModalLabel">
                            <asp:Label ID="lblModalTitle" runat="server" Text="Add New Book"></asp:Label>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">ISBN *</label>
                                <asp:TextBox ID="txtISBN" runat="server" CssClass="form-control" placeholder="Enter ISBN"></asp:TextBox>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Title *</label>
                                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="Enter book title"></asp:TextBox>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Author *</label>
                                <asp:TextBox ID="txtAuthor" runat="server" CssClass="form-control" placeholder="Enter author name"></asp:TextBox>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Category *</label>
                                <asp:DropDownList ID="ddlBookCategory" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="">Select Category</asp:ListItem>
                                    <asp:ListItem Value="Programming">Programming</asp:ListItem>
                                    <asp:ListItem Value="Artificial Intelligence">Artificial Intelligence</asp:ListItem>
                                    <asp:ListItem Value="Data Communications">Data Communications</asp:ListItem>
                                    <asp:ListItem Value="Literature">Literature</asp:ListItem>
                                    <asp:ListItem Value="Business">Business</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Total Copies *</label>
                                <asp:TextBox ID="txtTotalCopies" runat="server" CssClass="form-control"
                                    TextMode="Number" min="1" placeholder="Enter total copies"></asp:TextBox>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Available Copies *</label>
                                <asp:TextBox ID="txtAvailableCopies" runat="server" CssClass="form-control"
                                    TextMode="Number" min="0" placeholder="Enter available copies"></asp:TextBox>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12 mb-3">
                                <label class="form-label">Description</label>
                                <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                                    TextMode="MultiLine" Rows="3" placeholder="Enter book description (optional)"></asp:TextBox>
                            </div>
                        </div>
                        <asp:HiddenField ID="hfBookId" runat="server" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnSaveBook" runat="server" Text="Save Book"
                            CssClass="btn btn-primary" OnClick="btnSaveBook_Click" />
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="viewBookModal" tabindex="-1" aria-labelledby="viewBookModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="viewBookModalLabel">Book Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">ISBN</label>
                                <p id="viewISBN" class="form-control-plaintext"></p>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Title</label>
                                <p id="viewTitle" class="form-control-plaintext"></p>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Author</label>
                                <p id="viewAuthor" class="form-control-plaintext"></p>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Category</label>
                                <p id="viewCategory" class="form-control-plaintext"></p>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Total Copies</label>
                                <p id="viewTotalCopies" class="form-control-plaintext"></p>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-bold">Available Copies</label>
                                <p id="viewAvailableCopies" class="form-control-plaintext"></p>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12 mb-3">
                                <label class="form-label fw-bold">Description</label>
                                <p id="viewDescription" class="form-control-plaintext"></p>
                            </div>
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
    <script>
        window.addEventListener('DOMContentLoaded', function () {
            var builtInPager = document.querySelector('tr.pagination td');
            var customPager = document.getElementById('customPager');
            if (builtInPager && customPager) {
                customPager.innerHTML = builtInPager.innerHTML;
            }
        });

        function showBookModal() {
            var isbnField = document.getElementById('<%= txtISBN.ClientID %>');
            isbnField.value = '';
            isbnField.disabled = false;
            isbnField.readOnly = false;
            document.getElementById('<%= txtTitle.ClientID %>').value = '';
            document.getElementById('<%= txtAuthor.ClientID %>').value = '';
            document.getElementById('<%= ddlBookCategory.ClientID %>').selectedIndex = 0;
            document.getElementById('<%= txtTotalCopies.ClientID %>').value = '';
            document.getElementById('<%= txtAvailableCopies.ClientID %>').value = '';
            document.getElementById('<%= txtDescription.ClientID %>').value = '';
            document.getElementById('<%= hfBookId.ClientID %>').value = '';
            document.getElementById('<%= lblModalTitle.ClientID %>').innerText = 'Add New Book';
            var modalElement = document.getElementById('bookModal');
            var modal = new bootstrap.Modal(modalElement);
            modal.show();
        }

        function hideBookModal() {
            var modalElement = document.getElementById('bookModal');
            var modal = bootstrap.Modal.getInstance(modalElement);
            if (modal) modal.hide();
        }

        function showViewBookModal() {
            var modalElement = document.getElementById('viewBookModal');
            var modal = new bootstrap.Modal(modalElement);
            modal.show();
        }

        function hideViewBookModal() {
            var modalElement = document.getElementById('viewBookModal');
            var modal = bootstrap.Modal.getInstance(modalElement);
            if (modal) modal.hide();
        }

        function editBook(button) {
            var isbn = button.getAttribute('data-isbn');
            fetch('Books.aspx/GetBookData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ isbn: isbn })
            })
            .then(response => response.json())
            .then(data => {
                var book = data.d;
                if (book) {
                    document.getElementById('<%= txtISBN.ClientID %>').value = book.ISBN;
                    document.getElementById('<%= txtISBN.ClientID %>').disabled = true;
                    document.getElementById('<%= txtTitle.ClientID %>').value = book.Title;
                    document.getElementById('<%= txtAuthor.ClientID %>').value = book.Author;
                    document.getElementById('<%= ddlBookCategory.ClientID %>').value = book.Category;
                    document.getElementById('<%= txtTotalCopies.ClientID %>').value = book.TotalCopies;
                    document.getElementById('<%= txtAvailableCopies.ClientID %>').value = book.AvailableCopies;
                    document.getElementById('<%= txtDescription.ClientID %>').value = book.Description || '';
                    document.getElementById('<%= hfBookId.ClientID %>').value = book.ISBN;
                    document.getElementById('<%= lblModalTitle.ClientID %>').innerText = 'Edit Book';
                    showBookModal();
                }
            })
                .catch(error => {
                    console.error('Error loading book data:', error);
                    alert('Error loading book data');
                });
            return false;
        }

        function viewBook(button) {
            var isbn = button.getAttribute('data-isbn');
            fetch('Books.aspx/GetBookData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ isbn: isbn })
            })
                .then(response => response.json())
                .then(data => {
                    var book = data.d;
                    if (book) {
                        document.getElementById('viewISBN').innerText = book.ISBN;
                        document.getElementById('viewTitle').innerText = book.Title;
                        document.getElementById('viewAuthor').innerText = book.Author;
                        document.getElementById('viewCategory').innerText = book.Category;
                        document.getElementById('viewTotalCopies').innerText = book.TotalCopies;
                        document.getElementById('viewAvailableCopies').innerText = book.AvailableCopies;
                        document.getElementById('viewDescription').innerText = book.Description || 'No description available';
                        showViewBookModal();
                    }
                })
                .catch(error => {
                    console.error('Error loading book data:', error);
                    alert('Error loading book data');
                });
            return false;
        }
    </script>
</body>
</html>