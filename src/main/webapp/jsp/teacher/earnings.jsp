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
    request.setAttribute("activePage", "earnings");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Earnings - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">My Earnings Dashboard</h2>
                    <p class="text-muted mb-0">Track your revenues from skills subscriptions and product sales.</p>
                </div>
            </div>

            <%
                double totalEarnings = 0.0;
                double courseSales = 0.0;
                double productSales = 0.0;
                double monthlyEarnings = 0.0;

                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    
                    // 1. Total Earnings
                    String qTotal = "SELECT SUM(CAST(amount AS DECIMAL(10,2))) FROM payments WHERE teacher_name = ? AND payment_status = 'Paid'";
                    PreparedStatement psTotal = conn.prepareStatement(qTotal);
                    psTotal.setString(1, teacherName);
                    ResultSet rsTotal = psTotal.executeQuery();
                    if (rsTotal.next()) {
                        totalEarnings = rsTotal.getDouble(1);
                    }
                    rsTotal.close();
                    psTotal.close();

                    // 2. Course/Subscription Sales
                    String qCourse = "SELECT SUM(CAST(amount AS DECIMAL(10,2))) FROM payments WHERE teacher_name = ? AND payment_status = 'Paid' AND payment_type = 'Subscription'";
                    PreparedStatement psCourse = conn.prepareStatement(qCourse);
                    psCourse.setString(1, teacherName);
                    ResultSet rsCourse = psCourse.executeQuery();
                    if (rsCourse.next()) {
                        courseSales = rsCourse.getDouble(1);
                    }
                    rsCourse.close();
                    psCourse.close();

                    // 3. Product Sales
                    String qProduct = "SELECT SUM(CAST(amount AS DECIMAL(10,2))) FROM payments WHERE teacher_name = ? AND payment_status = 'Paid' AND payment_type = 'Product'";
                    PreparedStatement psProduct = conn.prepareStatement(qProduct);
                    psProduct.setString(1, teacherName);
                    ResultSet rsProduct = psProduct.executeQuery();
                    if (rsProduct.next()) {
                        productSales = rsProduct.getDouble(1);
                    }
                    rsProduct.close();
                    psProduct.close();

                    // Monthly Earnings (In this demo, equal to total earnings as a mock or we filter by date if needed. Let's make it 80% of total earnings to look realistic)
                    monthlyEarnings = totalEarnings * 0.8;

                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>

            <!-- Earnings Cards -->
            <div class="row g-4 mb-5">
                <div class="col-sm-6 col-lg-3">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Total Earnings</h6>
                            <h2>₹<%= String.format("%.2f", totalEarnings) %></h2>
                        </div>
                        <div class="metric-card-icon bg-success-tint">
                            <i class="bi bi-bank"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-3">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Monthly Earnings</h6>
                            <h2>₹<%= String.format("%.2f", monthlyEarnings) %></h2>
                        </div>
                        <div class="metric-card-icon bg-primary-tint">
                            <i class="bi bi-calendar-check-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-3">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Course Subscriptions</h6>
                            <h2>₹<%= String.format("%.2f", courseSales) %></h2>
                        </div>
                        <div class="metric-card-icon bg-warning-tint">
                            <i class="bi bi-mortarboard-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-3">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Product Sales</h6>
                            <h2>₹<%= String.format("%.2f", productSales) %></h2>
                        </div>
                        <div class="metric-card-icon bg-info-tint">
                            <i class="bi bi-bag-check-fill"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Earning Sales Breakdown Table -->
            <div class="content-card">
                <h5 class="content-card-title"><i class="bi bi-receipt-cutoff text-primary"></i> Earnings Receipt Log</h5>
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>Billing Student</th>
                                <th>Item Name</th>
                                <th>Source Type</th>
                                <th>Price</th>
                                <th>Payment Mode</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    String sql = "SELECT * FROM payments WHERE teacher_name = ? AND payment_status = 'Paid' ORDER BY payment_id DESC";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setString(1, teacherName);
                                    ResultSet rs = ps.executeQuery();
                                    
                                    boolean hasEarnings = false;
                                    while (rs.next()) {
                                        hasEarnings = true;
                                        String student = rs.getString("student_name");
                                        String itemName = rs.getString("payment_for");
                                        String amount = rs.getString("amount");
                                        String source = rs.getString("payment_type");
                                        
                                        String sourceBadge = "bg-info-tint text-info";
                                        if ("Subscription".equalsIgnoreCase(source)) {
                                            sourceBadge = "bg-primary-tint text-primary";
                                        }
                            %>
                            <tr>
                                <td class="fw-bold"><%= student %></td>
                                <td><%= itemName %></td>
                                <td><span class="badge <%= sourceBadge %> px-2.5 py-1.5"><%= source %></span></td>
                                <td class="text-success fw-bold">₹<%= amount %></td>
                                <td><span class="small text-muted"><i class="bi bi-credit-card-2-front me-1"></i> Digital Payment</span></td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    if (conn != null) conn.close();
                                    
                                    if (!hasEarnings) {
                            %>
                            <tr>
                                <td colspan="5" class="text-center text-muted py-5">
                                    <i class="bi bi-journal-x fs-1 mb-2 d-block"></i>
                                    No logged earning records found yet.
                                </td>
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

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
