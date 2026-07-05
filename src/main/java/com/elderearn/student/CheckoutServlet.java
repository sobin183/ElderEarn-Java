package com.elderearn.student;

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

@WebServlet("/CheckoutServlet")
public class CheckoutServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String studentName = (String) request.getSession().getAttribute("full_name");
            if (studentName == null) {
                response.sendRedirect("jsp/auth/login.jsp?error=session_expired");
                return;
            }

            String itemType = request.getParameter("item_type");
            String itemIdStr = request.getParameter("item_id");
            String cardName = request.getParameter("card_name");
            String cardNumber = request.getParameter("card_number");

            if (itemType == null || itemIdStr == null || cardName == null || cardNumber == null ||
                itemType.trim().isEmpty() || itemIdStr.trim().isEmpty() || cardName.trim().isEmpty() || cardNumber.trim().isEmpty()) {
                response.sendRedirect("jsp/student/student-dashboard.jsp?error=invalid_checkout");
                return;
            }

            int itemId = Integer.parseInt(itemIdStr);
            String teacherName = "";
            String itemName = "";
            String price = "";

            Connection conn = DBConnection.getConnection();

            if ("skill".equalsIgnoreCase(itemType)) {
                // Fetch skill details
                String sql = "SELECT * FROM skills WHERE skill_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, itemId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    teacherName = rs.getString("teacher_name");
                    itemName = rs.getString("skill_title");
                    price = rs.getString("price");
                }
                rs.close();
                ps.close();

                if (teacherName == null || teacherName.isEmpty()) teacherName = "System";

                // Insert into subscriptions with Pending access status (Teacher must authorize)
                String insSub = "INSERT INTO subscriptions(student_name, teacher_name, course_name, amount, payment_status, access_status) VALUES(?,?,?,?,?,?)";
                PreparedStatement psSub = conn.prepareStatement(insSub);
                psSub.setString(1, studentName);
                psSub.setString(2, teacherName);
                psSub.setString(3, itemName);
                psSub.setString(4, price);
                psSub.setString(5, "Paid");
                psSub.setString(6, "Pending"); // Pending authorization by teacher
                psSub.executeUpdate();
                psSub.close();

                // Insert into payments
                String insPay = "INSERT INTO payments(student_name, teacher_name, payment_for, amount, payment_status, payment_type) VALUES(?,?,?,?,?,?)";
                PreparedStatement psPay = conn.prepareStatement(insPay);
                psPay.setString(1, studentName);
                psPay.setString(2, teacherName);
                psPay.setString(3, itemName);
                psPay.setString(4, price);
                psPay.setString(5, "Paid");
                psPay.setString(6, "Subscription");
                psPay.executeUpdate();
                psPay.close();

                conn.close();
                response.sendRedirect("jsp/student/student-dashboard.jsp?success=subscribed");

            } else if ("product".equalsIgnoreCase(itemType)) {
                // Fetch product details
                String sql = "SELECT * FROM products WHERE product_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, itemId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    teacherName = rs.getString("teacher_name");
                    itemName = rs.getString("product_name");
                    price = rs.getString("price");
                }
                rs.close();
                ps.close();

                if (teacherName == null || teacherName.isEmpty()) teacherName = "System";

                // Insert into payments
                String insPay = "INSERT INTO payments(student_name, teacher_name, payment_for, amount, payment_status, payment_type) VALUES(?,?,?,?,?,?)";
                PreparedStatement psPay = conn.prepareStatement(insPay);
                psPay.setString(1, studentName);
                psPay.setString(2, teacherName);
                psPay.setString(3, itemName);
                psPay.setString(4, price);
                psPay.setString(5, "Paid");
                psPay.setString(6, "Product");
                psPay.executeUpdate();
                psPay.close();

                conn.close();
                response.sendRedirect("jsp/student/student-dashboard.jsp?success=purchased");

            } else {
                conn.close();
                response.sendRedirect("jsp/student/student-dashboard.jsp?error=invalid_type");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/student/student-dashboard.jsp?error=db_error");
        }
    }
}
