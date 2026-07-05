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
    request.setAttribute("activePage", "subscribers");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Subscribers - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">My Subscribers</h2>
                    <p class="text-muted mb-0">Authorize or revoke student access based on payment confirmations.</p>
                </div>
            </div>

            <!-- Context Alerts -->
            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                
                if ("authorize".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Student access authorized successfully.
                </div>
            <%
                } else if ("unauthorize".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Student access revoked successfully.
                </div>
            <%
                }
                
                if ("not_authorized".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> You are not authorized to manage this subscription.
                </div>
            <%
                } else if ("db_error".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> Database error occurred. Please try again.
                </div>
            <%
                }
            %>

            <!-- Subscribers Table -->
            <div class="content-card">
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>Student Name</th>
                                <th>Course Title</th>
                                <th>Amount</th>
                                <th>Payment Status</th>
                                <th>Access Status</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT * FROM subscriptions WHERE teacher_name = ? ORDER BY subscription_id DESC";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setString(1, teacherName);
                                    ResultSet rs = ps.executeQuery();
                                    
                                    boolean hasSubscribers = false;
                                    while (rs.next()) {
                                        hasSubscribers = true;
                                        int id = rs.getInt("subscription_id");
                                        String student = rs.getString("student_name");
                                        String course = rs.getString("course_name");
                                        String amount = rs.getString("amount");
                                        String payStatus = rs.getString("payment_status");
                                        String accStatus = rs.getString("access_status");
                                        
                                        String accBadge = "bg-warning-tint text-warning";
                                        if ("Active".equalsIgnoreCase(accStatus)) accBadge = "bg-success-tint text-success";
                                        else if ("Expired".equalsIgnoreCase(accStatus)) accBadge = "bg-danger-tint text-danger";
                                        
                                        String payBadge = "bg-warning-tint text-warning";
                                        if ("Paid".equalsIgnoreCase(payStatus)) payBadge = "bg-success-tint text-success";
                                        else if ("Failed".equalsIgnoreCase(payStatus)) payBadge = "bg-danger-tint text-danger";
                            %>
                            <tr>
                                <td class="fw-bold"><%= student %></td>
                                <td><%= course %></td>
                                <td class="fw-bold">₹<%= amount %></td>
                                <td><span class="badge <%= payBadge %> px-2.5 py-1.5"><%= payStatus %></span></td>
                                <td><span class="badge <%= accBadge %> px-2.5 py-1.5"><%= accStatus %></span></td>
                                <td class="text-end">
                                    <div class="d-flex justify-content-end gap-2">
                                        <% if (!"Active".equalsIgnoreCase(accStatus)) { %>
                                            <a href="../../ManageSubscriptionServlet?sub_id=<%= id %>&action=authorize" class="btn btn-custom-sm btn-success"><i class="bi bi-shield-check"></i> Authorize</a>
                                        <% } else { %>
                                            <a href="../../ManageSubscriptionServlet?sub_id=<%= id %>&action=unauthorize" class="btn btn-custom-sm btn-danger"><i class="bi bi-shield-slash"></i> Revoke</a>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    conn.close();
                                    
                                    if (!hasSubscribers) {
                            %>
                            <tr>
                                <td colspan="6" class="text-center text-muted py-5">
                                    <i class="bi bi-people fs-1 mb-2 d-block"></i>
                                    No students have subscribed to your skills yet.
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
