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
    request.setAttribute("activePage", "upload-video");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Video - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Upload Recorded Class</h2>
                    <p class="text-muted mb-0">Publish recorded video lectures and tutorials for your students.</p>
                </div>
                <a href="my-videos.jsp" class="btn btn-outline-secondary rounded-pill px-4"><i class="bi bi-collection-play me-1"></i> Manage Videos</a>
            </div>

            <div class="content-card">
                <form action="../../UploadVideoServlet" method="post" enctype="multipart/form-data" class="row g-3">
                    <div class="col-md-6">
                        <label for="course_name" class="form-label fw-semibold">Link to Skill Course</label>
                        <select id="course_name" name="course_name" class="form-select" required>
                            <option value="">-- Select Course --</option>
                            <%
                                Connection conn = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT skill_title FROM skills WHERE teacher_name = ? ORDER BY skill_id DESC";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setString(1, teacherName);
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                                        String title = rs.getString("skill_title");
                            %>
                                <option value="<%= title %>"><%= title %></option>
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
                        <div class="form-text small">Select the course list item to group this video under.</div>
                    </div>

                    <div class="col-md-6">
                        <label for="video_title" class="form-label fw-semibold">Video Title</label>
                        <input type="text" id="video_title" name="video_title" class="form-control" placeholder="e.g. Chapter 1: Introduction to Knitting" required>
                    </div>

                    <div class="col-md-6">
                        <label for="category" class="form-label fw-semibold">Category</label>
                        <select id="category" name="category" class="form-select" required>
                            <option value="Technology">Technology</option>
                            <option value="Music">Music</option>
                            <option value="Arts & Crafts">Arts & Crafts</option>
                            <option value="Cooking">Cooking</option>
                            <option value="Languages">Languages</option>
                            <option value="Business">Business</option>
                            <option value="Tuition">Tuition</option>
                            <option value="Fitness & Yoga">Fitness & Yoga</option>
                            <option value="Agriculture">Agriculture</option>
                            <option value="Handicrafts">Handicrafts</option>
                        </select>
                    </div>

                    <div class="col-md-6">
                        <label for="duration" class="form-label fw-semibold">Duration</label>
                        <input type="text" id="duration" name="duration" class="form-control" placeholder="e.g. 15 mins, 1 hour" required>
                    </div>

                    <div class="col-md-6">
                        <label for="thumbnail" class="form-label fw-semibold">Upload Thumbnail Photo</label>
                        <input type="file" id="thumbnail" name="thumbnail" accept="image/*" class="form-control" required>
                    </div>

                    <div class="col-md-6">
                        <label for="video_file" class="form-label fw-semibold">Upload Video File (MP4, AVI, MOV, MKV)</label>
                        <input type="file" id="video_file" name="video_file" accept="video/*" class="form-control" required>
                    </div>

                    <div class="col-12">
                        <div class="form-check form-switch p-3 bg-light rounded-4">
                            <input class="form-check-input ms-0 me-2" type="checkbox" id="preview_enabled" name="preview_enabled" value="Yes">
                            <label class="form-check-label fw-semibold" for="preview_enabled">Enable Preview (Allow unsubscribed students to watch this video as a demo)</label>
                        </div>
                    </div>

                    <div class="col-12">
                        <label for="description" class="form-label fw-semibold">Video Description</label>
                        <textarea id="description" name="description" class="form-control" rows="4" placeholder="Describe the topics covered in this lesson..." required></textarea>
                    </div>

                    <div class="col-12 mt-4 text-end">
                        <button type="submit" class="btn btn-custom btn-custom-primary rounded-pill px-5 py-2.5"><i class="bi bi-cloud-arrow-up-fill me-1"></i> Upload & Notify Students</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
