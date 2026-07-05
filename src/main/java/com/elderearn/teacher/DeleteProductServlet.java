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

@WebServlet("/DeleteProductServlet")
public class DeleteProductServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String teacherName = (String) request.getSession().getAttribute("full_name");
            if (teacherName == null) {
                response.sendRedirect("jsp/auth/login.jsp?error=session_expired");
                return;
            }

            String idStr = request.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                response.sendRedirect("jsp/teacher/view-my-products.jsp?error=invalid_id");
                return;
            }

            int productId = Integer.parseInt(idStr);

            Connection conn = DBConnection.getConnection();
            String sql = "DELETE FROM products WHERE product_id = ? AND teacher_name = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, productId);
            ps.setString(2, teacherName);

            int rowsDeleted = ps.executeUpdate();
            ps.close();
            conn.close();

            if (rowsDeleted > 0) {
                response.sendRedirect("jsp/teacher/view-my-products.jsp?success=deleted");
            } else {
                response.sendRedirect("jsp/teacher/view-my-products.jsp?error=not_found");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/teacher/view-my-products.jsp?error=db_error");
        }
    }
}
