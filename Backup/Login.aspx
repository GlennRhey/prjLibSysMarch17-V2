<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="prjLibrarySystem.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Library Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function selectRole(role) {
            // Update button styles
            document.getElementById('btnStudentRole').classList.remove('active');
            document.getElementById('btnAdminRole').classList.remove('active');

            if (role === 'Student') {
                document.getElementById('btnStudentRole').classList.add('active');
                document.getElementById('lblLoginTitle').innerText = 'Student Login';
            } else {
                document.getElementById('btnAdminRole').classList.add('active');
                document.getElementById('lblLoginTitle').innerText = 'Admin Login';
            }

            // Update hidden field
            document.getElementById('hfSelectedRole').value = role;

            // Clear any error messages
            var errorDiv = document.getElementById('divError');
            if (errorDiv) {
                errorDiv.style.display = 'none';
            }
        }
    </script>
    <style>
        body {
            background: linear-gradient(135deg, #f2f2f2 0%, #e6e6e6 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(139, 0, 0, 0.15);
            overflow: hidden;
            max-width: 900px;
            width: 100%;
            margin: 20px;
        }

        .ama-logo {
            width: 180px;
            max-width: 100%;
        }

        .role-selection {
            background: linear-gradient(135deg, #8b0000 0%, #b11226 100%);
            padding: 40px;
            text-align: center;
            color: white;
        }

        .logo-container {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            margin-bottom: 20px;
            gap: 5px; /* move book icon much closer to ama-logo */
            position: relative;
            left: -8px; /* move both logos a bit more to the left */
        }

        .logo-container .library-icon {
            font-size: 4.2rem; /* bigger */
            margin-top: -10px; /* move upwards */
        }

        .login-form {
            padding: 40px;
        }

        .role-btn {
            background: rgba(255, 255, 255, 0.2);
            border: 2px solid white;
            color: white;
            padding: 15px 30px;
            margin: 10px;
            border-radius: 50px;
            font-weight: bold;
            transition: all 0.3s;
            cursor: pointer;
        }

        .role-btn:hover {
            background: white;
            color: #8b0000;
            transform: translateY(-2px);
        }

        /* Fix checkbox double box issue */
        .form-check-input {
            border: none !important;
            background-image: none !important;
            background-color: white !important;
            margin-right: 0.05em !important;
            vertical-align: middle !important;
        }
        
        .form-check-label {
            margin-left: -0.35em !important;
            vertical-align: middle !important;
        }

        .role-btn.active {
            background: white;
            color: #8b0000;
        }

        .form-control:focus {
            border-color: #8b0000;
            box-shadow: 0 0 0 0.2rem rgba(139, 0, 0, 0.25);
        }

        .btn-login {
            background: linear-gradient(135deg, #8b0000 0%, #b11226 100%);
            border: none;
            color: white;
            padding: 12px 30px;
            border-radius: 50px;
            font-weight: bold;
            transition: all 0.3s;
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(139, 0, 0, 0.3);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-container">
            <div class="row g-0">
                <!-- Role Selection Side -->
                <div class="col-md-5 role-selection">

                    <!-- Logo + Book Icon Side by Side -->
                    <div class="logo-container">
                        <img src="images/ama-logo.png?v=2" alt="AMA Computer College Logo" class="ama-logo">
                        <div class="library-icon">
                            <i class="fas fa-book-open"></i>
                        </div>
                    </div>

                    <h2 class="mb-4">AMA Library Management System</h2>
                    <p class="mb-4">Select your role to continue</p>
                    
                    <button type="button" id="btnStudentRole" class="btn role-btn active" 
                        onclick="selectRole('Student')">Student</button>
                    <button type="button" id="btnAdminRole" class="btn role-btn" 
                        onclick="selectRole('Admin')">Admin</button>
                    
                    <div class="mt-4">
                        <small>
                            <i class="fas fa-info-circle"></i> 
                            Students can browse and borrow books<br>
                            Admins can manage the entire system
                        </small>
                    </div>
                </div>
                
                <!-- Login Form Side -->
                <div class="col-md-7 login-form">
                    <h3 class="mb-4">
                        <asp:Label ID="lblLoginTitle" runat="server" Text="Student Login"></asp:Label>
                    </h3>
                    
                    <div class="mb-3">
                        <label for="txtUsername" class="form-label">Username</label>
                        <div class="input-group">
                            <span class="input-group-text">
                                <i class="fas fa-user"></i>
                            </span>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" 
                                placeholder="Enter your username" required></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="txtPassword" class="form-label">Password</label>
                        <div class="input-group">
                            <span class="input-group-text">
                                <i class="fas fa-lock"></i>
                            </span>
                            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" 
                                TextMode="Password" placeholder="Enter your password" required></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="mb-3 form-check">
                        <asp:CheckBox ID="chkRememberMe" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label" for="chkRememberMe">
                            Remember me
                        </label>
                    </div>
                    
                    <div class="mb-3">
                        <asp:Button ID="btnLogin" runat="server" CssClass="btn btn-login w-100" 
                            Text="Login" OnClick="btnLogin_Click" />
                    </div>
                    
                    <div class="alert alert-danger" id="divError" runat="server" visible="false">
                        <asp:Label ID="lblError" runat="server" Text=""></asp:Label>
                    </div>
                    
                    <div class="text-center mt-3">
                        <small class="text-muted">
                            &copy; 2026 AMA Library Management System
                        </small>
                    </div>
                </div>
            </div>
        </div>
        
        <asp:HiddenField ID="hfSelectedRole" runat="server" Value="Student" />
    </form>
</body>
</html>
