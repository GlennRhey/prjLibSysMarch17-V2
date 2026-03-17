<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminMembers.aspx.cs" Inherits="prjLibrarySystem.AdminMembers" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Member Management - Library System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css?v=2.0" rel="stylesheet"/>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css?v=2.0" rel="stylesheet"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function selectMemberType(type) {
            var studentBtn = document.getElementById('<%= btnStudentRole.ClientID %>');
            var teacherBtn = document.getElementById('<%= btnTeacherRole.ClientID %>');
            studentBtn.classList.remove('active');
            teacherBtn.classList.remove('active');
            if (type === 'Student') {
                studentBtn.classList.add('active');
                document.getElementById('studentFields').style.display = 'block';
                document.getElementById('<%= lblRegisterTitle.ClientID %>').innerText = 'Add Student Member';
            } else {
                teacherBtn.classList.add('active');
                document.getElementById('studentFields').style.display = 'none';
                document.getElementById('<%= lblRegisterTitle.ClientID %>').innerText = 'Add Teacher Member';
            }
            document.getElementById('<%= hfSelectedRole.ClientID %>').value = type;
        }
    </script>
    <style>
        .main-content { padding: 20px; }
        .action-buttons .btn { margin-right: 5px; }
        .status-active   { background-color: #28a745 !important; color: #fff !important; border: 1px solid #1e7e34; padding: 4px 8px; min-width: 70px; border-radius: 4px; cursor: pointer; }
        .status-inactive { background-color: #dc3545 !important; color: #fff !important; border: 1px solid #bd2130; padding: 4px 8px; min-width: 70px; border-radius: 4px; cursor: pointer; }
        .card-body { min-height: 580px; max-height: 580px; overflow-y: auto; position: relative; padding-bottom: 0; }
        tr.pagination { display: none !important; }
        .pagination-bar { position: absolute; bottom: 0; left: 0; right: 0; height: 54px; display: flex; align-items: center; justify-content: flex-start; padding: 0 12px; border-top: 1px solid #f0f0f0; background: #fff; border-radius: 0 0 4px 4px; }
        .pagination-bar a, .pagination-bar span { color: #555; display: inline-block; padding: 6px 12px; text-decoration: none !important; border: 1px solid #ddd; margin: 0 2px; border-radius: 6px; font-weight: 500; font-size: 13px; transition: all 0.25s ease; }
        .pagination-bar a:hover { border-color: #8b0000 !important; color: #8b0000 !important; transform: translateY(-2px); background-color: transparent !important; }
        .pagination-bar span { background-color: #8b0000; color: white !important; border-color: #8b0000; cursor: default; }
        .pagination-bar a.disabled-link { color: #aaa !important; background-color: #f5f5f5 !important; border-color: #ddd !important; pointer-events: none; }
        .role-selection { background: linear-gradient(135deg, #8b0000 0%, #b11226 100%); padding: 40px; text-align: center; color: white; display: flex; flex-direction: column; justify-content: center; align-items: center; }
        .role-btn { background: rgba(255,255,255,0.2); border: 2px solid white; color: white; padding: 12px; border-radius: 50px; font-weight: bold; }
        .role-btn.active { background: white; color: #8b0000; }
        .btn-register { background: linear-gradient(135deg, #8b0000 0%, #b11226 100%); border: none; color: white; font-weight: bold; }
        .modal-body .row.g-0 { display: flex; height: 500px; }
        .modal-body .col-md-7 { display: flex; flex-direction: column; justify-content: flex-start; overflow-y: auto; max-height: 500px; }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <asp:HiddenField ID="hfSelectedRole"    runat="server" Value="Student" />
    <asp:HiddenField ID="hfEditingMemberId" runat="server" />

    <div class="container-fluid">
        <div class="row">

            <%-- Dynamic sidebar — red for Admin, blue for Super Admin --%>
            <asp:Literal ID="litSidebar" runat="server"></asp:Literal>

            <main class="col-12 col-md-9 col-lg-10 px-md-4 main-content">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Member Management</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <div class="btn-group me-2">
                            <asp:Button ID="btnAddNewMember" runat="server"
                                Text="Add New Member" CssClass="btn btn-primary"
                                OnClick="btnAddNewMember_Click" />
                        </div>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="input-group">
                            <asp:TextBox ID="txtSearchMember" runat="server" CssClass="form-control"
                                placeholder="Search by name, email, or User ID..."></asp:TextBox>
                            <asp:Button ID="btnSearchMember" runat="server" Text="Search"
                                CssClass="btn btn-outline-secondary" OnClick="btnSearchMember_Click" />
                        </div>
                    </div>
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlMembershipType" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlMembershipType_SelectedIndexChanged">
                            <asp:ListItem Value="">All Types</asp:ListItem>
                            <asp:ListItem Value="Student">Student</asp:ListItem>
                            <asp:ListItem Value="Teacher">Teacher</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3">
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                            <asp:ListItem Value="">All Status</asp:ListItem>
                            <asp:ListItem Value="Active">Active</asp:ListItem>
                            <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <%-- Status alert — shows inline instead of alert() popup --%>
                <div class="mb-3">
                    <asp:Label ID="lblStatusAlert" runat="server" CssClass="alert d-none"></asp:Label>
                </div>

                <div class="card shadow">
                    <div class="card-header py-3">
                        <h6 class="m-0 font-weight-bold text-primary">Members Directory (Students &amp; Teachers)</h6>
                    </div>
                    <div class="card-body">
                        <asp:GridView ID="gvMembers" runat="server" CssClass="table table-hover"
                            AutoGenerateColumns="false" GridLines="None" AllowPaging="true"
                            PageSize="10" OnPageIndexChanging="gvMembers_PageIndexChanging"
                            OnRowCommand="gvMembers_RowCommand" DataKeyNames="Username,MemberID,Role">
                            <PagerStyle CssClass="pagination" />
                            <Columns>
                                <asp:BoundField DataField="MemberID"         HeaderText="Member ID" />
                                <asp:BoundField DataField="FullName"         HeaderText="Full Name" />
                                <asp:BoundField DataField="Username"         HeaderText="Username" />
                                <asp:BoundField DataField="Email"            HeaderText="Email" />
                                <asp:BoundField DataField="Course"           HeaderText="Course" />
                                <asp:BoundField DataField="YearLevel"        HeaderText="Year Level" />
                                <asp:BoundField DataField="Role"             HeaderText="Type" />
                                <asp:BoundField DataField="RegistrationDate" HeaderText="Register Date" DataFormatString="{0:yyyy-MM-dd}" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnToggleStatus" runat="server"
                                            CommandName="ToggleStatus"
                                            CommandArgument='<%# Container.DataItemIndex %>'
                                            CssClass='<%# GetStatusBadgeClass(Eval("Status")) %>'>
                                            <%# Eval("Status") %>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <div class="action-buttons">
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditMember"
                                                CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-sm btn-warning">
                                                <i class="fas fa-edit"></i>
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteMember"
                                                CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-sm btn-danger"
                                                OnClientClick="return confirm('Are you sure you want to delete this member?');">
                                                <i class="fas fa-trash"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <div class="pagination-bar" id="customPager"></div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <%-- Add / Edit Member Modal --%>
    <div class="modal fade" id="memberModal" tabindex="-1">
        <div class="modal-dialog modal-xl modal-dialog-centered" style="max-width:1000px;">
            <div class="modal-content">
                <div class="modal-body p-0">
                    <div class="row g-0">
                        <div class="col-md-5 role-selection">
                            <h3 class="mb-4">Library System</h3>
                            <p>Select Member Type</p>
                            <asp:Button ID="btnStudentRole" runat="server" Text="Student"
                                CssClass="btn role-btn active w-75"
                                OnClientClick="selectMemberType('Student'); return false;" />
                            <asp:Button ID="btnTeacherRole" runat="server" Text="Teacher"
                                CssClass="btn role-btn w-75 mt-2"
                                OnClientClick="selectMemberType('Teacher'); return false;" />
                        </div>
                        <div class="col-md-7 p-4">
                            <h4 class="mb-4">
                                <asp:Label ID="lblRegisterTitle" runat="server" Text="Add Student Member"></asp:Label>
                            </h4>
                            <div class="mb-3">
                                <label>User ID</label>
                                <asp:TextBox ID="txtUserId" runat="server" CssClass="form-control" />
                            </div>
                            <div class="mb-3">
                                <label>Full Name</label>
                                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
                            </div>
                            <div class="mb-3">
                                <label>Email</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" />
                            </div>
                            <div id="studentFields">
                                <div class="mb-3">
                                    <label>Course</label>
                                    <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="">-- Select Course --</asp:ListItem>
                                        <asp:ListItem Value="BSIT">BSIT</asp:ListItem>
                                        <asp:ListItem Value="BSCS">BSCS</asp:ListItem>
                                        <asp:ListItem Value="BSCpE">BSCpE</asp:ListItem>
                                        <asp:ListItem Value="BSBA">BSBA</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="mb-3">
                                    <label>Year Level</label>
                                    <asp:DropDownList ID="ddlYearLevel" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="1st Year" />
                                        <asp:ListItem Text="2nd Year" />
                                        <asp:ListItem Text="3rd Year" />
                                        <asp:ListItem Text="4th Year" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label>Password</label>
                                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" />
                            </div>
                            <div class="d-flex gap-2">
                                <asp:Button ID="btnSaveMember" runat="server" Text="Save Member"
                                    CssClass="btn btn-register w-50" OnClick="btnSaveMember_Click" />
                                <button type="button" class="btn btn-secondary w-50" data-bs-dismiss="modal">Cancel</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</form>
<script>
    window.addEventListener('DOMContentLoaded', function () {
        var builtInPager = document.querySelector('tr.pagination td');
        var customPager = document.getElementById('customPager');
        if (builtInPager && customPager) customPager.innerHTML = builtInPager.innerHTML;
    });
</script>
</body>
</html>
