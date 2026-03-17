<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Logout.aspx.cs" Inherits="prjLibrarySystem.Logout" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Logging Out...</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #8b0000 0%, #b11226 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .logout-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            padding: 40px;
            text-align: center;
            max-width: 400px;
            width: 100%;
        }
        .logout-icon {
            font-size: 4rem;
            color: #8b0000;
            margin-bottom: 20px;
            animation: spin 2s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .logout-message {
            color: #666;
            margin-bottom: 20px;
        }
        .redirect-link {
            color: #8b0000;
            text-decoration: none;
            font-weight: bold;
        }
        .redirect-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="logout-container">
            <div class="logout-icon">
                <i class="fas fa-sign-out-alt"></i>
            </div>
            <h2>Logging Out...</h2>
            <p class="logout-message">
                Thank you for using the Library Management System. You are being logged out securely.
            </p>
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-3">
                <small>If you are not redirected automatically, 
                    <asp:HyperLink ID="hlLoginLink" runat="server" CssClass="redirect-link" NavigateUrl="Login.aspx">click here</asp:HyperLink>
                </small>
            </p>
        </div>
    </form>
</body>
</html>
