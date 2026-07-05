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
    request.setAttribute("activePage", "profile");

    String bio = "";
    String qualifications = "";
    String skills = "";
    int experience = 0;
    String languages = "";
    String email = "";
    String phone = "";
    String photo = "";
    String social = "";

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT * FROM teacher_profiles WHERE teacher_name = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, teacherName);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            bio = rs.getString("bio");
            if (bio == null) bio = "";
            qualifications = rs.getString("qualifications");
            if (qualifications == null) qualifications = "";
            skills = rs.getString("skills_expertise");
            if (skills == null) skills = "";
            experience = rs.getInt("experience_years");
            languages = rs.getString("languages");
            if (languages == null) languages = "";
            email = rs.getString("contact_email");
            if (email == null) email = "";
            phone = rs.getString("phone");
            if (phone == null) phone = "";
            photo = rs.getString("photo_path");
            if (photo == null) photo = "";
            social = rs.getString("social_links");
            if (social == null) social = "";
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
    <title>Edit Profile - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Edit Professional Profile</h2>
                    <p class="text-muted mb-0">Build your credibility. Students will see this information on your profile page.</p>
                </div>
                <a href="my-profile.jsp" class="btn btn-outline-secondary rounded-pill px-4"><i class="bi bi-arrow-left me-1"></i> Back to Profile</a>
            </div>

            <div class="content-card">
                <form action="../../UpdateProfileServlet" method="post" class="row g-3">
                    <div class="col-md-6">
                        <label for="photo" class="form-label fw-semibold">Profile Photo Link/Name</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="bi bi-image"></i></span>
                            <input type="text" id="photo" name="photo" class="form-control" placeholder="e.g. avatar.png or URL" value="<%= photo %>">
                        </div>
                        <div class="form-text small">Provide an image file path or URL for your profile picture.</div>
                    </div>

                    <div class="col-md-6">
                        <label for="social" class="form-label fw-semibold">Social Media / Website Link</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="bi bi-linkedin"></i></span>
                            <input type="url" id="social" name="social" class="form-control" placeholder="e.g. https://linkedin.com/in/username" value="<%= social %>">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <label for="qualifications" class="form-label fw-semibold">Qualifications</label>
                        <input type="text" id="qualifications" name="qualifications" class="form-control" placeholder="e.g. Retired Professor, B.Ed" value="<%= qualifications %>" required>
                    </div>

                    <div class="col-md-6">
                        <label for="skills" class="form-label fw-semibold">Skills & Expertise</label>
                        <input type="text" id="skills" name="skills" class="form-control" placeholder="e.g. Knitting, Violin, Calculus" value="<%= skills %>" required>
                    </div>

                    <div class="col-md-4">
                        <label for="experience" class="form-label fw-semibold">Years of Experience</label>
                        <input type="number" id="experience" name="experience" class="form-control" placeholder="e.g. 15" value="<%= experience %>" min="0" required>
                    </div>

                    <div class="col-md-8">
                        <label for="languages" class="form-label fw-semibold">Languages Known</label>
                        <input type="text" id="languages" name="languages" class="form-control" placeholder="e.g. English, Hindi, Spanish" value="<%= languages %>" required>
                    </div>

                    <div class="col-md-6">
                        <label for="email" class="form-label fw-semibold">Contact Email (Optional)</label>
                        <input type="email" id="email" name="email" class="form-control" placeholder="e.g. contact@example.com" value="<%= email %>">
                    </div>

                    <div class="col-md-6">
                        <label for="phone" class="form-label fw-semibold">Contact Phone (Optional)</label>
                        <input type="text" id="phone" name="phone" class="form-control" placeholder="e.g. +91 9876543210" value="<%= phone %>">
                    </div>

                    <div class="col-12">
                        <label for="bio" class="form-label fw-semibold">Professional Bio</label>
                        <textarea id="bio" name="bio" class="form-control" rows="5" placeholder="Share your story, experience, and why you love teaching seniors/youth..." required><%= bio %></textarea>
                    </div>

                    <div class="col-12 mt-4 text-end">
                        <button type="submit" class="btn btn-custom btn-custom-primary rounded-pill px-5 py-2.5"><i class="bi bi-save-fill me-1"></i> Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
