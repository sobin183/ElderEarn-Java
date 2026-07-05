<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    request.setAttribute("activePage", "my-subscriptions");
    String studentName = (String) session.getAttribute("full_name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Subscriptions - Student Portal</title>
    
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
                    <h2 class="fw-bold mb-1">My Subscriptions</h2>
                    <p class="text-muted mb-0">Track your active class subscriptions and access credentials.</p>
                </div>
                <div>
                    <a href="browse-skills.jsp" class="btn btn-custom btn-custom-primary"><i class="bi bi-search me-1"></i> Browse Skills</a>
                </div>
            </div>

            <!-- Subscriptions Table -->
            <div class="content-card">
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>Course Name</th>
                                <th>Teacher</th>
                                <th>Price</th>
                                <th>Access Status</th>
                                <th>Action Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT * FROM subscriptions WHERE student_name = ? ORDER BY subscription_id DESC";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setString(1, studentName);
                                    ResultSet rs = ps.executeQuery();
                                    
                                    boolean hasSubs = false;
                                    while (rs.next()) {
                                        hasSubs = true;
                                        String course = rs.getString("course_name");
                                        String teacher = rs.getString("teacher_name");
                                        String price = rs.getString("amount");
                                        String status = rs.getString("access_status");
                                        
                                        String badgeClass = "bg-warning-tint text-warning";
                                        String note = "Waiting for teacher confirmation";
                                        
                                        if ("Active".equalsIgnoreCase(status)) {
                                            badgeClass = "bg-success-tint text-success";
                                            note = "Class materials unlocked";
                                        } else if ("Expired".equalsIgnoreCase(status)) {
                                            badgeClass = "bg-danger-tint text-danger";
                                            note = "Subscription plan ended";
                                        }
                            %>
                            <tr>
                                <td class="fw-bold"><%= course %></td>
                                <td><%= teacher %></td>
                                <td class="fw-bold text-success">₹<%= price %>/mo</td>
                                <td><span class="badge <%= badgeClass %> px-2.5 py-1.5"><%= status %></span></td>
                                <td>
                                    <span class="small text-muted">
                                        <% if ("Active".equalsIgnoreCase(status)) { %>
                                            <i class="bi bi-unlock-fill text-success me-1"></i> <%= note %>
                                        <% } else { %>
                                            <i class="bi bi-lock-fill text-warning me-1"></i> <%= note %>
                                        <% } %>
                                    </span>
                                </td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    conn.close();
                                    
                                    if (!hasSubs) {
                            %>
                            <tr>
                                <td colspan="5" class="text-center text-muted py-5">
                                    <i class="bi bi-journal-x fs-1 mb-2 d-block"></i>
                                    You have not subscribed to any skill courses yet.
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                            %>
                            <tr>
                                <td colspan="5" class="text-center text-danger py-4">Database load error.</td>
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
