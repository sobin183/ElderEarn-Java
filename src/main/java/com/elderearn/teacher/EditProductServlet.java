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

@WebServlet("/EditProductServlet")
public class EditProductServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String teacherName = (String) request.getSession().getAttribute("full_name");
            if (teacherName == null) {
                response.sendRedirect("jsp/auth/login.jsp?error=session_expired");
                return;
            }

            String idStr = request.getParameter("product_id");
            String productName = request.getParameter("product_name");
            String productType = request.getParameter("product_type");
            String description = request.getParameter("description");
            String price = request.getParameter("price");

            if (idStr == null || productName == null || productType == null || description == null || price == null ||
                idStr.trim().isEmpty() || productName.trim().isEmpty() || productType.trim().isEmpty() || description.trim().isEmpty() || price.trim().isEmpty()) {
                response.sendRedirect("jsp/teacher/view-my-products.jsp?error=empty");
                return;
            }

            int productId = Integer.parseInt(idStr);

            Connection conn = DBConnection.getConnection();
            String sql = "UPDATE products SET product_name = ?, product_type = ?, description = ?, price = ? WHERE product_id = ? AND teacher_name = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, productName.trim());
            ps.setString(2, productType.trim());
            ps.setString(3, description.trim());
            ps.setString(4, price.trim());
            ps.setInt(5, productId);
            ps.setString(6, teacherName);

            int rowsUpdated = ps.executeUpdate();
            ps.close();
            conn.close();

            if (rowsUpdated > 0) {
                response.sendRedirect("jsp/teacher/view-my-products.jsp?success=updated");
            } else {
                response.sendRedirect("jsp/teacher/view-my-products.jsp?error=not_authorized");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/teacher/view-my-products.jsp?error=db_error");
        }
    }
}
