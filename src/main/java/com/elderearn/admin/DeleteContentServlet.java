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

@WebServlet("/DeleteContentServlet")
public class DeleteContentServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String adminRole = (String) request.getSession().getAttribute("role");
            if (adminRole == null || !"admin".equals(adminRole)) {
                response.sendRedirect("jsp/auth/login.jsp?error=not_authorized");
                return;
            }

            String type = request.getParameter("type");
            String idStr = request.getParameter("id");

            if (type == null || idStr == null || type.trim().isEmpty() || idStr.trim().isEmpty()) {
                response.sendRedirect("jsp/admin/admin-dashboard.jsp?error=invalid_params");
                return;
            }

            int contentId = Integer.parseInt(idStr);
            Connection conn = DBConnection.getConnection();
            String sql = "";

            if ("skill".equalsIgnoreCase(type)) {
                sql = "DELETE FROM skills WHERE skill_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, contentId);
                ps.executeUpdate();
                ps.close();
                conn.close();
                response.sendRedirect("jsp/admin/skills.jsp?success=deleted");
            } else if ("product".equalsIgnoreCase(type)) {
                sql = "DELETE FROM products WHERE product_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, contentId);
                ps.executeUpdate();
                ps.close();
                conn.close();
                response.sendRedirect("jsp/admin/products.jsp?success=deleted");
            } else {
                conn.close();
                response.sendRedirect("jsp/admin/admin-dashboard.jsp?error=invalid_type");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/admin/admin-dashboard.jsp?error=db_error");
        }
    }
}
