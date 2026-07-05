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

@WebServlet("/AddBankAccountServlet")
public class AddBankAccountServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String userName = (String) request.getSession().getAttribute("full_name");
            String role = (String) request.getSession().getAttribute("role");
            
            if (userName == null || role == null) {
                response.sendRedirect("jsp/auth/login.jsp");
                return;
            }

            String accHolder = request.getParameter("acc_holder");
            String bankName = request.getParameter("bank_name");
            String accNum = request.getParameter("account_number");
            String ifsc = request.getParameter("ifsc_code");

            if (accHolder == null || bankName == null || accNum == null || ifsc == null ||
                accHolder.trim().isEmpty() || bankName.trim().isEmpty() || accNum.trim().isEmpty() || ifsc.trim().isEmpty()) {
                response.sendRedirect("jsp/" + role + "/settings.jsp?error=missing_fields");
                return;
            }

            Connection conn = DBConnection.getConnection();
            String sql = "INSERT INTO bank_accounts (user_name, acc_holder_name, bank_name, account_number, ifsc_code) VALUES (?, ?, ?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE acc_holder_name = VALUES(acc_holder_name), bank_name = VALUES(bank_name), account_number = VALUES(account_number), ifsc_code = VALUES(ifsc_code)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, userName);
            ps.setString(2, accHolder.trim());
            ps.setString(3, bankName.trim());
            ps.setString(4, accNum.trim());
            ps.setString(5, ifsc.trim());
            ps.executeUpdate();
            
            ps.close();
            conn.close();

            response.sendRedirect("jsp/" + role + "/settings.jsp?success=bank_updated");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("jsp/auth/login.jsp");
        }
    }
}
