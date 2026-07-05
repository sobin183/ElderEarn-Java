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

@WebServlet("/EditSkillServlet")
public class EditSkillServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String teacherName = (String) request.getSession().getAttribute("full_name");
            if (teacherName == null) {
                response.sendRedirect("jsp/auth/login.jsp?error=session_expired");
                return;
            }

            String idStr = request.getParameter("skill_id");
            String skillTitle = request.getParameter("skill_title");
            String category = request.getParameter("category");
            String description = request.getParameter("description");
            String price = request.getParameter("price");

            if (idStr == null || skillTitle == null || category == null || description == null || price == null ||
                idStr.trim().isEmpty() || skillTitle.trim().isEmpty() || category.trim().isEmpty() || description.trim().isEmpty() || price.trim().isEmpty()) {
                response.sendRedirect("jsp/teacher/view-my-skills.jsp?error=empty");
                return;
            }

            int skillId = Integer.parseInt(idStr);

            Connection conn = DBConnection.getConnection();
            String sql = "UPDATE skills SET skill_title = ?, category = ?, description = ?, price = ? WHERE skill_id = ? AND teacher_name = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, skillTitle.trim());
            ps.setString(2, category.trim());
            ps.setString(3, description.trim());
            ps.setString(4, price.trim());
            ps.setInt(5, skillId);
            ps.setString(6, teacherName);

            int rowsUpdated = ps.executeUpdate();
            ps.close();
            conn.close();

            if (rowsUpdated > 0) {
                response.sendRedirect("jsp/teacher/view-my-skills.jsp?success=updated");
            } else {
                response.sendRedirect("jsp/teacher/view-my-skills.jsp?error=not_authorized");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/teacher/view-my-skills.jsp?error=db_error");
        }
    }
}
