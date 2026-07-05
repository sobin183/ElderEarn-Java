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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Skills - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">My Published Skills</h2>
                    <p class="text-muted mb-0">Manage and update your active courses and classes.</p>
                </div>
                <div>
                    <a href="add-skill.jsp" class="btn btn-custom btn-custom-primary"><i class="bi bi-plus-circle-fill me-1"></i> Add New Skill</a>
                </div>
            </div>

            <!-- Context Alerts -->
            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                
                if ("added".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Skill published successfully!
                </div>
            <%
                } else if ("deleted".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Skill course deleted successfully.
                </div>
            <%
                } else if ("updated".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Skill details updated successfully.
                </div>
            <%
                }
                
                if ("not_found".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> Skill course not found.
                </div>
            <%
                } else if ("not_authorized".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> You are not authorized to manage this course.
                </div>
            <%
                }
            %>

            <!-- Skills Table -->
            <div class="content-card">
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>Skill Title</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Description</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT * FROM skills WHERE teacher_name = ? ORDER BY skill_id DESC";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setString(1, teacherName);
                                    ResultSet rs = ps.executeQuery();
                                    
                                    boolean hasSkills = false;
                                    while (rs.next()) {
                                        hasSkills = true;
                                        int id = rs.getInt("skill_id");
                                        String title = rs.getString("skill_title");
                                        String category = rs.getString("category");
                                        String price = rs.getString("price");
                                        String desc = rs.getString("description");
                                        if (desc != null && desc.length() > 60) {
                                            desc = desc.substring(0, 57) + "...";
                                        }
                            %>
                            <tr>
                                <td class="fw-bold"><%= title %></td>
                                <td><span class="badge bg-primary-tint text-primary px-2.5 py-1.5"><%= category %></span></td>
                                <td class="fw-bold text-success">₹<%= price %>/mo</td>
                                <td class="text-muted small"><%= desc %></td>
                                <td class="text-end">
                                    <div class="d-flex justify-content-end gap-2">
                                        <a href="edit-skill.jsp?id=<%= id %>" class="btn btn-custom-sm btn-outline-primary"><i class="bi bi-pencil-fill"></i> Edit</a>
                                        <a href="../../DeleteSkillServlet?id=<%= id %>" onclick="return confirm('Are you sure you want to delete this skill?');" class="btn btn-custom-sm btn-outline-danger"><i class="bi bi-trash3-fill"></i> Delete</a>
                                    </div>
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
                                <td colspan="5" class="text-center text-muted py-5">
                                    <i class="bi bi-journal-x fs-1 mb-2 d-block"></i>
                                    You have not published any skills yet.
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
