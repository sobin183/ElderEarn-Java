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
    request.setAttribute("activePage", "my-learning");

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("student-dashboard.jsp");
        return;
    }

    int videoId = Integer.parseInt(idStr);
    String title = "";
    String course = "";
    String teacher = "";
    String path = "";
    String preview = "";
    String desc = "";
    boolean allowed = false;

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        
        // Fetch video details
        String sql = "SELECT * FROM videos WHERE video_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, videoId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            title = rs.getString("video_title");
            course = rs.getString("course_name");
            teacher = rs.getString("teacher_name");
            path = rs.getString("video_path");
            preview = rs.getString("preview_enabled");
            desc = rs.getString("description");
        }
        rs.close();
        ps.close();
        
        // Check access permission
        if ("Yes".equalsIgnoreCase(preview)) {
            allowed = true;
        } else {
            // Check if active subscription exists
            String subSql = "SELECT COUNT(*) FROM subscriptions WHERE student_name = ? AND course_name = ? AND teacher_name = ? AND access_status = 'Active'";
            PreparedStatement subPs = conn.prepareStatement(subSql);
            subPs.setString(1, studentName);
            subPs.setString(2, course);
            subPs.setString(3, teacher);
            ResultSet subRs = subPs.executeQuery();
            if (subRs.next()) {
                allowed = (subRs.getInt(1) > 0);
            }
            subRs.close();
            subPs.close();
        }
        
        // Increment views count if allowed
        if (allowed) {
            String incSql = "UPDATE videos SET views_count = views_count + 1 WHERE video_id = ?";
            PreparedStatement incPs = conn.prepareStatement(incSql);
            incPs.setInt(1, videoId);
            incPs.executeUpdate();
            incPs.close();
        }
        
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Watch Video - Student Portal</title>
    
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
                    <h2 class="fw-bold mb-1"><%= title %></h2>
                    <p class="text-muted mb-0">Course: <strong><%= course %></strong> | Instructor: <strong><%= teacher %></strong></p>
                </div>
                <a href="teacher-profile.jsp?teacher=<%= java.net.URLEncoder.encode(teacher, "UTF-8") %>" class="btn btn-outline-secondary rounded-pill px-4"><i class="bi bi-arrow-left me-1"></i> Back to Profile</a>
            </div>

            <div class="row">
                <div class="col-lg-9 mx-auto">
                    <% if (allowed) { %>
                    <!-- Responsive Video Frame -->
                    <div class="content-card p-0 overflow-hidden mb-4" style="border-radius: 20px;">
                        <div class="ratio ratio-16x9 bg-dark">
                            <%
                                String thumbPath = "";
                                try {
                                    String thumbSql = "SELECT thumbnail_path FROM videos WHERE video_id = ?";
                                    PreparedStatement thumbPs = conn.prepareStatement(thumbSql);
                                    thumbPs.setInt(1, videoId);
                                    ResultSet thumbRs = thumbPs.executeQuery();
                                    if (thumbRs.next()) {
                                        thumbPath = thumbRs.getString("thumbnail_path");
                                    }
                                    thumbRs.close();
                                    thumbPs.close();
                                } catch(Exception e){}
                            %>
                            <video src="../../<%= path %>" poster="../../<%= thumbPath %>" controls class="w-100 h-100" style="object-fit: cover;"></video>
                        </div>
                    </div>
                    
                    <div class="content-card">
                        <h5 class="fw-bold mb-3">About this lesson</h5>
                        <p class="text-muted"><%= desc %></p>
                    </div>
                    <% } else { %>
                    <!-- Locked / Paywall Alert Screen -->
                    <div class="content-card text-center py-5">
                        <div class="p-4 bg-danger bg-opacity-10 text-danger rounded-circle d-inline-flex mb-4">
                            <i class="bi bi-lock-fill fs-1"></i>
                        </div>
                        <h3 class="fw-bold text-dark mb-2">Lesson Material Locked</h3>
                        <p class="text-muted mx-auto mb-4" style="max-width: 500px;">
                            This video is available only for subscribed students.
                        </p>
                        <a href="teacher-profile.jsp?teacher=<%= java.net.URLEncoder.encode(teacher, "UTF-8") %>" class="btn btn-custom btn-custom-primary rounded-pill px-5 py-2.5">
                            <i class="bi bi-bookmark-plus-fill me-1"></i> View Subscription Options
                        </a>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%
    if (conn != null) {
        try { conn.close(); } catch(Exception e) {}
    }
%>
