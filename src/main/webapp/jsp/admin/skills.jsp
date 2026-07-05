<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    request.setAttribute("activePage", "skills");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Skills - Admin Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Manage Skills & Courses</h2>
                    <p class="text-muted mb-0">Monitor, filter, and delete active learning listings across the entire system.</p>
                </div>
            </div>

            <!-- Context Alerts -->
            <%
                String success = request.getParameter("success");
                if ("deleted".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Skill course deleted successfully.
                </div>
            <%
                }
            %>

            <!-- Filters -->
            <div class="content-card py-3 mb-4">
                <form action="skills.jsp" method="get" class="row g-3">
                    <div class="col-md-6 col-lg-5">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" name="search" class="form-control border-start-0" placeholder="Search by title, teacher, or description..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                        </div>
                    </div>
                    <div class="col-md-4 col-lg-4">
                        <select name="category" class="form-select">
                            <option value="">All Categories</option>
                            <%
                                String[] cats = {"Technology", "Music", "Arts & Crafts", "Cooking", "Languages", "Business", "Tuition", "Fitness & Yoga", "Agriculture", "Handicrafts"};
                                String currentCat = request.getParameter("category");
                                for (String c : cats) {
                            %>
                                <option value="<%= c %>" <%= c.equals(currentCat) ? "selected" : "" %>><%= c %></option>
                            <%
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-2 col-lg-3 d-flex gap-2">
                        <button type="submit" class="btn btn-custom btn-custom-primary w-100"><i class="bi bi-funnel-fill me-1"></i> Filter</button>
                        <a href="skills.jsp" class="btn btn-light border"><i class="bi bi-arrow-counterclockwise"></i></a>
                    </div>
                </form>
            </div>

            <!-- Skills List Table -->
            <div class="content-card">
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Skill Course Title</th>
                                <th>Teacher/Instructor</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    String search = request.getParameter("search");
                                    String cat = request.getParameter("category");
                                    
                                    String sql = "SELECT * FROM skills WHERE 1=1";
                                    if (search != null && !search.trim().isEmpty()) {
                                        sql += " AND (skill_title LIKE ? OR teacher_name LIKE ? OR description LIKE ?)";
                                    }
                                    if (cat != null && !cat.trim().isEmpty()) {
                                        sql += " AND category = ?";
                                    }
                                    sql += " ORDER BY skill_id DESC";
                                    
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    int idx = 1;
                                    if (search != null && !search.trim().isEmpty()) {
                                        String pattern = "%" + search.trim() + "%";
                                        ps.setString(idx++, pattern);
                                        ps.setString(idx++, pattern);
                                        ps.setString(idx++, pattern);
                                    }
                                    if (cat != null && !cat.trim().isEmpty()) {
                                        ps.setString(idx++, cat.trim());
                                    }
                                    
                                    ResultSet rs = ps.executeQuery();
                                    boolean hasSkills = false;
                                    while (rs.next()) {
                                        hasSkills = true;
                                        int id = rs.getInt("skill_id");
                                        String title = rs.getString("skill_title");
                                        String teacher = rs.getString("teacher_name");
                                        if (teacher == null) teacher = "System";
                                        String category = rs.getString("category");
                                        String price = rs.getString("price");
                            %>
                            <tr>
                                <td>#EE-SKL-<%= id %></td>
                                <td class="fw-bold"><%= title %></td>
                                <td><%= teacher %></td>
                                <td><span class="badge bg-primary-tint text-primary px-2.5 py-1.5"><%= category %></span></td>
                                <td class="fw-bold text-success">₹<%= price %>/mo</td>
                                <td class="text-end">
                                    <a href="../../DeleteContentServlet?type=skill&id=<%= id %>" onclick="return confirm('Are you sure you want to delete this course from the platform?');" class="btn btn-custom-sm btn-outline-danger"><i class="bi bi-trash3-fill"></i> Delete</a>
                                </td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    conn.close();
                                    
                                    if (!hasSkills) {
                            %>
                            <tr>
                                <td colspan="6" class="text-center text-muted py-5">No skill courses found.</td>
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
