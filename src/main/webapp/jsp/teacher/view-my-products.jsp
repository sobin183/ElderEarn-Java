<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>
<%
    String teacherName = (String) session.getAttribute("full_name");
    String teacherRole = (String) session.getAttribute("role");
    if (teacherName == null || !"teacher".equals(teacherRole)) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp?error=invalid_role");
        return;
    }
    request.setAttribute("activePage", "my-products");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Products - Teacher Portal</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Custom Dashboard CSS -->
    <link rel="stylesheet" href="../../css/dashboard.css">
</head>
<body>

    <div class="container-fluid p-0">
        <!-- Reusable Sidebar -->
        <jsp:include page="sidebar.jsp" />

        <!-- Main Content -->
        <div class="main-content">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold mb-1">My Published Products</h2>
                    <p class="text-muted mb-0">View, update, or remove physical crafts and digital files you sell.</p>
                </div>
                <div>
                    <a href="add-product.jsp" class="btn btn-custom btn-custom-primary"><i class="bi bi-plus-circle-fill me-1"></i> Add New Product</a>
                </div>
            </div>

            <!-- Context Alerts -->
            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                
                if ("added".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Product published successfully!
                </div>
            <%
                } else if ("deleted".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Product deleted successfully.
                </div>
            <%
                } else if ("updated".equals(success)) {
            %>
                <div class="alert alert-success border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> Product details updated successfully.
                </div>
            <%
                }
                
                if ("not_found".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> Product not found.
                </div>
            <%
                } else if ("not_authorized".equals(error)) {
            %>
                <div class="alert alert-danger border-0 rounded-4 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> You are not authorized to manage this product.
                </div>
            <%
                }
            %>

            <!-- Products Table -->
            <div class="content-card">
                <div class="table-responsive">
                    <table class="table table-custom mb-0">
                        <thead>
                            <tr>
                                <th>Product Name</th>
                                <th>Category/Type</th>
                                <th>Price</th>
                                <th>Description</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                try {
                                    conn = DBConnection.getConnection();
                                    String sql = "SELECT * FROM products WHERE teacher_name = ? ORDER BY product_id DESC";
                                    PreparedStatement ps = conn.prepareStatement(sql);
                                    ps.setString(1, teacherName);
                                    ResultSet rs = ps.executeQuery();
                                    
                                    boolean hasProducts = false;
                                    while (rs.next()) {
                                        hasProducts = true;
                                        int id = rs.getInt("product_id");
                                        String name = rs.getString("product_name");
                                        String type = rs.getString("product_type");
                                        String price = rs.getString("price");
                                        String desc = rs.getString("description");
                                        if (desc != null && desc.length() > 60) {
                                            desc = desc.substring(0, 57) + "...";
                                        }
                            %>
                            <tr>
                                <td class="fw-bold"><%= name %></td>
                                <td><span class="badge bg-success-tint text-success px-2.5 py-1.5"><%= type %></span></td>
                                <td class="fw-bold text-primary">₹<%= price %></td>
                                <td class="text-muted small"><%= desc %></td>
                                <td class="text-end">
                                    <div class="d-flex justify-content-end gap-2">
                                        <a href="edit-product.jsp?id=<%= id %>" class="btn btn-custom-sm btn-outline-primary"><i class="bi bi-pencil-fill"></i> Edit</a>
                                        <a href="../../DeleteProductServlet?id=<%= id %>" onclick="return confirm('Are you sure you want to delete this product?');" class="btn btn-custom-sm btn-outline-danger"><i class="bi bi-trash3-fill"></i> Delete</a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                    rs.close();
                                    ps.close();
                                    conn.close();
                                    
                                    if (!hasProducts) {
                            %>
                            <tr>
                                <td colspan="5" class="text-center text-muted py-5">
                                    <i class="bi bi-box-seam fs-1 mb-2 d-block"></i>
                                    You have not published any products yet.
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                            %>
                            <tr>
                                <td colspan="5" class="text-center text-danger py-4">Database load error.</td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
