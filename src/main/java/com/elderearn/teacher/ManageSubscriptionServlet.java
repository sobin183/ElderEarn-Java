package com.elderearn.teacher;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.elderearn.database.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/ManageSubscriptionServlet")
public class ManageSubscriptionServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String teacherName = (String) request.getSession().getAttribute("full_name");
            if (teacherName == null) {
                response.sendRedirect("jsp/auth/login.jsp?error=session_expired");
                return;
            }

            String subIdStr = request.getParameter("sub_id");
            String action = request.getParameter("action");

            if (subIdStr == null || action == null || subIdStr.trim().isEmpty() || action.trim().isEmpty()) {
                response.sendRedirect("jsp/teacher/subscribers.jsp?error=invalid_params");
                return;
            }

            int subId = Integer.parseInt(subIdStr);
            String status = "Pending";
            if ("authorize".equalsIgnoreCase(action)) {
                status = "Active";
            } else if ("unauthorize".equalsIgnoreCase(action)) {
                status = "Expired";
            }

            Connection conn = DBConnection.getConnection();
            String sql = "UPDATE subscriptions SET access_status = ? WHERE subscription_id = ? AND teacher_name = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, subId);
            ps.setString(3, teacherName);

            int rowsUpdated = ps.executeUpdate();
            ps.close();
            conn.close();

            if (rowsUpdated > 0) {
                response.sendRedirect("jsp/teacher/subscribers.jsp?success=" + action);
            } else {
                response.sendRedirect("jsp/teacher/subscribers.jsp?error=not_authorized");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/teacher/subscribers.jsp?error=db_error");
        }
    }
}
