package com.elderearn.auth;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.elderearn.database.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/SendMessageServlet")
public class SendMessageServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String senderName = (String) request.getSession().getAttribute("full_name");
            String role = (String) request.getSession().getAttribute("role");
            
            if (senderName == null) {
                response.sendRedirect("jsp/auth/login.jsp");
                return;
            }

            String receiverName = request.getParameter("receiver");
            String messageText = request.getParameter("message");

            if (receiverName == null || messageText == null || messageText.trim().isEmpty()) {
                if ("teacher".equals(role)) {
                    response.sendRedirect("jsp/teacher/messages.jsp");
                } else {
                    response.sendRedirect("jsp/student/messages.jsp");
                }
                return;
            }

            Connection conn = DBConnection.getConnection();

            // Enforce student permissions if student is sending
            if ("student".equals(role)) {
                // Check if student has active subscription or has purchased a product from this teacher
                String accessSql = "SELECT COUNT(*) FROM subscriptions WHERE student_name = ? AND teacher_name = ? AND access_status = 'Active'";
                PreparedStatement accessPs = conn.prepareStatement(accessSql);
                accessPs.setString(1, senderName);
                accessPs.setString(2, receiverName);
                ResultSet accessRs = accessPs.executeQuery();
                int hasAccess = 0;
                if (accessRs.next()) {
                    hasAccess = accessRs.getInt(1);
                }
                accessRs.close();
                accessPs.close();

                if (hasAccess == 0) {
                    // Check product purchases
                    String prodSql = "SELECT COUNT(*) FROM payments WHERE student_name = ? AND teacher_name = ? AND payment_status = 'Paid' AND payment_type = 'Product'";
                    PreparedStatement prodPs = conn.prepareStatement(prodSql);
                    prodPs.setString(1, senderName);
                    prodPs.setString(2, receiverName);
                    ResultSet prodRs = prodPs.executeQuery();
                    if (prodRs.next()) {
                        hasAccess += prodRs.getInt(1);
                    }
                    prodRs.close();
                    prodPs.close();
                }

                if (hasAccess == 0) {
                    conn.close();
                    response.sendRedirect("jsp/student/messages.jsp?error=not_authorized");
                    return;
                }
            }

            // Save message
            String sql = "INSERT INTO messages (sender_name, receiver_name, message_text) VALUES (?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, senderName);
            ps.setString(2, receiverName);
            ps.setString(3, messageText.trim());
            ps.executeUpdate();
            ps.close();

            // Trigger notification
            String notifySql = "INSERT INTO notifications (user_name, message_text) VALUES (?, ?)";
            PreparedStatement notifyPs = conn.prepareStatement(notifySql);
            notifyPs.setString(1, receiverName);
            
            String truncateMsg = messageText.length() > 50 ? messageText.substring(0, 47) + "..." : messageText;
            notifyPs.setString(2, "New message from " + senderName + ": " + truncateMsg);
            notifyPs.executeUpdate();
            notifyPs.close();

            conn.close();

            // Redirect back to chat page
            if ("teacher".equals(role)) {
                response.sendRedirect("jsp/teacher/messages.jsp?chat=" + java.net.URLEncoder.encode(receiverName, "UTF-8"));
            } else {
                response.sendRedirect("jsp/student/messages.jsp?chat=" + java.net.URLEncoder.encode(receiverName, "UTF-8"));
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp");
        }
    }
}
