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

@WebServlet("/AddReviewServlet")
public class AddReviewServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String studentName = (String) request.getSession().getAttribute("full_name");
            String role = (String) request.getSession().getAttribute("role");
            
            if (studentName == null || !"student".equals(role)) {
                response.sendRedirect("jsp/auth/login.jsp?error=invalid_role");
                return;
            }

            String teacherName = request.getParameter("teacher");
            int rating = Integer.parseInt(request.getParameter("rating"));
            String reviewText = request.getParameter("review");

            if (teacherName == null || teacherName.trim().isEmpty()) {
                response.sendRedirect("jsp/student/student-dashboard.jsp");
                return;
            }

            Connection conn = DBConnection.getConnection();
            
            // Insert review
            String sql = "INSERT INTO reviews (teacher_name, student_name, rating, review_text) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, teacherName);
            ps.setString(2, studentName);
            ps.setInt(3, rating);
            ps.setString(4, reviewText);
            ps.executeUpdate();
            ps.close();

            // Calculate aggregates
            String aggSql = "SELECT AVG(rating), COUNT(*) FROM reviews WHERE teacher_name = ?";
            PreparedStatement aggPs = conn.prepareStatement(aggSql);
            aggPs.setString(1, teacherName);
            ResultSet rs = aggPs.executeQuery();
            double avgRating = 0.0;
            int count = 0;
            if (rs.next()) {
                avgRating = rs.getDouble(1);
                count = rs.getInt(2);
            }
            rs.close();
            aggPs.close();

            // Update teacher profiles
            String updateSql = "UPDATE teacher_profiles SET rating_avg = ?, reviews_count = ? WHERE teacher_name = ?";
            PreparedStatement updatePs = conn.prepareStatement(updateSql);
            updatePs.setDouble(1, avgRating);
            updatePs.setInt(2, count);
            updatePs.setString(3, teacherName);
            updatePs.executeUpdate();
            updatePs.close();

            conn.close();
            response.sendRedirect("jsp/student/teacher-profile.jsp?teacher=" + java.net.URLEncoder.encode(teacherName, "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/student/student-dashboard.jsp");
        }
    }
}
