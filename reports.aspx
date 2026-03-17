<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="reports.aspx.cs" Inherits="prjLibrarySystem.reports" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Library Reports - Library System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css?v=2.0" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css?v=2.0" rel="stylesheet">
    <style>
        .main-content { padding: 20px; }
        .summary-card .card-body { display: flex; justify-content: space-between; align-items: center; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row">

                <%-- Dynamic sidebar — set by code-behind based on session role --%>
                <asp:Literal ID="litSidebar" runat="server"></asp:Literal>

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
                                    <asp:Label ID="lblTotalBooks" runat="server" Text="0" CssClass="badge bg-dark"></asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card summary-card border-success">
                                <div class="card-body">
                                    <span>Total Members</span>
                                    <asp:Label ID="lblTotalMembers" runat="server" Text="0" CssClass="badge bg-dark"></asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card summary-card border-warning">
                                <div class="card-body">
                                    <span>Currently Borrowed</span>
                                    <asp:Label ID="lblIssuedBooks" runat="server" Text="0" CssClass="badge bg-dark"></asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card summary-card border-danger">
                                <div class="card-body">
                                    <span>Books Overdue</span>
                                    <asp:Label ID="lblOverdueBooks" runat="server" Text="0" CssClass="badge bg-dark"></asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="card summary-card border-primary">
                                <div class="card-body">
                                    <span>Most Borrowed Book</span>
                                    <asp:Label ID="lblMostBorrowed" runat="server" Text="N/A" CssClass="badge bg-dark"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-4">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh Report" CssClass="btn btn-primary me-2" OnClick="btnRefresh_Click" />
                        <asp:Button ID="btnExport"  runat="server" Text="Export Report"  CssClass="btn btn-success"       OnClick="btnExport_Click" />
                    </div>
                </main>
            </div>
        </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
