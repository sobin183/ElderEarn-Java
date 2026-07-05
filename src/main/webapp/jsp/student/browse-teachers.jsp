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
    request.setAttribute("activePage", "browse-teachers");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Teachers - Student Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Browse Mentors & Teachers</h2>
                    <p class="text-muted mb-0">Learn from experienced elders and expert educators sharing their skills.</p>
                </div>
            </div>

            <!-- Filters -->
            <div class="content-card py-3 mb-4">
                <form action="browse-teachers.jsp" method="get" class="row g-3">
                    <div class="col-md-8 col-lg-9">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" name="search" class="form-control border-start-0" placeholder="Search by name, expertise, or qualifications..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                        </div>
                    </div>
                    <div class="col-md-4 col-lg-3 d-flex gap-2">
                        <button type="submit" class="btn btn-custom btn-custom-primary w-100"><i class="bi bi-funnel-fill me-1"></i> Search</button>
                        <a href="browse-teachers.jsp" class="btn btn-light border"><i class="bi bi-arrow-counterclockwise"></i></a>
                    </div>
                </form>
            </div>

            <!-- Teacher Grid -->
            <div class="row g-4">
                <%
                    Connection conn = null;
                    try {
                        conn = DBConnection.getConnection();
                        String search = request.getParameter("search");
                        
                        String sql = "SELECT u.full_name, u.email, tp.bio, tp.qualifications, tp.skills_expertise, tp.rating_avg, tp.followers_count, tp.photo_path " +
                                     "FROM users u " +
                                     "LEFT JOIN teacher_profiles tp ON u.full_name = tp.teacher_name " +
                                     "WHERE u.role = 'teacher'";
                        
                        if (search != null && !search.trim().isEmpty()) {
                            sql += " AND (u.full_name LIKE ? OR tp.skills_expertise LIKE ? OR tp.qualifications LIKE ?)";
                        }
                        sql += " ORDER BY tp.rating_avg DESC, u.user_id DESC";
                        
                        PreparedStatement ps = conn.prepareStatement(sql);
                        if (search != null && !search.trim().isEmpty()) {
                            String pattern = "%" + search.trim() + "%";
                            ps.setString(1, pattern);
                            ps.setString(2, pattern);
                            ps.setString(3, pattern);
                        }
                        
                        ResultSet rs = ps.executeQuery();
                        boolean hasTeachers = false;
                        while (rs.next()) {
                            hasTeachers = true;
                            String name = rs.getString("full_name");
                            String bio = rs.getString("bio");
                            if (bio == null) bio = "No bio written yet.";
                            String qual = rs.getString("qualifications");
                            if (qual == null) qual = "Expert Instructor";
                            String skills = rs.getString("skills_expertise");
                            if (skills == null) skills = "N/A";
                            double rating = rs.getDouble("rating_avg");
                            int followers = rs.getInt("followers_count");
                            String photo = rs.getString("photo_path");
                %>
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 rounded-4 shadow-sm" style="background-color: var(--white);">
                        <div class="card-body p-4 text-center">
                            <div class="user-avatar mb-3 mx-auto" style="width: 70px; height: 70px; background-color: var(--sky-blue); color: var(--primary-blue);">
                                <i class="bi bi-person-workspace fs-2"></i>
                            </div>
                            <h5 class="fw-bold mb-1"><%= name %></h5>
                            <span class="badge bg-light text-secondary mb-3"><%= qual %></span>
                            
                            <div class="d-flex justify-content-center align-items-center gap-1 text-warning mb-3">
                                <i class="bi bi-star-fill"></i>
                                <span class="fw-bold text-dark"><%= String.format("%.1f", rating) %></span>
                                <span class="text-muted small">(<%= followers %> followers)</span>
                            </div>

                            <p class="card-text text-muted small text-truncate-3 mb-4" style="min-height: 60px;">
                                <%= bio.length() > 120 ? bio.substring(0, 117) + "..." : bio %>
                            </p>

                            <div class="p-3 bg-light rounded-4 text-start mb-4">
                                <span class="small text-muted d-block fw-semibold mb-1">Expertise:</span>
                                <span class="small fw-medium text-dark"><%= skills %></span>
                            </div>

                            <a href="teacher-profile.jsp?teacher=<%= java.net.URLEncoder.encode(name, "UTF-8") %>" class="btn btn-outline-primary rounded-pill w-100">View Teacher Profile</a>
                        </div>
                    </div>
                </div>
                <%
                        }
                        rs.close();
                        ps.close();
                        conn.close();
                        
                        if (!hasTeachers) {
                %>
                <div class="col-12 text-center text-muted py-5">
                    <i class="bi bi-person-x fs-1 mb-2 d-block"></i>
                    No teachers found matching your search.
                </div>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                %>
                <div class="col-12 text-center text-danger py-4">Database load error.</div>
                <%
                    }
                %>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
