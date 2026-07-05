<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "";
    
    String adminName = (String) session.getAttribute("full_name");
    String adminRole = (String) session.getAttribute("role");
    
    // Safety check: Redirect if not logged in or wrong role
    if (adminName == null || !"admin".equals(adminRole)) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp?error=invalid_role");
        return;
    }
%>
<div class="sidebar d-flex flex-column justify-content-between">
    <div>
        <div class="sidebar-brand text-center mb-4 py-2">
            <i class="bi bi-mortarboard-fill text-primary-light"></i> ElderEarn
        </div>
        <div class="sidebar-user mb-4 p-3 bg-dark-tint rounded-4 text-center">
            <div class="user-avatar mb-2 mx-auto" style="background-color: rgba(220, 53, 69, 0.15); color: #dc3545;"><i class="bi bi-shield-lock-fill fs-3"></i></div>
            <div class="fw-bold text-truncate text-white"><%= adminName %></div>
            <div class="small text-muted text-capitalize">System Admin</div>
        </div>
        
        <ul class="nav nav-pills flex-column mb-auto">
            <li class="nav-item mb-2">
                <a href="admin-dashboard.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "dashboard".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-grid-1x2-fill"></i> Dashboard
                </a>
            </li>
            <li class="nav-item mb-2">
                <a href="users.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "users".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-people-fill"></i> Manage Users
                </a>
            </li>
            <li class="nav-item mb-2">
                <a href="skills.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "skills".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-patch-check-fill"></i> Manage Skills
                </a>
            </li>
            <li class="nav-item mb-2">
                <a href="products.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "products".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-box-seam-fill"></i> Manage Products
                </a>
            </li>
            <li class="nav-item mb-2">
                <a href="subscriptions.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "subscriptions".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-journal-bookmark-fill"></i> Subscriptions
                </a>
            </li>
            <li class="nav-item mb-2">
                <a href="payments.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "payments".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-credit-card-2-back-fill"></i> View Payments
                </a>
            </li>
            <li class="nav-item mb-2">
                <a href="reports.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "reports".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-graph-up-arrow"></i> Reports
                </a>
            </li>
        </ul>
    </div>
    
    <div>
        <a href="../../LogoutServlet" class="btn btn-outline-danger w-100 rounded-pill d-flex align-items-center justify-content-center gap-2 mt-4">
            <i class="bi bi-box-arrow-right"></i> Logout
        </a>
    </div>
</div>
