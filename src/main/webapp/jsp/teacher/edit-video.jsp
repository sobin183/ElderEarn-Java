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

    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("my-videos.jsp");
        return;
    }

    int videoId = Integer.parseInt(idStr);
    String courseName = "";
    String videoTitle = "";
    String category = "";
    String description = "";
    String duration = "";
    String thumbnail = "";
    String videoFile = "";
    String previewEnabled = "";

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT * FROM videos WHERE video_id = ? AND teacher_name = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, videoId);
        ps.setString(2, teacherName);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            courseName = rs.getString("course_name");
            videoTitle = rs.getString("video_title");
            category = rs.getString("category");
            description = rs.getString("description");
            duration = rs.getString("duration");
            thumbnail = rs.getString("thumbnail_path");
            videoFile = rs.getString("video_path");
            previewEnabled = rs.getString("preview_enabled");
        } else {
            rs.close();
            ps.close();
            conn.close();
            response.sendRedirect("my-videos.jsp?error=not_found");
            return;
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Video - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Edit Video Details</h2>
                    <p class="text-muted mb-0">Modify video metadata and settings.</p>
                </div>
                <a href="my-videos.jsp" class="btn btn-outline-secondary rounded-pill px-4"><i class="bi bi-arrow-left me-1"></i> Back to Catalog</a>
            </div>

            <div class="content-card">
                <form action="../../EditVideoServlet" method="post" class="row g-3">
                    <input type="hidden" name="video_id" value="<%= videoId %>">
                    
                    <div class="col-md-6">
                        <label for="course_name" class="form-label fw-semibold">Linked Skill Course</label>
                        <select id="course_name" name="course_name" class="form-select" required>
                            <%
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT skill_title FROM skills WHERE teacher_name = ? ORDER BY skill_id DESC";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setString(1, teacherName);
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                                        String title = rs.getString("skill_title");
                                        boolean isSelected = title.equals(courseName);
                            %>
                                <option value="<%= title %>" <%= isSelected ? "selected" : "" %>><%= title %></option>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    conn.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            %>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label for="video_title" class="form-label fw-semibold">Video Title</label>
                        <input type="text" id="video_title" name="video_title" class="form-control" value="<%= videoTitle %>" required>
                    </div>

                    <div class="col-md-6">
                        <label for="category" class="form-label fw-semibold">Category</label>
                        <select id="category" name="category" class="form-select" required>
                            <%
                                String[] cats = {"Technology", "Music", "Arts & Crafts", "Cooking", "Languages", "Business", "Tuition", "Fitness & Yoga", "Agriculture", "Handicrafts"};
                                for (String c : cats) {
                            %>
                                <option value="<%= c %>" <%= c.equals(category) ? "selected" : "" %>><%= c %></option>
                            <%
                                }
                            %>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label for="duration" class="form-label fw-semibold">Duration</label>
                        <input type="text" id="duration" name="duration" class="form-control" value="<%= duration %>" required>
                    </div>

                    <div class="col-md-6">
                        <label for="thumbnail" class="form-label fw-semibold">Thumbnail Image File/URL</label>
                        <input type="text" id="thumbnail" name="thumbnail" class="form-control" value="<%= thumbnail %>" required>
                    </div>

                    <div class="col-md-6">
                        <label for="video_file" class="form-label fw-semibold">Video File Name</label>
                        <input type="text" id="video_file" name="video_file" class="form-control" value="<%= videoFile %>" required>
                    </div>

                    <div class="col-12">
                        <div class="form-check form-switch p-3 bg-light rounded-4">
                            <input class="form-check-input ms-0 me-2" type="checkbox" id="preview_enabled" name="preview_enabled" value="Yes" <%= "Yes".equalsIgnoreCase(previewEnabled) ? "checked" : "" %>>
                            <label class="form-check-label fw-semibold" for="preview_enabled">Enable Preview (Allow unsubscribed students to watch this video as a demo)</label>
                        </div>
                    </div>

                    <div class="col-12">
                        <label for="description" class="form-label fw-semibold">Video Description</label>
                        <textarea id="description" name="description" class="form-control" rows="4" required><%= description %></textarea>
                    </div>

                    <div class="col-12 mt-4 text-end">
                        <button type="submit" class="btn btn-custom btn-custom-primary rounded-pill px-5 py-2.5"><i class="bi bi-save-fill me-1"></i> Update Details</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
