package com.elderearn.auth;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.elderearn.database.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/AddFundsServlet")
public class AddFundsServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String userName = (String) request.getSession().getAttribute("full_name");
            String role = (String) request.getSession().getAttribute("role");
            
            if (userName == null || role == null) {
                response.sendRedirect("jsp/auth/login.jsp");
                return;
            }

            String amountStr = request.getParameter("amount");
            if (amountStr == null || amountStr.trim().isEmpty()) {
                response.sendRedirect("jsp/" + role + "/settings.jsp?error=invalid_amount");
                return;
            }

            double amount = Double.parseDouble(amountStr);
            if (amount <= 0) {
                response.sendRedirect("jsp/" + role + "/settings.jsp?error=negative_amount");
                return;
            }

            Connection conn = DBConnection.getConnection();
            String sql = "INSERT INTO wallets (user_name, balance) VALUES (?, ?) ON DUPLICATE KEY UPDATE balance = balance + VALUES(balance)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, userName);
            ps.setDouble(2, amount);
            ps.executeUpdate();
            
            ps.close();
            conn.close();

            response.sendRedirect("jsp/" + role + "/settings.jsp?success=funds_added");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/auth/login.jsp");
        }
    }
}
