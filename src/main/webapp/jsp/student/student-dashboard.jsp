<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    request.setAttribute("activePage", "dashboard");
    String studentName = (String) session.getAttribute("full_name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - ElderEarn</title>
    
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
                    <h2 class="fw-bold mb-1">Welcome back, <%= studentName %>!</h2>
                    <p class="text-muted mb-0">Learn something new today. Browse courses and educational digital tools.</p>
                </div>
                <div class="bg-white px-3 py-2 rounded-4 shadow-sm border d-flex align-items-center gap-2">
                    <i class="bi bi-calendar3 text-primary"></i>
                    <span class="fw-bold small text-muted">July 2, 2026</span>
                </div>
            </div>

            <%
                int availableSkills = 0;
                int purchasedProducts = 0;
                int activeSubscriptions = 0;

                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    
                    // 1. Available Skills count
                    String qSkills = "SELECT COUNT(*) FROM skills";
                    Statement stmtSkills = conn.createStatement();
                    ResultSet rsSkills = stmtSkills.executeQuery(qSkills);
                    if (rsSkills.next()) {
                        availableSkills = rsSkills.getInt(1);
                    }
                    rsSkills.close();
                    stmtSkills.close();

                    // 2. Purchased Products count
                    String qProducts = "SELECT COUNT(*) FROM payments WHERE student_name = ? AND payment_status = 'Paid' AND payment_type = 'Product'";
                    PreparedStatement psProducts = conn.prepareStatement(qProducts);
                    psProducts.setString(1, studentName);
                    ResultSet rsProducts = psProducts.executeQuery();
                    if (rsProducts.next()) {
                        purchasedProducts = rsProducts.getInt(1);
                    }
                    rsProducts.close();
                    psProducts.close();

                    // 3. Active Subscriptions count
                    String qSub = "SELECT COUNT(*) FROM subscriptions WHERE student_name = ? AND access_status = 'Active'";
                    PreparedStatement psSub = conn.prepareStatement(qSub);
                    psSub.setString(1, studentName);
                    ResultSet rsSub = psSub.executeQuery();
                    if (rsSub.next()) {
                        activeSubscriptions = rsSub.getInt(1);
                    }
                    rsSub.close();
                    psSub.close();

                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>

            <!-- Stats Metric Cards -->
            <div class="row g-4 mb-5">
                <div class="col-md-4">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Available Skills</h6>
                            <h2><%= availableSkills %></h2>
                        </div>
                        <div class="metric-card-icon bg-primary-tint">
                            <i class="bi bi-search"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Purchased Products</h6>
                            <h2><%= purchasedProducts %></h2>
                        </div>
                        <div class="metric-card-icon bg-success-tint">
                            <i class="bi bi-bag-check-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Active Subscriptions</h6>
                            <h2><%= activeSubscriptions %></h2>
                        </div>
                        <div class="metric-card-icon bg-warning-tint">
                            <i class="bi bi-journal-bookmark-fill"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Dashboard Tables -->
            <div class="row g-4">
                <!-- My Subscriptions -->
                <div class="col-lg-6">
                    <div class="content-card">
                        <div class="content-card-title d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-journal-check text-warning"></i> Active Subscriptions</span>
                            <a href="my-subscriptions.jsp" class="btn btn-link btn-sm text-decoration-none fw-bold p-0">View All</a>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Course/Skill</th>
                                        <th>Teacher</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String qRecSub = "SELECT course_name, teacher_name, access_status FROM subscriptions WHERE student_name = ? ORDER BY subscription_id DESC LIMIT 4";
                                            PreparedStatement psRecSub = conn.prepareStatement(qRecSub);
                                            psRecSub.setString(1, studentName);
                                            ResultSet rsRecSub = psRecSub.executeQuery();
                                            boolean hasSub = false;
                                            while (rsRecSub.next()) {
                                                hasSub = true;
                                                String course = rsRecSub.getString("course_name");
                                                String teacher = rsRecSub.getString("teacher_name");
                                                String status = rsRecSub.getString("access_status");
                                                
                                                String badgeClass = "bg-warning-tint text-warning";
                                                if ("Active".equalsIgnoreCase(status)) badgeClass = "bg-success-tint text-success";
                                                else if ("Expired".equalsIgnoreCase(status)) badgeClass = "bg-danger-tint text-danger";
                                    %>
                                    <tr>
                                        <td class="fw-bold"><%= course %></td>
                                        <td><%= teacher %></td>
                                        <td><span class="badge <%= badgeClass %> px-2.5 py-1.5"><%= status %></span></td>
                                    </tr>
                                    <%
                                            }
                                            rsRecSub.close();
                                            psRecSub.close();
                                            if (!hasSub) {
                                    %>
                                    <tr>
                                        <td colspan="3" class="text-center text-muted py-4">You have no active skill course subscriptions.</td>
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

                <!-- Recent Purchases -->
                <div class="col-lg-6">
                    <div class="content-card">
                        <div class="content-card-title d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-cart-check-fill text-success"></i> Recent Purchases</span>
                            <a href="payment-history.jsp" class="btn btn-link btn-sm text-decoration-none fw-bold p-0">View All</a>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-custom mb-0">
                                <thead>
                                    <tr>
                                        <th>Product</th>
                                        <th>Price</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String qRecPay = "SELECT payment_for, amount, payment_status FROM payments WHERE student_name = ? AND payment_type = 'Product' ORDER BY payment_id DESC LIMIT 4";
                                            PreparedStatement psRecPay = conn.prepareStatement(qRecPay);
                                            psRecPay.setString(1, studentName);
                                            ResultSet rsRecPay = psRecPay.executeQuery();
                                            boolean hasPay = false;
                                            while (rsRecPay.next()) {
                                                hasPay = true;
                                                String item = rsRecPay.getString("payment_for");
                                                String amount = rsRecPay.getString("amount");
                                                String status = rsRecPay.getString("payment_status");
                                                
                                                String badgeClass = "bg-warning-tint text-warning";
                                                if ("Paid".equalsIgnoreCase(status)) badgeClass = "bg-success-tint text-success";
                                                else if ("Failed".equalsIgnoreCase(status)) badgeClass = "bg-danger-tint text-danger";
                                    %>
                                    <tr>
                                        <td class="fw-bold"><%= item %></td>
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
                                        <td colspan="3" class="text-center text-muted py-4">No product purchases logged.</td>
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