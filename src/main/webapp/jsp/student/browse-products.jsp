<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    request.setAttribute("activePage", "browse-products");
    String studentName = (String) session.getAttribute("full_name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Products - ElderEarn</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Dashboard CSS -->
    <link rel="stylesheet" href="../../css/dashboard.css">
    
    <style>
        .product-card {
            border: none;
            border-radius: 20px;
            box-shadow: var(--card-shadow);
            transition: all 0.3s;
            height: 100%;
            display: flex;
            flex-direction: column;
            background-color: var(--white);
        }

        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(15, 76, 129, 0.08);
        }

        .product-header-icon {
            width: 50px;
            height: 50px;
            border-radius: 15px;
            background-color: rgba(25, 135, 84, 0.1);
            color: #198754;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
    </style>
</head>
<body>

    <div class="container-fluid p-0">
        <!-- Reusable Sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content -->
        <div class="main-content">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center mb-4 gap-3">
                <div>
                    <h2 class="fw-bold mb-1">Browse Educational Products</h2>
                    <p class="text-muted mb-0">Purchase textbook resources, digital templates, guides, or handmade goods.</p>
                </div>
            </div>

            <!-- Search and Filter Panel -->
            <div class="content-card py-3 mb-4">
                <form action="browse-products.jsp" method="get" class="row g-3">
                    <div class="col-md-6 col-lg-5">
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-search"></i></span>
                            <input type="text" name="search" class="form-control border-start-0" placeholder="Search by product name or details..." value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                        </div>
                    </div>
                    <div class="col-md-4 col-lg-4">
                        <select name="type" class="form-select">
                            <option value="">All Categories</option>
                            <%
                                String[] types = {"Books", "Notes", "Templates", "Craft Items", "Digital Products", "Courses"};
                                String currentType = request.getParameter("type");
                                for (String t : types) {
                            %>
                                <option value="<%= t %>" <%= t.equals(currentType) ? "selected" : "" %>><%= t %></option>
                            <%
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-2 col-lg-3 d-flex gap-2">
                        <button type="submit" class="btn btn-custom btn-custom-primary w-100"><i class="bi bi-funnel-fill me-1"></i> Filter</button>
                        <a href="browse-products.jsp" class="btn btn-light border"><i class="bi bi-arrow-counterclockwise"></i></a>
                    </div>
                </form>
            </div>

            <!-- Product Cards Grid -->
            <div class="row g-4">
                <%
                    Connection conn = null;
                    try {
                        conn = DBConnection.getConnection();
                        String search = request.getParameter("search");
                        String type = request.getParameter("type");
                        
                        String sql = "SELECT * FROM products WHERE 1=1";
                        if (search != null && !search.trim().isEmpty()) {
                            sql += " AND (product_name LIKE ? OR description LIKE ?)";
                        }
                        if (type != null && !type.trim().isEmpty()) {
                            sql += " AND product_type = ?";
                        }
                        sql += " ORDER BY product_id DESC";
                        
                        PreparedStatement ps = conn.prepareStatement(sql);
                        int idx = 1;
                        if (search != null && !search.trim().isEmpty()) {
                            String pattern = "%" + search.trim() + "%";
                            ps.setString(idx++, pattern);
                            ps.setString(idx++, pattern);
                        }
                        if (type != null && !type.trim().isEmpty()) {
                            ps.setString(idx++, type.trim());
                        }
                        
                        ResultSet rs = ps.executeQuery();
                        boolean hasProducts = false;
                        while (rs.next()) {
                            hasProducts = true;
                            int productId = rs.getInt("product_id");
                            String name = rs.getString("product_name");
                            String teacher = rs.getString("teacher_name");
                            if (teacher == null) teacher = "Anonymous Scholar";
                            String pType = rs.getString("product_type");
                            String price = rs.getString("price");
                            String description = rs.getString("description");
                            
                            // Map icon based on type
                            String iconClass = "bi-file-earmark-text-fill";
                            if ("Books".equalsIgnoreCase(pType)) iconClass = "bi-book-fill";
                            else if ("Templates".equalsIgnoreCase(pType)) iconClass = "bi-layout-text-sidebar-reverse";
                            else if ("Craft Items".equalsIgnoreCase(pType)) iconClass = "bi-gift-fill";
                            else if ("Courses".equalsIgnoreCase(pType)) iconClass = "bi-play-btn-fill";
                %>
                <div class="col-md-6 col-lg-4">
                    <div class="product-card card">
                        <div class="card-body d-flex flex-column justify-content-between p-4">
                            <div>
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div class="product-header-icon">
                                        <i class="bi <%= iconClass %>"></i>
                                    </div>
                                    <span class="badge bg-success-tint text-success px-2.5 py-1.5"><%= pType %></span>
                                </div>
                                <h4 class="fw-bold mb-2 text-dark"><%= name %></h4>
                                <span class="small text-muted d-block mb-3">Seller: <a href="teacher-profile.jsp?teacher=<%= java.net.URLEncoder.encode(teacher, "UTF-8") %>" class="fw-bold text-primary text-decoration-none hover-underline"><%= teacher %></a></span>
                                <p class="text-muted small mb-4">
                                    <%= description.length() > 140 ? description.substring(0, 137) + "..." : description %>
                                </p>
                            </div>
                            
                            <div>
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <span class="text-muted small">One-time Buy</span>
                                    <h4 class="fw-bold text-primary mb-0">₹<%= price %></h4>
                                </div>
                                <div class="row g-2">
                                    <div class="col-6">
                                        <!-- View Details Modal Trigger -->
                                        <button type="button" class="btn btn-outline-success w-100 btn-custom-sm" data-bs-toggle="modal" data-bs-target="#productModal<%= productId %>">
                                            View Details
                                        </button>
                                    </div>
                                    <div class="col-6">
                                        <a href="checkout.jsp?item_type=product&item_id=<%= productId %>" class="btn btn-success w-100 btn-custom-sm">Buy Now</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product Details Modal -->
                <div class="modal fade" id="productModal<%= productId %>" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content rounded-4 border-0 shadow">
                            <div class="modal-header border-0 pb-0">
                                <button type="button" class="btn-close" data-bs-shadow="none" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body px-4 pb-4 pt-0">
                                <div class="text-center mb-4">
                                    <div class="product-header-icon mx-auto mb-3" style="width:60px; height:60px; font-size:1.5rem;"><i class="bi <%= iconClass %>"></i></div>
                                    <h4 class="fw-bold mb-1"><%= name %></h4>
                                    <p class="text-muted small">Offered by <span class="fw-bold"><%= teacher %></span></p>
                                    <span class="badge bg-success-tint text-success px-3 py-1.5 rounded-pill"><%= pType %></span>
                                </div>
                                
                                <h6 class="fw-bold mb-2">Product Description</h6>
                                <p class="text-muted small mb-4" style="line-height:1.6; white-space: pre-wrap;"><%= description %></p>
                                
                                <div class="bg-light p-3 rounded-4 d-flex justify-content-between align-items-center mb-4">
                                    <div>
                                        <span class="small text-muted d-block">One-time Price</span>
                                        <span class="fw-bold text-success fs-5">₹<%= price %></span>
                                    </div>
                                    <span class="small text-muted"><i class="bi bi-shield-fill-check text-success"></i> Instant Access</span>
                                </div>
                                
                                <div class="d-flex gap-2">
                                    <a href="checkout.jsp?item_type=product&item_id=<%= productId %>" class="btn btn-success w-100 btn-custom">Buy Now</a>
                                    <button type="button" class="btn btn-light border w-100 btn-custom" data-bs-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%
                        }
                        rs.close();
                        ps.close();
                        conn.close();
                        
                        if (!hasProducts) {
                %>
                <div class="col-12 text-center text-muted py-5">
                    <i class="bi bi-gift fs-1 d-block mb-3"></i>
                    No products matched your search queries. Try choosing another category or keyword.
                </div>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                %>
                <div class="col-12 text-center text-danger py-4">Database load error.</div>
                <%
                    }
                %>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
