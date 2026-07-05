<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    String studentName = (String) session.getAttribute("full_name");
    
    String itemType = request.getParameter("item_type");
    String itemIdStr = request.getParameter("item_id");
    
    if (itemType == null || itemIdStr == null || itemType.trim().isEmpty() || itemIdStr.trim().isEmpty()) {
        response.sendRedirect("student-dashboard.jsp?error=invalid_params");
        return;
    }
    
    int itemId = Integer.parseInt(itemIdStr);
    String itemName = "";
    String itemDesc = "";
    String price = "";
    String seller = "";
    
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        if ("skill".equalsIgnoreCase(itemType)) {
            String sql = "SELECT * FROM skills WHERE skill_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                itemName = rs.getString("skill_title");
                itemDesc = rs.getString("description");
                price = rs.getString("price");
                seller = rs.getString("teacher_name");
            }
            rs.close();
            ps.close();
        } else if ("product".equalsIgnoreCase(itemType)) {
            String sql = "SELECT * FROM products WHERE product_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                itemName = rs.getString("product_name");
                itemDesc = rs.getString("description");
                price = rs.getString("price");
                seller = rs.getString("teacher_name");
            }
            rs.close();
            ps.close();
        }
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - ElderEarn</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary-blue: #0f4c81;
            --accent-blue: #3a86c8;
            --sky-blue: #e8f4fd;
            --deep-dark: #0b1a30;
            --body-bg: #f0f4f8;
            --white: #ffffff;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background: linear-gradient(135deg, var(--sky-blue) 0%, var(--body-bg) 100%);
            min-height: 100vh;
            color: var(--deep-dark);
            padding: 40px 20px;
        }

        .checkout-box {
            background-color: var(--white);
            border-radius: 25px;
            box-shadow: 0 15px 35px rgba(15, 76, 129, 0.06);
            overflow: hidden;
            border: none;
        }

        .summary-panel {
            background-color: #fafbfc;
            padding: 40px;
            border-right: 1px solid rgba(0,0,0,0.05);
            height: 100%;
        }

        .payment-panel {
            padding: 40px;
        }

        .form-control {
            border-radius: 12px;
            padding: 12px 16px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }

        .form-control:focus {
            border-color: var(--primary-blue);
            box-shadow: 0 0 0 4px rgba(15, 76, 129, 0.1);
        }

        .btn-pay {
            background-color: var(--primary-blue);
            border: none;
            border-radius: 12px;
            padding: 14px;
            font-weight: 600;
            color: var(--white);
            transition: all 0.3s;
        }

        .btn-pay:hover {
            background-color: var(--accent-blue);
            transform: translateY(-1px);
        }
    </style>
</head>
<body>

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-xl-10">
                <div class="checkout-box row g-0">
                    <!-- Order Summary Panel -->
                    <div class="col-lg-5 summary-panel">
                        <h4 class="fw-bold mb-4">Order Summary</h4>
                        
                        <div class="mb-4">
                            <span class="badge bg-primary text-uppercase px-2.5 py-1.5 mb-2"><%= itemType %></span>
                            <h3 class="fw-bold text-dark mb-1"><%= itemName %></h3>
                            <span class="text-muted small">Seller: <strong class="text-dark"><%= seller %></strong></span>
                        </div>
                        
                        <p class="text-muted small mb-4" style="line-height: 1.6;"><%= itemDesc %></p>
                        
                        <hr class="my-4">
                        
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span class="text-muted small">Subtotal</span>
                            <span class="fw-bold">₹<%= price %></span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span class="text-muted small">Tax (0%)</span>
                            <span class="fw-bold">₹0.00</span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mt-4">
                            <span class="fw-bold text-dark fs-5">Total Due</span>
                            <span class="fw-bold text-success fs-4">₹<%= price %></span>
                        </div>
                    </div>

                    <!-- Payment Panel -->
                    <div class="col-lg-7 payment-panel">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h4 class="fw-bold mb-0">Secure Payment</h4>
                            <span class="text-muted small"><i class="bi bi-shield-fill-check text-success fs-5"></i> SSL Encrypted</span>
                        </div>
                        
                        <form action="../../CheckoutServlet" method="post">
                            <input type="hidden" name="item_type" value="<%= itemType %>">
                            <input type="hidden" name="item_id" value="<%= itemId %>">
                            
                            <div class="mb-3">
                                <label for="card_name" class="form-label fw-semibold small">Name on Card</label>
                                <input type="text" id="card_name" name="card_name" class="form-control" placeholder="" required>
                            </div>
                            
                            <div class="mb-3">
                                <label for="card_number" class="form-label fw-semibold small">Card Number</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-credit-card"></i></span>
                                    <input type="text" id="card_number" name="card_number" class="form-control border-start-0" placeholder="4111 2222 3333 4444" pattern="\d{16}" title="16-digit card number" required>
                                </div>
                            </div>
                            
                            <div class="row g-3 mb-4">
                                <div class="col-6">
                                    <label class="form-label fw-semibold small">Expiration Date</label>
                                    <input type="text" class="form-control text-center" placeholder="MM/YY" required>
                                </div>
                                <div class="col-6">
                                    <label class="form-label fw-semibold small">CVV</label>
                                    <input type="password" class="form-control text-center" placeholder="•••" maxlength="3" required>
                                </div>
                            </div>
                            
                            <button type="submit" class="btn btn-pay w-100 mb-3">Pay & Activate Account</button>
                            <a href="student-dashboard.jsp" class="btn btn-link w-100 text-decoration-none text-muted small">Cancel & Return</a>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
