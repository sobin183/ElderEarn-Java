<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "";
    
    String studentName = (String) session.getAttribute("full_name");
    String studentRole = (String) session.getAttribute("role");
    
    // Safety check: Redirect if not logged in or wrong role
    if (studentName == null || !"student".equals(studentRole)) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp?error=invalid_role");
        return;
    }

    int unreadMsgs = 0;
    int unreadNotifications = 0;
    Connection connSidebar = null;
    try {
        connSidebar = DBConnection.getConnection();
        
        // Count unread messages
        String msgSql = "SELECT COUNT(*) FROM messages WHERE receiver_name = ? AND is_read = 0";
        PreparedStatement msgPs = connSidebar.prepareStatement(msgSql);
        msgPs.setString(1, studentName);
        ResultSet msgRs = msgPs.executeQuery();
        if (msgRs.next()) unreadMsgs = msgRs.getInt(1);
        msgRs.close();
        msgPs.close();

        // Count unread notifications
        String notSql = "SELECT COUNT(*) FROM notifications WHERE user_name = ? AND is_read = 0";
        PreparedStatement notPs = connSidebar.prepareStatement(notSql);
        notPs.setString(1, studentName);
        ResultSet notRs = notPs.executeQuery();
        if (notRs.next()) unreadNotifications = notRs.getInt(1);
        notRs.close();
        notPs.close();
        
        connSidebar.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<div class="sidebar d-flex flex-column justify-content-between">
    <div>
        <div class="sidebar-brand text-center mb-4 py-2">
            <i class="bi bi-mortarboard-fill text-primary-light"></i> ElderEarn
        </div>
        <div class="sidebar-user mb-4 p-3 bg-dark-tint rounded-4 text-center">
            <div class="user-avatar mb-2 mx-auto"><i class="bi bi-person-circle fs-3 text-info"></i></div>
            <div class="fw-bold text-truncate text-white"><%= studentName %></div>
            <div class="small text-muted text-capitalize"><%= studentRole %> Portal</div>
        </div>
        
        <ul class="nav nav-pills flex-column mb-auto" style="gap: 2px;">
            <li class="nav-item">
                <a href="student-dashboard.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "dashboard".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-grid-1x2-fill"></i> Dashboard
                </a>
            </li>
            <li class="nav-item">
                <a href="browse-teachers.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "browse-teachers".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-people-fill"></i> Browse Teachers
                </a>
            </li>
            <li class="nav-item">
                <a href="browse-skills.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "browse-skills".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-search"></i> Browse Skills
                </a>
            </li>
            <li class="nav-item">
                <a href="browse-products.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "browse-products".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-bag-fill"></i> Browse Products
                </a>
            </li>
            <li class="nav-item">
                <a href="my-subscriptions.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "my-subscriptions".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-journal-check"></i> My Subscriptions
                </a>
            </li>
            <li class="nav-item">
                <a href="payment-history.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "payments".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-credit-card-2-back-fill"></i> Payment History
                </a>
            </li>
            <li class="nav-item">
                <a href="messages.jsp" class="nav-link text-white d-flex align-items-center justify-content-between <%= "messages".equals(activePage) ? "active" : "" %>">
                    <span class="d-flex align-items-center gap-3">
                        <i class="bi bi-chat-fill"></i> Messages
                    </span>
                    <% if (unreadMsgs > 0) { %>
                        <span class="badge bg-danger rounded-pill"><%= unreadMsgs %></span>
                    <% } %>
                </a>
            </li>
            <li class="nav-item">
                <a href="notifications.jsp" class="nav-link text-white d-flex align-items-center justify-content-between <%= "notifications".equals(activePage) ? "active" : "" %>">
                    <span class="d-flex align-items-center gap-3">
                        <i class="bi bi-bell-fill"></i> Notifications
                    </span>
                    <% if (unreadNotifications > 0) { %>
                        <span class="badge bg-danger rounded-pill"><%= unreadNotifications %></span>
                    <% } %>
                </a>
            </li>
            <li class="nav-item">
                <a href="profile.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "profile".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-person-bounding-box"></i> Profile
                </a>
            </li>
            <li class="nav-item">
                <a href="settings.jsp" class="nav-link text-white d-flex align-items-center gap-3 <%= "settings".equals(activePage) ? "active" : "" %>">
                    <i class="bi bi-gear-fill"></i> Settings
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
