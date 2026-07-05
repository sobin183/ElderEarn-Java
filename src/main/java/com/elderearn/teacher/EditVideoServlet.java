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

@WebServlet("/EditVideoServlet")
public class EditVideoServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String teacherName = (String) request.getSession().getAttribute("full_name");
            String role = (String) request.getSession().getAttribute("role");
            
            if (teacherName == null || !"teacher".equals(role)) {
                response.sendRedirect("jsp/auth/login.jsp?error=invalid_role");
                return;
            }

            int videoId = Integer.parseInt(request.getParameter("video_id"));
            String courseName = request.getParameter("course_name");
            String videoTitle = request.getParameter("video_title");
            String category = request.getParameter("category");
            String description = request.getParameter("description");
            String duration = request.getParameter("duration");
            String thumbnail = request.getParameter("thumbnail");
            String videoFile = request.getParameter("video_file");
            String previewEnabled = request.getParameter("preview_enabled");

            if (previewEnabled == null) previewEnabled = "No";

            Connection conn = DBConnection.getConnection();
            String sql = "UPDATE videos SET course_name=?, video_title=?, category=?, description=?, duration=?, thumbnail_path=?, video_path=?, preview_enabled=? WHERE video_id=? AND teacher_name=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, courseName);
            ps.setString(2, videoTitle);
            ps.setString(3, category);
            ps.setString(4, description);
            ps.setString(5, duration);
            ps.setString(6, thumbnail);
            ps.setString(7, videoFile);
            ps.setString(8, previewEnabled);
            ps.setInt(9, videoId);
            ps.setString(10, teacherName);
            ps.executeUpdate();
            
            ps.close();
            conn.close();
            response.sendRedirect("jsp/teacher/my-videos.jsp?success=updated");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/teacher/my-videos.jsp?error=db_error");
        }
    }
}
