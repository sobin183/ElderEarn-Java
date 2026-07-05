<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    String teacherName = (String) session.getAttribute("full_name");
    String role = (String) session.getAttribute("role");
    if (teacherName == null || !"teacher".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp?error=invalid_role");
        return;
    }
    request.setAttribute("activePage", "settings");

    double walletBalance = 0.00;
    String accHolder = "";
    String bankName = "";
    String accNum = "";
    String ifsc = "";
    boolean hasBank = false;

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();

        // 1. Fetch Wallet Balance (or auto-create if not exists)
        String wSql = "SELECT balance FROM wallets WHERE user_name = ?";
        PreparedStatement wPs = conn.prepareStatement(wSql);
        wPs.setString(1, teacherName);
        ResultSet wRs = wPs.executeQuery();
        if (wRs.next()) {
            walletBalance = wRs.getDouble("balance");
        } else {
            // Auto initialize
            String initSql = "INSERT INTO wallets (user_name, balance) VALUES (?, 0.00)";
            PreparedStatement initPs = conn.prepareStatement(initSql);
            initPs.setString(1, teacherName);
            initPs.executeUpdate();
            initPs.close();
        }
        wRs.close();
        wPs.close();

        // 2. Fetch Bank Details
        String bSql = "SELECT * FROM bank_accounts WHERE user_name = ?";
        PreparedStatement bPs = conn.prepareStatement(bSql);
        bPs.setString(1, teacherName);
        ResultSet bRs = bPs.executeQuery();
        if (bRs.next()) {
            hasBank = true;
            accHolder = bRs.getString("acc_holder_name");
            bankName = bRs.getString("bank_name");
            accNum = bRs.getString("account_number");
            ifsc = bRs.getString("ifsc_code");
        }
        bRs.close();
        bPs.close();

    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings & Wallet - Teacher Portal</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Dashboard CSS -->
    <link rel="stylesheet" href="../../css/dashboard.css">
    
    <style>
        .settings-card {
            background-color: var(--white);
            border-radius: 20px;
            box-shadow: var(--card-shadow);
            padding: 30px;
            margin-bottom: 25px;
        }
        .wallet-banner {
            background: linear-gradient(135deg, var(--primary-blue), var(--accent-blue));
            color: var(--white);
            border-radius: 20px;
            padding: 30px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 20px rgba(10, 88, 202, 0.2);
        }
        .settings-nav-pills .nav-link {
            color: var(--text-muted);
            font-weight: 500;
            padding: 12px 20px;
            border-radius: 12px;
            transition: all 0.2s;
        }
        .settings-nav-pills .nav-link.active {
            background-color: var(--primary-blue);
            color: var(--white);
        }
    </style>
