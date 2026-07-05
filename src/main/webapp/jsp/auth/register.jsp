<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ElderEarn Register</title>
    
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
            padding: 20px 10px;
        }

        .register-card {
            width: 100%;
            max-width: 480px;
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

        .form-control, .form-select {
            border-radius: 12px;
            padding: 12px 16px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }

        .form-control:focus, .form-select:focus {
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

    <div class="register-card">
        <a href="../../index.jsp" class="back-home mb-4"><i class="bi bi-arrow-left"></i> Back to Home</a>
        
        <div class="brand-logo">
            <i class="bi bi-mortarboard-fill"></i> ElderEarn
        </div>
        <p class="text-center text-muted mb-4">Create your free account</p>

        <!-- Dynamic Alerts for Registration Errors -->
        <%
            String error = request.getParameter("error");
            if ("password_mismatch".equals(error)) {
        %>
            <div class="alert alert-danger alert-dismissible fade show border-0 rounded-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> Passwords do not match.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
            } else if ("email_exists".equals(error)) {
        %>
            <div class="alert alert-danger alert-dismissible fade show border-0 rounded-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> This email address is already registered.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <%
            } else if ("empty_fields".equals(error)) {
        %>
            <div class="alert alert-danger alert-dismissible fade show border-0 rounded-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> Please fill in all fields.
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
        %>

        <!-- JS Password matching alert placeholder -->
        <div id="js-alert" class="alert alert-danger border-0 rounded-4 d-none" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> <span id="js-alert-text"></span>
        </div>

        <!-- Registration Form -->
        <form action="../../RegisterServlet" method="post" onsubmit="return validatePasswords();">
            <div class="mb-3">
                <label for="full_name" class="form-label">Full Name</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-person"></i></span>
                    <input type="text" id="full_name" name="full_name" class="form-control border-start-0" placeholder="" required>
                </div>
            </div>

            <div class="mb-3">
                <label for="email" class="form-label">Email Address</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-envelope"></i></span>
                    <input type="email" id="email" name="email" class="form-control border-start-0" placeholder="" required>
                </div>
            </div>

            <div class="mb-3">
                <label for="role" class="form-label">Account Role</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-people"></i></span>
                    <select id="role" name="role" class="form-select border-start-0" required>
                        <option value="">Select Role</option>
                        <option value="teacher" <%= "teacher".equals(request.getParameter("role")) ? "selected" : "" %>>Teacher (Knowledge Provider)</option>
                        <option value="student" <%= "student".equals(request.getParameter("role")) ? "selected" : "" %>>Student (Learner)</option>
                    </select>
                </div>
            </div>

            <div class="mb-3">
                <label for="password" class="form-label">Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                    <input type="password" id="password" name="password" class="form-control border-start-0" placeholder="••••••••" required>
                </div>
            </div>

            <div class="mb-4">
                <label for="confirm_password" class="form-label">Confirm Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-shield-check"></i></span>
                    <input type="password" id="confirm_password" name="confirm_password" class="form-control border-start-0" placeholder="••••••••" required>
                </div>
            </div>

            <button type="submit" class="btn btn-primary-custom w-100 mb-3">Sign Up</button>
        </form>

        <p class="text-center mb-0 mt-2 text-muted small">
            Already have account? <a href="login.jsp" class="text-primary fw-bold text-decoration-none">Sign In</a>
        </p>
    </div>

    <!-- Client-side Password Validation Script -->
    <script>
        function validatePasswords() {
            var pass = document.getElementById("password").value;
            var confirmPass = document.getElementById("confirm_password").value;
            var jsAlert = document.getElementById("js-alert");
            var jsAlertText = document.getElementById("js-alert-text");
            
            if (pass !== confirmPass) {
                jsAlert.classList.remove("d-none");
                jsAlertText.innerText = "Passwords do not match. Please verify.";
                window.scrollTo(0, 0);
                return false;
            }
            return true;
        }
    </script>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>