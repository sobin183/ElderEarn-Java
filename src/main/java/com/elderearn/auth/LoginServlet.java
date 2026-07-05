package com.elderearn.auth;

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
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect("jsp/auth/login.jsp?error=empty");
            return;
        }

        try {
            Connection conn = DBConnection.getConnection();
            String sql = "SELECT * FROM users WHERE email=? AND password=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email.trim().toLowerCase());
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("full_name", rs.getString("full_name"));
                session.setAttribute("email", rs.getString("email"));
                session.setAttribute("role", rs.getString("role"));

                String role = rs.getString("role");

                if ("admin".equals(role)) {
                    response.sendRedirect("jsp/admin/admin-dashboard.jsp");
                } else if ("teacher".equals(role)) {
                    response.sendRedirect("jsp/teacher/teacher-dashboard.jsp");
                } else if ("student".equals(role)) {
                    response.sendRedirect("jsp/student/student-dashboard.jsp");
                } else {
                    response.sendRedirect("jsp/auth/login.jsp?error=invalid_role");
                }
            } else {
                response.sendRedirect("jsp/auth/login.jsp?error=invalid");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/auth/login.jsp?error=db_error");
        }
    }
}