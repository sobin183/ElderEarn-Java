<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    request.setAttribute("activePage", "users");
    String adminEmail = (String) session.getAttribute("email");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - Admin Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Manage Users</h2>
                    <p class="text-muted mb-0">Monitor and manage platform accounts (admins, teachers, students).</p>
                </div>
            </div>

            <!-- Context Alerts -->
            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                
                if ("deleted".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> User account deleted successfully.
                </div>
            <%
                }
                
                if ("self_deletion".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> Action Denied: You cannot delete your own logged-in admin account.
                </div>
            <%
                } else if ("not_found".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> User not found.
                </div>
            <%
                }
            %>

            <!-- Filters -->
            <div class="content-card py-3 mb-4">
                <form action="users.jsp" method="get" class="row g-3">
                    <div class="col-md-6 col-lg-5">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" name="search" class="form-control border-start-0" placeholder="Search by name or email..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                        </div>
                    </div>
                    <div class="col-md-4 col-lg-4">
                        <select name="role" class="form-select">
                            <option value="">All Roles</option>
                            <option value="admin" <%= "admin".equals(request.getParameter("role")) ? "selected" : "" %>>Admin</option>
                            <option value="teacher" <%= "teacher".equals(request.getParameter("role")) ? "selected" : "" %>>Teacher</option>
                            <option value="student" <%= "student".equals(request.getParameter("role")) ? "selected" : "" %>>Student</option>
                        </select>
                    </div>
                    <div class="col-md-2 col-lg-3 d-flex gap-2">
                        <button type="submit" class="btn btn-custom btn-custom-primary w-100"><i class="bi bi-funnel-fill me-1"></i> Filter</button>
                        <a href="users.jsp" class="btn btn-light border"><i class="bi bi-arrow-counterclockwise"></i></a>
                    </div>
                </form>
            </div>

            <!-- Users List Table -->
            <div class="content-card">
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>User ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Register Date</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    String search = request.getParameter("search");
                                    String role = request.getParameter("role");
                                    
                                    String sql = "SELECT * FROM users WHERE 1=1";
                                    if (search != null && !search.trim().isEmpty()) {
                                        sql += " AND (full_name LIKE ? OR email LIKE ?)";
                                    }
                                    if (role != null && !role.trim().isEmpty()) {
                                        sql += " AND role = ?";
                                    }
                                    sql += " ORDER BY user_id DESC";
                                    
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    int idx = 1;
                                    if (search != null && !search.trim().isEmpty()) {
                                        String pattern = "%" + search.trim() + "%";
                                        ps.setString(idx++, pattern);
                                        ps.setString(idx++, pattern);
                                    }
                                    if (role != null && !role.trim().isEmpty()) {
                                        ps.setString(idx++, role.trim());
                                    }
                                    
                                    ResultSet rs = ps.executeQuery();
                                    boolean hasUsers = false;
                                    while (rs.next()) {
                                        hasUsers = true;
                                        int id = rs.getInt("user_id");
                                        String name = rs.getString("full_name");
                                        String email = rs.getString("email");
                                        String userRole = rs.getString("role");
                                        Timestamp reg = rs.getTimestamp("created_at");
                                        String dateStr = reg != null ? reg.toString().split(" ")[0] : "N/A";
                                        
                                        String badge = "bg-primary-tint text-primary";
                                        if ("teacher".equalsIgnoreCase(userRole)) badge = "bg-success-tint text-success";
                                        else if ("admin".equalsIgnoreCase(userRole)) badge = "bg-danger-tint text-danger";
                            %>
                            <tr>
                                <td>#EE-USR-<%= id %></td>
                                <td class="fw-bold"><%= name %></td>
                                <td><%= email %></td>
                                <td><span class="badge <%= badge %> text-capitalize px-2.5 py-1.5"><%= userRole %></span></td>
                                <td><%= dateStr %></td>
                                <td class="text-end">
                                    <% if (email != null && !email.equalsIgnoreCase(adminEmail)) { %>
                                        <a href="../../DeleteUserServlet?id=<%= id %>" onclick="return confirm('Are you sure you want to delete this user? This cannot be undone.');" class="btn btn-custom-sm btn-outline-danger"><i class="bi bi-trash3-fill"></i> Delete</a>
                                    <% } else { %>
                                        <span class="small text-muted italic">Self (Admin)</span>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    conn.close();
                                    
                                    if (!hasUsers) {
                            %>
                            <tr>
                                <td colspan="6" class="text-center text-muted py-5">No user records match the filters.</td>
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
