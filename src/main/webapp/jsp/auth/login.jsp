<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ElderEarn Login</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary-blue: #0f4c81;
            --accent-blue: #3a86c8;
            --sky-blue: #e8f4fd;
            --deep-dark: #0b1a30;
            --body-bg: #f0f4f8;
            --white: #ffffff;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background: linear-gradient(135deg, var(--sky-blue) 0%, var(--body-bg) 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--deep-dark);
            padding: 20px;
        }

        .login-card {
            width: 100%;
            max-width: 450px;
            background-color: var(--white);
            border: none;
            border-radius: 25px;
            box-shadow: 0 15px 35px rgba(15, 76, 129, 0.08);
            padding: 40px;
        }

        .brand-logo {
            font-size: 2.25rem;
            font-weight: 800;
            color: var(--primary-blue);
            text-align: center;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .form-label {
            font-weight: 500;
            font-size: 0.9rem;
            margin-bottom: 6px;
        }

        .form-control {
            border-radius: 12px;
            padding: 12px 16px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }

        .form-control:focus {
            border-color: var(--primary-blue);
            box-shadow: 0 0 0 4px rgba(15, 76, 129, 0.1);
        }

        .btn-primary-custom {
            background-color: var(--primary-blue);
            border: none;
            border-radius: 12px;
            padding: 12px;
            font-weight: 600;
            color: var(--white);
            transition: all 0.3s;
        }

        .btn-primary-custom:hover {
            background-color: var(--accent-blue);
            transform: translateY(-1px);
        }

        .back-home {
            text-decoration: none;
            color: var(--primary-blue);
            font-weight: 500;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: color 0.3s;
        }

        .back-home:hover {
            color: var(--accent-blue);
        }
    </style>
</head>
<body>

    <div class="login-card">
        <a href="../../index.jsp" class="back-home mb-4"><i class="bi bi-arrow-left"></i> Back to Home</a>
        
        <div class="brand-logo">
            <i class="bi bi-mortarboard-fill"></i> ElderEarn
        </div>
        <p class="text-center text-muted mb-4">Login to your dashboard</p>

        <!-- Dynamic Alerts for Registration / Login Errors -->
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            
            if ("invalid".equals(error)) {
        %>
            <div class="alert alert-danger alert-dismissible fade show border-0 rounded-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> Invalid Email or Password.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
            } else if ("empty".equals(error)) {
        %>
            <div class="alert alert-danger alert-dismissible fade show border-0 rounded-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> Please enter both email and password.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
            } else if ("invalid_role".equals(error)) {
        %>
            <div class="alert alert-danger alert-dismissible fade show border-0 rounded-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> Your account does not have a valid role assigned.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
            } else if ("db_error".equals(error)) {
        %>
            <div class="alert alert-danger alert-dismissible fade show border-0 rounded-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> Database error occurred. Please try again.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
            }
            
            if ("registered".equals(success)) {
        %>
            <div class="alert alert-success alert-dismissible fade show border-0 rounded-4" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> Registration successful! You can now log in below.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
            }
        %>

        <!-- Login Form -->
        <form action="../../LoginServlet" method="post">
            <div class="mb-3">
                <label for="email" class="form-label">Email Address</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-envelope"></i></span>
                    <input type="email" id="email" name="email" class="form-control border-start-0" placeholder="yourname@gmail.com" required>
                </div>
            </div>

            <div class="mb-4">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <label for="password" class="form-label mb-0">Password</label>
                    <a href="#" class="text-decoration-none small text-muted">Forgot?</a>
                </div>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                    <input type="password" id="password" name="password" class="form-control border-start-0" placeholder="••••••••" required>
                </div>
            </div>

            <button type="submit" class="btn btn-primary-custom w-100 mb-3">Sign In</button>
        </form>

        <p class="text-center mb-0 mt-2 text-muted small">
            Don't have an account? <a href="register.jsp" class="text-primary fw-bold text-decoration-none">Create Account</a>
        </p>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>