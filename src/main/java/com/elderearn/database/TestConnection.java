package com.elderearn.database;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/TestConnection")
public class TestConnection extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");

        PrintWriter out = response.getWriter();

        Connection conn = DBConnection.getConnection();

        if(conn != null) {

            out.println("<h1>Database Connected Successfully!</h1>");

        } else {

            out.println("<h1>Database Connection Failed!</h1>");

        }
    }
}