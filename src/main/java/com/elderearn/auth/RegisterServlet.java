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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String full_name = request.getParameter("full_name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String role = request.getParameter("role");

        if (full_name == null || email == null || password == null || role == null ||
            full_name.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty() || role.trim().isEmpty()) {
            response.sendRedirect("jsp/auth/register.jsp?error=empty_fields");
            return;
        }

        if (!password.equals(confirmPassword)) {
            response.sendRedirect("jsp/auth/register.jsp?error=password_mismatch");
            return;
        }

        try {
            Connection conn = DBConnection.getConnection();
            
            // Check if email already exists
            String checkSql = "SELECT user_id FROM users WHERE email=?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, email);
            ResultSet checkRs = checkPs.executeQuery();
            
            if (checkRs.next()) {
                response.sendRedirect("jsp/auth/register.jsp?error=email_exists");
                return;
            }

            String sql = "INSERT INTO users(full_name,email,password,role) VALUES(?,?,?,?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, full_name.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, password);
            ps.setString(4, role);

            ps.executeUpdate();
            response.sendRedirect("jsp/auth/login.jsp?success=registered");

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/auth/register.jsp?error=db_error");
        }
    }
}