<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Books.aspx.cs" Inherits="prjLibrarySystem.Books" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Book Management - Library System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css?v=2.0" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css?v=2.0" rel="stylesheet">
    <style>
        .main-content { padding:20px; }
        .action-buttons .btn { margin-right:5px; }
        .card-body { height:436px; padding:0; position:relative; }
        .table { table-layout:fixed; width:100%; margin-bottom:0; }
        .table th,.table td { overflow:hidden; text-overflow:ellipsis; white-space:nowrap; vertical-align:middle; padding-left:12px; }
        .table th { height:52px; } .table td { height:66px; }
        .table th:nth-child(1),.table td:nth-child(1){width:130px;}
        .table th:nth-child(2),.table td:nth-child(2){width:22%;}
        .table th:nth-child(3),.table td:nth-child(3){width:15%;}
        .table th:nth-child(4),.table td:nth-child(4){width:14%;}
        .table th:nth-child(5),.table td:nth-child(5){width:100px;}
        .table th:nth-child(6),.table td:nth-child(6){width:90px;}
        .table th:nth-child(7),.table td:nth-child(7){width:100px;}
        .table th:nth-child(8),.table td:nth-child(8){width:120px;}
        tr.pagination{display:none!important;}
        .pagination-bar{position:absolute;bottom:0;left:0;right:0;height:54px;display:flex;align-items:center;justify-content:flex-start;padding:0 12px;border-top:1px solid #f0f0f0;background:#fff;border-radius:0 0 4px 4px;}
        .pagination-bar a,.pagination-bar span{color:#555;display:inline-block;padding:6px 12px;text-decoration:none!important;border:1px solid #ddd;margin:0 2px;border-radius:6px;font-weight:500;font-size:13px;transition:all .25s ease;}
        .pagination-bar a:hover{border-color:#8b0000!important;color:#8b0000!important;transform:translateY(-2px);background-color:transparent!important;}
        .pagination-bar span{background-color:#8b0000;color:white!important;border-color:#8b0000;cursor:default;}
        .pagination-bar a.disabled-link{color:#aaa!important;background-color:#f5f5f5!important;border-color:#ddd!important;pointer-events:none;}
        .modal-dialog{position:fixed;top:15vh;left:50%;transform:translateX(-50%);margin:0;max-width:90vw;width:800px;}
        .modal.show .modal-dialog{transform:translateX(-50%)!important;}
        .modal input[type="text"],.modal input[type="number"]{pointer-events:auto!important;user-select:text!important;}
        .btn-borrow-settings{background:linear-gradient(135deg,#1a237e 0%,#3949ab 100%);border:none;color:white!important;font-weight:500;}
        .btn-borrow-settings:hover{background:linear-gradient(135deg,#283593 0%,#3f51b5 100%);color:white!important;}
        #borrowSettingsModal .modal-dialog{width:540px;}
        #borrowSettingsModal .modal-header{background:linear-gradient(135deg,#1a237e 0%,#283593 100%);color:white;}
        #borrowSettingsModal .modal-header .btn-close{filter:invert(1);}
        .settings-section{background:#f0f4ff;border-radius:10px;padding:16px 18px 12px;margin-bottom:14px;border:1px solid #c5cae9;}
        .settings-section:last-child{margin-bottom:0;}
        .settings-section-title{font-size:.82rem;font-weight:700;text-transform:uppercase;letter-spacing:.07em;margin-bottom:12px;}
        .settings-section-title.student{color:#1565c0;} .settings-section-title.teacher{color:#6a1b9a;}
        .settings-section-title i{margin-right:6px;}
        .settings-input-label{font-size:.83rem;color:#444;margin-bottom:4px;}
        .settings-input-wrap{position:relative;}
        .settings-input-wrap .unit-tag{position:absolute;right:10px;top:50%;transform:translateY(-50%);font-size:.75rem;color:#888;pointer-events:none;}
        .settings-num-input{width:100%;padding:6px 44px 6px 12px;border:1px solid #9fa8da;border-radius:6px;font-size:.95rem;outline:none;transition:border-color .15s,box-shadow .15s;}
        .settings-num-input:focus{border-color:#3949ab;box-shadow:0 0 0 .2rem rgba(57,73,171,.2);}
        #borrowSettingsModal .modal-footer{background:#f0f4ff;border-top:1px solid #c5cae9;}
        .btn-save-settings{background:linear-gradient(135deg,#1a237e 0%,#3949ab 100%);border:none;color:white;padding:8px 24px;border-radius:6px;font-weight:600;}
        .btn-save-settings:hover{background:linear-gradient(135deg,#283593 0%,#3f51b5 100%);color:white;}
        .btn-save-settings:disabled{opacity:.65;cursor:not-allowed;}
        #settingsToast{position:fixed;bottom:28px;right:28px;z-index:9999;min-width:300px;border-radius:10px;box-shadow:0 8px 24px rgba(0,0,0,.18);opacity:0;transform:translateY(16px);transition:opacity .3s ease,transform .3s ease;pointer-events:none;}
        #settingsToast.show{opacity:1;transform:translateY(0);pointer-events:auto;}
        .toast-success{background:#1b5e20;color:white;} .toast-error{background:#b71c1c;color:white;}
        .toast-body-inner{display:flex;align-items:center;padding:14px 18px;}
        .toast-icon{font-size:1.2rem;margin-right:10px;}
        .toast-msg{flex:1;font-size:.92rem;font-weight:500;}
        .toast-close{background:none;border:none;color:rgba(255,255,255,.7);font-size:1.1rem;cursor:pointer;padding:0 0 0 12px;}
        .toast-close:hover{color:white;}
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="container-fluid">
        <div class="row">

            <%-- Dynamic sidebar — rendered by code-behind based on session role --%>
            <asp:Literal ID="litSidebar" runat="server"></asp:Literal>

            <main class="col-12 col-md-9 col-lg-10 px-md-4 main-content">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Book Management</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <div class="btn-group me-2">
                            <asp:Button ID="btnAddBook" runat="server" Text="Add New Book"
                                CssClass="btn btn-primary" OnClientClick="resetBookModal(); return false;" CausesValidation="false" />
                            <asp:Button ID="btnBorrowSettings" runat="server" Text="Borrow Settings"
                                CssClass="btn btn-borrow-settings ms-2"
                                OnClientClick="openBorrowSettings(); return false;" CausesValidation="false" />
                        </div>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="input-group">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search by title, author, or ISBN..."></asp:TextBox>
                            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-outline-secondary" OnClick="btnSearch_Click" CausesValidation="false" />
                        </div>
                    </div>
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                            <asp:ListItem Value="">All Categories</asp:ListItem>
                            <asp:ListItem Value="Programming">Programming</asp:ListItem>
                            <asp:ListItem Value="Artificial Intelligence">Artificial Intelligence</asp:ListItem>
                            <asp:ListItem Value="Data Communications">Data Communications</asp:ListItem>
                            <asp:ListItem Value="Literature">Literature</asp:ListItem>
                            <asp:ListItem Value="Business">Business</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlAvailability" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAvailability_SelectedIndexChanged">
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
                                <asp:BoundField DataField="ISBN"            HeaderText="ISBN" />
                                <asp:BoundField DataField="Title"           HeaderText="Title" />
                                <asp:BoundField DataField="Author"          HeaderText="Author" />
                                <asp:BoundField DataField="Category"        HeaderText="Category" />
                                <asp:BoundField DataField="TotalCopies"     HeaderText="Total Copies" />
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
                                                OnClientClick="return editBook(this);"><i class="fas fa-edit"></i></asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteBook"
                                                CommandArgument='<%# Eval("ISBN") %>' CssClass="btn btn-sm btn-danger"
                                                CausesValidation="false"
                                                OnClientClick="return confirm('Are you sure you want to delete this book?');"><i class="fas fa-trash"></i></asp:LinkButton>
                                            <asp:LinkButton ID="btnDetails" runat="server" CommandName="ViewDetails"
                                                CommandArgument='<%# Eval("ISBN") %>' CssClass="btn btn-sm btn-info"
                                                CausesValidation="false" data-isbn='<%# Eval("ISBN") %>'
                                                OnClientClick="return viewBook(this);"><i class="fas fa-eye"></i></asp:LinkButton>
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

    <%-- Add/Edit Book Modal --%>
    <div class="modal fade" id="bookModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><asp:Label ID="lblModalTitle" runat="server" Text="Add New Book"></asp:Label></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">ISBN *</label><asp:TextBox ID="txtISBN" runat="server" CssClass="form-control" placeholder="Enter ISBN"></asp:TextBox></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Title *</label><asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="Enter book title"></asp:TextBox></div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">Author *</label><asp:TextBox ID="txtAuthor" runat="server" CssClass="form-control" placeholder="Enter author name"></asp:TextBox></div>
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
                        <div class="col-md-6 mb-3"><label class="form-label">Total Copies *</label><asp:TextBox ID="txtTotalCopies" runat="server" CssClass="form-control" TextMode="Number" min="1" placeholder="Enter total copies"></asp:TextBox></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Available Copies *</label><asp:TextBox ID="txtAvailableCopies" runat="server" CssClass="form-control" TextMode="Number" min="0" placeholder="Enter available copies"></asp:TextBox></div>
                    </div>
                    <div class="row">
                        <div class="col-12 mb-3"><label class="form-label">Description</label><asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Enter book description (optional)"></asp:TextBox></div>
                    </div>
                    <asp:HiddenField ID="hfBookId" runat="server" />
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btnSaveBook" runat="server" Text="Save Book" CssClass="btn btn-primary" OnClick="btnSaveBook_Click" />
                </div>
            </div>
        </div>
    </div>

    <%-- View Book Details Modal --%>
    <div class="modal fade" id="viewBookModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Book Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label fw-bold">ISBN</label><p id="viewISBN" class="form-control-plaintext"></p></div>
                        <div class="col-md-6 mb-3"><label class="form-label fw-bold">Title</label><p id="viewTitle" class="form-control-plaintext"></p></div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label fw-bold">Author</label><p id="viewAuthor" class="form-control-plaintext"></p></div>
                        <div class="col-md-6 mb-3"><label class="form-label fw-bold">Category</label><p id="viewCategory" class="form-control-plaintext"></p></div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label fw-bold">Total Copies</label><p id="viewTotalCopies" class="form-control-plaintext"></p></div>
                        <div class="col-md-6 mb-3"><label class="form-label fw-bold">Available Copies</label><p id="viewAvailableCopies" class="form-control-plaintext"></p></div>
                    </div>
                    <div class="row">
                        <div class="col-12 mb-3"><label class="form-label fw-bold">Description</label><p id="viewDescription" class="form-control-plaintext"></p></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <%-- Borrow Settings Modal --%>
    <div class="modal fade" id="borrowSettingsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content" style="border:none;border-radius:10px;overflow:hidden;">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-sliders-h me-2"></i>Borrow Settings</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" style="padding:20px 24px;">
                    <div class="settings-section">
                        <p class="settings-section-title student"><i class="fas fa-user-graduate"></i>Student</p>
                        <div class="row g-3">
                            <div class="col-6">
                                <p class="settings-input-label mb-1">Max Books to Borrow</p>
                                <div class="settings-input-wrap">
                                    <input type="number" id="inputStuMax" class="settings-num-input" min="1" max="50" />
                                    <span class="unit-tag">books</span>
                                </div>
                            </div>
                            <div class="col-6">
                                <p class="settings-input-label mb-1">Borrow Duration</p>
                                <div class="settings-input-wrap">
                                    <input type="number" id="inputStuDays" class="settings-num-input" min="1" max="365" />
                                    <span class="unit-tag">days</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="settings-section" style="margin-bottom:0;">
                        <p class="settings-section-title teacher"><i class="fas fa-chalkboard-teacher"></i>Teacher</p>
                        <div class="row g-3">
                            <div class="col-6">
                                <p class="settings-input-label mb-1">Max Books to Borrow</p>
                                <div class="settings-input-wrap">
                                    <input type="number" id="inputTchMax" class="settings-num-input" min="1" max="50" />
                                    <span class="unit-tag">books</span>
                                </div>
                            </div>
                            <div class="col-6">
                                <p class="settings-input-label mb-1">Borrow Duration</p>
                                <div class="settings-input-wrap">
                                    <input type="number" id="inputTchDays" class="settings-num-input" min="1" max="365" />
                                    <span class="unit-tag">days</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" id="btnSaveSettings" class="btn btn-save-settings" onclick="saveBorrowSettings()">
                        <i class="fas fa-save me-1"></i> Save Settings
                    </button>
                </div>
            </div>
        </div>
    </div>

    <%-- Toast --%>
    <div id="settingsToast">
        <div id="settingsToastInner" class="toast-body-inner toast-success">
            <span id="settingsToastIcon" class="toast-icon"><i class="fas fa-check-circle"></i></span>
            <span id="settingsToastMsg" class="toast-msg">Settings saved.</span>
            <button class="toast-close" onclick="hideToast()">&times;</button>
        </div>
    </div>

</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    window.addEventListener('DOMContentLoaded', function () {
        var builtIn = document.querySelector('tr.pagination td');
        var custom = document.getElementById('customPager');
        if (builtIn && custom) custom.innerHTML = builtIn.innerHTML;
    });

    var _toastTimer = null;
    function showToast(message, type) {
        var toast = document.getElementById('settingsToast');
        var inner = document.getElementById('settingsToastInner');
        var icon = document.getElementById('settingsToastIcon');
        var msg = document.getElementById('settingsToastMsg');
        inner.className = 'toast-body-inner ' + (type === 'error' ? 'toast-error' : 'toast-success');
        icon.innerHTML = type === 'error' ? '<i class="fas fa-exclamation-circle"></i>' : '<i class="fas fa-check-circle"></i>';
        msg.textContent = message;
        toast.classList.add('show');
        if (_toastTimer) clearTimeout(_toastTimer);
        _toastTimer = setTimeout(hideToast, 3500);
    }
    function hideToast() {
        document.getElementById('settingsToast').classList.remove('show');
        if (_toastTimer) { clearTimeout(_toastTimer); _toastTimer = null; }
    }

    function showBookModal() {
        new bootstrap.Modal(document.getElementById('bookModal')).show();
    }
    function resetBookModal() {
        var f = document.getElementById('<%= txtISBN.ClientID %>');
        f.value = ''; f.disabled = false; f.readOnly = false;
        document.getElementById('<%= txtTitle.ClientID %>').value = '';
        document.getElementById('<%= txtAuthor.ClientID %>').value = '';
        document.getElementById('<%= ddlBookCategory.ClientID %>').selectedIndex = 0;
        document.getElementById('<%= txtTotalCopies.ClientID %>').value = '';
        document.getElementById('<%= txtAvailableCopies.ClientID %>').value='';
        document.getElementById('<%= txtDescription.ClientID %>').value='';
        document.getElementById('<%= hfBookId.ClientID %>').value='';
        document.getElementById('<%= lblModalTitle.ClientID %>').innerText='Add New Book';
        new bootstrap.Modal(document.getElementById('bookModal')).show();
    }
    function hideBookModal() {
        var inst = bootstrap.Modal.getInstance(document.getElementById('bookModal'));
        if (inst) inst.hide();
    }
    function showViewBookModal() { new bootstrap.Modal(document.getElementById('viewBookModal')).show(); }

    function openBorrowSettings() {
        fetch('Books.aspx/GetBorrowSettings', { method:'POST', headers:{'Content-Type':'application/json;charset=utf-8'}, body:JSON.stringify({}) })
        .then(function(r){return r.json();})
        .then(function(data){
            var s=data.d;
            if(s){
                document.getElementById('inputStuMax').value=s.StudentMaxBooks;
                document.getElementById('inputStuDays').value=s.StudentBorrowDays;
                document.getElementById('inputTchMax').value=s.TeacherMaxBooks;
                document.getElementById('inputTchDays').value=s.TeacherBorrowDays;
            }
            new bootstrap.Modal(document.getElementById('borrowSettingsModal')).show();
        })
        .catch(function(err){console.error(err);showToast('Could not load borrow settings.','error');});
    }

    function saveBorrowSettings() {
        var stuMax=parseInt(document.getElementById('inputStuMax').value,10);
        var stuDays=parseInt(document.getElementById('inputStuDays').value,10);
        var tchMax=parseInt(document.getElementById('inputTchMax').value,10);
        var tchDays=parseInt(document.getElementById('inputTchDays').value,10);
        if(!stuMax||stuMax<1||!stuDays||stuDays<1||!tchMax||tchMax<1||!tchDays||tchDays<1){
            showToast('All fields are required and must be positive numbers.','error'); return;
        }
        var btn=document.getElementById('btnSaveSettings');
        btn.disabled=true; btn.innerHTML='<i class="fas fa-spinner fa-spin me-1"></i> Saving…';
        var inst=bootstrap.Modal.getInstance(document.getElementById('borrowSettingsModal'));
        if(inst) inst.hide();
        fetch('Books.aspx/SaveBorrowSettings',{method:'POST',headers:{'Content-Type':'application/json;charset=utf-8'},
            body:JSON.stringify({studentMaxBooks:stuMax,studentBorrowDays:stuDays,teacherMaxBooks:tchMax,teacherBorrowDays:tchDays})})
        .then(function(r){return r.json();})
        .then(function(data){
            btn.disabled=false; btn.innerHTML='<i class="fas fa-save me-1"></i> Save Settings';
            if(data.d==='OK') showToast('Borrow settings saved successfully.','success');
            else showToast(data.d||'An error occurred.','error');
        })
        .catch(function(err){
            console.error(err); btn.disabled=false; btn.innerHTML='<i class="fas fa-save me-1"></i> Save Settings';
            showToast('Failed to save settings.','error');
        });
    }

    function editBook(button) {
        var isbn=button.getAttribute('data-isbn');
        fetch('Books.aspx/GetBookData',{method:'POST',headers:{'Content-Type':'application/json;charset=utf-8'},body:JSON.stringify({isbn:isbn})})
        .then(function(r){return r.json();})
        .then(function(data){
            var book=data.d;
            if(book){
                document.getElementById('<%= txtISBN.ClientID %>').value=book.ISBN;
                document.getElementById('<%= txtISBN.ClientID %>').disabled=true;
                document.getElementById('<%= txtTitle.ClientID %>').value=book.Title;
                document.getElementById('<%= txtAuthor.ClientID %>').value=book.Author;
                document.getElementById('<%= ddlBookCategory.ClientID %>').value=book.Category;
                document.getElementById('<%= txtTotalCopies.ClientID %>').value=book.TotalCopies;
                document.getElementById('<%= txtAvailableCopies.ClientID %>').value=book.AvailableCopies;
                document.getElementById('<%= txtDescription.ClientID %>').value=book.Description||'';
                document.getElementById('<%= hfBookId.ClientID %>').value=book.ISBN;
                document.getElementById('<%= lblModalTitle.ClientID %>').innerText = 'Edit Book';
                showBookModal(); // fields already populated above
            }
        })
            .catch(function (err) { console.error(err); alert('Error loading book data'); });
        return false;
    }

    function viewBook(button) {
        var isbn = button.getAttribute('data-isbn');
        fetch('Books.aspx/GetBookData', { method: 'POST', headers: { 'Content-Type': 'application/json;charset=utf-8' }, body: JSON.stringify({ isbn: isbn }) })
            .then(function (r) { return r.json(); })
            .then(function (data) {
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
            .catch(function (err) { console.error(err); alert('Error loading book data'); });
        return false;
    }
</script>
</body>
</html>
