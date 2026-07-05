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
    request.setAttribute("activePage", "video-analytics");

    int totalVideos = 0;
    int totalViews = 0;
    int totalSubs = 0;

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        
        // Total videos
        String vSql = "SELECT COUNT(*), SUM(views_count) FROM videos WHERE teacher_name = ?";
        PreparedStatement vPs = conn.prepareStatement(vSql);
        vPs.setString(1, teacherName);
        ResultSet vRs = vPs.executeQuery();
        if (vRs.next()) {
            totalVideos = vRs.getInt(1);
            totalViews = vRs.getInt(2);
        }
        vRs.close();
        vPs.close();

        // Total subscribers
        String sSql = "SELECT COUNT(DISTINCT student_name) FROM subscriptions WHERE teacher_name = ? AND access_status = 'Active'";
        PreparedStatement sPs = conn.prepareStatement(sSql);
        sPs.setString(1, teacherName);
        ResultSet sRs = sPs.executeQuery();
        if (sRs.next()) {
            totalSubs = sRs.getInt(1);
        }
        sRs.close();
        sPs.close();
        
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Video Analytics - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Video Analytics</h2>
                    <p class="text-muted mb-0">Track engagement, view counts, and reach metrics for your lectures.</p>
                </div>
            </div>

            <!-- Stats Metric Cards -->
            <div class="row g-4 mb-5">
                <div class="col-md-4">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Total Video Lectures</h6>
                            <h2><%= totalVideos %></h2>
                        </div>
                        <div class="metric-card-icon bg-primary-tint">
                            <i class="bi bi-collection-play-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Total Video Views</h6>
                            <h2><%= totalViews %></h2>
                        </div>
                        <div class="metric-card-icon bg-info-tint">
                            <i class="bi bi-eye-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Active Course Subscribers</h6>
                            <h2><%= totalSubs %></h2>
                        </div>
                        <div class="metric-card-icon bg-success-tint">
                            <i class="bi bi-people-fill"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Video Popularity Table -->
            <div class="content-card">
                <h5 class="content-card-title mb-4"><i class="bi bi-bar-chart-line-fill text-primary"></i> Performance by Lecture</h5>
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>Lecture Title</th>
                                <th>Linked Skill Course</th>
                                <th>Category</th>
                                <th>Preview Allowed?</th>
                                <th>Total Views</th>
                                <th>Percentage of Total Views</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    String sql = "SELECT * FROM videos WHERE teacher_name = ? ORDER BY views_count DESC";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setString(1, teacherName);
                                    ResultSet rs = ps.executeQuery();
                                    
                                    boolean hasVideos = false;
                                    while (rs.next()) {
                                        hasVideos = true;
                                        String title = rs.getString("video_title");
                                        String course = rs.getString("course_name");
                                        String category = rs.getString("category");
                                        String preview = rs.getString("preview_enabled");
                                        int views = rs.getInt("views_count");
                                        
                                        double pct = totalViews > 0 ? ((double)views / totalViews) * 100 : 0.0;
                            %>
                            <tr>
                                <td class="fw-bold"><%= title %></td>
                                <td><%= course %></td>
                                <td><span class="badge bg-primary-tint text-primary px-2.5 py-1.5"><%= category %></span></td>
                                <td>
                                    <span class="badge <%= "Yes".equalsIgnoreCase(preview) ? "bg-success-tint text-success" : "bg-warning-tint text-warning" %> px-2.5 py-1.5"><%= preview %></span>
                                </td>
                                <td class="fw-bold text-info"><%= views %> views</td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="progress flex-grow-1" style="height: 8px; border-radius: 4px;">
                                            <div class="progress-bar bg-info" role="progressbar" style="width: <%= pct %>%;"></div>
                                        </div>
                                        <span class="small fw-semibold"><%= String.format("%.1f", pct) %>%</span>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    if (conn != null) conn.close();
                                    
                                    if (!hasVideos) {
                            %>
                            <tr>
                                <td colspan="6" class="text-center text-muted py-5">No metrics logs logged yet.</td>
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
