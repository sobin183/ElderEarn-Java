<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    request.setAttribute("activePage", "profile");
    String studentName = (String) session.getAttribute("full_name");
    String studentEmail = (String) session.getAttribute("email");
    
    String phone = "";
    String regDate = "";
    
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT * FROM users WHERE email = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, studentEmail);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            phone = rs.getString("phone");
            if (phone == null) phone = "Not provided";
            Timestamp ts = rs.getTimestamp("created_at");
            if (ts != null) regDate = ts.toString();
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
    <title>My Profile - Student Portal</title>
    
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
                    <h2 class="fw-bold mb-1">My Profile</h2>
                    <p class="text-muted mb-0">Review your learner profile and settings.</p>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-6">
                    <div class="content-card">
                        <div class="text-center mb-4 pb-3 border-bottom">
                            <div class="user-avatar mb-3 mx-auto" style="width: 80px; height: 80px; background-color: var(--sky-blue); color: var(--primary-blue);">
                                <i class="bi bi-person-circle fs-1"></i>
                            </div>
                            <h4 class="fw-bold mb-1"><%= studentName %></h4>
                            <span class="badge bg-primary text-uppercase px-3 py-2 rounded-pill"><%= session.getAttribute("role") %></span>
                        </div>
                        
                        <div class="mb-3 d-flex justify-content-between align-items-center">
                            <span class="text-muted fw-bold small"><i class="bi bi-envelope-fill me-2"></i> Email Address</span>
                            <span class="fw-medium"><%= studentEmail %></span>
                        </div>
                        
                        <div class="mb-3 d-flex justify-content-between align-items-center">
                            <span class="text-muted fw-bold small"><i class="bi bi-telephone-fill me-2"></i> Phone Number</span>
                            <span class="fw-medium"><%= phone %></span>
                        </div>
                        
                        <div class="mb-3 d-flex justify-content-between align-items-center">
                            <span class="text-muted fw-bold small"><i class="bi bi-calendar-event-fill me-2"></i> Member Since</span>
                            <span class="fw-medium small"><%= regDate %></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
