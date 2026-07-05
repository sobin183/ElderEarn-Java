<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    String studentName = (String) session.getAttribute("full_name");
    String role = (String) session.getAttribute("role");
    if (studentName == null || !"student".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp?error=invalid_role");
        return;
    }
    request.setAttribute("activePage", "notifications");

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        
        // Mark all as read when opening notifications page
        String readSql = "UPDATE notifications SET is_read = 1 WHERE user_name = ?";
        PreparedStatement readPs = conn.prepareStatement(readSql);
        readPs.setString(1, studentName);
        readPs.executeUpdate();
        readPs.close();
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications - Student Portal</title>
    
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
                    <h2 class="fw-bold mb-1">My Notifications</h2>
                    <p class="text-muted mb-0">Stay updated on your chat replies, subscription statuses, and new lectures.</p>
                </div>
            </div>

            <!-- Notifications List -->
            <div class="content-card">
                <div class="d-flex flex-column gap-3">
                    <%
                        try {
                            String sql = "SELECT * FROM notifications WHERE user_name = ? ORDER BY notification_id DESC";
                            PreparedStatement ps = conn.prepareStatement(sql);
                            ps.setString(1, studentName);
                            ResultSet rs = ps.executeQuery();
                            
                            boolean hasNotifications = false;
                            while (rs.next()) {
                                hasNotifications = true;
                                String text = rs.getString("message_text");
                                Timestamp t = rs.getTimestamp("created_at");
                                String dateStr = t != null ? t.toString() : "N/A";
                                int isRead = rs.getInt("is_read");
                    %>
                    <div class="p-3 border rounded-4 d-flex align-items-center justify-content-between <%= isRead == 0 ? "bg-light fw-bold" : "" %>">
                        <div class="d-flex align-items-center gap-3">
                            <div class="p-2 bg-info bg-opacity-10 text-info rounded-circle d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                                <i class="bi bi-bell-fill"></i>
                            </div>
                            <div>
                                <p class="mb-0 text-dark small"><%= text %></p>
                                <span class="small text-muted" style="font-size: 0.75rem;"><%= dateStr %></span>
                            </div>
                        </div>
                        <% if (isRead == 0) { %>
                            <span class="badge bg-danger rounded-pill">New</span>
                        <% } %>
                    </div>
                    <%
                            }
                            rs.close();
                            ps.close();
                            conn.close();
                            
                            if (!hasNotifications) {
                    %>
                    <div class="text-center text-muted py-5">
                        <i class="bi bi-bell-slash fs-1 mb-2 d-block"></i>
                        You have no notifications yet.
                    </div>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
