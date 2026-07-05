<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    request.setAttribute("activePage", "reports");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & Insights - Admin Portal</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Dashboard CSS -->
    <link rel="stylesheet" href="../../css/dashboard.css">
    
    <style>
        .report-chart-container {
            background-color: var(--white);
            border-radius: 20px;
            padding: 30px;
            box-shadow: var(--card-shadow);
            height: 100%;
        }

        .bar-chart-row {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }

        .bar-chart-label {
            width: 140px;
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--deep-dark);
        }

        .bar-chart-progress {
            flex-grow: 1;
            height: 24px;
            background-color: var(--sky-blue);
            border-radius: 8px;
            overflow: hidden;
        }

        .bar-chart-value {
            width: 80px;
            text-align: right;
            font-size: 0.9rem;
            font-weight: 700;
            color: var(--primary-blue);
        }
    </style>
</head>
<body>

    <div class="container-fluid p-0">
        <!-- Reusable Sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content -->
        <div class="main-content">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">Reports & Analytics</h2>
                    <p class="text-muted mb-0">Platform overview, transaction records, and user type distribution metrics.</p>
                </div>
            </div>

            <%
                int totalUsers = 0;
                int teachersCount = 0;
                int studentsCount = 0;
                int skillsCount = 0;
                int productsCount = 0;
                double totalRevenue = 0.0;
                double subscriptionRev = 0.0;
                double productRev = 0.0;

                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    
                    // 1. Core aggregates
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*), SUM(CASE WHEN role='teacher' THEN 1 ELSE 0 END), SUM(CASE WHEN role='student' THEN 1 ELSE 0 END) FROM users");
                    if (rs.next()) {
                        totalUsers = rs.getInt(1);
                        teachersCount = rs.getInt(2);
                        studentsCount = rs.getInt(3);
                    }
                    rs.close();

                    ResultSet rsSkl = stmt.executeQuery("SELECT COUNT(*) FROM skills");
                    if (rsSkl.next()) skillsCount = rsSkl.getInt(1);
                    rsSkl.close();

                    ResultSet rsPrd = stmt.executeQuery("SELECT COUNT(*) FROM products");
                    if (rsPrd.next()) productsCount = rsPrd.getInt(1);
                    rsPrd.close();

                    ResultSet rsRev = stmt.executeQuery("SELECT SUM(CAST(amount AS DECIMAL(10,2))), SUM(CASE WHEN payment_type='Subscription' THEN CAST(amount AS DECIMAL(10,2)) ELSE 0 END), SUM(CASE WHEN payment_type='Product' THEN CAST(amount AS DECIMAL(10,2)) ELSE 0 END) FROM payments WHERE payment_status='Paid'");
                    if (rsRev.next()) {
                        totalRevenue = rsRev.getDouble(1);
                        subscriptionRev = rsRev.getDouble(2);
                        productRev = rsRev.getDouble(3);
                    }
                    rsRev.close();
                    stmt.close();

                } catch (Exception e) {
                    e.printStackTrace();
                }
                
                // Calculate percentages for chart representation
                double subPct = totalRevenue > 0 ? (subscriptionRev / totalRevenue) * 100 : 0;
                double prdPct = totalRevenue > 0 ? (productRev / totalRevenue) * 100 : 0;
                
                double teacherPct = totalUsers > 0 ? ((double)teachersCount / totalUsers) * 100 : 0;
                double studentPct = totalUsers > 0 ? ((double)studentsCount / totalUsers) * 100 : 0;
            %>

            <!-- Stats Metric Cards -->
            <div class="row g-4 mb-5">
                <div class="col-sm-6 col-lg-3">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Total Revenue</h6>
                            <h2>₹<%= String.format("%.2f", totalRevenue) %></h2>
                        </div>
                        <div class="metric-card-icon bg-success-tint" style="background-color: rgba(25, 135, 84, 0.15); color: #198754;">
                            <i class="bi bi-wallet2"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-3">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Course Revenue</h6>
                            <h2>₹<%= String.format("%.2f", subscriptionRev) %></h2>
                        </div>
                        <div class="metric-card-icon bg-primary-tint">
                            <i class="bi bi-mortarboard-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-3">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Product Revenue</h6>
                            <h2>₹<%= String.format("%.2f", productRev) %></h2>
                        </div>
                        <div class="metric-card-icon bg-info-tint">
                            <i class="bi bi-bag-check-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-lg-3">
                    <div class="metric-card">
                        <div class="metric-card-info">
                            <h6>Total Users</h6>
                            <h2><%= totalUsers %></h2>
                        </div>
                        <div class="metric-card-icon bg-warning-tint">
                            <i class="bi bi-people-fill"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Visualization Charts -->
            <div class="row g-4 mb-5">
                <!-- Revenue Distribution Chart -->
                <div class="col-lg-6">
                    <div class="report-chart-container">
                        <h5 class="fw-bold mb-4"><i class="bi bi-pie-chart-fill text-success"></i> Revenue Stream Distribution</h5>
                        
                        <div class="bar-chart-row">
                            <div class="bar-chart-label">Subscriptions</div>
                            <div class="bar-chart-progress">
                                <div class="bg-primary h-100" style="width: <%= subPct %>%;"></div>
                            </div>
                            <div class="bar-chart-value">₹<%= String.format("%.0f", subscriptionRev) %></div>
                        </div>

                        <div class="bar-chart-row">
                            <div class="bar-chart-label">Product Purchases</div>
                            <div class="bar-chart-progress">
                                <div class="bg-success h-100" style="width: <%= prdPct %>%;"></div>
                            </div>
                            <div class="bar-chart-value">₹<%= String.format("%.0f", productRev) %></div>
                        </div>
                        
                        <div class="mt-4 p-3 bg-light rounded-4 small text-muted">
                            <i class="bi bi-info-circle-fill me-1"></i> Subscriptions represent monthly recurring income, while Product Purchases represent flat transaction rates.
                        </div>
                    </div>
                </div>

                <!-- User Type Distribution Chart -->
                <div class="col-lg-6">
                    <div class="report-chart-container">
                        <h5 class="fw-bold mb-4"><i class="bi bi-people-fill text-primary"></i> Platform User Breakdown</h5>
                        
                        <div class="bar-chart-row">
                            <div class="bar-chart-label">Students</div>
                            <div class="bar-chart-progress">
                                <div class="bg-info h-100" style="width: <%= studentPct %>%;"></div>
                            </div>
                            <div class="bar-chart-value"><%= studentsCount %> Users</div>
                        </div>

                        <div class="bar-chart-row">
                            <div class="bar-chart-label">Teachers</div>
                            <div class="bar-chart-progress">
                                <div class="bg-success h-100" style="width: <%= teacherPct %>%;"></div>
                            </div>
                            <div class="bar-chart-value"><%= teachersCount %> Users</div>
                        </div>
                        
                        <div class="mt-4 p-3 bg-light rounded-4 small text-muted">
                            <i class="bi bi-info-circle-fill me-1"></i> Current Student-to-Teacher Ratio: <strong><%= teachersCount > 0 ? String.format("%.1f", (double)studentsCount / teachersCount) : "N/A" %> : 1</strong>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Content Aggregates -->
            <div class="row g-4">
                <div class="col-12">
                    <div class="content-card">
                        <h5 class="content-card-title"><i class="bi bi-activity text-primary"></i> Content & Asset Statistics</h5>
                        <div class="row g-4 text-center mt-2">
                            <div class="col-6 col-md-3">
                                <div class="p-3 border rounded-4 bg-light">
                                    <span class="text-muted small d-block">Published Courses</span>
                                    <h3 class="fw-bold text-dark mt-2 mb-0"><%= skillsCount %></h3>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="p-3 border rounded-4 bg-light">
                                    <span class="text-muted small d-block">Marketplace Goods</span>
                                    <h3 class="fw-bold text-dark mt-2 mb-0"><%= productsCount %></h3>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="p-3 border rounded-4 bg-light">
                                    <span class="text-muted small d-block">Total Registered Accounts</span>
                                    <h3 class="fw-bold text-dark mt-2 mb-0"><%= totalUsers %></h3>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="p-3 border rounded-4 bg-light">
                                    <span class="text-muted small d-block">Completed Payouts</span>
                                    <h3 class="fw-bold text-success mt-2 mb-0">₹<%= String.format("%.0f", totalRevenue) %></h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
