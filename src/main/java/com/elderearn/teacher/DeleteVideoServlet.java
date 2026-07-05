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

@WebServlet("/DeleteVideoServlet")
public class DeleteVideoServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String teacherName = (String) request.getSession().getAttribute("full_name");
            String role = (String) request.getSession().getAttribute("role");
            
            if (teacherName == null || !"teacher".equals(role)) {
                response.sendRedirect("jsp/auth/login.jsp?error=invalid_role");
                return;
            }

            String idStr = request.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) {
                response.sendRedirect("jsp/teacher/my-videos.jsp?error=invalid_id");
                return;
            }

            int videoId = Integer.parseInt(idStr);

            Connection conn = DBConnection.getConnection();
            String sql = "DELETE FROM videos WHERE video_id = ? AND teacher_name = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, videoId);
            ps.setString(2, teacherName);
            ps.executeUpdate();
            
            ps.close();
            conn.close();
            response.sendRedirect("jsp/teacher/my-videos.jsp?success=deleted");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/teacher/my-videos.jsp?error=db_error");
        }
    }
}
