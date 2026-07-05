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

@WebServlet("/AddProductServlet")
public class AddProductServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String teacherName = (String) request.getSession().getAttribute("full_name");
            if (teacherName == null) {
                response.sendRedirect("jsp/auth/login.jsp?error=session_expired");
                return;
            }

            String productName = request.getParameter("product_name");
            String productType = request.getParameter("product_type");
            String description = request.getParameter("description");
            String price = request.getParameter("price");

            if (productName == null || productType == null || description == null || price == null ||
                productName.trim().isEmpty() || productType.trim().isEmpty() || description.trim().isEmpty() || price.trim().isEmpty()) {
                response.sendRedirect("jsp/teacher/add-product.jsp?error=empty");
                return;
            }

            Connection conn = DBConnection.getConnection();
            String sql = "INSERT INTO products(teacher_name, product_name, description, price, product_type) VALUES(?,?,?,?,?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, teacherName);
            ps.setString(2, productName.trim());
            ps.setString(3, description.trim());
            ps.setString(4, price.trim());
            ps.setString(5, productType.trim());

            ps.executeUpdate();
            ps.close();
            conn.close();

            response.sendRedirect("jsp/teacher/view-my-products.jsp?success=added");

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/teacher/add-product.jsp?error=db_error");
        }
    }
}
