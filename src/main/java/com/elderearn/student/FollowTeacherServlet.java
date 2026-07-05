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

@WebServlet("/FollowTeacherServlet")
public class FollowTeacherServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String studentName = (String) request.getSession().getAttribute("full_name");
            String role = (String) request.getSession().getAttribute("role");
            
            if (studentName == null || !"student".equals(role)) {
                response.sendRedirect("jsp/auth/login.jsp?error=invalid_role");
                return;
            }

            String teacherName = request.getParameter("teacher");
            if (teacherName == null || teacherName.trim().isEmpty()) {
                response.sendRedirect("jsp/student/student-dashboard.jsp");
                return;
            }

            Connection conn = DBConnection.getConnection();
            
            // Check if already following
            String checkSql = "SELECT * FROM teacher_followers WHERE student_name = ? AND teacher_name = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, studentName);
            checkPs.setString(2, teacherName);
            ResultSet rs = checkPs.executeQuery();
            boolean isFollowing = rs.next();
            rs.close();
            checkPs.close();

            if (isFollowing) {
                // Unfollow
                String deleteSql = "DELETE FROM teacher_followers WHERE student_name = ? AND teacher_name = ?";
                PreparedStatement delPs = conn.prepareStatement(deleteSql);
                delPs.setString(1, studentName);
                delPs.setString(2, teacherName);
                delPs.executeUpdate();
                delPs.close();

                // Decrement follower count
                String decSql = "UPDATE teacher_profiles SET followers_count = GREATEST(0, followers_count - 1) WHERE teacher_name = ?";
                PreparedStatement decPs = conn.prepareStatement(decSql);
                decPs.setString(1, teacherName);
                decPs.executeUpdate();
                decPs.close();
            } else {
                // Follow
                String insertSql = "INSERT INTO teacher_followers (student_name, teacher_name) VALUES (?, ?)";
                PreparedStatement insPs = conn.prepareStatement(insertSql);
                insPs.setString(1, studentName);
                insPs.setString(2, teacherName);
                try {
                    insPs.executeUpdate();
                } catch (Exception e) {}
                insPs.close();

                // Increment follower count
                String incSql = "UPDATE teacher_profiles SET followers_count = followers_count + 1 WHERE teacher_name = ?";
                PreparedStatement incPs = conn.prepareStatement(incSql);
                incPs.setString(1, teacherName);
                incPs.executeUpdate();
                incPs.close();
            }

            conn.close();
            response.sendRedirect("jsp/student/teacher-profile.jsp?teacher=" + java.net.URLEncoder.encode(teacherName, "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/student/student-dashboard.jsp");
        }
    }
}
