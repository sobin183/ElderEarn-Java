<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    request.setAttribute("activePage", "subscriptions");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Subscriptions - Admin Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Subscriptions Monitor</h2>
                    <p class="text-muted mb-0">Track all active, expired, and pending student subscriptions to teachers' classes.</p>
                </div>
            </div>

            <!-- Subscriptions Table -->
            <div class="content-card">
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>Sub ID</th>
                                <th>Student</th>
                                <th>Teacher</th>
                                <th>Course Title</th>
                                <th>Price</th>
                                <th>Payment</th>
                                <th>Access</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT * FROM subscriptions ORDER BY subscription_id DESC";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ResultSet rs = ps.executeQuery();
                                    
                                    boolean hasSubs = false;
                                    while (rs.next()) {
                                        hasSubs = true;
                                        int id = rs.getInt("subscription_id");
                                        String student = rs.getString("student_name");
                                        String teacher = rs.getString("teacher_name");
                                        String course = rs.getString("course_name");
                                        String amount = rs.getString("amount");
                                        String payStatus = rs.getString("payment_status");
                                        String accStatus = rs.getString("access_status");
                                        
                                        String payBadge = "bg-warning-tint text-warning";
                                        if ("Paid".equalsIgnoreCase(payStatus)) payBadge = "bg-success-tint text-success";
                                        else if ("Failed".equalsIgnoreCase(payStatus)) payBadge = "bg-danger-tint text-danger";
                                        
                                        String accBadge = "bg-warning-tint text-warning";
                                        if ("Active".equalsIgnoreCase(accStatus)) accBadge = "bg-success-tint text-success";
                                        else if ("Expired".equalsIgnoreCase(accStatus)) accBadge = "bg-danger-tint text-danger";
                            %>
                            <tr>
                                <td>#EE-SUB-<%= id %></td>
                                <td class="fw-bold"><%= student %></td>
                                <td><%= teacher %></td>
                                <td><%= course %></td>
                                <td class="fw-bold text-success">₹<%= amount %>/mo</td>
                                <td><span class="badge <%= payBadge %> px-2.5 py-1.5"><%= payStatus %></span></td>
                                <td><span class="badge <%= accBadge %> px-2.5 py-1.5"><%= accStatus %></span></td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    conn.close();
                                    
                                    if (!hasSubs) {
                            %>
                            <tr>
                                <td colspan="7" class="text-center text-muted py-5">No subscription entries registered.</td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                            %>
                            <tr>
                                <td colspan="7" class="text-center text-danger py-4">Database load error.</td>
                            </tr>
                            <%
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
