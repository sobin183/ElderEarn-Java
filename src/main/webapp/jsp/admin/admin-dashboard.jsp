<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    request.setAttribute("activePage", "dashboard");
    String adminName = (String) session.getAttribute("full_name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - ElderEarn</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Dashboard CSS -->
    <link rel="stylesheet" href="../../css/dashboard.css">
</head>
<body>

    <div class="container-fluid p-0">
        <!-- Reusable Sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content -->
        <div class="main-content">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">Welcome, Admin!</h2>
                    <p class="text-muted mb-0">System Overview and metrics analysis dashboard.</p>
                </div>
            </div>

            <%
                int totalUsers = 0;
                int totalTeachers = 0;
                int totalStudents = 0;
                int totalSkills = 0;
                int totalProducts = 0;
                double totalRevenue = 0.0;

                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    
                    // 1. Total Users
                    Statement sUsers = conn.createStatement();
                    ResultSet rsUsers = sUsers.executeQuery("SELECT COUNT(*) FROM users");
                    if (rsUsers.next()) totalUsers = rsUsers.getInt(1);
                    rsUsers.close();
                    sUsers.close();

                    // 2. Total Teachers
                    Statement sTeachers = conn.createStatement();
                    ResultSet rsTeachers = sTeachers.executeQuery("SELECT COUNT(*) FROM users WHERE role='teacher'");
                    if (rsTeachers.next()) totalTeachers = rsTeachers.getInt(1);
                    rsTeachers.close();
                    sTeachers.close();

                    // 3. Total Students
                    Statement sStudents = conn.createStatement();
                    ResultSet rsStudents = sStudents.executeQuery("SELECT COUNT(*) FROM users WHERE role='student'");
                    if (rsStudents.next()) totalStudents = rsStudents.getInt(1);
                    rsStudents.close();
                    sStudents.close();

                    // 4. Total Skills
                    Statement sSkills = conn.createStatement();
                    ResultSet rsSkills = sSkills.executeQuery("SELECT COUNT(*) FROM skills");
                    if (rsSkills.next()) totalSkills = rsSkills.getInt(1);
                    rsSkills.close();
                    sSkills.close();

                    // 5. Total Products
                    Statement sProducts = conn.createStatement();
                    ResultSet rsProducts = sProducts.executeQuery("SELECT COUNT(*) FROM products");
                    if (rsProducts.next()) totalProducts = rsProducts.getInt(1);
                    rsProducts.close();
                    sProducts.close();

                    // 6. Total Revenue
                    Statement sRev = conn.createStatement();
                    ResultSet rsRev = sRev.executeQuery("SELECT SUM(CAST(amount AS DECIMAL(10,2))) FROM payments WHERE payment_status='Paid'");
                    if (rsRev.next()) totalRevenue = rsRev.getDouble(1);
                    rsRev.close();
                    sRev.close();

                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>

            <!-- Stats Metric Cards -->
            <div class="row g-4 mb-5">
                <div class="col-sm-6 col-lg-4 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Total Users</h6>
                            <h2><%= totalUsers %></h2>
                        </div>
                        <div class="metric-card-icon bg-primary-tint">
                            <i class="bi bi-people-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-4 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Teachers</h6>
                            <h2><%= totalTeachers %></h2>
                        </div>
                        <div class="metric-card-icon bg-success-tint">
                            <i class="bi bi-person-check-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-4 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Students</h6>
                            <h2><%= totalStudents %></h2>
                        </div>
                        <div class="metric-card-icon bg-info-tint">
                            <i class="bi bi-person-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-4 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Total Skills</h6>
                            <h2><%= totalSkills %></h2>
                        </div>
                        <div class="metric-card-icon bg-warning-tint">
                            <i class="bi bi-journal-check"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-4 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Products</h6>
                            <h2><%= totalProducts %></h2>
                        </div>
                        <div class="metric-card-icon bg-danger-tint">
                            <i class="bi bi-box-seam-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-4 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Revenue</h6>
                            <h2>₹<%= String.format("%.0f", totalRevenue) %></h2>
                        </div>
                        <div class="metric-card-icon bg-success-tint" style="background-color: rgba(25, 135, 84, 0.15); color: #198754;">
                            <i class="bi bi-currency-rupee"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Content Area Tables -->
            <div class="row g-4">
                <!-- Recent Registrations -->
                <div class="col-lg-6">
                    <div class="content-card">
                        <div class="content-card-title d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-person-plus-fill text-primary"></i> Recent Registrations</span>
                            <a href="users.jsp" class="btn btn-link btn-sm text-decoration-none fw-bold p-0">Manage Users</a>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th>Email</th>
                                        <th>Role</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            Statement stmt = conn.createStatement();
                                            ResultSet rs = stmt.executeQuery("SELECT full_name, email, role FROM users ORDER BY user_id DESC LIMIT 4");
                                            boolean hasUsers = false;
                                            while (rs.next()) {
                                                hasUsers = true;
                                                String name = rs.getString("full_name");
                                                String email = rs.getString("email");
                                                String role = rs.getString("role");
                                                
                                                String roleBadge = "bg-primary-tint text-primary";
                                                if ("teacher".equalsIgnoreCase(role)) roleBadge = "bg-success-tint text-success";
                                                else if ("admin".equalsIgnoreCase(role)) roleBadge = "bg-danger-tint text-danger";
                                    %>
                                    <tr>
                                        <td class="fw-bold"><%= name %></td>
                                        <td><%= email %></td>
                                        <td><span class="badge <%= roleBadge %> text-capitalize px-2.5 py-1.5"><%= role %></span></td>
                                    </tr>
                                    <%
                                            }
                                            rs.close();
                                            stmt.close();
                                            if (!hasUsers) {
                                    %>
                                    <tr>
                                        <td colspan="3" class="text-center text-muted py-4">No users registered in system.</td>
                                    </tr>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Recent Payments -->
                <div class="col-lg-6">
                    <div class="content-card">
                        <div class="content-card-title d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-credit-card-fill text-success"></i> Recent Transactions</span>
                            <a href="payments.jsp" class="btn btn-link btn-sm text-decoration-none fw-bold p-0">View Payments</a>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Student</th>
                                        <th>Teacher</th>
                                        <th>Amount</th>
                                        <th>Type</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            Statement stmt = conn.createStatement();
                                            ResultSet rs = stmt.executeQuery("SELECT student_name, teacher_name, amount, payment_type FROM payments ORDER BY payment_id DESC LIMIT 4");
                                            boolean hasPay = false;
                                            while (rs.next()) {
                                                hasPay = true;
                                                String student = rs.getString("student_name");
                                                String teacher = rs.getString("teacher_name");
                                                String amount = rs.getString("amount");
                                                String type = rs.getString("payment_type");
                                                
                                                String typeBadge = "bg-info-tint text-info";
                                                if ("Subscription".equalsIgnoreCase(type)) typeBadge = "bg-primary-tint text-primary";
                                    %>
                                    <tr>
                                        <td class="fw-bold"><%= student %></td>
                                        <td><%= teacher %></td>
                                        <td class="text-success fw-bold">₹<%= amount %></td>
                                        <td><span class="badge <%= typeBadge %> px-2.5 py-1.5"><%= type %></span></td>
                                    </tr>
                                    <%
                                            }
                                            rs.close();
                                            stmt.close();
                                            if (conn != null) conn.close();
                                            if (!hasPay) {
                                    %>
                                    <tr>
                                        <td colspan="4" class="text-center text-muted py-4">No logged transaction payouts.</td>
                                    </tr>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>