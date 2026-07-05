<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    String teacherName = (String) session.getAttribute("full_name");
    String teacherRole = (String) session.getAttribute("role");
    if (teacherName == null || !"teacher".equals(teacherRole)) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp?error=invalid_role");
        return;
    }
    request.setAttribute("activePage", "dashboard");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard - ElderEarn</title>
    
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
                    <h2 class="fw-bold mb-1">Welcome back, <%= teacherName %>!</h2>
                    <p class="text-muted mb-0">Here is what's happening with your courses and earnings today.</p>
                </div>
                <div class="bg-white px-3 py-2 rounded-4 shadow-sm border d-flex align-items-center gap-2">
                    <i class="bi bi-calendar3 text-primary"></i>
                    <span class="fw-bold small text-muted">July 2, 2026</span>
                </div>
            </div>

            <%
                int totalSkills = 0;
                int totalProducts = 0;
                double totalEarnings = 0.0;
                int totalStudents = 0;
                int totalVideos = 0;
                int totalViews = 0;
                int activeCourses = 0;

                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    
                    // 1. Total Skills Count
                    String qSkills = "SELECT COUNT(*) FROM skills WHERE teacher_name = ?";
                    PreparedStatement psSkills = conn.prepareStatement(qSkills);
                    psSkills.setString(1, teacherName);
                    ResultSet rsSkills = psSkills.executeQuery();
                    if (rsSkills.next()) {
                        totalSkills = rsSkills.getInt(1);
                    }
                    rsSkills.close();
                    psSkills.close();

                    // 2. Total Products Count
                    String qProducts = "SELECT COUNT(*) FROM products WHERE teacher_name = ?";
                    PreparedStatement psProducts = conn.prepareStatement(qProducts);
                    psProducts.setString(1, teacherName);
                    ResultSet rsProducts = psProducts.executeQuery();
                    if (rsProducts.next()) {
                        totalProducts = rsProducts.getInt(1);
                    }
                    rsProducts.close();
                    psProducts.close();

                    // 3. Total Earnings Count
                    String qEarnings = "SELECT SUM(CAST(amount AS DECIMAL(10,2))) FROM payments WHERE teacher_name = ? AND payment_status = 'Paid'";
                    PreparedStatement psEarnings = conn.prepareStatement(qEarnings);
                    psEarnings.setString(1, teacherName);
                    ResultSet rsEarnings = psEarnings.executeQuery();
                    if (rsEarnings.next()) {
                        totalEarnings = rsEarnings.getDouble(1);
                    }
                    rsEarnings.close();
                    psEarnings.close();

                    // 4. Total Active Students Count
                    String qStudents = "SELECT COUNT(DISTINCT student_name) FROM subscriptions WHERE teacher_name = ? AND access_status = 'Active'";
                    PreparedStatement psStudents = conn.prepareStatement(qStudents);
                    psStudents.setString(1, teacherName);
                    ResultSet rsStudents = psStudents.executeQuery();
                    if (rsStudents.next()) {
                        totalStudents = rsStudents.getInt(1);
                    }
                    rsStudents.close();
                    psStudents.close();

                    // 5. Total Videos Count
                    String qVideos = "SELECT COUNT(*) FROM videos WHERE teacher_name = ?";
                    PreparedStatement psVideos = conn.prepareStatement(qVideos);
                    psVideos.setString(1, teacherName);
                    ResultSet rsVideos = psVideos.executeQuery();
                    if (rsVideos.next()) {
                        totalVideos = rsVideos.getInt(1);
                    }
                    rsVideos.close();
                    psVideos.close();

                    // 6. Total Video Views
                    String qViews = "SELECT SUM(views_count) FROM videos WHERE teacher_name = ?";
                    PreparedStatement psViews = conn.prepareStatement(qViews);
                    psViews.setString(1, teacherName);
                    ResultSet rsViews = psViews.executeQuery();
                    if (rsViews.next()) {
                        totalViews = rsViews.getInt(1);
                    }
                    rsViews.close();
                    psViews.close();

                    // 7. Active Courses
                    String qAct = "SELECT COUNT(DISTINCT course_name) FROM subscriptions WHERE teacher_name = ? AND access_status = 'Active'";
                    PreparedStatement psAct = conn.prepareStatement(qAct);
                    psAct.setString(1, teacherName);
                    ResultSet rsAct = psAct.executeQuery();
                    if (rsAct.next()) {
                        activeCourses = rsAct.getInt(1);
                    }
                    rsAct.close();
                    psAct.close();

                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>

            <!-- Stats Metric Cards -->
            <div class="row g-4 mb-5">
                <div class="col-sm-6 col-lg-3 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Total Skills</h6>
                            <h2><%= totalSkills %></h2>
                        </div>
                        <div class="metric-card-icon bg-primary-tint">
                            <i class="bi bi-patch-check-fill"></i>
                        </div>
                    </div>
                </div>
                
                <div class="col-sm-6 col-lg-3 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Products</h6>
                            <h2><%= totalProducts %></h2>
                        </div>
                        <div class="metric-card-icon bg-success-tint">
                            <i class="bi bi-box-seam-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-3 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Videos</h6>
                            <h2><%= totalVideos %></h2>
                        </div>
                        <div class="metric-card-icon bg-info-tint">
                            <i class="bi bi-collection-play-fill"></i>
                        </div>
                    </div>
                </div>
                
                <div class="col-sm-6 col-lg-3 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Subscribers</h6>
                            <h2><%= totalStudents %></h2>
                        </div>
                        <div class="metric-card-icon bg-warning-tint">
                            <i class="bi bi-people-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-3 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Earnings</h6>
                            <h2>₹<%= String.format("%.0f", totalEarnings) %></h2>
                        </div>
                        <div class="metric-card-icon bg-success-tint" style="background-color: rgba(25, 135, 84, 0.15); color: #198754;">
                            <i class="bi bi-currency-rupee"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-3 col-xl-2">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Views</h6>
                            <h2><%= totalViews %></h2>
                        </div>
                        <div class="metric-card-icon bg-info-tint" style="background-color: rgba(13, 202, 240, 0.15); color: #0dcaf0;">
                            <i class="bi bi-eye-fill"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Detailed Lists -->
            <div class="row g-4">
                <!-- Recent Subscriptions -->
                <div class="col-lg-6">
                    <div class="content-card">
                        <div class="content-card-title d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-people-fill text-primary"></i> Recent Subscriptions</span>
                            <a href="subscribers.jsp" class="btn btn-link btn-sm text-decoration-none fw-bold p-0">View All</a>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Student</th>
                                        <th>Course/Skill</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String qRecSub = "SELECT student_name, course_name, access_status FROM subscriptions WHERE teacher_name = ? ORDER BY subscription_id DESC LIMIT 4";
                                            PreparedStatement psRecSub = conn.prepareStatement(qRecSub);
                                            psRecSub.setString(1, teacherName);
                                            ResultSet rsRecSub = psRecSub.executeQuery();
                                            boolean hasSub = false;
                                            while (rsRecSub.next()) {
                                                hasSub = true;
                                                String student = rsRecSub.getString("student_name");
                                                String course = rsRecSub.getString("course_name");
                                                String status = rsRecSub.getString("access_status");
                                                
                                                String badgeClass = "bg-warning-tint text-warning";
                                                if ("Active".equalsIgnoreCase(status)) badgeClass = "bg-success-tint text-success";
                                                else if ("Expired".equalsIgnoreCase(status)) badgeClass = "bg-danger-tint text-danger";
                                    %>
                                    <tr>
                                        <td class="fw-bold"><%= student %></td>
                                        <td><%= course %></td>
                                        <td><span class="badge <%= badgeClass %> px-2.5 py-1.5"><%= status %></span></td>
                                    </tr>
                                    <%
                                            }
                                            rsRecSub.close();
                                            psRecSub.close();
                                            if (!hasSub) {
                                    %>
                                    <tr>
                                        <td colspan="3" class="text-center text-muted py-4">No recent subscriptions.</td>
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
                            <span><i class="bi bi-credit-card-fill text-success"></i> Recent Payouts</span>
                            <a href="payments.jsp" class="btn btn-link btn-sm text-decoration-none fw-bold p-0">View All</a>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Student</th>
                                        <th>Item</th>
                                        <th>Amount</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String qRecPay = "SELECT student_name, payment_for, amount, payment_status FROM payments WHERE teacher_name = ? ORDER BY payment_id DESC LIMIT 4";
                                            PreparedStatement psRecPay = conn.prepareStatement(qRecPay);
                                            psRecPay.setString(1, teacherName);
                                            ResultSet rsRecPay = psRecPay.executeQuery();
                                            boolean hasPay = false;
                                            while (rsRecPay.next()) {
                                                hasPay = true;
                                                String student = rsRecPay.getString("student_name");
                                                String item = rsRecPay.getString("payment_for");
                                                String amount = rsRecPay.getString("amount");
                                                String status = rsRecPay.getString("payment_status");
                                                
                                                String badgeClass = "bg-warning-tint text-warning";
                                                if ("Paid".equalsIgnoreCase(status)) badgeClass = "bg-success-tint text-success";
                                                else if ("Failed".equalsIgnoreCase(status)) badgeClass = "bg-danger-tint text-danger";
                                    %>
                                    <tr>
                                        <td class="fw-bold"><%= student %></td>
                                        <td><%= item %></td>
                                        <td class="text-success fw-bold">₹<%= amount %></td>
                                        <td><span class="badge <%= badgeClass %> px-2.5 py-1.5"><%= status %></span></td>
                                    </tr>
                                    <%
                                            }
                                            rsRecPay.close();
                                            psRecPay.close();
                                            if (!hasPay) {
                                    %>
                                    <tr>
                                        <td colspan="4" class="text-center text-muted py-4">No recent payment transactions.</td>
                                    </tr>
                                    <%
                                            }
                                            if (conn != null) conn.close();
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