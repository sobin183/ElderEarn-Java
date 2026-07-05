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

@WebServlet("/AddSkillServlet")
public class AddSkillServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String teacherName = (String) request.getSession().getAttribute("full_name");
            if (teacherName == null) {
                response.sendRedirect("jsp/auth/login.jsp?error=session_expired");
                return;
            }

            String skillTitle = request.getParameter("skill_title");
            String category = request.getParameter("category");
            String description = request.getParameter("description");
            String price = request.getParameter("price");

            if (skillTitle == null || category == null || description == null || price == null ||
                skillTitle.trim().isEmpty() || category.trim().isEmpty() || description.trim().isEmpty() || price.trim().isEmpty()) {
                response.sendRedirect("jsp/teacher/add-skill.jsp?error=empty");
                return;
            }

            Connection conn = DBConnection.getConnection();
            String sql = "INSERT INTO skills(teacher_name, skill_title, category, description, price) VALUES(?,?,?,?,?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, teacherName);
            ps.setString(2, skillTitle.trim());
            ps.setString(3, category.trim());
            ps.setString(4, description.trim());
            ps.setString(5, price.trim());

            ps.executeUpdate();
            ps.close();
            conn.close();

            response.sendRedirect("jsp/teacher/view-my-skills.jsp?success=added");

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/teacher/add-skill.jsp?error=db_error");
        }
    }
}
