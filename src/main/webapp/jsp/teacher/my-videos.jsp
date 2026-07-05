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
    request.setAttribute("activePage", "my-videos");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Videos - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">My Videos</h2>
                    <p class="text-muted mb-0">Manage your educational videos and recorded learning material.</p>
                </div>
                <a href="upload-video.jsp" class="btn btn-custom btn-custom-primary rounded-pill px-4"><i class="bi bi-plus-circle-fill me-1"></i> Upload New Video</a>
            </div>

            <!-- Context Alerts -->
            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                
                if ("uploaded".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Video uploaded successfully and subscribers notified!
                </div>
            <%
                } else if ("updated".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Video details updated successfully.
                </div>
            <%
                } else if ("deleted".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Video deleted successfully.
                </div>
            <%
                }
            %>

            <%
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    
                    // Get distinct categories for this teacher
                    String catSql = "SELECT DISTINCT category FROM videos WHERE teacher_name = ? ORDER BY category ASC";
                    PreparedStatement catPs = conn.prepareStatement(catSql);
                    catPs.setString(1, teacherName);
                    ResultSet catRs = catPs.executeQuery();
                    
                    boolean hasPlaylists = false;
                    while (catRs.next()) {
                        hasPlaylists = true;
                        String categoryName = catRs.getString("category");
            %>
            
            <!-- Category Playlist Header -->
            <div class="d-flex align-items-center gap-2 mb-3 mt-4">
                <div class="p-2 bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center" style="width: 38px; height: 38px;">
                    <i class="bi bi-collection-play-fill"></i>
                </div>
                <h5 class="fw-bold mb-0 text-dark">Category Playlist: <%= categoryName %></h5>
            </div>

            <!-- Videos List Table for Category -->
            <div class="content-card mb-4">
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>Thumbnail</th>
                                <th>Video Title</th>
                                <th>Skill Course</th>
                                <th>Duration</th>
                                <th>Views</th>
                                <th>Preview?</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                String sql = "SELECT * FROM videos WHERE teacher_name = ? AND category = ? ORDER BY video_id DESC";
                                PreparedStatement ps = conn.prepareStatement(sql);
                                ps.setString(1, teacherName);
                                ps.setString(2, categoryName);
                                ResultSet rs = ps.executeQuery();
                                
                                while (rs.next()) {
                                    int id = rs.getInt("video_id");
                                    String title = rs.getString("video_title");
                                    String course = rs.getString("course_name");
                                    String duration = rs.getString("duration");
                                    int views = rs.getInt("views_count");
                                    String preview = rs.getString("preview_enabled");
                                    String thumb = rs.getString("thumbnail_path");
                                    
                                    String previewBadge = "bg-warning-tint text-warning";
                                    if ("Yes".equalsIgnoreCase(preview)) previewBadge = "bg-success-tint text-success";
                            %>
                            <tr>
                                <td style="width: 100px;">
                                    <div class="rounded-3 bg-light d-flex align-items-center justify-content-center text-secondary overflow-hidden" style="height: 55px; width: 90px; border: 1px solid rgba(0,0,0,0.08);">
                                        <% if (thumb != null && !thumb.isEmpty() && !"default_thumb.jpg".equals(thumb)) { %>
                                            <img src="../../<%= thumb %>" alt="thumbnail" style="width: 100%; height: 100%; object-fit: cover;">
                                        <% } else { %>
                                            <i class="bi bi-play-btn-fill fs-3 text-muted"></i>
                                        <% } %>
                                    </div>
                                </td>
                                <td>
                                    <h6 class="fw-bold mb-0"><%= title %></h6>
                                    <span class="small text-muted"><%= rs.getTimestamp("created_at").toString().split(" ")[0] %></span>
                                </td>
                                <td><%= course %></td>
                                <td><%= duration %></td>
                                <td class="fw-bold text-info"><%= views %> views</td>
                                <td><span class="badge <%= previewBadge %> px-2.5 py-1.5"><%= preview %></span></td>
                                <td class="text-end">
                                    <div class="d-flex gap-2 justify-content-end">
                                        <a href="edit-video.jsp?id=<%= id %>" class="btn btn-custom-sm btn-outline-primary"><i class="bi bi-pencil-fill"></i> Edit</a>
                                        <a href="../../DeleteVideoServlet?id=<%= id %>" onclick="return confirm('Are you sure you want to delete this video?');" class="btn btn-custom-sm btn-outline-danger"><i class="bi bi-trash3-fill"></i> Delete</a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                }
                                rs.close();
                                ps.close();
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <%
                    }
                    catRs.close();
                    catPs.close();
                    
                    if (!hasPlaylists) {
            %>
            <div class="content-card text-center text-muted py-5">
                <i class="bi bi-collection-play fs-1 mb-2 d-block"></i>
                You have not uploaded any educational videos yet. Grouped playlists will appear here once you upload.
            </div>
            <%
                    }
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
            %>
            <div class="content-card text-center text-danger py-4">Database load error.</div>
            <%
                }
            %>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
