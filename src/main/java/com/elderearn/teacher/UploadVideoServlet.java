package com.elderearn.teacher;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.elderearn.database.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/UploadVideoServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 100,       // 100MB limit for video upload
    maxRequestSize = 1024 * 1024 * 150     // 150MB total request size
)
public class UploadVideoServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String teacherName = (String) request.getSession().getAttribute("full_name");
            String role = (String) request.getSession().getAttribute("role");
            
            if (teacherName == null || !"teacher".equals(role)) {
                response.sendRedirect("jsp/auth/login.jsp?error=invalid_role");
                return;
            }

            // Read text inputs
            String courseName = request.getParameter("course_name");
            String videoTitle = request.getParameter("video_title");
            String category = request.getParameter("category");
            String description = request.getParameter("description");
            String duration = request.getParameter("duration");
            String previewEnabled = request.getParameter("preview_enabled");

            if (previewEnabled == null) previewEnabled = "No";

            // Process file uploads
            String uploadPath = request.getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }

            // 1. Thumbnail File
            Part thumbPart = request.getPart("thumbnail");
            String thumbName = thumbPart.getSubmittedFileName();
            // Sanitize file name
            if (thumbName != null && !thumbName.isEmpty()) {
                thumbName = System.currentTimeMillis() + "_" + thumbName.replaceAll("[^a-zA-Z0-9\\.\\-]", "_");
                thumbPart.write(uploadPath + File.separator + thumbName);
            } else {
                thumbName = "default_thumb.jpg";
            }

            // 2. Video File
            Part videoPart = request.getPart("video_file");
            String videoName = videoPart.getSubmittedFileName();
            if (videoName != null && !videoName.isEmpty()) {
                videoName = System.currentTimeMillis() + "_" + videoName.replaceAll("[^a-zA-Z0-9\\.\\-]", "_");
                videoPart.write(uploadPath + File.separator + videoName);
            } else {
                videoName = "placeholder.mp4";
            }

            String thumbDBPath = "uploads/" + thumbName;
            String videoDBPath = "uploads/" + videoName;

            Connection conn = DBConnection.getConnection();
            
            // Insert video details
            String sql = "INSERT INTO videos (teacher_name, course_name, video_title, category, description, duration, thumbnail_path, video_path, preview_enabled) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, teacherName);
            ps.setString(2, courseName);
            ps.setString(3, videoTitle);
            ps.setString(4, category);
            ps.setString(5, description);
            ps.setString(6, duration);
            ps.setString(7, thumbDBPath);
            ps.setString(8, videoDBPath);
            ps.setString(9, previewEnabled);
            ps.executeUpdate();
            ps.close();

            // Find subscribers to notify
            String subSql = "SELECT DISTINCT student_name FROM subscriptions WHERE course_name = ? AND teacher_name = ? AND access_status = 'Active'";
            PreparedStatement subPs = conn.prepareStatement(subSql);
            subPs.setString(1, courseName);
            subPs.setString(2, teacherName);
            ResultSet rs = subPs.executeQuery();
            List<String> students = new ArrayList<>();
            while (rs.next()) {
                students.add(rs.getString("student_name"));
            }
            rs.close();
            subPs.close();

            // Send notifications
            String notifySql = "INSERT INTO notifications (user_name, message_text) VALUES (?, ?)";
            PreparedStatement notifyPs = conn.prepareStatement(notifySql);
            for (String student : students) {
                notifyPs.setString(1, student);
                notifyPs.setString(2, "Teacher " + teacherName + " uploaded a new video: " + videoTitle + " for course: " + courseName);
                notifyPs.executeUpdate();
            }
            notifyPs.close();

            conn.close();
            response.sendRedirect("jsp/teacher/my-videos.jsp?success=uploaded");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/teacher/my-videos.jsp?error=db_error");
        }
    }
}
