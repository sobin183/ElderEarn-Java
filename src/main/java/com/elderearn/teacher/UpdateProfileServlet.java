package com.elderearn.teacher;

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

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String teacherName = (String) request.getSession().getAttribute("full_name");
            String role = (String) request.getSession().getAttribute("role");
            
            if (teacherName == null || !"teacher".equals(role)) {
                response.sendRedirect("jsp/auth/login.jsp?error=invalid_role");
                return;
            }

            String bio = request.getParameter("bio");
            String qualifications = request.getParameter("qualifications");
            String skills = request.getParameter("skills");
            int experience = 0;
            try {
                experience = Integer.parseInt(request.getParameter("experience"));
            } catch (Exception e) {}
            
            String languages = request.getParameter("languages");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String photo = request.getParameter("photo");
            String social = request.getParameter("social");

            Connection conn = DBConnection.getConnection();
            
            // Check if profile exists
            String checkSql = "SELECT * FROM teacher_profiles WHERE teacher_name = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, teacherName);
            ResultSet rs = checkPs.executeQuery();
            boolean exists = rs.next();
            rs.close();
            checkPs.close();

            if (exists) {
                String sql = "UPDATE teacher_profiles SET bio=?, qualifications=?, skills_expertise=?, experience_years=?, languages=?, contact_email=?, phone=?, photo_path=?, social_links=? WHERE teacher_name=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, bio);
                ps.setString(2, qualifications);
                ps.setString(3, skills);
                ps.setInt(4, experience);
                ps.setString(5, languages);
                ps.setString(6, email);
                ps.setString(7, phone);
                ps.setString(8, photo);
                ps.setString(9, social);
                ps.setString(10, teacherName);
                ps.executeUpdate();
                ps.close();
            } else {
                String sql = "INSERT INTO teacher_profiles (teacher_name, bio, qualifications, skills_expertise, experience_years, languages, contact_email, phone, photo_path, social_links) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, teacherName);
                ps.setString(2, bio);
                ps.setString(3, qualifications);
                ps.setString(4, skills);
                ps.setInt(5, experience);
                ps.setString(6, languages);
                ps.setString(7, email);
                ps.setString(8, phone);
                ps.setString(9, photo);
                ps.setString(10, social);
                ps.executeUpdate();
                ps.close();
            }

            conn.close();
            response.sendRedirect("jsp/teacher/my-profile.jsp?success=updated");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/teacher/my-profile.jsp?error=db_error");
        }
    }
}
