<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String teacherName = (String) session.getAttribute("full_name");
    String teacherRole = (String) session.getAttribute("role");
    if (teacherName == null || !"teacher".equals(teacherRole)) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp?error=invalid_role");
        return;
    }
    request.setAttribute("activePage", "notifications");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications - Teacher Portal</title>
    
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
                    <h2 class="fw-bold mb-1">Notifications</h2>
                    <p class="text-muted mb-0">Stay updated on your class schedules, payouts, and subscriptions.</p>
                </div>
            </div>

            <!-- Notifications List -->
            <div class="content-card">
                <div class="d-flex flex-column gap-3">
                    <div class="alert alert-info border-0 rounded-4 shadow-sm mb-0 d-flex gap-3 align-items-start">
                        <i class="bi bi-info-circle-fill fs-4 text-primary"></i>
                        <div>
                            <h6 class="fw-bold mb-1">Welcome to ElderEarn Portal!</h6>
                            <p class="mb-1 small">You have successfully logged in. Start by publishing your skills in the "Add Skill" tab.</p>
                            <span class="small text-muted">Just now</span>
                        </div>
                    </div>
                    
                    <div class="alert alert-warning border-0 rounded-4 shadow-sm mb-0 d-flex gap-3 align-items-start">
                        <i class="bi bi-wallet2 fs-4 text-warning"></i>
                        <div>
                            <h6 class="fw-bold mb-1">Direct Bank Transferred Status Active</h6>
                            <p class="mb-1 small">Your payments system profile setup has been completed automatically with dummy payouts enabled.</p>
                            <span class="small text-muted">1 hour ago</span>
                        </div>
                    </div>
                    
                    <div class="alert alert-success border-0 rounded-4 shadow-sm mb-0 d-flex gap-3 align-items-start">
                        <i class="bi bi-mortarboard-fill fs-4 text-success"></i>
                        <div>
                            <h6 class="fw-bold mb-1">Tip: Engage Your Students</h6>
                            <p class="mb-1 small">You can see who subscribed and authorize/revoke student access quickly from the "Subscribers" panel.</p>
                            <span class="small text-muted">1 day ago</span>
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
