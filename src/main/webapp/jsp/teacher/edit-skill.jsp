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
    request.setAttribute("activePage", "my-skills");
    
    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
        response.sendRedirect("view-my-skills.jsp?error=invalid_id");
        return;
    }
    
    int skillId = Integer.parseInt(idStr);
    String title = "";
    String category = "";
    String description = "";
    String price = "";
    
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT * FROM skills WHERE skill_id = ? AND teacher_name = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, skillId);
        ps.setString(2, teacherName);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            title = rs.getString("skill_title");
            category = rs.getString("category");
            description = rs.getString("description");
            price = rs.getString("price");
        } else {
            response.sendRedirect("view-my-skills.jsp?error=not_found");
            return;
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("view-my-skills.jsp?error=db_error");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Skill - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Edit Skill Course</h2>
                    <p class="text-muted mb-0">Modify details of your published learning course.</p>
                </div>
            </div>

            <!-- Form Card -->
            <div class="row">
                <div class="col-lg-8">
                    <div class="content-card">
                        <form action="../../EditSkillServlet" method="post">
                            <input type="hidden" name="skill_id" value="<%= skillId %>">
                            
                            <div class="mb-4">
                                <label for="skill_title" class="form-label fw-bold">Skill Title</label>
                                <input type="text" id="skill_title" name="skill_title" class="form-control" value="<%= title %>" required>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label for="category" class="form-label fw-bold">Category</label>
                                    <select id="category" name="category" class="form-select" required>
                                        <option value="Technology" <%= "Technology".equals(category) ? "selected" : "" %>>Technology</option>
                                        <option value="Music" <%= "Music".equals(category) ? "selected" : "" %>>Music</option>
                                        <option value="Arts & Crafts" <%= "Arts & Crafts".equals(category) ? "selected" : "" %>>Arts & Crafts</option>
                                        <option value="Cooking" <%= "Cooking".equals(category) ? "selected" : "" %>>Cooking</option>
                                        <option value="Languages" <%= "Languages".equals(category) ? "selected" : "" %>>Languages</option>
                                        <option value="Business" <%= "Business".equals(category) ? "selected" : "" %>>Business</option>
                                        <option value="Tuition" <%= "Tuition".equals(category) ? "selected" : "" %>>Tuition</option>
                                        <option value="Fitness & Yoga" <%= "Fitness & Yoga".equals(category) ? "selected" : "" %>>Fitness & Yoga</option>
                                        <option value="Agriculture" <%= "Agriculture".equals(category) ? "selected" : "" %>>Agriculture</option>
                                        <option value="Handicrafts" <%= "Handicrafts".equals(category) ? "selected" : "" %>>Handicrafts</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="price" class="form-label fw-bold">Price (₹ per Month)</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light text-muted">₹</span>
                                        <input type="number" id="price" name="price" min="0" step="1" class="form-control" value="<%= price %>" required>
                                    </div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="description" class="form-label fw-bold">Detailed Description</label>
                                <textarea id="description" name="description" class="form-control" rows="6" required><%= description %></textarea>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-custom btn-custom-primary px-4"><i class="bi bi-save-fill me-1"></i> Save Changes</button>
                                <a href="view-my-skills.jsp" class="btn btn-light border px-4">Cancel</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
