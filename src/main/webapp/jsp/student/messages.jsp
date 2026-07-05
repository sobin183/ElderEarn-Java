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
    request.setAttribute("activePage", "messages");

    String activeChat = request.getParameter("chat");
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        
        // Mark messages as read if activeChat is open
        if (activeChat != null && !activeChat.trim().isEmpty()) {
            String readSql = "UPDATE messages SET is_read = 1 WHERE sender_name = ? AND receiver_name = ?";
            PreparedStatement readPs = conn.prepareStatement(readSql);
            readPs.setString(1, activeChat);
            readPs.setString(2, studentName);
            readPs.executeUpdate();
            readPs.close();
        }
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Messages - Student Portal</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Dashboard CSS -->
    <link rel="stylesheet" href="../../css/dashboard.css">
    
    <style>
        .chat-container {
            display: flex;
            height: calc(100vh - 160px);
            background-color: var(--white);
            border-radius: 20px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
        }

        .chat-sidebar {
            width: 320px;
            border-right: 1px solid rgba(0,0,0,0.08);
            display: flex;
            flex-direction: column;
        }

        .chat-list {
            overflow-y: auto;
            flex-grow: 1;
        }

        .chat-item {
            padding: 15px 20px;
            border-bottom: 1px solid rgba(0,0,0,0.04);
            cursor: pointer;
            transition: background 0.2s;
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: inherit;
        }

        .chat-item:hover, .chat-item.active {
            background-color: var(--sky-blue);
        }

        .chat-main {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            background-color: #f8fafc;
        }

        .chat-header {
            padding: 15px 30px;
            background-color: var(--white);
            border-bottom: 1px solid rgba(0,0,0,0.08);
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .chat-messages {
            flex-grow: 1;
            padding: 30px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .message-bubble {
            max-width: 60%;
            padding: 12px 18px;
            border-radius: 18px;
            font-size: 0.95rem;
            position: relative;
            line-height: 1.4;
        }

        .message-sent {
            background-color: var(--primary-blue);
            color: var(--white);
            align-self: flex-end;
            border-bottom-right-radius: 4px;
        }

        .message-received {
            background-color: var(--white);
            color: var(--deep-dark);
            align-self: flex-start;
            border-bottom-left-radius: 4px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.02);
        }

        .message-time {
            font-size: 0.7rem;
            margin-top: 5px;
            display: block;
            text-align: right;
            opacity: 0.7;
        }

        .chat-input-area {
            padding: 20px 30px;
            background-color: var(--white);
            border-top: 1px solid rgba(0,0,0,0.08);
        }
    </style>
</head>
<body>

    <div class="container-fluid p-0">
        <!-- Reusable Sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content -->
        <div class="main-content">
            <h2 class="fw-bold mb-4">Chat with Teachers</h2>

            <%
                String error = request.getParameter("error");
                if ("not_authorized".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> Security Block: You can only communicate with teachers whose course subscriptions or products you have purchased.
                </div>
            <%
                }
            %>

            <div class="chat-container">
                <!-- Sidebar (Teacher List) -->
                <div class="chat-sidebar">
                    <div class="p-3 border-bottom bg-light fw-bold text-muted small uppercase">
                        My Mentors
                    </div>
                    <div class="chat-list">
                        <%
                            try {
                                // Enforce security rules: Distinct teachers whose courses or products have been subscribed/purchased
                                String listSql = "SELECT DISTINCT teacher_name FROM subscriptions WHERE student_name = ? AND access_status = 'Active' " +
                                                 "UNION " +
                                                 "SELECT DISTINCT teacher_name FROM payments WHERE student_name = ? AND payment_status = 'Paid' AND payment_type = 'Product' " +
                                                 "ORDER BY teacher_name ASC";
                                PreparedStatement listPs = conn.prepareStatement(listSql);
                                listPs.setString(1, studentName);
                                listPs.setString(2, studentName);
                                ResultSet listRs = listPs.executeQuery();
                                
                                boolean hasTeachers = false;
                                while (listRs.next()) {
                                    hasTeachers = true;
                                    String name = listRs.getString("teacher_name");
                                    
                                    // Count unread
                                    String unreadSql = "SELECT COUNT(*) FROM messages WHERE sender_name = ? AND receiver_name = ? AND is_read = 0";
                                    PreparedStatement unreadPs = conn.prepareStatement(unreadSql);
                                    unreadPs.setString(1, name);
                                    unreadPs.setString(2, studentName);
                                    ResultSet unreadRs = unreadPs.executeQuery();
                                    int unreadCount = 0;
                                    if (unreadRs.next()) unreadCount = unreadRs.getInt(1);
                                    unreadRs.close();
                                    unreadPs.close();
                                    
                                    boolean isActive = name.equals(activeChat);
                        %>
                        <a href="messages.jsp?chat=<%= java.net.URLEncoder.encode(name, "UTF-8") %>" class="chat-item <%= isActive ? "active" : "" %>">
                            <div class="user-avatar text-white" style="background-color: var(--accent-blue); width: 40px; height: 40px;">
                                <i class="bi bi-person-workspace"></i>
                            </div>
                            <div class="flex-grow-1 text-truncate">
                                <h6 class="fw-bold mb-0 text-truncate"><%= name %></h6>
                            </div>
                            <% if (unreadCount > 0) { %>
                                <span class="badge bg-danger rounded-pill"><%= unreadCount %></span>
                            <% } %>
                        </a>
                        <%
                                }
                                listRs.close();
                                listPs.close();
                                
                                if (!hasTeachers) {
                        %>
                        <div class="p-4 text-center text-muted small">No active mentors found. Go to "Browse Skills" or "Browse Products" to connect and unlock communication!</div>
                        <%
                                }
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </div>
                </div>

                <!-- Chat Main Window -->
                <div class="chat-main">
                    <% if (activeChat != null && !activeChat.trim().isEmpty()) { %>
                    <!-- Chat Header -->
                    <div class="chat-header">
                        <div class="user-avatar text-white" style="background-color: var(--primary-blue); width: 45px; height: 45px;">
                            <i class="bi bi-person-fill fs-5"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-0"><%= activeChat %></h5>
                            <span class="text-success small"><i class="bi bi-circle-fill fs-6" style="font-size: 8px;"></i> Teacher</span>
                        </div>
                    </div>

                    <!-- Chat Messages list -->
                    <div class="chat-messages" id="chat-messages-container">
                        <%
                            try {
                                String msgSql = "SELECT * FROM messages WHERE (sender_name = ? AND receiver_name = ?) OR (sender_name = ? AND receiver_name = ?) ORDER BY message_id ASC";
                                PreparedStatement msgPs = conn.prepareStatement(msgSql);
                                msgPs.setString(1, studentName);
                                msgPs.setString(2, activeChat);
                                msgPs.setString(3, activeChat);
                                msgPs.setString(4, studentName);
                                ResultSet msgRs = msgPs.executeQuery();
                                
                                while (msgRs.next()) {
                                    String sender = msgRs.getString("sender_name");
                                    String text = msgRs.getString("message_text");
                                    Timestamp time = msgRs.getTimestamp("sent_at");
                                    String timeStr = time.toString().split(" ")[1].substring(0, 5); // HH:mm
                                    
                                    boolean isSent = sender.equals(studentName);
                        %>
                        <div class="message-bubble <%= isSent ? "message-sent" : "message-received" %>">
                            <%= text %>
                            <span class="message-time"><%= timeStr %></span>
                        </div>
                        <%
                                }
                                msgRs.close();
                                msgPs.close();
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </div>

                    <!-- Input Area -->
                    <div class="chat-input-area">
                        <form action="../../SendMessageServlet" method="post" class="d-flex gap-2">
                            <input type="hidden" name="receiver" value="<%= activeChat %>">
                            <input type="text" name="message" class="form-control rounded-pill px-4" placeholder="Type your message here..." required autocomplete="off">
                            <button type="submit" class="btn btn-custom btn-custom-primary rounded-pill px-4"><i class="bi bi-send-fill"></i></button>
                        </form>
                    </div>
                    <% } else { %>
                    <!-- Empty Chat Placeholder -->
                    <div class="flex-grow-1 d-flex flex-column align-items-center justify-content-center text-muted">
                        <i class="bi bi-chat-dots-fill fs-1 mb-3"></i>
                        <h5>Select a teacher to start chatting</h5>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto Scroll Chat to Bottom
        var container = document.getElementById("chat-messages-container");
        if (container) {
            container.scrollTop = container.scrollHeight;
        }
    </script>
</body>
</html>
<%
    if (conn != null) {
        try { conn.close(); } catch(Exception e) {}
    }
%>
