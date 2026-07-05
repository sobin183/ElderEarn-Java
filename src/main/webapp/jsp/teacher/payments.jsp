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
    request.setAttribute("activePage", "payments");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payments Received - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Payments Received Log</h2>
                    <p class="text-muted mb-0">Monitor all student transactions, subscription statuses, and invoice records.</p>
                </div>
            </div>

            <!-- Payments Table -->
            <div class="content-card">
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>Payment ID</th>
                                <th>Student</th>
                                <th>Paid For</th>
                                <th>Type</th>
                                <th>Amount</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT * FROM payments WHERE teacher_name = ? ORDER BY payment_id DESC";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setString(1, teacherName);
                                    ResultSet rs = ps.executeQuery();
                                    
                                    boolean hasPayments = false;
                                    while (rs.next()) {
                                        hasPayments = true;
                                        int payId = rs.getInt("payment_id");
                                        String student = rs.getString("student_name");
                                        String item = rs.getString("payment_for");
                                        String amount = rs.getString("amount");
                                        String type = rs.getString("payment_type");
                                        String status = rs.getString("payment_status");
                                        
                                        String statusBadge = "bg-warning-tint text-warning";
                                        if ("Paid".equalsIgnoreCase(status)) statusBadge = "bg-success-tint text-success";
                                        else if ("Failed".equalsIgnoreCase(status)) statusBadge = "bg-danger-tint text-danger";
                                        
                                        String typeBadge = "bg-info-tint text-info";
                                        if ("Subscription".equalsIgnoreCase(type)) typeBadge = "bg-primary-tint text-primary";
                            %>
                            <tr>
                                <td>#EE-PAY-<%= payId %></td>
                                <td class="fw-bold"><%= student %></td>
                                <td><%= item %></td>
                                <td><span class="badge <%= typeBadge %> px-2.5 py-1.5"><%= type %></span></td>
                                <td class="fw-bold text-success">₹<%= amount %></td>
                                <td><span class="badge <%= statusBadge %> px-2.5 py-1.5"><%= status %></span></td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    conn.close();
                                    
                                    if (!hasPayments) {
                            %>
                            <tr>
                                <td colspan="6" class="text-center text-muted py-5">
                                    <i class="bi bi-credit-card-2-front fs-1 mb-2 d-block"></i>
                                    No payment transaction history records found.
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                            %>
                            <tr>
                                <td colspan="6" class="text-center text-danger py-4">Database load error.</td>
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
