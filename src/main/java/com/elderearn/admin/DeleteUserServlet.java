package com.elderearn.admin;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.elderearn.database.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/DeleteUserServlet")
public class DeleteUserServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String adminRole = (String) request.getSession().getAttribute("role");
            String adminEmail = (String) request.getSession().getAttribute("email");
            
            if (adminRole == null || !"admin".equals(adminRole)) {
                response.sendRedirect("jsp/auth/login.jsp?error=not_authorized");
                return;
            }

            String idStr = request.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                response.sendRedirect("jsp/admin/users.jsp?error=invalid_id");
                return;
            }

            int userId = Integer.parseInt(idStr);

            Connection conn = DBConnection.getConnection();
            
            // Check that the admin is not deleting themselves
            String checkSql = "SELECT email FROM users WHERE user_id = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, userId);
            var rs = checkPs.executeQuery();
            if (rs.next()) {
                String targetEmail = rs.getString("email");
                if (targetEmail != null && targetEmail.equalsIgnoreCase(adminEmail)) {
                    rs.close();
                    checkPs.close();
                    conn.close();
                    response.sendRedirect("jsp/admin/users.jsp?error=self_deletion");
                    return;
                }
            }
            rs.close();
            checkPs.close();

            String sql = "DELETE FROM users WHERE user_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            int rowsDeleted = ps.executeUpdate();
            
            ps.close();
            conn.close();

            if (rowsDeleted > 0) {
                response.sendRedirect("jsp/admin/users.jsp?success=deleted");
            } else {
                response.sendRedirect("jsp/admin/users.jsp?error=not_found");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/admin/users.jsp?error=db_error");
        }
    }
}