</head>
<body>

    <div class="container-fluid p-0">
        <!-- Reusable Sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content -->
        <div class="main-content">
            <h2 class="fw-bold mb-1">Account Settings & Wallet</h2>
            <p class="text-muted mb-4">Manage your payouts, wallet balances, linked bank accounts, and profile sorting.</p>

            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                if ("bank_updated".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm mb-4">
                    <i class="bi bi-check-circle-fill me-2"></i> Bank Account details updated successfully.
                </div>
            <% } else if ("funds_added".equals(success)) { %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm mb-4">
                    <i class="bi bi-check-circle-fill me-2"></i> Wallet topped up successfully!
                </div>
            <% } %>

            <div class="row g-4">
                <!-- Left Column: Navigation Options -->
                <div class="col-lg-3">
                    <div class="settings-card p-3">
                        <div class="nav flex-column nav-pills settings-nav-pills" id="settings-tabs" role="tablist" aria-orientation="vertical">
                            <button class="nav-link active text-start d-flex align-items-center gap-2 mb-2" id="wallet-tab" data-bs-toggle="pill" data-bs-target="#tab-wallet" type="button" role="tab"><i class="bi bi-wallet2"></i> My Wallet</button>
                            <button class="nav-link text-start d-flex align-items-center gap-2 mb-2" id="bank-tab" data-bs-toggle="pill" data-bs-target="#tab-bank" type="button" role="tab"><i class="bi bi-credit-card-2-front"></i> Bank Account</button>
                            <button class="nav-link text-start d-flex align-items-center gap-2" id="categories-tab" data-bs-toggle="pill" data-bs-target="#tab-categories" type="button" role="tab"><i class="bi bi-sort-alpha-down"></i> Categories Settings</button>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Settings Panels -->
                <div class="col-lg-9">
                    <div class="tab-content" id="settings-tabs-content">
                        
                        <!-- Panel 1: Wallet -->
                        <div class="tab-pane fade show active" id="tab-wallet" role="tabpanel">
                            <div class="wallet-banner mb-4">
                                <div class="row align-items-center">
                                    <div class="col-md-7">
                                        <span class="small text-white-50 uppercase fw-bold tracking-wider">Teacher Earnings Wallet</span>
                                        <h1 class="fw-bold mt-1 mb-3">₹<%= String.format("%.2f", walletBalance) %></h1>
                                        <p class="mb-0 text-white-50 small">All product sales and subscription earnings are credited here instantly.</p>
                                    </div>
                                    <div class="col-md-5 text-md-end mt-3 mt-md-0">
                                        <button class="btn btn-light rounded-pill px-4 me-2" data-bs-toggle="modal" data-bs-target="#addFundsModal"><i class="bi bi-plus-circle-fill"></i> Add Funds</button>
                                        <button class="btn btn-outline-light rounded-pill px-4" <%= !hasBank ? "disabled data-bs-toggle='tooltip' title='Link bank account first'" : "" %>><i class="bi bi-arrow-up-right-circle-fill"></i> Withdraw</button>
                                    </div>
                                </div>
                            </div>

                            <div class="settings-card">
                                <h5 class="fw-bold mb-4">Wallet Security & Activity</h5>
                                <div class="p-3 bg-light rounded-4 d-flex align-items-center justify-content-between mb-3">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="p-2 bg-success bg-opacity-10 text-success rounded-circle"><i class="bi bi-shield-check"></i></div>
                                        <div>
                                            <h6 class="fw-bold mb-0">Withdrawals Autopay</h6>
                                            <span class="small text-muted">Earnings automatically route to bank account.</span>
                                        </div>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" role="switch" checked>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Panel 2: Bank Account Details -->
                        <div class="tab-pane fade" id="tab-bank" role="tabpanel">
                            <div class="settings-card">
                                <h5 class="fw-bold mb-2">Link Bank Account</h5>
                                <p class="text-muted small mb-4">Provide banking credentials to enable automatic monthly payouts.</p>

                                <form action="../../AddBankAccountServlet" method="post" class="row g-3">
                                    <div class="col-md-6">
                                        <label for="acc_holder" class="form-label small fw-semibold">Account Holder Name</label>
                                        <input type="text" id="acc_holder" name="acc_holder" class="form-control" placeholder="FullName" value="<%= accHolder %>" required autocomplete="off">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="bank_name" class="form-label small fw-semibold">Bank Name</label>
                                        <input type="text" id="bank_name" name="bank_name" class="form-control" placeholder="e.g. State Bank of India" value="<%= bankName %>" required autocomplete="off">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="account_number" class="form-label small fw-semibold">Account Number</label>
                                        <input type="password" id="account_number" name="account_number" class="form-control" placeholder="Account Number" value="<%= accNum %>" required autocomplete="off">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="ifsc_code" class="form-label small fw-semibold">IFSC Code</label>
                                        <input type="text" id="ifsc_code" name="ifsc_code" class="form-control" placeholder="e.g. SBIN0001234" value="<%= ifsc %>" required autocomplete="off">
                                    </div>

                                    <div class="col-12 mt-4 text-end">
                                        <button type="submit" class="btn btn-custom btn-custom-primary rounded-pill px-5"><i class="bi bi-credit-card-fill me-1"></i> Save Bank Account</button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <!-- Panel 3: Categories & Custom Sorting -->
                        <div class="tab-pane fade" id="tab-categories" role="tabpanel">
                            <div class="settings-card">
                                <h5 class="fw-bold mb-3">Order Classes & Expertise Categories</h5>
                                <p class="text-muted small mb-4">Reorder and manage your target teaching focus areas. Choose categories to prioritize on your profile page.</p>

                                <div class="list-group rounded-4">
                                    <div class="list-group-item d-flex align-items-center justify-content-between p-3 border-0 bg-light mb-2 rounded-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <i class="bi bi-list text-muted"></i>
                                            <span class="fw-semibold">1. Arts & Crafts</span>
                                        </div>
                                        <span class="badge bg-primary rounded-pill">Active</span>
                                    </div>
                                    <div class="list-group-item d-flex align-items-center justify-content-between p-3 border-0 bg-light mb-2 rounded-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <i class="bi bi-list text-muted"></i>
                                            <span class="fw-semibold">2. Handicrafts</span>
                                        </div>
                                        <span class="badge bg-primary rounded-pill">Active</span>
                                    </div>
                                    <div class="list-group-item d-flex align-items-center justify-content-between p-3 border-0 bg-light mb-2 rounded-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <i class="bi bi-list text-muted"></i>
                                            <span class="fw-semibold">3. Cooking & Culinary</span>
                                        </div>
                                        <span class="badge bg-secondary rounded-pill">Available</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal: Add Funds -->
    <div class="modal fade" id="addFundsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 border-0">
                <form action="../../AddFundsServlet" method="post">
                    <div class="modal-header border-bottom-0 p-4 pb-0">
                        <h5 class="fw-bold modal-title">Load Wallet Balance</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label for="amount" class="form-label small fw-semibold">Enter Amount (₹)</label>
                            <input type="number" id="amount" name="amount" class="form-control" placeholder="1000" min="1" step="any" required>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 p-4 pt-0">
                        <button type="submit" class="btn btn-custom btn-custom-primary rounded-pill w-100"><i class="bi bi-plus-circle-fill"></i> Add Funds</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<%
    if (conn != null) {
        try { conn.close(); } catch(Exception e) {}
    }
%>
